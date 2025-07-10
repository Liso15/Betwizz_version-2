class AppConstants {
  static const String appName = 'Betwizz';
  static const String appVersion = '3.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.betwizz.co.za';
  static const String sportradarApiUrl = 'https://api.sportradar.com';
  
  // PayFast Configuration
  static const String payFastMerchantId = 'your_merchant_id';
  static const String payFastMerchantKey = 'your_merchant_key';
  
  // Subscription Tiers (ZAR)
  static const double basicTierPrice = 49.0;
  static const double premiumTierPrice = 149.0;
  static const double eliteTierPrice = 499.0;
  
  // Performance Benchmarks
  static const int maxAppLaunchTimeMs = 1200;
  static const int maxStreamStartupTimeMs = 3000;
  static const int maxOcrProcessingTimeMs = 4000;
}
