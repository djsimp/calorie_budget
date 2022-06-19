// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmBjcRIV2H9osRJK3bwjQpanX6E6SNtDc',
    appId: '1:69526502739:web:2ac56551887dc4593cf5a6',
    messagingSenderId: '69526502739',
    projectId: 'simpson-solutions',
    authDomain: 'simpson-solutions.firebaseapp.com',
    storageBucket: 'simpson-solutions.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClTEyndiyKLBsTFfqwDGDqh1NjawepRTQ',
    appId: '1:69526502739:android:01fbbc7bad2d5e6a3cf5a6',
    messagingSenderId: '69526502739',
    projectId: 'simpson-solutions',
    storageBucket: 'simpson-solutions.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjbNK-3kAEcLq6NELaYTc9k6PT-e4G6kc',
    appId: '1:69526502739:ios:fa8fc044b628bef63cf5a6',
    messagingSenderId: '69526502739',
    projectId: 'simpson-solutions',
    storageBucket: 'simpson-solutions.appspot.com',
    iosClientId: '69526502739-241tlhc20jpfid6ke9vtbhb73jmqrh7m.apps.googleusercontent.com',
    iosBundleId: 'com.example.calorieBudget',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjbNK-3kAEcLq6NELaYTc9k6PT-e4G6kc',
    appId: '1:69526502739:ios:fa8fc044b628bef63cf5a6',
    messagingSenderId: '69526502739',
    projectId: 'simpson-solutions',
    storageBucket: 'simpson-solutions.appspot.com',
    iosClientId: '69526502739-241tlhc20jpfid6ke9vtbhb73jmqrh7m.apps.googleusercontent.com',
    iosBundleId: 'com.example.calorieBudget',
  );
}
