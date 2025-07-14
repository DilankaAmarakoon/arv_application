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
    apiKey: 'AIzaSyD6araVWaxYVzEaRMUsd2vPPDu4Ts-Wtug',
    appId: '1:747706141861:web:db98a7293c1881a6ed114c',
    messagingSenderId: '747706141861',
    projectId: 'flutter-firebase-staff-noti',
    authDomain: 'flutter-firebase-staff-noti.firebaseapp.com',
    storageBucket: 'flutter-firebase-staff-noti.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4nJFXD_ckgoiyMU9PNWVX827KozUwTqs',
    appId: '1:747706141861:android:d39888d37f224ba0ed114c',
    messagingSenderId: '747706141861',
    projectId: 'flutter-firebase-staff-noti',
    storageBucket: 'flutter-firebase-staff-noti.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7Q4rEBELzqGjRQz5nRP28wqKPw6eweLI',
    appId: '1:747706141861:ios:15da6726a7ca1de9ed114c',
    messagingSenderId: '747706141861',
    projectId: 'flutter-firebase-staff-noti',
    storageBucket: 'flutter-firebase-staff-noti.firebasestorage.app',
    iosBundleId: 'com.example.staffMangement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7Q4rEBELzqGjRQz5nRP28wqKPw6eweLI',
    appId: '1:747706141861:ios:15da6726a7ca1de9ed114c',
    messagingSenderId: '747706141861',
    projectId: 'flutter-firebase-staff-noti',
    storageBucket: 'flutter-firebase-staff-noti.firebasestorage.app',
    iosBundleId: 'com.example.staffMangement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6araVWaxYVzEaRMUsd2vPPDu4Ts-Wtug',
    appId: '1:747706141861:web:4d5f4e8f2f065a71ed114c',
    messagingSenderId: '747706141861',
    projectId: 'flutter-firebase-staff-noti',
    authDomain: 'flutter-firebase-staff-noti.firebaseapp.com',
    storageBucket: 'flutter-firebase-staff-noti.firebasestorage.app',
  );
}
