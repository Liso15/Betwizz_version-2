import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase web-specific configuration and initialization
class FirebaseWeb {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseAnalytics? _analytics;
  
  static const String _tag = 'FirebaseWeb';
  
  /// Initialize Firebase for web platform
  static Future<void> initialize() async {
    if (!kIsWeb) {
      if (kDebugMode) {
        print('$_tag: Not running on web, skipping Firebase initialization');
      }
      return;
    }
    
    try {
      // Initialize Firebase app
      _app = await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxx", // Replace with actual key
          authDomain: "betwizz-prod.firebaseapp.com",
          projectId: "betwizz-prod",
          storageBucket: "betwizz-prod.appspot.com",
          messagingSenderId: "123456789012",
          appId: "1:123456789012:web:abcdef123456789012345678",
          measurementId: "G-XXXXXXXXXX",
        ),
      );
      
      // Initialize services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _analytics = FirebaseAnalytics.instance;
      
      // Configure Firestore for web
      await _configureFirestore();
      
      // Configure Analytics
      await _configureAnalytics();
      
      if (kDebugMode) {
        print('$_tag: Firebase initialized successfully');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Firebase initialization failed: $e');
      }
      rethrow;
    }
  }
  
  /// Configure Firestore settings for web
  static Future<void> _configureFirestore() async {
    if (_firestore == null) return;
    
    try {
      // Enable offline persistence for web
      await _firestore!.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      
      // Configure cache settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      if (kDebugMode) {
        print('$_tag: Firestore configured with offline persistence');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Firestore configuration warning: $e');
      }
    }
  }
  
  /// Configure Analytics for web
  static Future<void> _configureAnalytics() async {
    if (_analytics == null) return;
    
    try {
      // Set analytics collection enabled
      await _analytics!.setAnalyticsCollectionEnabled(true);
      
      // Log startup event with environment parameters
      await _analytics!.logEvent(
        name: 'startup',
        parameters: {
          'platform': 'web',
          'app_version': '1.0.0',
          'environment': kDebugMode ? 'development' : 'production',
        },
      );
      
      if (kDebugMode) {
        print('$_tag: Analytics configured');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Analytics configuration failed: $e');
      }
    }
  }
  
  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw StateError('Firebase not initialized. Call FirebaseWeb.initialize() first.');
    }
    return _auth!;
  }
  
  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw StateError('Firebase not initialized. Call FirebaseWeb.initialize() first.');
    }
    return _firestore!;
  }
  
  /// Get Analytics instance
  static FirebaseAnalytics get analytics {
    if (_analytics == null) {
      throw StateError('Firebase not initialized. Call FirebaseWeb.initialize() first.');
    }
    return _analytics!;
  }
  
  /// Check if user is authenticated
  static bool get isAuthenticated => _auth?.currentUser != null;
  
  /// Get current user
  static User? get currentUser => _auth?.currentUser;
  
  /// Sign in anonymously for betting features
  static Future<UserCredential> signInAnonymously() async {
    try {
      final credential = await auth.signInAnonymously();
      
      if (kDebugMode) {
        print('$_tag: Anonymous sign-in successful');
      }
      
      // Track sign-in event
      await analytics.logEvent(
        name: 'login',
        parameters: {
          'method': 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      return credential;
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Anonymous sign-in failed: $e');
      }
      rethrow;
    }
  }
  
  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      
      if (kDebugMode) {
        print('$_tag: User signed out');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Sign out failed: $e');
      }
      rethrow;
    }
  }
  
  /// Log custom analytics event
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
      
      if (kDebugMode) {
        print('$_tag: Event logged: $name');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Event logging failed: $e');
      }
    }
  }
  
  /// Get user document from Firestore
  static DocumentReference getUserDocument(String userId) {
    return firestore.collection('users').doc(userId);
  }
  
  /// Get channels collection
  static CollectionReference get channelsCollection {
    return firestore.collection('channels');
  }
  
  /// Get bets collection
  static CollectionReference get betsCollection {
    return firestore.collection('bets');
  }
  
  /// Get chat messages collection
  static CollectionReference get chatMessagesCollection {
    return firestore.collection('chat_messages');
  }
  
  /// Initialize user data on first sign-in
  static Future<void> initializeUserData(String userId) async {
    try {
      final userDoc = getUserDocument(userId);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        await userDoc.set({
          'created_at': FieldValue.serverTimestamp(),
          'last_active': FieldValue.serverTimestamp(),
          'platform': 'web',
          'version': '1.0.0',
          'preferences': {
            'theme': 'system',
            'notifications': true,
            'sound_effects': true,
          },
        });
        
        if (kDebugMode) {
          print('$_tag: User data initialized for $userId');
        }
      } else {
        // Update last active timestamp
        await userDoc.update({
          'last_active': FieldValue.serverTimestamp(),
        });
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: User data initialization failed: $e');
      }
    }
  }
  
  /// Update user activity
  static Future<void> updateUserActivity() async {
    if (!isAuthenticated) return;
    
    try {
      final userId = currentUser!.uid;
      await getUserDocument(userId).update({
        'last_active': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: User activity update failed: $e');
      }
    }
  }
  
  /// Clean up resources
  static Future<void> dispose() async {
    try {
      await _analytics?.setAnalyticsCollectionEnabled(false);
      
      if (kDebugMode) {
        print('$_tag: Firebase resources cleaned up');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Cleanup failed: $e');
      }
    }
  }
}

/// Firebase configuration options for different environments
class FirebaseConfig {
  static const FirebaseOptions development = FirebaseOptions(
    apiKey: "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    authDomain: "betwizz-dev.firebaseapp.com",
    projectId: "betwizz-dev",
    storageBucket: "betwizz-dev.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:dev123456789012345678",
    measurementId: "G-DEVXXXXXXX",
  );
  
  static const FirebaseOptions production = FirebaseOptions(
    apiKey: "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    authDomain: "betwizz-prod.firebaseapp.com",
    projectId: "betwizz-prod",
    storageBucket: "betwizz-prod.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:prod123456789012345678",
    measurementId: "G-PRODXXXXXXX",
  );
  
  /// Get configuration based on environment
  static FirebaseOptions get current {
    return kDebugMode ? development : production;
  }
}
