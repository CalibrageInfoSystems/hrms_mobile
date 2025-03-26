import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import 'database/HRMSDatabaseHelper.dart';
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
  bool isLocationEnabled = false;
  bool _isRequestingPermission = false;
  HRMSDatabaseHelper? _hrmsDatabaseHelper;
  @override
  void initState() {
    super.initState();
  //  _initializeApp();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    checkLocationEnabled();
    _requestPermissions();

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

  Future<void> _initializeApp() async {
    try {
      _hrmsDatabaseHelper = HRMSDatabaseHelper();
      await _hrmsDatabaseHelper!.createDatabase();
    } catch (e) {
      print("Error initializing database: $e");
    }
  }

  Future<void> checkLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isLocationEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      // If location services are disabled, prompt the user to enable them
      await _promptUserToEnableLocation();
    }
  }

  Future<void> _promptUserToEnableLocation() async {
    bool locationEnabled = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Services Disabled"),
          content:
          const Text("Please enable location services to use this app."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );

    if (locationEnabled) {
      // Redirect the user to the device settings to enable location services
      await Geolocator.openLocationSettings();
    }
  }
  void _requestPermissions() async {
    if (_isRequestingPermission) {
      print("Permission request already in progress. Please wait.");
      return; // Exit if a request is already in progress
    }

    _isRequestingPermission = true; // Set the flag to true

    try {
      // Request storage permission
      Map<Permission, PermissionStatus> storageStatuses = await [
        Permission.storage,
        // Permission.manageExternalStorage,
        Permission.camera
      ].request();

      var storagePermission = storageStatuses[Permission.storage];
      // var manageExternalStoragePermission = storageStatuses[Permission.manageExternalStorage];

      var status = await Permission.location.request();
      if (status.isGranted) {
        var backgroundStatus = await Permission.locationAlways.status;
        if (backgroundStatus.isGranted) {
          print('Background location permission is granted');
        } else {
          print('Requesting background location permission');
          await Permission.locationAlways.request();
        }
      } else {
        print('Requesting foreground location permission');
        await Permission.location.request();
      }

      try {
        _initializeApp();
      } catch (e) {
        print('Error while getting master data: ${e.toString()}');
      }
      /*  if (storagePermission!.isGranted || manageExternalStoragePermission!.isGranted) {
        // Storage permissions granted, do something
        try {
          palm3FoilDatabase = await Palm3FoilDatabase.getInstance();
          await palm3FoilDatabase!.createDatabase();
        startMasterSync(); //todo
        } catch (e) {
          print('Error while getting master data: ${e.toString()}');
        }
      } else {
        // Storage permissions not granted, handle accordingly
        openAppSettings();
      } */
    } catch (e) {
      print("Error during permission request: $e");
    } finally {
      _isRequestingPermission = false; // Reset the flag after request
    }
  }
}
