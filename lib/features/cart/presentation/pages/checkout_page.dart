import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/config/routes/app_router.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/cart/data/models/address_model.dart';
import 'package:arjan_startup/features/cart/data/models/payment_method_model.dart';

class CheckoutPage extends StatefulWidget {
  final String merchantId;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.merchantId,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartBloc _cartBloc = getIt<CartBloc>();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'fa_IR',
    symbol: '',
    decimalDigits: 0,
  );

  List<AddressDto> _addresses = [];
  AddressDto? _selectedAddress;
  Map<String, String> _deliveryDates = {};
  String? _selectedDate;
  Map<String, String> _deliveryTimes = {};
  String? _selectedTime;
  List<PaymentMethodDto> _paymentMethods = [];
  PaymentMethodDto? _selectedPaymentMethod;
  final int _userPoints = 50000;
  int _appliedPoints = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('🛒 [CHECKOUT] صفحه تسویه باز شد - totalAmount: ${widget.totalAmount}');
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ وقتی صفحه برگشت داده شد، آدرس‌ها رو دوباره بارگذاری کن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _addresses.isEmpty) {
        _loadAddresses();
      }
    });
  }

  Future<void> _loadInitialData() async {
    debugPrint('🛒 [CHECKOUT] شروع بارگذاری داده‌ها');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _loadAddresses();
    await _loadDeliveryDates();
    await _loadPaymentMethods();
  }

  Future<void> _loadAddresses() async {
    debugPrint('📍 [CHECKOUT] بارگذاری آدرس‌ها');
    final addressResult = await _cartBloc.getAddressBookDropDown();
    if (!mounted) return;
    
    addressResult.fold(
      (failure) {
        debugPrint('❌ [CHECKOUT] خطا در دریافت آدرس‌ها: ${failure.message}');
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (addresses) {
        debugPrint('✅ [CHECKOUT] ${addresses.length} آدرس دریافت شد');
        setState(() {
          _addresses = addresses;
          if (addresses.isNotEmpty) {
            _selectedAddress = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
          }
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadPaymentMethods() async {
    debugPrint('💳 [CHECKOUT] دریافت روش‌های پرداخت');
    final result = await _cartBloc.getPaymentList(
      widget.merchantId,
      30.5882768,
      50.2575974,
    );
    
    if (!mounted) return;
    result.fold(
      (failure) {
        debugPrint('❌ [CHECKOUT] خطا در دریافت روش‌های پرداخت: ${failure.message}');
      },
      (methods) {
        debugPrint('✅ [CHECKOUT] ${methods.length} روش پرداخت دریافت شد');
        debugPrint('💳 [CHECKOUT] روش‌های پرداخت: ${methods.map((m) => m.paymentName).join(', ')}');
        setState(() {
          _paymentMethods = methods;
          final stpMethod = methods.firstWhere(
            (m) => m.paymentCode == 'stp',
            orElse: () => methods.first,
          );
          _selectedPaymentMethod = stpMethod;
          debugPrint('💳 [CHECKOUT] روش پرداخت پیش‌فرض انتخاب شد: ${_selectedPaymentMethod?.paymentName}');
        });
      },
    );
  }

  Future<void> _loadDeliveryDates() async {
    debugPrint('🛒 [CHECKOUT] دریافت تاریخ‌های تحویل');
    final dateResult = await _cartBloc.getDeliveryDateList(widget.merchantId);
    if (!mounted) return;
    
    dateResult.fold(
      (failure) {
        debugPrint('❌ [CHECKOUT] خطا در دریافت تاریخ‌ها: ${failure.message}');
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (dates) {
        debugPrint('✅ [CHECKOUT] ${dates.length} تاریخ دریافت شد');
        setState(() {
          _deliveryDates = dates;
          if (dates.isNotEmpty) {
            _selectedDate = dates.keys.first;
          }
        });
        if (_selectedDate != null) {
          _loadDeliveryTimes();
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _loadDeliveryTimes() async {
    if (_selectedDate == null) return;
    
    debugPrint('🛒 [CHECKOUT] دریافت ساعات تحویل برای تاریخ: $_selectedDate');
    final timeResult = await _cartBloc.getDeliveryTimeList(
      widget.merchantId,
      _selectedDate!,
    );
    if (!mounted) return;
    
    timeResult.fold(
      (failure) {
        debugPrint('❌ [CHECKOUT] خطا در دریافت ساعات: ${failure.message}');
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (times) {
        debugPrint('✅ [CHECKOUT] ${times.length} ساعت دریافت شد');
        setState(() {
          _deliveryTimes = times;
          if (times.isNotEmpty) {
            _selectedTime = times.keys.first;
          }
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _applyPoints() async {
    if (_appliedPoints > 0) {
      setState(() {
        _appliedPoints = 0;
      });
      return;
    }

    debugPrint('🛒 [CHECKOUT] اعمال امتیاز کیف پول');
    final result = await _cartBloc.applyRedeemPoints(_userPoints, widget.merchantId);
    if (!mounted) return;
    
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (response) {
        if (response.success) {
          debugPrint('✅ [CHECKOUT] امتیاز با موفقیت اعمال شد');
          setState(() {
            _appliedPoints = _userPoints;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('امتیاز با موفقیت اعمال شد'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Future<void> _submitOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً آدرس تحویل را انتخاب کنید'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً تاریخ و ساعت تحویل را انتخاب کنید'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً روش پرداخت را انتخاب کنید'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint('🛒 [CHECKOUT] شروع ثبت سفارش - روش پرداخت: ${_selectedPaymentMethod!.paymentName}');
    setState(() {
      _isSubmitting = true;
    });

    final preCheckoutResult = await _cartBloc.preCheckout(
      transactionType: 'delivery',
      deliveryDate: _selectedDate!,
      deliveryTime: _selectedTime!,
      merchantId: widget.merchantId,
    );

    if (!mounted) return;
    await preCheckoutResult.fold(
      (failure) async {
        debugPrint('❌ [CHECKOUT] خطا در پیش‌تسویه: ${failure.message}');
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (preCheckoutResponse) async {
        debugPrint('✅ [CHECKOUT] پیش‌تسویه موفق');

        final payNowResult = await _cartBloc.payNow(
          transactionType: 'delivery',
          paymentProvider: _selectedPaymentMethod!.paymentCode,
          deliveryDate: _selectedDate!,
          deliveryTime: _selectedTime!,
          merchantId: widget.merchantId,
        );

        if (!mounted) return;
        payNowResult.fold(
          (failure) {
            debugPrint('❌ [CHECKOUT] خطا در پرداخت: ${failure.message}');
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          (payNowResponse) {
            debugPrint('✅ [CHECKOUT] سفارش ثبت شد! orderId: ${payNowResponse.orderId}, مبلغ: ${payNowResponse.totalAmount}');
            setState(() {
              _isSubmitting = false;
            });
            
            if (_selectedPaymentMethod!.paymentCode == 'stp') {
              _openPaymentInBrowser(payNowResponse.redirectUrl);
            } else {
              _showSuccessDialog(payNowResponse.orderId);
            }
          },
        );
      },
    );
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('سفارش ثبت شد!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سفارش شما با موفقیت ثبت شد.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.green),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('کد پیگیری', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('#$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('محصولات به زودی ارسال خواهد شد.', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('بازگشت به صفحه اصلی'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPaymentInBrowser(String url) async {
    debugPrint('🌐 [CHECKOUT] باز کردن درگاه پرداخت: $url');
    
    try {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('✅ [CHECKOUT] لینک با موفقیت باز شد');
    } catch (e) {
      debugPrint('❌ [CHECKOUT] خطا در باز کردن لینک: $e');
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('درگاه پرداخت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('لطفاً لینک زیر را کپی کرده و در مرورگر باز کنید:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بستن'),
            ),
          ],
        ),
      );
    }
  }

  // ✅ اصلاح: رفتن به صفحه مدیریت آدرس پروفایل
  Future<void> _navigateToAddressManagement() async {
    debugPrint('📍 [CHECKOUT] رفتن به صفحه مدیریت آدرس‌ها');
    
    // رفتن به صفحه آدرس‌های پروفایل
    final result = await AppRouter.router.push('/profile/addresses');
    
    // بعد از برگشت، آدرس‌ها رو دوباره بارگذاری کن
    if (mounted) {
      debugPrint('📍 [CHECKOUT] برگشت از صفحه مدیریت آدرس‌ها، بارگذاری مجدد آدرس‌ها');
      await _loadAddresses();
      
      // اگر آدرسی انتخاب شده بود، دوباره به روز کن
      if (_addresses.isNotEmpty && _selectedAddress == null) {
        setState(() {
          _selectedAddress = _addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => _addresses.first,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);
    const Color bgColor = Color(0xFFF8F9FA);
    
    final finalAmount = widget.totalAmount - _appliedPoints;
    debugPrint('💰 [CHECKOUT] محاسبه مبلغ: totalAmount=${widget.totalAmount}, appliedPoints=$_appliedPoints, finalAmount=$finalAmount');
    debugPrint('💳 [CHECKOUT] تعداد روش‌های پرداخت در build: ${_paymentMethods.length}');
    debugPrint('💳 [CHECKOUT] روش پرداخت انتخاب شده در build: ${_selectedPaymentMethod?.paymentName}');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'تسویه حساب',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                        onPressed: _loadInitialData,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. نشانی تحویل
                      _buildSectionCard(
                        title: 'نشانی تحویل',
                        icon: Icons.location_on_outlined,
                        child: _buildAddressSection(primaryColor),
                      ),
                      const SizedBox(height: 12),

                      // 2. روش تحویل
                      _buildSectionCard(
                        title: 'روش تحویل',
                        icon: Icons.motorcycle_outlined,
                        child: const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.home_outlined, size: 22),
                          title: Text('تحویل درب منزل'),
                          trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. زمان تحویل
                      _buildSectionCard(
                        title: 'زمان تحویل',
                        icon: Icons.schedule_outlined,
                        child: Column(
                          children: [
                            if (_deliveryDates.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedDate,
                                  decoration: const InputDecoration(
                                    labelText: 'تاریخ تحویل',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: _deliveryDates.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDate = value;
                                      _selectedTime = null;
                                    });
                                    if (value != null) {
                                      _loadDeliveryTimes();
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 12),
                            if (_deliveryTimes.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedTime,
                                  decoration: const InputDecoration(
                                    labelText: 'ساعت تحویل',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: _deliveryTimes.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTime = value;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4. روش پرداخت
                      _buildSectionCard(
                        title: 'روش پرداخت',
                        icon: Icons.payment_outlined,
                        child: _paymentMethods.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: Text('در حال بارگذاری روش‌های پرداخت...')),
                              )
                            : Column(
                                children: _paymentMethods.map((method) {
                                  final isSelected = _selectedPaymentMethod?.paymentCode == method.paymentCode;
                                  return RadioListTile<PaymentMethodDto>(
                                    value: method,
                                    groupValue: _selectedPaymentMethod,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPaymentMethod = value;
                                        debugPrint('💳 [CHECKOUT] روش پرداخت تغییر کرد به: ${value?.paymentName}');
                                      });
                                    },
                                    title: Text(
                                      method.paymentName,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    activeColor: primaryColor,
                                    contentPadding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // 5. کیف پول
                      _buildSectionCard(
                        title: 'کیف پول',
                        icon: Icons.account_balance_wallet_outlined,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('موجودی کیف پول شما', style: TextStyle(color: Colors.grey.shade600)),
                                Text('${_currencyFormat.format(_userPoints)} تومان', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (_appliedPoints == 0) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _applyPoints,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: primaryColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('استفاده از کیف پول (${_currencyFormat.format(_userPoints)} تومان)'),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('مبلغ استفاده شده', style: TextStyle(color: Colors.green.shade700)),
                                    Text(
                                      '${_currencyFormat.format(_appliedPoints)} تومان',
                                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _appliedPoints = 0;
                                  });
                                },
                                child: const Text('لغو استفاده از کیف پول', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. دکمه ثبت سفارش
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'ثبت سفارش ${_currencyFormat.format(finalAmount)} تومان',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 22, color: const Color(0xFFFF7A00)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(Color primaryColor) {
    if (_addresses.isEmpty) {
      return Column(
        children: [
          const Text(
            'آدرسی ثبت نشده است',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _navigateToAddressManagement,
              icon: const Icon(Icons.add_location, size: 18),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              label: const Text(
                'افزودن آدرس جدید',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        ..._addresses.map((address) => RadioListTile<AddressDto>(
          value: address,
          groupValue: _selectedAddress,
          onChanged: (value) {
            setState(() {
              _selectedAddress = value;
            });
          },
          title: Text(
            address.locationName.isNotEmpty ? address.locationName : 'آدرس ${_addresses.indexOf(address) + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            address.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          activeColor: primaryColor,
          contentPadding: EdgeInsets.zero,
        )),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _navigateToAddressManagement,
          icon: const Icon(Icons.add_location, size: 18),
          label: const Text('مدیریت آدرس‌ها'),
        ),
      ],
    );
  }
}