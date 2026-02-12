class AppConstants {
  // Base URL اصلی API
  static const String baseUrl = "https://arjanapp.ir/mobileappv2/api";
  
  // آدرس پایه برای تصاویر (طبق تحلیل ریسپانس‌ها معمولا این شکلی است، بعداً داینامیک می‌کنیم)
  static const String baseImageUrl = "https://arjanapp.ir/upload";

  // کلید امنیتی که در هدر یا بادی باید ارسال شود (از اسکرین‌شات شما)
  static const String apiKey = "OOMW8CGDJJDRW3NBSABe3K26F7HQ75VGN";
  
  // تایم‌اوت درخواست‌ها
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
}