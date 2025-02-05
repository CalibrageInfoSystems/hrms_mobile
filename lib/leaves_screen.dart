import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:flutter_month_picker/flutter_month_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/holiday_model.dart';
import 'package:hrms/leave_model.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/test_apply_leave.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Commonutils.dart';
import 'Constants.dart';
import 'Model Class/HolidayResponse.dart';
import 'Model Class/LookupDetail.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'apply_leave.dart';
import 'home_screen.dart';
import 'main.dart';

class leaves_screen extends StatefulWidget {
  @override
  _leaves_screen_screenState createState() => _leaves_screen_screenState();
}

class _leaves_screen_screenState extends State<leaves_screen> {
  int currentTab = 0;
  DateTime _selectedMonthPL = DateTime.now();
  DateTime _selectedMonthCL = DateTime.now();
  DateTime _selectedMonthlwp = DateTime.now();
  double usedPrivilegeLeavesInYear = 0.0;
  double allottedPrivilegeLeaves = 0.0;
  double? noOfleavesinPLs;
  double? noOfleavesinCLs;
  double noOfleavesinLWP = 0.0;
  double usedCasualLeavesInMonth = 0.0;
  String EmployeName = '';
  int employeid = 0;
  double allottedPriviegeLeaves = 0.0;
  double usedCasualLeavesInYear = 0.0;
  double allotcausalleaves = 0.0;
  double availablepls = 0.0;
  double availablecls = 0.0;
  String accessToken = '';
  List<LookupDetail> lookupDetails = [];
  String? logintime;
  int DayWorkStatus = 0;
  bool _isLoading = true;
  bool isLoading = true;
  List<Holiday_Model> holidaylist = [];
  bool ismatchedlogin = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        loadAccessToken();
        _loademployeleaves();
        getDayWorkStatus();
        getLoginTime();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  Future<String?> getLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logintime = prefs.getString('loginTime') ?? 'Unknown';
    print('Login Time: $logintime');
    login(logintime!);
    return logintime;
  }

  Future<void> deleteLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginTime');
  }

  void _showtimeoutdialog(BuildContext context) {
    showDialog(
      // barrierDismissible: false,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                //mainAxisAlignment: MainAxisAlignment.,
                children: [
                  Container(
                    height: 50.0,
                    width: 60.0,
                    child: SvgPicture.asset(
                      'assets/cislogo-new.svg',
                      height: 120.0,
                      width: 55.0,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  Text(
                    "Session Time Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    "Please Login Again",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    deleteLoginTime();
                    onConfirmLogout(context);
                    // Navigator.of(context).pop();
                  },
                  child: Text(
                    'Ok',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void onConfirmLogout(BuildContext context) {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  void login(String logintime) {
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime!);
    DateTime loginTime = formattedlogintime /* Replace with your login time */;

    // Calculate the time difference
    Duration timeDifference = currentTime.difference(loginTime);

    // Check if the time difference is less than or equal to 1 hour (3600 seconds)
    if (timeDifference.inSeconds <= 3600) {
      // Login is within the allowed window

      setState(() {
        ismatchedlogin = false;
      });
      print("Login is within 1 hour of current time.");
    } else {
      // Login is outside the allowed window
      // _showtimeoutdialog(context);
      setState(() {
        ismatchedlogin = true;
      });
      print("Login is more than 1 hour from current time.");
    }
  }

  void _loademployeleaves() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final emplyeid = loadedData["employeeId"];
      final usedprivilegeleavesinyear = loadedData['usedPrivilegeLeavesInYear'];
      final allotedprivilegeleaves = loadedData['allottedPrivilegeLeaves'];
      final usedcausalleavesinmonth = loadedData['usedCasualLeavesInMonth'];
      final usedPrivilegeLeavesInMonth =
          loadedData['usedPrivilegeLeavesInMonth'];
      final usedcasualleavesinyear = loadedData['usedCasualLeavesInYear'];
      final usdl = loadedData['allottedCasualLeaves'];
      // final mobilenum = loadedData['mobileNumber'];
      // final bloodgroup = loadedData['bloodGroup'];
      print('allottedCasualLeaves: $usdl');

      print('usedprivilegeleavesinyear: $usedprivilegeleavesinyear');
      print('allotedprivilegeleaves: $allotedprivilegeleaves');
      print('usedcausalleavesinmonth: $usedcausalleavesinmonth');
      //  print('allotedpls: $allotedpls');
      print('usedcasualleavesinyear: $usedcasualleavesinyear');
      // print('mobilenum: $mobilenum');
      // print('bloodgroup: $bloodgroup');

      setState(() {
        employeid = emplyeid;
        print('employeid: $employeid');
        allotcausalleaves = usdl.toDouble();
        EmployeName = employeeName;
        usedPrivilegeLeavesInYear = usedprivilegeleavesinyear.toDouble();
        allottedPrivilegeLeaves = allotedprivilegeleaves.toDouble();
        usedCasualLeavesInMonth = usedcausalleavesinmonth.toDouble();
        usedCasualLeavesInYear = usedcasualleavesinyear.toDouble();
        // allottedPriviegeLeaves = allotedpls;
        //  usedCasualLeavesInYear = usedcasualleavesinyear;
        availablepls = allottedPrivilegeLeaves.toDouble() -
            usedPrivilegeLeavesInYear.toDouble();

        print("Available Privilege Leaves: $availablepls");

        availablecls =
            allotcausalleaves.toDouble() - usedCasualLeavesInYear.toDouble();

        print('Available Causal Leaves: $availablecls');
        DateTime now = DateTime.now();
        // Extract the current month from the DateTime object
        int currentMonth = now.month;
        // Print the current month
        print('Current month: $currentMonth');
        int currentYear = now.year;
        montlyleavesPl(currentMonth, currentYear);
        montlyleavesCL(currentMonth, currentYear);
        montlyleaveslwp(currentMonth);
        //  print('availablecls: $availablecls');
      });
    }
    // availablepls = allottedPrivilegeLeaves - usedPrivilegeLeavesInYear;
    // availablecls = allotcausalleaves - usedCasualLeavesInYear;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 3.5;
    if (ismatchedlogin) {
      Future.microtask(() => _showtimeoutdialog(context));
    }
    return WillPopScope(
        onWillPop: () async {
          // Handle back button press here
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (context) => home_screen()),
          // ); //
          // You can add any custom logic before closing the app
          return true; // Return true to allow back button press and close the app
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Stack(
              children: [
                Image.asset(
                  'assets/background_layer_2.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                // SingleChildScrollView(
                //   child:
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Padding(
                              //   padding:
                              //       EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
                              //   child: Container(
                              //     width: double.infinity,
                              //     decoration: BoxDecoration(
                              //       color: Color(0xFFf15f22),
                              //       borderRadius: BorderRadius.circular(6.0),
                              //     ),
                              //     child:
                              // ElevatedButton(
                              //   onPressed: () async {
                              //     Navigator.of(context).pushReplacement(
                              //       MaterialPageRoute(
                              //         builder: (context) => apply_leave(
                              //           buttonName: "test", // Example button name
                              //           lookupDetailId: -3, // Pass the lookupDetailId
                              //         ),
                              //       ),
                              //     );
                              //   },
                              //   child: Text(
                              //     'Apply',
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 16,
                              //       fontFamily: 'hind_semibold',
                              //     ),
                              //   ),
                              //   style: ElevatedButton.styleFrom(
                              //     primary: Colors.transparent,
                              //     elevation: 0,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(4.0),
                              //     ),
                              //   ),
                              // ),
                              //   ),
                              //  ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  DateTime currentTime = DateTime.now();
                                  DateTime formattedlogintime =
                                      DateTime.parse(logintime!);
                                  DateTime loginTime =
                                      formattedlogintime /* Replace with your login time */;

                                  // Calculate the time difference
                                  Duration timeDifference =
                                      currentTime.difference(loginTime);

                                  // Check if the time difference is less than or equal to 1 hour (3600 seconds)
                                  if (timeDifference.inSeconds <= 3600) {
                                    // Login is within the allowed window
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return
                                              /* apply_leave(
                                            buttonName:
                                                "test", // Example button name
                                            lookupDetailId: -3,
                                            employename:
                                                '${EmployeName}', // Pass the lookupDetailId 
                                          ); */
                                              const TestApplyLeave();
                                        },
                                      ),
                                    );

                                    print(
                                        "Login is within 1 hour of current time.");
                                  } else {
                                    // Login is outside the allowed window
                                    _showtimeoutdialog(context);
                                    print(
                                        "Login is more than 1 hour from current time.");
                                  }

                                  // Handle the apply button click event
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFf15f22),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                                child: Text(
                                  "Apply",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(6.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF746cdf),
                                      Color(0xFF81aed5),
                                    ], // Adjust the colors as needed
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 19.0),
                                      // Adjust the padding as needed
                                      child: Text(
                                        "PL's",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Calibri'),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$usedPrivilegeLeavesInYear",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Calibri'),
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Text(
                                          "/",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Text(
                                          "$allottedPrivilegeLeaves",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Calibri'),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.0),
                                  // Adjust the radius as needed
                                  border: Border.all(
                                    color: Color(0xFF7F7FE1),
                                    // Specify the border color
                                    width:
                                        2.0, // Adjust the border width as needed
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 3.0),
                                      // Adjust the padding as needed
                                      child: Text(
                                        "Monthly PL's",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFf15f22),
                                            fontFamily: 'Calibri'),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: width / 6,
                                          height: 30.0,
                                          child: IconButton(
                                            padding:
                                                EdgeInsets.only(right: 0.0),
                                            onPressed: () {
                                              _selectPreviousMonthPL();
                                            },
                                            iconSize: 20.0,
                                            icon: Icon(
                                              Icons.arrow_left,
                                              color: Color(0xFFf15f22),
                                            ),
                                          ),
                                        ),
                                        // Container(
                                        //   width: width / 1.6, // Set your desired width here
                                        //   child: Text(
                                        //     DateFormat('MMMM').format(_selectedMonthPL),
                                        //     style: TextStyle(
                                        //       fontSize: 14,
                                        //       fontWeight: FontWeight.w600,
                                        //       fontFamily: 'Calibri',
                                        //       color: Color(0xFF746cdf),
                                        //     ),
                                        //     textAlign: TextAlign.center,
                                        //   ),
                                        // ),
                                        GestureDetector(
                                          onTap: () async {
                                            final selected =
                                                await showMonthPicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (selected != null) {
                                              // Print the selected month and year
                                              print(
                                                  'Selected month: ${selected.month}, year: ${selected.year}');

                                              // Optionally, update the UI with the selected month and year
                                              setState(() {
                                                _selectedMonthPL = selected;
                                                montlyleavesPl(selected.month,
                                                    selected.year);
                                              });
                                            }
                                            // showmonthpickerforpl();
                                          },
                                          child: Container(
                                            width: width / 1.6,
                                            child: Text(
                                              '${_selectedMonthPL.month}/${_selectedMonthPL.year}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Calibri',
                                                  color: Color(0xFF746cdf)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          width: width / 6,
                                          height: 30.0,
                                          child: IconButton(
                                              padding: EdgeInsets.only(left: 0),
                                              onPressed: () {
                                                _selectNextMonthPL();
                                              },
                                              iconSize: 20.0,
                                              icon: Icon(
                                                Icons.arrow_right,
                                                color: Color(0xFFf15f22),
                                              ),
                                              alignment: Alignment.center),
                                        ),
                                      ],
                                    ),
                                    // Padding(
                                    //   padding: EdgeInsets.only(top: 1.0),
                                    //   // Adjust the padding as needed
                                    //   child: Text(
                                    //     "$noOfleavesinPLs",
                                    //     style: TextStyle(
                                    //       fontSize: 18,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Calibri',
                                    //       color: Color(0xFFf15f22),
                                    //     ),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.0),
                                      // Adjust the padding as needed
                                      child: isLoading
                                          ? Container(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator
                                                  .adaptive(),
                                            ) // Show circular loading indicator
                                          : Text(
                                              "${noOfleavesinPLs ?? 0.0}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri',
                                                color: Color(0xFFf15f22),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.0),
                                  // Adjust the radius as needed
                                  border: Border.all(
                                    color: Color(0xFF7F7FE1),
                                    // Specify the border color
                                    width:
                                        2.0, // Adjust the border width as needed
                                  ),
                                ),
                                child: Column(children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 3.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "Available PL's",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Calibri',
                                        color: Color(0xFFf15f22),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Your click listener logic here
                                        print("Container Clicked!");

                                        //  printLookupDetailId('PL');

                                        DateTime currentTime = DateTime.now();
                                        DateTime formattedlogintime =
                                            DateTime.parse(logintime!);
                                        // Replace this with your actual login time
                                        DateTime loginTime =
                                            formattedlogintime /* Replace with your login time */;

                                        // Calculate the time difference
                                        Duration timeDifference =
                                            currentTime.difference(loginTime);

                                        // Check if the time difference is less than or equal to 1 hour (3600 seconds)
                                        if (timeDifference.inSeconds <= 3600) {
                                          // Login is within the allowed window
                                          if (availablepls <= 0) {
                                            // Show a toast message
                                            Commonutils
                                                .showCustomToastMessageLong(
                                                    'No PLs Available!',
                                                    context,
                                                    1,
                                                    3);
                                          } else {
                                            printLookupDetailId('PL');
                                          }
                                          print(
                                              "Login is within 1 hour of current time.");
                                        } else {
                                          // Login is outside the allowed window
                                          _showtimeoutdialog(context);
                                          print(
                                              "Login is more than 1 hour from current time.");
                                        }

                                        // Navigator.of(context).pushReplacement(
                                        //   MaterialPageRoute(
                                        //       builder: (context) => apply_leave()),
                                        // );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "$availablepls",
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Calibri',
                                              color: Color(0xFFf15f22),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   height: 3.0,
                                          // ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(
                                              "Click Here to Apply",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri',
                                                color: Color(0xFF7F7FE1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ]),
                                // Other child widgets or content can be added here
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: 95,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF746cdf),
                                      Color(0xFF81aed5),
                                    ], // Adjust the colors as needed
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 19.0),
                                      // Adjust the padding as needed
                                      child: Text(
                                        "CL's",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Calibri',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$usedCasualLeavesInYear",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Text(
                                          "/",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 2.0,
                                        ),
                                        Text(
                                          "$allotcausalleaves",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.0),
                                  // Adjust the radius as needed
                                  border: Border.all(
                                    color: Color(0xFF7F7FE1),
                                    // Specify the border color
                                    width:
                                        2.0, // Adjust the border width as needed
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 3.0),
                                      // Adjust the padding as needed
                                      child: Text(
                                        "Monthly CL's",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Calibri',
                                          color: Color(0xFFf15f22),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: width / 6,
                                          height: 30.0,
                                          child: IconButton(
                                            padding:
                                                EdgeInsets.only(right: 0.0),
                                            onPressed: () {
                                              _selectPreviousMonthCL();
                                              //       ///_calender();
                                            },
                                            iconSize: 20.0,
                                            icon: Icon(
                                              Icons.arrow_left,
                                              color: Color(0xFFf15f22),
                                            ),
                                          ),
                                        ),
                                        // Container(
                                        //   width: width / 1.6, // Set your desired width here
                                        //   child: Text(
                                        //     DateFormat('MMMM').format(_selectedMonthCL),
                                        //     style: TextStyle(
                                        //       fontSize: 14,
                                        //       fontWeight: FontWeight.w600,
                                        //       fontFamily: 'Calibri',
                                        //       color: Color(0xFF746cdf),
                                        //     ),
                                        //     textAlign: TextAlign.center,
                                        //   ),
                                        // ),
                                        GestureDetector(
                                          onTap: () async {
                                            final selected =
                                                await showMonthPicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (selected != null) {
                                              // Print the selected month and year
                                              print(
                                                  'Selected month: ${selected.month}, year: ${selected.year}');

                                              // Optionally, update the UI with the selected month and year
                                              setState(() {
                                                _selectedMonthCL = selected;
                                                montlyleavesCL(selected.month,
                                                    selected.year);
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: width / 1.6,
                                            child: Text(
                                              '${_selectedMonthCL.month}/${_selectedMonthCL.year}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Calibri',
                                                  color: Color(0xFF746cdf)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          width: width / 6,
                                          height: 30.0,
                                          child: IconButton(
                                              padding: EdgeInsets.only(left: 0),
                                              onPressed: () {
                                                _selectNextMonthCL();
                                              },
                                              iconSize: 20.0,
                                              icon: Icon(
                                                Icons.arrow_right,
                                                color: Color(0xFFf15f22),
                                              ),
                                              alignment: Alignment.center),
                                        ),
                                      ],
                                    ),
                                    // Padding(
                                    //   padding: EdgeInsets.only(top: 1.0),
                                    //   // Adjust the padding as needed
                                    //   child: Text(
                                    //     "$noOfleavesinCLs",
                                    //     style: TextStyle(
                                    //       fontSize: 18,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Calibri',
                                    //       color: Color(0xFFf15f22),
                                    //     ),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 1.0),
                                      // Adjust the padding as needed
                                      child: _isLoading
                                          ? Container(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator
                                                  .adaptive(),
                                            ) // Show circular loading indicator
                                          : Text(
                                              "${noOfleavesinCLs ?? 0.0}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri',
                                                color: Color(0xFFf15f22),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),

                                // Other child widgets or content can be added here
                              ),

                              Container(
                                width: MediaQuery.of(context).size.width / 3.5,
                                height: 95,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: Color(0xFF7F7FE1),
                                    width: 2.0,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    DateTime currentTime = DateTime.now();
                                    DateTime formattedlogintime =
                                        DateTime.parse(logintime!);
                                    // Replace this with your actual login time
                                    DateTime loginTime =
                                        formattedlogintime /* Replace with your login time */;

                                    // Calculate the time difference
                                    Duration timeDifference =
                                        currentTime.difference(loginTime);

                                    // Check if the time difference is less than or equal to 1 hour (3600 seconds)
                                    if (timeDifference.inSeconds <= 3600) {
                                      // Login is within the allowed window
                                      if (availablecls <= 0) {
                                        // Show a toast message
                                        Commonutils.showCustomToastMessageLong(
                                            'No CLs Available!', context, 1, 3);
                                      } else {
                                        printLookupDetailId('CL');
                                      }
                                      print(
                                          "Login is within 1 hour of current time.");
                                    } else {
                                      // Login is outside the allowed window
                                      _showtimeoutdialog(context);
                                      print(
                                          "Login is more than 1 hour from current time.");
                                    }
                                    //  printLookupDetailId('CL');
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 3.0),
                                        child: Text(
                                          "Available CL's",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                            color: Color(0xFFf15f22),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "$availablecls",
                                              style: TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri',
                                                color: Color(0xFFf15f22),
                                              ),
                                            ),
                                            // SizedBox(
                                            //   height: 3.0,
                                            // ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                "Click Here to Apply",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Calibri',
                                                  color: Color(0xFF7F7FE1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //
                            ],
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                        ],
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //
                      //   padding: EdgeInsets.all(10.0),
                      //   color: Color(0xFFf15f22), // Set background color to orange
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Padding(
                      //         padding: EdgeInsets.only(left: 4.0),
                      //         child: Column(
                      //           children: [
                      //             Text(
                      //               'Holiday Title',
                      //               style: TextStyle(color: Colors.white), // Set text color to white
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: EdgeInsets.only(right: 8.0),
                      //         child: Column(
                      //           children: [
                      //             Text(
                      //               'From Date',
                      //               style: TextStyle(color: Colors.white), // Set text color to white
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: EdgeInsets.only(right: 25.0),
                      //         child: Column(
                      //           children: [
                      //             Text(
                      //               'To Date',
                      //               style: TextStyle(color: Colors.white), // Set text color to white
                      //             ),
                      //           ],
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // FutureBuilder(
                      //   future: fetchHolidayList(),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState == ConnectionState.waiting) {
                      //       return Container(
                      //           padding: EdgeInsets.all(25.0),
                      //           child: Center(
                      //             child: CircularProgressIndicator(),
                      //           ));
                      //     } else if (snapshot.hasError) {
                      //       return Container(
                      //           padding: EdgeInsets.all(25.0),
                      //           child: Center(
                      //             child: Text('Please Login to Check Holidays List'),
                      //           ));
                      //     } else if (snapshot.hasData) {
                      //       List<dynamic> holidays = snapshot.data as List<dynamic>;
                      //       if (holidays.isEmpty) {
                      //         return Center(
                      //           child: Text('No holidays'),
                      //         );
                      //       } else {
                      //         return
                      // Expanded(
                      //     //   width: MediaQuery.of(context).size.width,
                      //     //   height: MediaQuery.of(context).size.height,
                      //     child: ListView.builder(
                      //   itemCount: holidaylist.length,
                      //   scrollDirection: Axis.vertical,
                      //   shrinkWrap: true,
                      //   physics: ClampingScrollPhysics(),
                      //   itemBuilder: (context, index) {
                      //     Holiday_Model holiday = holidaylist[index];
                      //     if (holiday.isActive == true) {
                      //       String? formattedFromDate;
                      //       String? formattedToDate;
                      //
                      //       if (holiday.fromDate != null) {
                      //         formattedFromDate = DateFormat('dd MMM yyyy').format(DateTime.parse(holiday.fromDate.toString()));
                      //         print('formattedFromDate$formattedFromDate');
                      //       }
                      //
                      //       // if (holiday.toDate.toString() == null) {
                      //       //   formattedToDate = DateFormat('dd MMM yyyy').format(DateTime.parse(holiday.toDate.toString()));
                      //       //   print('formattedToDate$formattedToDate');
                      //       // } else {
                      //       //   formattedToDate = formattedFromDate;
                      //       // }
                      //
                      //       if (holiday.toDate == null) {
                      //         formattedToDate = formattedFromDate;
                      //       } else {
                      //         formattedToDate = DateFormat('dd MMM yyyy').format(DateTime.parse(holiday.toDate.toString()));
                      //         print('formattedToDate: $formattedToDate');
                      //       }
                      //
                      //       return Scrollbar(
                      //           child: Column(
                      //         children: [
                      //           Container(
                      //             // margin: EdgeInsets.symmetric(vertical: 10.0),
                      //             //width: MediaQuery.of(context).size.width,
                      //             //   height: MediaQuery.of(context).size.height,
                      //             color: Colors.white,
                      //             padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Column(
                      //                   children: [
                      //                     //  Text('Holiday Title'),
                      //                     Container(
                      //                       width: 100,
                      //                       child: Text(
                      //                         holiday.title,
                      //                         softWrap: true,
                      //                       ),
                      //                     )
                      //                   ],
                      //                 ),
                      //                 Column(
                      //                   mainAxisAlignment: MainAxisAlignment.center,
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: [
                      //                     //  Text('From Date'),
                      //                     Container(
                      //                         width: 90,
                      //                         child: Text(
                      //                           formattedFromDate!,
                      //                           textAlign: TextAlign.center,
                      //                         ))
                      //                   ],
                      //                 ),
                      //                 Column(
                      //                   mainAxisAlignment: MainAxisAlignment.center,
                      //                   crossAxisAlignment: CrossAxisAlignment.center,
                      //                   children: [
                      //                     //  Text('From Date'),
                      //                     Container(
                      //                         width: 90,
                      //                         child: Text(
                      //                           formattedToDate!,
                      //                           textAlign: TextAlign.center,
                      //                         ))
                      //                   ],
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           Container(
                      //             color: Colors.grey.shade300,
                      //             width: MediaQuery.of(context).size.width,
                      //             height: 1.0,
                      //           )
                      //         ],
                      //       ));
                      //     } else {
                      //       return Container(); // Return empty container for inactive holidays
                      //     }
                      //   },
                      // ))
                      //       }
                      //     } else {
                      //       return Center(
                      //         child: Text('No data available'),
                      //       );
                      //     }
                      //   },
                      // ),
                    ],
                  ),
                ),
                // ),
              ],
            ),
          ),
        ));
  }

  // Future<List<dynamic>> fetchHolidayList() async {
  //   try {
  //     int currentYear = DateTime.now().year;
  //     final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': '$accessToken',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Response Body: ${response.body}');
  //
  //       try {
  //         List<dynamic> holidayList = json.decode(response.body);
  //         return holidayList;
  //       } on FormatException catch (e) {
  //         print('Error decoding JSON: $e');
  //         return []; // Return empty list on decoding error (adjust as needed)
  //       }
  //     } else {
  //       throw Exception('Failed to load holidays: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     rethrow; // Rethrow the caught exception
  //   }
  // }

  // Future<List<Holiday_Model>> fetchHolidayList(String Accesstoken) async {
  //   try {
  //     int currentYear = DateTime.now().year;
  //
  //     final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //     print('fetcholiday:$url');
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       dynamic jsonData = json.decode(response.body);
  //       print('jsonData$jsonData');
  //       if (jsonData is List) {
  //         List<Holiday_Model> holidayList = jsonData.map((json) => Holiday_Model.fromJson(json)).toList();
  //         print('holidayList$holidayList');
  //         setState(() {
  //           holidaylist = holidayList;
  //           print('holidaylist${holidaylist.length}');
  //         });
  //
  //         return holidayList;
  //       }
  //       // else if (jsonData is Map<String, dynamic>) {
  //       //   // Handle single object response
  //       //   Holiday_Model holiday = Holiday_Model.fromJson(jsonData);
  //       //   List<Holiday_Model> holidayList = [holiday];
  //       //
  //       //   setState(() {
  //       //     holidaylist = holidayList;
  //       //     print('holidaylist${holidaylist.length}');
  //       //   });
  //       //
  //       //   return holidayList;
  //       // } else {
  //       //   throw FormatException('Invalid data format in response');
  //       // }
  //       return [];
  //     } else {
  //       throw Exception('Failed to load holidays: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error_inholidayslist: $error');
  //     return []; // Return empty list in case of an error
  //   }
  // }
  // Future<List<Holiday_Model>> fetchHolidayList(String accessToken) async {
  //   try {
  //     int currentYear = DateTime.now().year;
  //
  //     final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //     print('fetchHoliday: $url');
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonData = jsonDecode(response.body);
  //       List<Holiday_Model> holidayList = jsonData.map((holidayJson) => Holiday_Model.fromJson(holidayJson)).toList();
  //       setState(() {
  //         holidaylist = holidayList;
  //       });
  //       print('holidays${holidaylist.length}');
  //       return holidayList;
  //     } else {
  //       throw Exception('Failed to load holidays: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error in holiday list: $error');
  //     return []; // Return empty list in case of an error
  //   }
  // }

