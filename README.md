# Betwizz - Sports Betting Intelligence Platform

## Project Overview

Betwizz is a comprehensive sports betting intelligence platform designed specifically for the South African market. The Flutter mobile application provides users with advanced betting analytics, live streaming capabilities, AI-powered predictions, and receipt scanning technology to enhance their sports betting experience.

### Key Value Propositions
- **AI-Powered Insights**: Mfethu AI assistant provides personalized betting strategies and predictions
- **Live Streaming**: Real-time sports analysis and betting discussions
- **Receipt Intelligence**: OCR technology for automatic bet tracking and analysis
- **Compliance-First**: Built with POPIA and SA gambling regulations in mind
- **Local Focus**: Optimized for South African sports, currency, and banking systems

## Features

### Core Features ✅
- **Channel Dashboard**: Browse and subscribe to betting expert channels
- **Live Streaming**: Watch real-time sports analysis and betting discussions
- **Receipt Scanner**: OCR-powered betting slip recognition and tracking
- **Mfethu AI Chat**: Intelligent betting assistant with strategy recommendations
- **User Profiles**: Comprehensive user management with FICA verification
- **Subscription Management**: Tiered subscription system (R49/R149/R499)

### Advanced Features 🚧
- **Khanyo Predictions**: TensorFlow Lite-powered match predictions
- **Strategy Vault**: Encrypted betting strategy sharing
- **Performance Analytics**: Detailed betting performance tracking
- **Responsible Gambling Tools**: Spending limits and behavior monitoring
- **Multi-language Support**: English, Afrikaans, Zulu, Xhosa

### Planned Features 📋
- **Social Features**: Community discussions and expert following
- **Advanced Analytics**: Machine learning-powered betting insights
- **Integration Hub**: Connect with major SA bookmakers
- **Offline Mode**: Full functionality without internet connection

## Technical Specifications

### Tech Stack
- **Frontend**: Flutter 4.0+ with Material Design 3
- **State Management**: Riverpod 3.0
- **Local Storage**: Hive 4.0 with AES-256 encryption
- **Backend**: Node.js/Express with PostgreSQL
- **Real-time**: WebSocket connections for live data
- **Authentication**: Firebase Auth with JWT tokens

### Backend Integration
- **PayFast SDK**: Payment processing for subscriptions
- **Agora RTC**: Live streaming infrastructure
- **Firebase ML Kit**: OCR processing for receipt scanning
- **Sportradar API**: Real-time sports data and odds
- **Dialogflow**: Natural language processing for AI chat
- **TensorFlow Lite**: On-device machine learning predictions

### Mobile-Specific Optimizations
- **Performance Targets**:
  - App launch time: <1.2 seconds
  - Stream startup: <3 seconds
  - OCR processing: <4 seconds
  - Battery impact: <8% per hour
- **Device Compatibility**: Android SDK 29+, iOS 15+
- **Screen Support**: 16:9, 18:9, 19.5:9 aspect ratios
- **Offline Capabilities**: Cached strategies, recent data, draft receipts

### Compliance & Security
- **POPIA Compliance**: Data encryption, consent management, audit logging
- **Gambling Regulations**: Age verification, spending limits, problem gambling detection
- **Security**: AES-256 encryption, secure storage, biometric authentication
- **Localization**: ZAR currency, SA banking integration, local sports data

## Installation

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development
- Node.js 18+ for backend services

