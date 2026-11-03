// Firebase settings for project trade-ordering-app-nx.
// These keys are public client identifiers, safe to commit. Access is
// controlled by firestore.rules and Firebase Auth, not by hiding these.
//
// To regenerate (e.g. after adding iOS): flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is set up for web and Android only. '
          'Run flutterfire configure to add other platforms.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB6HBHLgPjSk2TOoosUQTYcEVu2Djv15Rw',
    appId: '1:56295151478:web:3ab32aad57ae982fd10c57',
    messagingSenderId: '56295151478',
    projectId: 'trade-ordering-app-nx',
    authDomain: 'trade-ordering-app-nx.firebaseapp.com',
    storageBucket: 'trade-ordering-app-nx.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjHPM8LZs4X_ikAfaqbkkqRELdXpkftRY',
    appId: '1:56295151478:android:5798dbdbbfa5128bd10c57',
    messagingSenderId: '56295151478',
    projectId: 'trade-ordering-app-nx',
    storageBucket: 'trade-ordering-app-nx.firebasestorage.app',
  );
}
