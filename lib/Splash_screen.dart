import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/home_screen.dart';

import 'login_screen.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late bool isLogin;
  late bool welcome;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        isLogin = await SharedPreferencesHelper.getBool(Constants.IS_LOGIN);
        welcome = await SharedPreferencesHelper.getBool(Constants.WELCOME);
        print('isLogin:$isLogin');
        print('welcome:$welcome');
        // Add any additional logic or navigation based on the retrieved values

        // Example: Navigate to the appropriate screen
        if (isLogin) {
          navigateToHome();
          // User is logged in
          // Navigate to the home screen
        } else {
          // User is not logged in
          // Check the 'welcome' value and navigate accordingly

          navigateToLogin();
          // Navigate to the welcome screen
        }
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => home_screen()),
    );
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // builder: (context) => LoginPage(),
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  // Future<void> loadData() async {
  //   isLogin = await SharedPreferencesHelper.getBool(Constants.IS_LOGIN);
  //   welcome = await SharedPreferencesHelper.getBool(Constants.WELCOME);
  //
  //   // Add any additional logic or navigation based on the retrieved values
  //
  //   // Example: Navigate to the appropriate screen
  //   if (isLogin) {
  //     //   navigateToHome();
  //     // User is logged in
  //     // Navigate to the home screen
  //   } else {
  //     // User is not logged in
  //     // Check the 'welcome' value and navigate accordingly
  //     if (welcome) {
  //       navigateToLogin();
  //       // Navigate to the welcome screen
  //     } else {
  //       // Navigate to the login or onboarding screen
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_layer_2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget? child) {
              return Transform.scale(
                scale: _animation.value,
                child: Image.asset(
                  'assets/hrms_logo.png',
                  width: 200,
                  height: 200,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
