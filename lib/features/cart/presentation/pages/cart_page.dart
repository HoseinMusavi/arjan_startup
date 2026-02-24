import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final formatCurrency = NumberFormat.currency(locale: 'fa_IR', symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // درخواست لود دیتای فاکتور در لحظه ورود
    getIt<CartBloc>().add(const LoadCartDetails(30.5882768, 50.2575974));
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
      ),
      body: BlocBuilder<CartBloc, CartState>(
        bloc: getIt<CartBloc>(),
        builder: (context, state) {
          if (state.status == CartStatus.loading && state.cartDetails == null) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          
          if (state.cartCount == 0 || state.cartDetails == null || state.cartDetails!.items.isEmpty) {
            return _buildEmptyCart(primaryColor);
          }

          final details = state.cartDetails!;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // مشخصات رستوران
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
                      
                      // لیست غذاها
                      const Text('سفارش‌های شما', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 12),
                      ...details.items.map((item) => _buildCartItem(item, primaryColor)),
                      
                      const SizedBox(height: 24),
                      
                      // فاکتور پرداخت
                      _buildReceiptCard(details, primaryColor),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // فضای تنفس پایین صفحه
            ],
          );
        },
      ),
      // نوار چسبان تایید پرداخت
      bottomSheet: BlocBuilder<CartBloc, CartState>(
        bloc: getIt<CartBloc>(),
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
          // کنترل‌گر تعداد (موقتا دکمه‌های دکوری تا فاز بعدی که متدهای update/delete رو اضافه کنیم)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.add, color: primaryColor, size: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('${item.qty}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
                Icon(item.qty == 1 ? Icons.delete_outline : Icons.remove, color: primaryColor, size: 22),
              ],
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
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () {
          // در فاز بعدی (ثبت آدرس و درگاه بانکی)
        },
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