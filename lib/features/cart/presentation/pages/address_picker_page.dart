import 'package:flutter/material.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/cart/data/models/address_model.dart';

class AddressPickerPage extends StatefulWidget {
  final String merchantId;
  final double totalAmount;

  const AddressPickerPage({
    super.key,
    required this.merchantId,
    required this.totalAmount,
  });

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  final CartBloc _cartBloc = getIt<CartBloc>();
  List<AddressDto> _addresses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // کنترل‌رهای فرم آدرس جدید
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  bool _isAddingNewAddress = false;

  @override
  void initState() {
    super.initState();
    print('📍 [ADDRESS_PAGE] باز شدن صفحه انتخاب آدرس');
    _loadAddresses();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _locationNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    print('📍 [ADDRESS_PAGE] شروع بارگذاری آدرس‌ها');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _cartBloc.getAddressBookDropDown();
    
    result.fold(
      (failure) {
        print('❌ [ADDRESS_PAGE] خطا در بارگذاری آدرس‌ها: ${failure.message}');
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (addresses) {
        print('✅ [ADDRESS_PAGE] تعداد ${addresses.length} آدرس بارگذاری شد');
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _saveNewAddress() async {
    if (!_formKey.currentState!.validate()) return;

    print('📍 [ADDRESS_PAGE] شروع ثبت آدرس جدید');
    setState(() {
      _isAddingNewAddress = true;
    });

    final result = await _cartBloc.setDeliveryAddress(
      lat: 30.5882768,
      lng: 50.2575974,
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipcode: _zipcodeController.text,
      countryCode: 'IR',
      locationName: _locationNameController.text,
      contactPhone: _contactPhoneController.text,
      merchantId: widget.merchantId,
    );

    setState(() {
      _isAddingNewAddress = false;
    });

    result.fold(
      (failure) {
        print('❌ [ADDRESS_PAGE] خطا در ثبت آدرس: ${failure.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (response) {
        print('✅ [ADDRESS_PAGE] آدرس با موفقیت ثبت شد');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('آدرس با موفقیت ثبت شد'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
        _loadAddresses();
      },
    );
  }

  void _selectAddress(AddressDto address) {
    print('📍 [ADDRESS_PAGE] آدرس انتخاب شد: ${address.locationName}');
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);
    const Color bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('انتخاب آدرس تحویل', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadAddresses,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          return _buildAddressCard(address, primaryColor);
                        },
                      ),
                    ),
                    _buildAddNewAddressButton(primaryColor),
                  ],
                ),
    );
  }

  Widget _buildAddressCard(AddressDto address, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _selectAddress(address),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.locationName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (address.isDefault)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'پیش‌فرض',
                                style: TextStyle(color: Colors.green.shade700, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.address,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewAddressButton(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => _showAddAddressDialog(primaryColor),
          icon: const Icon(Icons.add_location, color: Colors.white),
          label: const Text('افزودن آدرس جدید', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  void _showAddAddressDialog(Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'افزودن آدرس جدید',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationNameController,
                    decoration: const InputDecoration(
                      labelText: 'نام آدرس (مثال: خانه، محل کار)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'لطفاً نام آدرس را وارد کنید' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'آدرس (خیابان، کوچه، پلاک)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'لطفاً آدرس را وارد کنید' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'شهر',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'لطفاً شهر را وارد کنید' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'استان',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'لطفاً استان را وارد کنید' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _zipcodeController,
                    decoration: const InputDecoration(
                      labelText: 'کد پستی',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'شماره تماس',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'لطفاً شماره تماس را وارد کنید' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAddingNewAddress ? null : _saveNewAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isAddingNewAddress
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('ثبت آدرس', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}