// Function to check if a string is valid JSON

  // Future<List<HolidayResponse>> fetchHolidayList() async {
  //   int currentYear = DateTime.now().year;
  //   final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //
  //   try {
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //
  //     final response = await http.get(url, headers: headers);
  //     if (response.statusCode == 200) {
  //       dynamic jsonData = json.decode(response.body);
  //
  //       if (jsonData is List) {
  //         List<HolidayResponse> holidayList = jsonData.map((json) => HolidayResponse.fromJson(json)).toList();
  //         setState(() {
  //           holidaylist = holidayList;
  //           print('holidaylist${holidaylist.length}');
  //         });
  //         return holidayList;
  //       } else {
  //         throw Exception('Invalid data format: Expected JSON array');
  //       }
  //     } else {
  //       // Handle error if the request was not successful
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //       return [];
  //     }
  //   } catch (error) {
  //     // Handle any exceptions that occurred during the request
  //     print('Error: $error');
  //     return [];
  //   }
  // }

  void printLookupDetailId(String buttonName) {
    if (lookupDetails.isNotEmpty) {
      LookupDetail selectedItem = lookupDetails.firstWhere(
        (item) => item.name == buttonName,
        orElse: () {
          // Provide a default value when no element is found
          return LookupDetail(
            lookupDetailId: 0, // Adjust the default values accordingly
            code: '',
            name: '',
            lookupId: 0,
            isActive: false,
            createdAt: '',
            updatedAt: '',
            createdBy: '',
            updatedBy: '',
          );
        },
      );
      if (selectedItem != null) {
        // Handle the case when an element is found
        print(selectedItem.lookupDetailId);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                /* apply_leave(
              buttonName: buttonName,
              lookupDetailId: selectedItem.lookupDetailId,
              employename: '$EmployeName',
            ), */
                TestApplyLeave(
              leaveType: buttonName,
              leaveTypeId: selectedItem.lookupDetailId,
              employeName: EmployeName,
            ),
          ),
        );
      } else {
        // Handle the case when no element is found
        print('Item not found for buttonName: $buttonName');
      }
    } else {
      // Handle the case when the list is empty
      print('lookupDetails list is empty');
    }

    // Find the item with the specified name in the lookupDetails list
  }

  Future<void> getDayWorkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      DayWorkStatus = prefs.getInt('dayWorkStatus') ?? 0;
    });
    print("DayWorkStatus:$DayWorkStatus");
    fetchDataleavetype(DayWorkStatus);
    // Provide a default value if not found
  }

  Future<void> fetchDataleavetype(int dayWorkStatus) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse(baseUrl + getdropdown + '$dayWorkStatus');
    print('fetchDataleavetype :${url}');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );

    // if (response.statusCode == 200) {
    //   List<dynamic> jsonData = json.decode(response.body);
    //
    //   setState(() {
    //     lookupDetails = jsonData.map((data) => LookupDetail.fromJson(data)).toList();
    //   });
    // } else {
    //   Commonutils.showCustomToastMessageLong(' Error :  ${response.statusCode} ', context, 1, 3);
    //   throw Exception('Failed to load data. Status Code: ${response.statusCode}');
    // }
    final dynamic jsonData = json.decode(response.body);

