import 'package:flutter/material.dart';

class AppTheme {
  // رنگ‌بندی تپسی‌طور (نارنجی پررنگ و مشکی/خاکستری)
  static const Color primaryColor = Color(0xFFFF5722); // نارنجی جذاب
  static const Color secondaryColor = Color(0xFF212121); // مشکی تیره
  static const Color scaffoldBackground = Color(0xFFF5F5F5); // خاکستری خیلی روشن برای پس‌زمینه

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      
      // فونت فارسی (اگر فونت وزیر یا یکان دارید بعدا اضافه میکنیم، فعلا پیش‌فرض)
      fontFamily: 'Tahoma', 

      // استایل دکمه‌ها (گرد و نارنجی)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white, // رنگ متن دکمه
          elevation: 0, // فلت و مدرن
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // گوشه‌های گرد
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // استایل فیلدهای ورودی (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // بدون بوردر در حالت عادی
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2), // بوردر نارنجی هنگام فوکوس
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),

      // استایل اپ‌بار
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // آیکون‌ها مشکی
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}