import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // تم نارنجی جذاب برای اپلیکیشن
    const Color primaryColor = Color(0xFFFF7A00);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // بخش بالایی: انتخاب آدرس و دکمه اعلان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ارسال به',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Row(
                        children: [
                          Text(
                            'انتخاب آدرس ...',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.black87),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                splashRadius: 24, // ✅ مشکل onRadius حل شد
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 28),
                onPressed: () {
                  // عملیات باز کردن اعلانات
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // بخش پایینی: نوار جستجوی جذاب و تعاملی
          InkWell(
            onTap: () {
              // عملیات باز کردن جستجو
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded, color: primaryColor, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    'جستجو در آرژان فود...',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}