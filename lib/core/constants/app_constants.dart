class AppConstants {
  // App Information
  static const String appName = 'Betwizz';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sports Betting Intelligence Platform';
  
  // Company Information
  static const String companyName = 'Betwizz Technologies';
  static const String supportEmail = 'support@betwizz.com';
  static const String websiteUrl = 'https://betwizz.com';
  
  // API Configuration
  static const String baseApiUrl = 'https://api.betwizz.com/v1';
  static const String websocketUrl = 'wss://ws.betwizz.com';
  
  // Feature Flags
  static const bool enableAIChat = true;
  static const bool enableReceiptScanner = true;
  static const bool enableLiveStreaming = true;
  static const bool enablePushNotifications = true;
  
  // Limits and Constraints
  static const int maxChatMessageLength = 500;
  static const int maxReceiptFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxChannelsPerUser = 50;
  static const int sessionTimeoutMinutes = 30;
  
  // South African Specific
  static const String currency = 'ZAR';
  static const String countryCode = 'ZA';
  static const String timeZone = 'Africa/Johannesburg';
  static const String locale = 'en_ZA';
  
  // Responsible Gambling
  static const String responsibleGamblingHotline = '0800 006 008';
  static const String responsibleGamblingUrl = 'https://www.responsiblegambling.org.za';
  
  // Legal Compliance
  static const int minimumAge = 18;
  static const String termsOfServiceUrl = 'https://betwizz.com/terms';
  static const String privacyPolicyUrl = 'https://betwizz.com/privacy';
  static const String ficaComplianceUrl = 'https://betwizz.com/fica';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/betwizz';
  static const String twitterUrl = 'https://twitter.com/betwizz';
  static const String instagramUrl = 'https://instagram.com/betwizz';
  static const String youtubeUrl = 'https://youtube.com/betwizz';
  
  // App Store Links
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.betwizz.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/betwizz/id123456789';
  
  // Cache and Storage
  static const String hiveChatBox = 'chat_messages';
  static const String hiveReceiptsBox = 'receipts';
  static const String hiveUserBox = 'user_data';
  static const String hiveSettingsBox = 'app_settings';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Network Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
