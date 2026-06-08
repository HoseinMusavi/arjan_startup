import 'package:arjan_startup/features/cart/presentation/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_event.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final formatCurrency = NumberFormat.currency(locale: 'fa_IR', symbol: '', decimalDigits: 0);
  final CartBloc _cartBloc = getIt<CartBloc>();

  @override
  void initState() {
    super.initState();
    debugPrint('🛒 [CART_PAGE] صفحه سبد خرید باز شد');
    
    // ✅ چک کن اگه cartDetails توی state هست، دوباره load نکن
    if (_cartBloc.state.cartDetails != null && _cartBloc.state.cartDetails!.items.isNotEmpty) {
      debugPrint('🛒 [CART_PAGE] جزئیات سبد از قبل موجود است، load مجدد انجام نمیشود');
      return;
    }
    
    // ✅ اگه merchantId فعال هست، جزئیات رو بگیر
    final activeMerchantId = _cartBloc.getActiveMerchantId();
    if (activeMerchantId.isNotEmpty) {
      debugPrint('🛒 [CART_PAGE] دریافت جزئیات برای merchantId: $activeMerchantId');
      _cartBloc.add(LoadCartDetails(30.5882768, 50.2575974));
    } else {
      debugPrint('🛒 [CART_PAGE] merchantId فعال وجود ندارد، تلاش با LoadFirstCart');
      _cartBloc.add(const LoadFirstCart(30.5882768, 50.2575974));
    }
  }

  Future<void> _clearCart() async {
    debugPrint('🗑️ [CART_PAGE] درخواست خالی کردن سبد خرید');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف همه موارد', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('آیا از حذف تمام آیتم‌های سبد خرید اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف همه', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      debugPrint('❌ [CART_PAGE] انصراف از خالی کردن سبد');
      return;
    }

    debugPrint('🔄 [CART_PAGE] شروع فرآیند خالی کردن سبد خرید');
    
    final activeMerchantId = _cartBloc.getActiveMerchantId();
    if (activeMerchantId.isEmpty) {
      debugPrint('⚠️ [CART_PAGE] هیچ فروشگاه فعالی برای خالی کردن سبد وجود ندارد');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سبد خرید خالی است'), backgroundColor: Colors.orange),
      );
      return;
    }

    debugPrint('🗑️ [CART_PAGE] ارسال درخواست clearCart برای فروشگاه: $activeMerchantId');
    
    final result = await _cartBloc.clearCart(activeMerchantId, 30.5882768, 50.2575974);
    
    result.fold(
      (failure) {
        debugPrint('❌ [CART_PAGE] خطا در خالی کردن سبد: ${failure.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: ${failure.message}'), backgroundColor: Colors.red),
        );
      },
      (_) {
        debugPrint('✅ [CART_PAGE] سبد خرید با موفقیت خالی شد');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سبد خرید خالی شد'), backgroundColor: Colors.green),
        );
      },
    );
  }

  void _goToCheckout() {
    final activeMerchantId = _cartBloc.getActiveMerchantId();
    
    double total = 0;
    if (_cartBloc.state.cartDetails != null) {
      total = _cartBloc.state.cartDetails!.total;
    } else if (_cartBloc.state.basketTotal.isNotEmpty) {
      final cleanTotal = _cartBloc.state.basketTotal.replaceAll(RegExp(r'[^0-9]'), '');
      total = double.tryParse(cleanTotal) ?? 0;
    }
    
    debugPrint('🛒 [CART_PAGE] رفتن به صفحه تسویه - merchantId: $activeMerchantId, total: $total');
    
    if (activeMerchantId.isEmpty || total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سبد خرید خالی است'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          merchantId: activeMerchantId,
          totalAmount: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF7A00);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('سبد خرید', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            bloc: _cartBloc,
            builder: (context, state) {
              if (state.cartCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _clearCart,
                  tooltip: 'خالی کردن سبد خرید',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        bloc: _cartBloc,
        builder: (context, state) {
          if (state.status == CartStatus.loading && state.cartDetails == null) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          if (state.cartCount == 0 || state.cartDetails == null || state.cartDetails!.items.isEmpty) {
            return _buildEmptyCart(primaryColor);
          }

          final details = state.cartDetails!;
          debugPrint('💰 [CART_PAGE] نمایش سبد خرید - total: ${details.total}, subtotal: ${details.subtotal}');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              color: Colors.grey.shade200,
                              image: details.merchantLogo.isNotEmpty 
                                  ? DecorationImage(image: NetworkImage(details.merchantLogo), fit: BoxFit.cover) 
                                  : null,
                            ),
                            child: details.merchantLogo.isEmpty ? const Icon(Icons.storefront, color: Colors.grey) : null,
                          ),
                          const SizedBox(width: 12),
                          Text('خرید از ${details.merchantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('سفارش‌های شما', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 12),
                      ...details.items.map((item) => _buildCartItem(item, primaryColor)),
                      const SizedBox(height: 24),
                      _buildReceiptCard(details, primaryColor),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      bottomSheet: BlocBuilder<CartBloc, CartState>(
        bloc: _cartBloc,
        builder: (context, state) {
          if (state.cartCount == 0 || state.cartDetails == null || state.cartDetails!.items.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildBottomCheckoutBar(state.cartDetails!.total, primaryColor);
        },
      ),
    );
  }

  Widget _buildCartItem(item, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Text('${formatCurrency.format(item.price)} تومان', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: Text(
              '${item.qty}',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(details, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('فاکتور خرید', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 20),
          _buildReceiptRow('مجموع سبد خرید', details.subtotal),
          const SizedBox(height: 12),
          _buildReceiptRow('هزینه ارسال (پیک)', details.deliveryCharges, isHighlight: details.deliveryCharges == 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.black12, thickness: 1, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مبلغ قابل پرداخت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${formatCurrency.format(details.total)} تومان', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String title, double amount, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(
          amount == 0 && isHighlight ? 'رایگان' : '${formatCurrency.format(amount)} تومان',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: amount == 0 && isHighlight ? Colors.green : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(double total, Color primaryColor) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _goToCheckout,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('تایید و ادامه خرید', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${formatCurrency.format(total)} تومان', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 90, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text('سبد خرید شما خالی است!', style: TextStyle(color: Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('می‌توانید از منوی رستوران‌ها غذا انتخاب کنید.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
            ),
            child: const Text('بازگشت به منو', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}