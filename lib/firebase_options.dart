import 'package:firebase_core/firebase_core.dart'
  show FirebaseOptions;
import 'package:flutter/foundation.dart'
  show defaultTargetPlatform,
       TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported '
          'for this platform.',
        );
    }
  }

  static const FirebaseOptions android =
    FirebaseOptions(
      apiKey: 'AIzaSyCJwN3pGhzYABadcPuJdVi0ZgalCX1NyMk',
      appId: '1:254265809328:android:'
        'f8db7a5b11539de0d29e75',
      messagingSenderId: '254265809328',
      projectId: 'rsc-project-500321',
      storageBucket:
        'rsc-project-500321.firebasestorage.app',
    );
}
