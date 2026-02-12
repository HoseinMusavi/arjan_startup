import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // --- پالت رنگی مدرن و گرم ---
  static const Color primaryColor = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color secondaryColor = Color(0xFF263238);
  static const Color scaffoldBackground = Color(0xFFF9F9F9);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'AppFont',

      // 1. تنظیمات رنگ‌بندی کلی
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: secondaryColor,
        error: errorColor,
      ),

      scaffoldBackgroundColor: scaffoldBackground,

      // 2. تنظیمات AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: secondaryColor),
        titleTextStyle: TextStyle(
          fontFamily: 'AppFont',
          color: secondaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 3. تایپوگرافی
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: secondaryColor),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: secondaryColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: secondaryColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF616161)),
      ),

      // 4. دکمه‌ها
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontFamily: 'AppFont',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 5. فیلدهای ورودی
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // 6. کارت‌ها (تغییر نام به CardThemeData)
      // اگر همچنان ارور داد، ممکن است در نسخه شما این کلاس وجود نداشته باشد،
      // در آن صورت کافیست کل بخش cardTheme را حذف کنید یا از CardTheme عادی استفاده کنید.
      cardTheme: const CardThemeData( 
        color: surfaceColor,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ).copyWith(
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }
}