import 'package:arjan_startup/core/enums/store_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:arjan_startup/core/di/service_locator.dart';
import 'package:arjan_startup/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:arjan_startup/features/restaurant/presentation/bloc/restaurant/restaurant_bloc.dart';
import 'package:arjan_startup/features/restaurant/data/models/item_details_dto.dart';
import 'package:arjan_startup/features/restaurant/data/models/menu_item_dto.dart';

class ItemDetailsPage extends StatefulWidget {
  final String merchantId;
  final String itemId;
  final String categoryId;
  final String merchantName;
  final String itemName;
  final StoreType storeType;

  const ItemDetailsPage({
    super.key,
    required this.merchantId,
    required this.itemId,
    required this.categoryId,
    required this.merchantName,
    required this.itemName,
    required this.storeType,
  });

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int _selectedQuantity = 1;
  PriceDto? _selectedPrice;
  List<PriceDto> _prices = [];

  final RestaurantBloc _restaurantBloc = getIt<RestaurantBloc>();
  final CartBloc _cartBloc = getIt<CartBloc>();

  @override
  void initState() {
    super.initState();
    debugPrint('🍽️ [ITEM_DETAILS] بارگذاری جزئیات غذا: ${widget.itemName}');
    _loadItemDetails();
  }

  void _loadItemDetails() {
    _restaurantBloc.add(
      LoadItemDetails(
        merchantId: widget.merchantId,
        itemId: widget.itemId,
        categoryId: widget.categoryId,
        lat: 30.5882768,
        lng: 50.2575974,
      ),
    );
  }

  void _addToCart() {
    if (_selectedPrice == null && _prices.isNotEmpty) {
      _selectedPrice = _prices.first;
    }
    
    if (_selectedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً سایز مورد نظر را انتخاب کنید'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    debugPrint('🛒 [ITEM_DETAILS] افزودن به سبد: ${widget.itemName} x$_selectedQuantity');
    
    final tempItem = MenuItemDto(
      id: widget.itemId,
      name: widget.itemName,
      description: '',
      photo: _selectedPrice!.price,
      price: _selectedPrice!.formattedPrice,
      rawPrice: _selectedPrice!.price,
    );
    
    _cartBloc.add(
      AddItemToCart(
        item: tempItem,
        merchantId: widget.merchantId,
        categoryId: widget.categoryId,
        lat: 30.5882768,
        lng: 50.2575974,
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.itemName} به سبد خرید اضافه شد'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }

  // متد کمکی برای پاک کردن "تومان" تکراری و اضافه کردن آن فقط یکبار
  String _formatPrice(String rawPrice) {
    // ابتدا هر چیزی غیر از عدد و علامت کاما را حذف می‌کنیم تا عدد خالص بدست آید
    String numericPart = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericPart.isEmpty) return rawPrice;
    // تبدیل به عدد با جدا کننده هزارگان
    final number = int.tryParse(numericPart) ?? 0;
    final formattedNumber = number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formattedNumber تومان';
  }

  String _cleanPrice(String price) {
    // اگر قیمت شامل "تومان" است، فقط یک بار آن را نگه دار
    String cleaned = price.replaceAll(RegExp(r'تومان\s*تومان'), 'تومان').trim();
    // اگر "تومان" وجود ندارد اضافه کن
    if (!cleaned.contains('تومان')) {
      cleaned = _formatPrice(cleaned);
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.storeType.primaryColor;
    const Color bgColor = Color(0xFFF8F9FA);

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
        title: Text(
          widget.itemName.length > 20 ? '${widget.itemName.substring(0, 20)}...' : widget.itemName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: StreamBuilder<RestaurantState>(
        stream: _restaurantBloc.stream,
        initialData: _restaurantBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;
          
          if (state == null || state.itemDetailsStatus == ItemDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.itemDetailsStatus == ItemDetailsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage.isNotEmpty ? state.errorMessage : 'خطا در دریافت اطلاعات',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadItemDetails,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          final item = state.selectedItem;
          if (item == null) {
            return const Center(child: Text('اطلاعاتی یافت نشد'));
          }

          _prices = item.data.prices;
          if (_selectedPrice == null && _prices.isNotEmpty) {
            _selectedPrice = _prices.first;
          }

          final totalPrice = (int.tryParse(_selectedPrice?.price ?? '0') ?? 0) * _selectedQuantity;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // تصویر غذا
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 280,
                            color: Colors.grey.shade100,
                            child: item.data.photo.isNotEmpty
                                ? Image.network(
                                    item.data.photo,
                                    width: double.infinity,
                                    height: 280,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Center(
                                      child: Icon(Icons.fastfood, size: 80, color: Colors.grey.shade400),
                                    ),
                                  )
                                : Center(
                                    child: Icon(Icons.fastfood, size: 80, color: Colors.grey.shade400),
                                  ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // نام و قیمت
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.data.itemName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (_selectedPrice != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _cleanPrice(_selectedPrice!.formattedPrice),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // توضیحات (HTML)
                            if (item.data.itemDescription.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Html(
                                  data: item.data.itemDescription,
                                  style: {
                                    'p': Style(
                                      color: Colors.grey.shade700,
                                      fontSize: FontSize(14),
                                      lineHeight: LineHeight(1.6),
                                      fontFamily: 'IRANSansMobile',
                                    ),
                                    'span': Style(
                                      color: Colors.grey.shade700,
                                      fontSize: FontSize(14),
                                    ),
                                  },
                                ),
                              ),
                            const SizedBox(height: 24),

                            // انتخاب سایز
                            if (_prices.length > 1) ...[
                              const Text(
                                'انتخاب سایز:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: _prices.map((price) {
                                  final isSelected = _selectedPrice == price;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedPrice = price;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? primaryColor : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? primaryColor : Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        price.size.isNotEmpty ? price.size : 'معمولی',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // انتخاب تعداد
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'تعداد:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (_selectedQuantity > 1) {
                                              setState(() {
                                                _selectedQuantity--;
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.remove, size: 20),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: Center(
                                            child: Text(
                                              '$_selectedQuantity',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedQuantity++;
                                            });
                                          },
                                          icon: const Icon(Icons.add, size: 20),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // تگ‌های اضافی
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (item.data.spicydish == '1')
                                  _buildTag(Icons.local_fire_department, 'سوزش', Colors.red),
                                if (item.data.dish.isNotEmpty)
                                  _buildTag(Icons.restaurant, item.data.dish, Colors.green),
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // نوار پایین
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _addToCart,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'افزودن به سبد خرید',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Row(
                        children: [
                          if (_selectedQuantity > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_selectedQuantity',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          Text(
                            '${totalPrice.toStringAsFixed(0)} تومان',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}