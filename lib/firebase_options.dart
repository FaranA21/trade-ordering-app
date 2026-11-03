// PLACEHOLDER. Replace it by running, in the project folder:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// flutterfire writes the real file with your Firebase project's keys.
// Until then the app only runs with --dart-define=USE_FIREBASE=false.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Firebase is not configured yet. Run "flutterfire configure", '
        'or start the app with --dart-define=USE_FIREBASE=false.',
      );
}