### Development Setup

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/betwizz/betwizz-flutter.git
   cd betwizz-flutter
   \`\`\`

2. **Install Flutter dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Configure environment variables**
   \`\`\`bash
   cp .env.example .env
   # Edit .env with your API keys and configuration
   \`\`\`

4. **Set up Firebase**
   \`\`\`bash
   # Add your google-services.json (Android) and GoogleService-Info.plist (iOS)
   # Configure Firebase project with Authentication, Firestore, and ML Kit
   \`\`\`

5. **Run the application**
   \`\`\`bash
   flutter run
   \`\`\`

### Backend Setup

1. **Install backend dependencies**
   \`\`\`bash
   cd backend
   npm install
   \`\`\`

2. **Set up database**
   \`\`\`bash
   # Configure PostgreSQL database
   npm run migrate
   npm run seed
   \`\`\`

3. **Start backend services**
   \`\`\`bash
   npm run dev
   \`\`\`

### Production Deployment

1. **Build for production**
   \`\`\`bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   \`\`\`

2. **Deploy backend**
   \`\`\`bash
   # Configure production environment
   # Deploy to cloud provider (AWS, Google Cloud, etc.)
   \`\`\`

## Usage

### Getting Started
1. **Download and install** the Betwizz app from Google Play Store or Apple App Store
2. **Create an account** using your email address
3. **Complete FICA verification** by uploading your SA ID document
4. **Choose a subscription tier** that suits your betting needs
5. **Start exploring** channels, scanning receipts, and chatting with Mfethu AI

### Key Workflows

#### Channel Subscription
1. Browse available channels in the Channel Dashboard
2. Preview channel content and creator profiles
3. Select subscription tier (Basic R49, Premium R149, Elite R499)
4. Complete payment through PayFast integration
5. Access premium content and live streams

#### Receipt Scanning
1. Navigate to Receipt Scanner
2. Point camera at betting slip
3. Capture image when prompted
4. Review and confirm extracted data
5. View analysis and add to betting history

#### AI Chat Interaction
1. Open Mfethu AI chat interface
2. Ask questions about betting strategies, odds analysis, or predictions
3. Receive personalized recommendations
4. Save important insights for future reference

## Contributing

We welcome contributions from the community! Please follow these guidelines:

### Development Guidelines
1. **Code Style**: Follow Flutter/Dart style guidelines
2. **Testing**: Write unit tests for new features
3. **Documentation**: Update documentation for API changes
4. **Compliance**: Ensure all changes maintain POPIA compliance

### Contribution Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Areas for Contribution
- UI/UX improvements and accessibility enhancements
- Performance optimizations and bug fixes
- Additional language translations
- Integration with new bookmakers or data sources
- Advanced analytics and machine learning features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses
- Flutter: BSD 3-Clause License
- Firebase: Google Terms of Service
- PayFast: PayFast Terms and Conditions
- Agora: Agora Terms of Service

## Gaps and Ambiguities

### Critical Implementation Gaps

#### 1. Backend Infrastructure (Priority: HIGH)
- **API Specifications**: Complete REST API documentation missing
- **Database Schema**: Detailed data models and relationships undefined
- **Authentication System**: JWT implementation and security measures not specified
- **Real-time Infrastructure**: WebSocket server architecture not defined
- **Payment Processing**: PayFast webhook handling and subscription lifecycle incomplete

#### 2. Third-Party Integrations (Priority: HIGH)
- **Sportradar API**: No endpoint specifications or data transformation logic
- **Agora RTC**: Token generation and streaming quality controls missing
- **Firebase ML Kit**: OCR model training and accuracy optimization not addressed
- **PayFast Integration**: Webhook security and subscription management incomplete

#### 3. Compliance Implementation (Priority: HIGH)
- **POPIA Compliance**: Data encryption, consent management, and audit logging not implemented
- **Gambling Regulations**: Age verification, spending limits, and problem gambling detection missing
- **Security Framework**: Comprehensive security measures and threat mitigation not specified

#### 4. Mobile Optimizations (Priority: MEDIUM)
- **Performance Optimization**: Memory management and battery optimization strategies undefined
- **Offline Capabilities**: Data synchronization and conflict resolution not implemented
- **Device Compatibility**: Tablet layouts and foldable device support missing

#### 5. UI/UX Completeness (Priority: MEDIUM)
- **Missing Screens**: Onboarding, payment flows, settings, and help screens not designed
- **Error Handling**: Comprehensive error states and user feedback mechanisms missing
- **Accessibility**: Screen reader support and accessibility testing not specified

#### 6. Testing and Quality Assurance (Priority: MEDIUM)
- **Testing Framework**: Unit, integration, and E2E testing strategies not defined
- **Performance Testing**: Load testing and stress testing procedures missing
- **Security Testing**: Penetration testing and vulnerability assessment not planned

### Ambiguous Requirements

#### 1. AI Implementation Details
- **Model Training**: Training data sources and model accuracy targets not specified
- **Response Quality**: AI response evaluation and improvement mechanisms unclear
- **Multilingual Support**: Language detection and translation capabilities undefined

#### 2. Streaming Infrastructure
- **Scalability**: Concurrent user limits and server scaling strategies not defined
- **Content Moderation**: Stream monitoring and inappropriate content handling unclear
- **Recording and Playback**: Video storage and retrieval mechanisms not specified

#### 3. Data Management
- **Data Retention**: Policies for user data storage and deletion not defined
- **Analytics**: User behavior tracking and privacy considerations unclear
- **Backup and Recovery**: Disaster recovery procedures and data backup strategies missing

### Recommendations for Resolution

#### Immediate Actions (0-4 weeks)
1. **Define complete API specification** with OpenAPI documentation
2. **Create detailed database schema** with migration scripts
3. **Implement basic authentication system** with JWT tokens
4. **Set up development environment** with proper tooling and CI/CD

#### Short-term Actions (1-3 months)
1. **Develop core backend services** with proper error handling
2. **Implement third-party integrations** with fallback mechanisms
3. **Create comprehensive testing framework** with automated testing
4. **Design missing UI screens** with user experience focus

#### Long-term Actions (3-6 months)
1. **Implement compliance framework** with legal consultation
2. **Optimize performance** with comprehensive monitoring
3. **Add advanced features** based on user feedback
4. **Conduct security audit** with third-party assessment

## Support and Contact

- **Documentation**: [https://docs.betwizz.co.za](https://docs.betwizz.co.za)
- **Support Email**: support@betwizz.co.za
- **Developer Portal**: [https://developers.betwizz.co.za](https://developers.betwizz.co.za)
- **Community Forum**: [https://community.betwizz.co.za](https://community.betwizz.co.za)

---

**Note**: This project is currently in active development. Many features are in various stages of implementation. Please refer to the project roadmap and issue tracker for the most up-to-date status information.
