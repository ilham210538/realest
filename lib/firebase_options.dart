// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyA-hX8C9ni6QRBbNqwlVYgwXpIv6U7rfEU',
    appId: '1:160573663308:web:b4bd7e3b2f520eca83ace9',
    messagingSenderId: '160573663308',
    projectId: 'cardatabase-21509',
    authDomain: 'cardatabase-21509.firebaseapp.com',
    storageBucket: 'cardatabase-21509.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOLUYbZn4XMJGYx-NnvMFoU8CjXKK4nr4',
    appId: '1:160573663308:android:f2a90dd65a5170b783ace9',
    messagingSenderId: '160573663308',
    projectId: 'cardatabase-21509',
    storageBucket: 'cardatabase-21509.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDA5OoWQOc6Gp0SjNQgD9hqrPAIWL3DV2o',
    appId: '1:160573663308:ios:78a443966685969983ace9',
    messagingSenderId: '160573663308',
    projectId: 'cardatabase-21509',
    storageBucket: 'cardatabase-21509.firebasestorage.app',
    iosBundleId: 'com.example.realest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDA5OoWQOc6Gp0SjNQgD9hqrPAIWL3DV2o',
    appId: '1:160573663308:ios:78a443966685969983ace9',
    messagingSenderId: '160573663308',
    projectId: 'cardatabase-21509',
    storageBucket: 'cardatabase-21509.firebasestorage.app',
    iosBundleId: 'com.example.realest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-hX8C9ni6QRBbNqwlVYgwXpIv6U7rfEU',
    appId: '1:160573663308:web:1caac466dc10996d83ace9',
    messagingSenderId: '160573663308',
    projectId: 'cardatabase-21509',
    authDomain: 'cardatabase-21509.firebaseapp.com',
    storageBucket: 'cardatabase-21509.firebasestorage.app',
  );
}
