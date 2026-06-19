import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class AddEditAddressPage extends StatefulWidget {
  const AddEditAddressPage({super.key});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _latController = TextEditingController(text: '30.0549908');
  final TextEditingController _lngController = TextEditingController(text: '50.1601352');
  final TextEditingController _locationNameController = TextEditingController(text: '1');

  String _selectedCountry = 'IR';
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('📍 [AddEditAddressPage] initState');
    _profileBloc = getIt<ProfileBloc>();
    _profileBloc.add(const ProfileCountryListRequested());
  }

  @override
  void dispose() {
    debugPrint('📍 [AddEditAddressPage] dispose');
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('افزودن آدرس جدید'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileAddressActionSuccess) {
              debugPrint('✅ [AddEditAddressPage] Success: ${state.message}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('آدرس با موفقیت اضافه شد'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) context.pop();
                });
              }
            }
            if (state is ProfileError) {
              debugPrint('❌ [AddEditAddressPage] Error: ${state.message}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
            if (state is ProfileCountryListLoaded) {
              debugPrint('📍 [AddEditAddressPage] Countries loaded: ${state.countries.keys}');
            }
          },
          builder: (context, state) {
            if (state is ProfileAddressActionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اطلاعات آدرس را وارد کنید',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'فیلدهای ستاره‌دار (*) اجباری هستند.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildDropdownField(
                      label: 'کشور *',
                      initialValue: _selectedCountry,
                      items: const [
                        DropdownMenuItem(value: 'IR', child: Text('ایران')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedCountry = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً کشور را انتخاب کنید';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _stateController,
                      label: 'استان *',
                      hint: 'مثال: تهران، خوزستان',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً استان را وارد کنید';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _cityController,
                      label: 'شهر *',
                      hint: 'مثال: تهران، اهواز',
                      icon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً شهر را وارد کنید';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _streetController,
                      label: 'آدرس (خیابان) *',
                      hint: 'خیابان اصلی، پلاک، واحد',
                      icon: Icons.streetview,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً آدرس را وارد کنید';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _zipcodeController,
                      label: 'کدپستی',
                      hint: 'کدپستی ۱۰ رقمی',
                      icon: Icons.pin_drop,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _latController,
                      label: 'عرض جغرافیایی',
                      hint: 'مثال: 30.0549908',
                      icon: Icons.map,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lngController,
                      label: 'طول جغرافیایی',
                      hint: 'مثال: 50.1601352',
                      icon: Icons.map_outlined,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _locationNameController,
                      label: 'نام مکان',
                      hint: 'مثال: منزل، محل کار',
                      icon: Icons.label,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'ثبت آدرس',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String initialValue,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.public, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _submitForm() {
    debugPrint('📤 [AddEditAddressPage] Submit form');
    if (_formKey.currentState?.validate() ?? false) {
      final addressData = {
        'lat': _latController.text.trim(),
        'lng': _lngController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipcode': _zipcodeController.text.trim(),
        'country_code': _selectedCountry,
        'location_name': _locationNameController.text.trim(),
        'delivery_instruction': '',
        'mapbox_drag_map': 'true',
        'mapbox_drag_end': 'true',
      };

      debugPrint('📤 [AddEditAddressPage] Sending: $addressData');
      _profileBloc.add(ProfileAddAddressRequested(addressData: addressData));
    } else {
      debugPrint('❌ [AddEditAddressPage] Validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تمام فیلدهای اجباری را به‌درستی پر کنید.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}