// Check if jsonData is a List<dynamic>
    if (jsonData is List<dynamic>) {
      // If it's a list, process it as usual
      setState(() {
        lookupDetails =
            jsonData.map((data) => LookupDetail.fromJson(data)).toList();
      });
    } else {
      // If it's not a list, handle the single string case
      // For example, you might want to display it or process it differently
      print('Response is not a list: $jsonData');
    }
  }

  // void _selectPreviousMonthPL() {
  //   setState(() {
  //     int previousMonthPL = _selectedMonthPL.month - 1;
  //     int monthId = previousMonthPL == 0 ? 12 : previousMonthPL;
  //     _selectedMonthPL = DateTime(_selectedMonthPL.year, previousMonthPL);
  //     montlyleavesPl(monthId);
  //     // Now, you can use the monthId variable as needed
  //     print('previous Month ID: $monthId');
  //   });
  // }
  void _selectPreviousMonthPL() {
    setState(() {
      _selectedMonthPL =
          DateTime(_selectedMonthPL.year, _selectedMonthPL.month - 1);
      print(' ${_selectedMonthPL.month}');

      // Print year
      print('Year: ${_selectedMonthPL.year}');
      montlyleavesPl(_selectedMonthPL.month, _selectedMonthPL.year);
    });
  }

  // void _selectNextMonthPL() {
  //   setState(() {
  //     int nextMonthPL = _selectedMonthPL.month + 1;
  //     int monthId = nextMonthPL > 12 ? 1 : nextMonthPL;
  //     _selectedMonthPL = DateTime(_selectedMonthPL.year, nextMonthPL);
  //     montlyleavesPl(monthId);
  //     // Now, you can use the monthId variable as needed
  //     print('Next Month ID: $monthId');
  //   });
  // }
  void _selectNextMonthPL() {
    setState(() {
      _selectedMonthPL =
          DateTime(_selectedMonthPL.year, _selectedMonthPL.month + 1);

      // Print month name and number
      print(' ${_selectedMonthPL.month}');

      // Print year
      print('Year: ${_selectedMonthPL.year}');
      montlyleavesPl(_selectedMonthPL.month, _selectedMonthPL.year);
    });
  }

  void _selectPreviousMonthCL() {
    setState(() {
      _selectedMonthCL =
          DateTime(_selectedMonthCL.year, _selectedMonthCL.month - 1);
      print(' ${_selectedMonthCL.month}');

      // Print year
      print('Year: ${_selectedMonthCL.year}');
      montlyleavesCL(_selectedMonthCL.month, _selectedMonthCL.year);

      // int previousMonthCL = _selectedMonthCL.month - 1;
      // int monthId = previousMonthCL == 0 ? 12 : previousMonthCL;
      // _selectedMonthCL = DateTime(_selectedMonthCL.year, previousMonthCL);
      // montlyleavesCL(monthId);
      // // Now, you can use the monthId variable as needed
      // print('previous Month ID: $monthId');
    });
  }

  void _selectNextMonthCL() {
    setState(() {
      _selectedMonthCL =
          DateTime(_selectedMonthCL.year, _selectedMonthCL.month + 1);

      // Print month name and number
      print(' ${_selectedMonthCL.month}');

      // Print year
      print('Year: ${_selectedMonthCL.year}');
      montlyleavesCL(_selectedMonthCL.month, _selectedMonthCL.year);
      // int nextMonthCl = _selectedMonthCL.month + 1;
      // int monthId = nextMonthCl > 12 ? 1 : nextMonthCl;
      // _selectedMonthCL = DateTime(_selectedMonthCL.year, nextMonthCl);
      // montlyleavesCL(monthId);
      // // Now, you can use the monthId variable as needed
      // print('Next Month ID: $monthId');
    });
  }

  void _selectPreviousMonthlwp() {
    setState(() {
      int previousMonthlwp = _selectedMonthlwp.month - 1;
      int monthIdlwp = previousMonthlwp == 0 ? 12 : previousMonthlwp;
      _selectedMonthlwp = DateTime(_selectedMonthlwp.year, previousMonthlwp);
      montlyleaveslwp(monthIdlwp);
      // Now, you can use the monthId variable as needed
      print('previous Month ID: $monthIdlwp');
    });
  }

  void _selectNextMonthlwp() {
    setState(() {
      int nextMonthlwp = _selectedMonthlwp.month + 1;
      int monthIdlwp = nextMonthlwp > 12 ? 1 : nextMonthlwp;
      _selectedMonthlwp = DateTime(_selectedMonthlwp.year, nextMonthlwp);
      montlyleaveslwp(monthIdlwp);
      // Now, you can use the monthId variable as needed
      print('Next Month ID: $monthIdlwp');
    });
  }

  Future<void> montlyleavesPl(int monthId, int year) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    setState(() {
      isLoading = true; // Set isLoading to true before making the API call
    });
    //  DateTime now = DateTime.now();

    // Extract the current year
    // int currentYear = now.year;

    // Print the current year
    //  print('Current Year: $currentYear');
    try {
      final url = Uri.parse(
          baseUrl + getmontlyleaves + '/$monthId' + '/$employeid' + '/$year');
      print('monthlyleavesPlsapi: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers: $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      print("responsecode ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);
        if (response.body == "[]") {
          setState(() {
            isLoading = false;
            noOfleavesinPLs = 0.0;
          });
        } else {
          print('response data : ${data}');
          List<leave_model> leaveInfos =
              data.map((json) => leave_model.fromJson(json)).toList();

          // Now you have a List of LeaveInfo objects
          for (var leaveInfo in leaveInfos) {
            print('LeavePLType: ${leaveInfo.leaveType}');
            // print('Used CLs in Month: ${leaveInfo.usedCLsInMonth}');
            print('Used PLs in Month: ${leaveInfo.usedPLsInMonth.toDouble()}');
            double noofPL = leaveInfo.usedPLsInMonth.toDouble();
            print('noofPL:$noofPL');
            setState(() {
              isLoading = false;
              noOfleavesinPLs = noofPL.toDouble();
              print('noOfleavesinPLs:$noOfleavesinPLs');
            });
          }
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        setState(() {
          isLoading = false; // Set isLoading to false if request fails
        });
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
      setState(() {
        isLoading = false; // Set isLoading to false if request fails
      });
    }
  }

  Future<void> montlyleavesCL(int monthId, int year) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    setState(() {
      _isLoading = true; // Set isLoading to true before making the API call
    });
    // DateTime now = DateTime.now();
    //
    // // Extract the current year
    // int currentYear = now.year;
    //
    // // Print the current year
    // print('Current Year: $currentYear');
    try {
      final url = Uri.parse(
          baseUrl + getmontlyleaves + '/$monthId' + '/$employeid' + '/$year');
      print('monthlyleavesClsapi: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers: $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      print("responsecode ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);
        if (response.body == "[]") {
          setState(() {
            _isLoading = false;
            noOfleavesinCLs = 0.0;
          });
        } else {
          print('response data : ${data}');
          List<leave_model> leaveInfos =
              data.map((json) => leave_model.fromJson(json)).toList();

          // Now you have a List of LeaveInfo objects
          for (var leaveInfoCl in leaveInfos) {
            print('LeaveClType: ${leaveInfoCl.leaveType}');
            // print('Used CLs in Month: ${leaveInfo.usedCLsInMonth}');
            print('UsedCLsin Month: ${leaveInfoCl.usedCLsInMonth.toDouble()}');

            double noofCL = leaveInfoCl.usedCLsInMonth.toDouble();
            print('noofCL:$noofCL');
            setState(() {
              _isLoading = false;
              noOfleavesinCLs = noofCL.toDouble();
              print('noOfleavesinCls:$noOfleavesinCLs');
            });
          }
        }
      } else {
        // Handle error if the request was not successful
        setState(() {
          _isLoading = false; // Set isLoading to false if request fails
        });
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false; // Set isLoading to false if request fails
      });
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    }
  }

  Future<void> montlyleaveslwp(int monthId) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    // Print the current year
    print('Current Year: $currentYear');
    try {
      final url = Uri.parse(baseUrl +
          getmontlyleaves +
          '/$monthId' +
          '/$employeid' +
          '/$currentYear');
      print('monthlyleaveslwpapi: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers: $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      print("responsecode ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        print('response data : ${data}');
        List<leave_model> leaveInfos =
            data.map((json) => leave_model.fromJson(json)).toList();

        // Now you have a List of LeaveInfo objects
        for (var leaveInfoLWP in leaveInfos) {
          if (leaveInfoLWP.leaveType == "LWP") {
            print('LeaveLWPType: ${leaveInfoLWP.leaveType}');
            // print('Used CLs in Month: ${leaveInfo.usedCLsInMonth}');
            print('UsedLWPin Month: ${leaveInfoLWP.usedPLsInMonth}');
            double noofCL = leaveInfoLWP.usedPLsInMonth.toDouble();

            setState(() {
              noOfleavesinLWP = noofCL.toDouble();
              print('noOfleavesinLWP:$noOfleavesinLWP');
            });
          }
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    }
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      //fetchHolidayList(accessToken);
    });
    print("accestokeninapplyleave:$accessToken");
  }

  void showmonthpickerforpl(BuildContext context) {
    showDialog(
      // barrierDismissible: false,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Confirmation",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Color(0xFFf15f22),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      //  Navigator.of(context, rootNavigator: true).pop(context);
                    },
                    child: Icon(
                      CupertinoIcons.multiply,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/caution-sign.png',
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Text(
                            'Your leave request is within the WFH span. will you want to split this,Please confirm this by Clicking Confirm else Cancel')
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
