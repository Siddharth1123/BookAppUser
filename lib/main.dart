import 'package:fashion_ecommerce_app/firebase_options.dart';
import 'package:fashion_ecommerce_app/screens/auth_Screens/auth_screens.dart';
import 'package:fashion_ecommerce_app/screens/splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      home: splash_screen(),
    ),
  );
}
