import 'dart:async';


import 'package:animate_do/animate_do.dart';
import 'package:fashion_ecommerce_app/screens/auth_Screens/auth_screens.dart';
import 'package:flutter/material.dart';

class splash_screen extends StatefulWidget {
  splash_screen({super.key});

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {
  Future splash_services() async {
    await Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(context as BuildContext,
          MaterialPageRoute(builder: (context) => Login()));
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    splash_services();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: FadeInUp(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Image.asset('assets/team logo.png'),
            ),
          ),
        ),
      ),
    );
  }
}
