import 'package:flutter/material.dart';

class AppTheme {
  // رنگ‌بندی سازمانی
  static const Color primaryColor = Color(0xFFFF5722); // نارنجی اصلی
  static const Color primaryDark = Color(0xFFE64A19); // نارنجی تیره‌تر برای گرادینت
  static const Color secondaryColor = Color(0xFF212121); 
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // تنظیم فونت پیش‌فرض برای کل برنامه
      fontFamily: 'AppFont', 

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: scaffoldBackground,
      ),
      
      scaffoldBackgroundColor: scaffoldBackground,

      // تایپوگرافی مدرن (برای اینکه فونت روی همه ویجت‌ها درست بشینه)
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: secondaryColor),
        bodyLarge: TextStyle(fontSize: 16, color: secondaryColor),
        bodyMedium: TextStyle(fontSize: 14, color: secondaryColor),
      ),

      // استایل دکمه‌ها
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'AppFont'),
        ),
      ),

      // استایل اینپوت‌ها
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }
}