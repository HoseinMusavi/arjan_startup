import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class AddressPickerMapPage extends StatefulWidget {
  const AddressPickerMapPage({super.key});

  @override
  State<AddressPickerMapPage> createState() => _AddressPickerMapPageState();
}

class _AddressPickerMapPageState extends State<AddressPickerMapPage> with SingleTickerProviderStateMixin {
  late final ProfileBloc _profileBloc;
  late final MapController _mapController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  // موقعیت فعلی
  LatLng _currentPosition = const LatLng(30.5882768, 50.2575974);
  LatLng _selectedPosition = const LatLng(30.5882768, 50.2575974);
  
  // وضعیت‌ها
  bool _isLoading = true;
  bool _mapReady = false;
  String _selectedAddress = 'موقعیت را روی نقشه انتخاب کنید';
  
  // کنترلرها
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileBloc = getIt<ProfileBloc>();
    _mapController = MapController();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _mapController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== دریافت موقعیت فعلی ====================
  Future<void> _getCurrentLocation() async {
    debugPrint('📍 [MAP] دریافت موقعیت فعلی...');
    setState(() => _isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('دسترسی به موقعیت رد شد');
          _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('لطفاً دسترسی موقعیت را در تنظیمات فعال کنید');
        _useDefaultLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 5),
      );

      debugPrint('📍 [MAP] موقعیت دریافت شد: ${position.latitude}, ${position.longitude}');
      
      _currentPosition = LatLng(position.latitude, position.longitude);
      _selectedPosition = _currentPosition;
      
      _moveToPosition(_currentPosition);
      _selectedAddress = 'موقعیت شما روی نقشه انتخاب شد';
      
      setState(() {
        _isLoading = false;
        _mapReady = true;
      });
      _animationController.forward();

    } catch (e) {
      debugPrint('❌ [MAP] خطا در دریافت موقعیت: $e');
      _useDefaultLocation();
    }
  }

  void _useDefaultLocation() {
    _currentPosition = const LatLng(30.5882768, 50.2575974);
    _selectedPosition = _currentPosition;
    _selectedAddress = 'موقعیت پیش‌فرض';
    setState(() {
      _isLoading = false;
      _mapReady = true;
    });
    _animationController.forward();
    _moveToPosition(_currentPosition);
  }

  void _moveToPosition(LatLng position) {
    try {
      _mapController.move(position, 14.0);
    } catch (e) {
      debugPrint('⚠️ [MAP] خطا در حرکت نقشه: $e');
    }
  }

  // ==================== ذخیره آدرس ====================
  void _saveAddress() {
    debugPrint('💾 [MAP] ذخیره آدرس...');
    
    final locationName = _locationNameController.text.trim();
    if (locationName.isEmpty) {
      _showError('لطفاً نام مکان را وارد کنید');
      return;
    }

    String street = _streetController.text.trim();
    String city = _cityController.text.trim();
    String state = _stateController.text.trim();
    String zipcode = _zipcodeController.text.trim();
    
    if (street.isEmpty || city.isEmpty || state.isEmpty) {
      _showError('لطفاً همه فیلدهای آدرس را کامل کنید');
      return;
    }

    final addressData = {
      'lat': _selectedPosition.latitude.toString(),
      'lng': _selectedPosition.longitude.toString(),
      'street': street,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'country_code': 'IR',
      'location_name': locationName,
      'delivery_instruction': '',
      'mapbox_drag_map': 'true',
      'mapbox_drag_end': 'true',
    };

    debugPrint('📤 [MAP] داده‌های آدرس: $addressData');
    _profileBloc.add(ProfileAddAddressRequested(addressData: addressData));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      bloc: _profileBloc,
      listener: (context, state) {
        if (state is ProfileAddressActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
        if (state is ProfileError) {
          _showError(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(state),
          body: _isLoading
              ? _buildSkeletonLoading()
              : Column(
                  children: [
                    _buildMapView(),
                    _buildAddressForm(state),
                  ],
                ),
        );
      },
    );
  }

  // ==================== AppBar ====================
  AppBar _buildAppBar(ProfileState state) {
    return AppBar(
      title: const Text(
        'افزودن آدرس جدید',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: state is ProfileAddressActionLoading ? null : _saveAddress,
          child: state is ProfileAddressActionLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'ذخیره',
                  style: TextStyle(
                    color: Color(0xFFFF7A00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ],
    );
  }

  // ==================== اسکلتون لودینگ ====================
  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شیمیر نقشه
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 300,
              color: Colors.grey.shade200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'در حال بارگذاری نقشه...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // شیمیر فرم
          _buildShimmerField(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerField()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerField()),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerField(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerField()),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerField()),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ==================== نقشه ====================
  Widget _buildMapView() {
    return Expanded(
      flex: 4,
      child: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.grey.shade100,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  initialZoom: 13.0,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      setState(() {
                        _selectedPosition = position.center;
                        _selectedAddress = 'موقعیت انتخاب شد';
                      });
                    }
                  },
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedPosition = point;
                      _selectedAddress = 'موقعیت انتخاب شد';
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.arjanstartup',
                    tileProvider: NetworkTileProvider(),
                  ),
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.arjanstartup',
                  ),
                  // ✅ فقط یک نشانگر
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 44,
                        height: 44,
                        point: _selectedPosition,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFFFF7A00),
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // ✅ آدرس انتخاب شده (فقط یک بار)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // دکمه موقعیت فعلی
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _getCurrentLocation,
              child: const Icon(
                Icons.my_location,
                color: Color(0xFFFF7A00),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== فرم اطلاعات آدرس ====================
  Widget _buildAddressForm(ProfileState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // هدر بخش
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'اطلاعات آدرس',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedPosition.latitude.toStringAsFixed(4)}, ${_selectedPosition.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFFFF7A00),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // نام مکان و کدپستی
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _locationNameController,
                  hintText: 'نام مکان (مثال: منزل، محل کار) *',
                  prefixIcon: Icons.label_outline,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _zipcodeController,
                  hintText: 'کدپستی',
                  prefixIcon: Icons.pin_drop,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // خیابان
          _buildTextField(
            controller: _streetController,
            hintText: 'خیابان، پلاک، واحد *',
            prefixIcon: Icons.streetview,
            isRequired: true,
          ),
          const SizedBox(height: 8),
          
          // شهر و استان
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  hintText: 'شهر *',
                  prefixIcon: Icons.location_city_outlined,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  hintText: 'استان *',
                  prefixIcon: Icons.location_city,
                  isRequired: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // دکمه ذخیره
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: state is ProfileAddressActionLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: state is ProfileAddressActionLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'ثبت آدرس',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ویجت فیلد سفارشی ====================
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.grey.shade500,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
        ),
      ),
    );
  }
}