import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  // ใช้ค่า demo ที่ทำงานได้ก่อน
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBdVl-cTICSwYKrjn-0sa_hNTXnb5wMtUA',
    appId: '1:448618578101:web:0b650370bb29e29cac3efc',
    messagingSenderId: '448618578101',
    projectId: 'easywork-demo-project',
    authDomain: 'easywork-demo-project.firebaseapp.com',
    storageBucket: 'easywork-demo-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdVl-cTICSwYKrjn-0sa_hNTXnb5wMtUA',
    appId: '1:448618578101:android:0b650370bb29e29cac3efc',
    messagingSenderId: '448618578101',
    projectId: 'easywork-demo-project',
    storageBucket: 'easywork-demo-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdVl-cTICSwYKrjn-0sa_hNTXnb5wMtUA',
    appId: '1:448618578101:ios:0b650370bb29e29cac3efc',
    messagingSenderId: '448618578101',
    projectId: 'easywork-demo-project',
    storageBucket: 'easywork-demo-project.appspot.com',
    iosBundleId: 'com.example.easyWork',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBdVl-cTICSwYKrjn-0sa_hNTXnb5wMtUA',
    appId: '1:448618578101:macos:0b650370bb29e29cac3efc',
    messagingSenderId: '448618578101',
    projectId: 'easywork-demo-project',
    storageBucket: 'easywork-demo-project.appspot.com',
    iosBundleId: 'com.example.easyWork',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBdVl-cTICSwYKrjn-0sa_hNTXnb5wMtUA',
    appId: '1:448618578101:windows:0b650370bb29e29cac3efc',
    messagingSenderId: '448618578101',
    projectId: 'easywork-demo-project',
    authDomain: 'easywork-demo-project.firebaseapp.com',
    storageBucket: 'easywork-demo-project.appspot.com',
  );
}