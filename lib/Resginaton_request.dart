import 'dart:convert';
import 'dart:io';
import 'package:hrms/NotificationReply.dart';
import 'package:hrms/Resignation.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:hrms/styles.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/personal_details.dart';
import 'package:hrms/projects_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Constants.dart';
import 'Model Class/LookupDetail.dart';
import 'Myleaveslist.dart';
import 'Notification_Model.dart';
import 'UpComingbdays.dart';
import 'api config.dart';
import 'feedback_Screen.dart';
import 'home_screen.dart';
import 'main.dart';

class Resgination_req extends StatefulWidget {
  const Resgination_req({super.key});

  @override
  _Resgination_req_screenState createState() => _Resgination_req_screenState();
}

class _Resgination_req_screenState extends State<Resgination_req> {
  String? accessToken;
  String empolyeid = '';
  String? userid;
  String? logintime;
  final TextEditingController _fromdateController = TextEditingController();
  final TextEditingController _Desctext = TextEditingController();
  final TextEditingController _otherreasontext = TextEditingController();
  final TextEditingController _withdrawreasontext = TextEditingController();
  String EmployeName = '';
  List<LookupDetail> lookupDetails = [];
  List<Resignation> resignationlist = [];
  int resignationlookupid = 0;
  int selectedleaveValue = -1;
  int selectedleaveTypeId = -1;
  String selectedleaveName = "";
  String defaultButtonName = 'Select Resignation Reason';
  final FocusNode _focusNode = FocusNode();
  final FocusNode _otherfocusNode = FocusNode();
  bool isOtherSelected = false;
  int? loggedInEmployeeId;
  bool checkwithdrawbtn = false;
  bool dropdownDisabled = false;
  bool ismatchedlogin = false;

  bool isRequestProcessing = false;

  String RegStatus = "";
  @override
  void initState() {
    loadAccessToken();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        loadAccessToken();
        loademployeid();
        _loademployeresponse();
        loadUserid();
        getResignationReq();
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

  Future<void> loademployeid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
      loggedInEmployeeId = int.tryParse(empolyeid);
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  Future<void> getResignationReq() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      resignationlookupid = prefs.getInt('ResignationReasons') ?? 0;
    });
    print("resignationlookupid:$resignationlookupid");
    fetchResignationReq(resignationlookupid);
    // Provide a default value if not found
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      CheckResignation(accessToken!);
    });
    print("accestoken:$accessToken");
  }

  Future<void> loadUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString("UserId") ?? "";
    });
    print("UserId:$userid");
  }

  void _loademployeresponse() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      print('employeeName: $employeeName');

      setState(() {
        EmployeName = employeeName;
        _fromdateController.text = EmployeName;
      });
    }
  }

  Future<void> fetchResignationReq(int resignationReq) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse('$baseUrl$getdropdown$resignationReq');
    print('fetchResignationReq :$url');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'APIKey': '$APIKey',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData == 'Token invalid !!!') {
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
          Commonutils.showCustomToastMessageLong(
              "Token is Expired", context, 0, 3);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
          return;
        }

        if (jsonData is List<dynamic>) {
          setState(() {
            lookupDetails =
                jsonData.map((data) => LookupDetail.fromJson(data)).toList();
          });
        } else {
          print('Unexpected response format: $jsonData');
          throw Exception('Failed to load data. Unexpected response format.');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
      // Commonutils.showCustomToastMessageLong("Token is Expired", context, 0, 3);
      //
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => LoginPage()),
      //       (route) => false,
      // );
      // Commonutils.showCustomToastMessageLong('Network is unreachable. Please check your internet connection.', context, 0, 3);
      print('SocketException: $e');
    } catch (e) {
      print('Error: $e');
      Commonutils.showCustomToastMessageLong(
          'An unexpected error occurred. Please try again later.',
          context,
          0,
          3);
    }
  }

  // Future<void> fetchResignationReq(int resingationreq) async {
  //   final url = Uri.parse(baseUrl + getdropdown + '$resingationreq');
  //   print('fetchResignationReq :${url}');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final dynamic jsonData = json.decode(response.body);
  //     if(jsonData == 'Token invalid !!!'){
  //
  //       SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
  //       Commonutils.showCustomToastMessageLong("Token is Experied", context, 0, 3);
  //       // Navigator.pushReplacement(
  //       //     context, MaterialPageRoute(builder: (context) => LoginPage()));
  //
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => LoginPage()),
  //             (route) => false,
  //       );
  //     }
  //     print('Unexpected response format: $jsonData');
  //     if (jsonData is List<dynamic>) {
  //       setState(() {
  //         lookupDetails = jsonData.map((data) => LookupDetail.fromJson(data)).toList();
  //       });
  //     } else {
  //
  //       print('Unexpected response format: $jsonData');
  //       throw Exception('Failed to load data. Unexpected response format.');
  //     }
  //   } else {
  //     print('HTTP error: ${response.statusCode}');
  //     throw Exception('Failed to load data. Status Code: ${response.statusCode}');
  //   }
  // }
  Future<void> CheckResignation(String accessToken) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String brnchId = prefs.getString(SharedKeys.brnchId) ?? "";
    String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    final url = Uri.parse(baseUrl + getResignations + '/' + brnchId);
    print('CheckResignation :$url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'APIKey': APIKey,
      },
    );

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);

      if (jsonData is List<dynamic>) {
        setState(() {
          resignationlist =
              jsonData.map((data) => Resignation.fromJson(data)).toList();
          bool isMatchingEmployeeId = jsonData
              .any((reply) => reply['employeeId'] == loggedInEmployeeId);
          print('isMatchingEmployeeId$isMatchingEmployeeId');

          if (isMatchingEmployeeId) {
            final matchingResignation = jsonData.firstWhere(
                (reply) => reply['employeeId'] == loggedInEmployeeId);

            if (matchingResignation['resignationStatus'] != 'Withdrawn') {
              setState(() {
                checkwithdrawbtn = true;
                // Get the resignation reason from the response
                selectedleaveTypeId = matchingResignation['reasonId'];
                selectedleaveName = matchingResignation['reason'];
                selectedleaveValue =
                    selectedleaveTypeId; // Bind the selected value
                _Desctext.text = matchingResignation['description'];
                if (selectedleaveName == 'Other') {
                  isOtherSelected = true;
                  _otherreasontext.text = matchingResignation['otherReason'];
                }
                RegStatus = matchingResignation[
                    'resignationStatus']; // Bind reviewDescription to _Desctext
                print('it is matching resignationStatus $RegStatus');
                dropdownDisabled = true;

                print('it is matching the employeid');
              });
            } else {
              setState(() {
                checkwithdrawbtn = false;
                dropdownDisabled = false;
                _Desctext.text = '';
                selectedleaveTypeId = -1;
              });
              print('The resignation status is Withdrawn.');
            }
          } else {
            setState(() {
              dropdownDisabled = false;
              print('it is not matching the employeid');
            });
          }
        });
      } else {
        print('Unexpected response format: $jsonData');
        if (jsonData == 'Invalid token !!!') {
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
          Commonutils.showCustomToastMessageLong(
              "Token is Experied", context, 0, 3);
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => LoginPage()));

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        }
        throw Exception('Failed to load data. Unexpected response format.');
      }
    } else {
      print('HTTP error: ${response.statusCode}');
      throw Exception(
          'Failed to load data. Status Code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ismatchedlogin) {
      Future.microtask(() => _showtimeoutdialog(context));
    }
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  backgroundColor: const Color(0xFFf15f22),
                  title: const Text(
                    'Resignation Request',
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => home_screen()),
                      );
                    },
                  )),
              body: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: 10.0, right: 0),
                        child: GestureDetector(
                          onTap: () async {},
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFf15f22), width: 1.5),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            child: AbsorbPointer(
                              child: SizedBox(
                                child: TextFormField(
                                  controller: _fromdateController,
                                  style: const TextStyle(
                                    fontFamily: 'Calibri',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Employee Name',
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri',
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: 20.0, right: 0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFf15f22), width: 1.5),
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white, // Add white background color
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: lookupDetails.isEmpty
                                  ? LoadingAnimationWidget.fourRotatingDots(
                                      color: Colors.blue,
                                      size: 40.0,
                                    )
                                  : DropdownButton<int>(
                                      value: selectedleaveValue,
                                      iconSize: 30,
                                      icon: null,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                      onChanged: dropdownDisabled
                                          ? null
                                          : (value) {
                                              setState(() {
                                                if (value != null &&
                                                    value != -1) {
                                                  selectedleaveTypeId = value;
                                                  LookupDetail selectedDetail =
                                                      lookupDetails.firstWhere(
                                                          (item) =>
                                                              item.lookupDetailId ==
                                                              value);
                                                  print(
                                                      "selectedDetail$selectedDetail");
                                                  selectedleaveValue =
                                                      selectedDetail
                                                          .lookupDetailId;
                                                  selectedleaveName =
                                                      selectedDetail.name;
                                                  isOtherSelected =
                                                      selectedleaveName ==
                                                          'Other';
                                                  _otherreasontext.clear();
                                                  _Desctext.clear();
                                                  print(
                                                      "selectedleaveName$selectedleaveName");
                                                }
                                              });
                                            },
                                      items: [
                                        DropdownMenuItem<int>(
                                          value: -1,
                                          child: Text(defaultButtonName),
                                        ),
                                        for (LookupDetail item in lookupDetails)
                                          DropdownMenuItem<int>(
                                            value: item.lookupDetailId,
                                            child: Text(item.name),
                                          ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      //    if (dropdownDisabled && isOtherSelected)
                      // Padding(
                      //   padding: EdgeInsets.only(left: 0, top: 20.0, right: 0),
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width,
                      //     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: Color(0xFFf15f22), width: 1.5),
                      //       borderRadius: BorderRadius.circular(5.0),
                      //       color: Colors.grey.withOpacity(0.5),
                      //     ),
                      //     child: Text(
                      //       selectedleaveName ?? '',
                      //       style: TextStyle(
                      //         color: Colors.black54,
                      //         fontWeight: FontWeight.bold,
                      //         fontFamily: 'Calibri',
                      //         fontSize: 14,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Visibility(
                        visible: isOtherSelected,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 20.0, right: 0),
                          child: AbsorbPointer(
                            absorbing: dropdownDisabled,
                            child: GestureDetector(
                              onTap: () async {
                                if (!dropdownDisabled &&
                                    !_otherfocusNode.hasFocus) {
                                  _otherfocusNode.requestFocus();
                                }
                              },
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFf15f22),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: dropdownDisabled
                                      ? Colors.grey[300]
                                      : Colors.white, // Grey out when disabled
                                ),
                                child: Stack(
                                  children: [
                                    TextFormField(
                                      enabled:
                                          !dropdownDisabled, // Disable text field when dropdownDisabled is true
                                      focusNode: _otherfocusNode,
                                      controller: _otherreasontext,
                                      style: TextStyle(
                                        fontFamily: 'Calibri',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: dropdownDisabled
                                            ? Colors.grey
                                            : Colors
                                                .black, // Grey out text when disabled
                                      ),
                                      maxLines: null,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value.startsWith(' ')) {
                                            _otherreasontext.value =
                                                TextEditingValue(
                                              text: value.trimLeft(),
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: value
                                                          .trimLeft()
                                                          .length),
                                            );
                                          }
                                          if (value.length > 20) {
                                            _otherreasontext.value =
                                                TextEditingValue(
                                              text: value.substring(0, 20),
                                              selection:
                                                  const TextSelection.collapsed(
                                                      offset: 20),
                                            );
                                          }
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Reason',
                                        hintStyle: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Calibri',
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8.0,
                                      right: 8.0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        child: Text(
                                          '${_otherreasontext.text.length}/20',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: 20.0, right: 0),
                        child: AbsorbPointer(
                          absorbing: dropdownDisabled,
                          child: GestureDetector(
                            onTap: () async {
                              if (!dropdownDisabled && !_focusNode.hasFocus) {
                                _focusNode.requestFocus();
                              }
                            },
                            child: Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color: dropdownDisabled
                                    ? Colors.grey[300]
                                    : Colors.white, // Grey out when disabled
                              ),
                              child: Stack(
                                children: [
                                  TextFormField(
                                    enabled:
                                        !dropdownDisabled, // Disable text field when dropdownDisabled is true
                                    focusNode: _focusNode,
                                    controller: _Desctext,
                                    style: TextStyle(
                                      fontFamily: 'Calibri',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: dropdownDisabled
                                          ? Colors.grey
                                          : Colors
                                              .black, // Grey out text when disabled
                                    ),
                                    maxLines: null,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.startsWith(' ')) {
                                          _Desctext.value = TextEditingValue(
                                            text: value.trimLeft(),
                                            selection: TextSelection.collapsed(
                                                offset:
                                                    value.trimLeft().length),
                                          );
                                        }
                                        if (value.length > 256) {
                                          _Desctext.value = TextEditingValue(
                                            text: value.substring(0, 256),
                                            selection:
                                                const TextSelection.collapsed(
                                                    offset: 256),
                                          );
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Resignation Description',
                                      hintStyle: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8.0,
                                    right: 8.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      child: Text(
                                        '${_Desctext.text.length}/256',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            top: 25.0, left: 0.0, right: 0.0),
                        child: SizedBox(
                          width: double.infinity,
                          // decoration: BoxDecoration(
                          //   color: dropdownDisabled ? Colors.grey : Color(0xFFf15f22),
                          //   borderRadius: BorderRadius.circular(6.0),
                          // ),
                          child: SizedBox(
                            height: 50.0, // Set the desired height here
                            child: ElevatedButton(
                              onPressed: dropdownDisabled
                                  ? null
                                  : () async {
                                      setState(() {
                                        isRequestProcessing = true;
                                      });
                                      if (Validations()) {
                                        ApplyResignation();
                                      } else {
                                        setState(() {
                                          isRequestProcessing = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRequestProcessing
                                    ? Colors.grey.shade400
                                    : (dropdownDisabled
                                        ? Colors.grey.shade400
                                        : Styles.primaryColor),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                              child: isRequestProcessing
                                  ? const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Styles.primaryColor,
                                      ))
                                  : const Text(
                                      'Submit',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Calibri'),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: checkwithdrawbtn,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 25.0, left: 0.0, right: 0.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: SizedBox(
                              height: 50.0,
                              child: ElevatedButton(
                                onPressed: RegStatus == "Accepted"
                                    ? null
                                    : () async {
                                        final matchingResignation =
                                            resignationlist.firstWhere(
                                                (reply) =>
                                                    reply.employeeId ==
                                                    loggedInEmployeeId);
                                        showdialogmethod(matchingResignation
                                            .toJson()); // Pass the matchingResignation data
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: RegStatus == "Accepted"
                                      ? Colors.grey
                                      : const Color(0xFFf15f22),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                                child: const Text(
                                  'Withdraw',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )));
  }

  void showdialogmethod(Map<String, dynamic> matchingResignation) {
    print(matchingResignation);
    _withdrawreasontext.clear();
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Withdraw Resignation",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Color(0xFFf15f22),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
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
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: _withdrawreasontext,
                          onChanged: (text) {},
                          decoration: InputDecoration(
                            hintText: 'Enter Description',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFf15f22),
                              ),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFFf15f22),
                              ),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.black26, // Label text color
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            alignLabelWithHint: true,
                          ),
                          maxLength: 256,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Calibri',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    Navigator.of(context).pop();
                    await withdrawApi(
                        matchingResignation); // Pass the matchingResignation data
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf15f22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Calibri'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool Validations() {
    if (selectedleaveValue == -1) {
      Commonutils.showCustomToastMessageLong(
          'Please Select Resignation Reason', context, 1, 4);

      return false;
    }
    if (isOtherSelected) {
      if (_otherreasontext.text.trim().isEmpty) {
        Commonutils.showCustomToastMessageLong(
            'Please Enter Other Reason', context, 1, 4);
        return false;
      }
    }
    return true;
  }

  Future<void> ApplyResignation() async {
    try {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (!isConnected) {
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      final url = Uri.parse(baseUrl + applyResignation);
      print('CheckResignation :$url');
      String desc = _Desctext.text.trim().toString();
      String otherdesc = _otherreasontext.text.trim().toString();
      final request = {
        "resignationId": 0,
        "employeeId": empolyeid,
        "employeeName": EmployeName,
        "reasonId": selectedleaveTypeId,
        "description": desc,
        "otherReason": otherdesc,
        "isActive": true,
        // "url": leaveApplyURL,
        // "url": 'https://182.18.157.215:/',
        "url": leaveApplyURL, // live url

        //"url": 'http://hrms.calibrage.in:/',
      };
      print('body${json.encode(request)}');
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': '$APIKey',
        },
      );

      setState(() {
        isRequestProcessing = false;
      });
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        print('response:$jsonData');
        print('response:${response.body}');
        _Desctext.clear();
        _otherreasontext.clear();

        //  Commonutils.showCustomToastMessageLong('Resignation Added Successfully', context, 1, 4);
        bool isSuccess = json.decode(response.body);

        if (isSuccess) {
          Commonutils.showCustomToastMessageLong(
              'Resignation Added Successfully', context, 0, 2);

          // Close the dialog
          //  Navigator.of(context).pop();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {
            accessToken = prefs.getString("accessToken") ?? "";
            CheckResignation(accessToken!);
          });
          // Refresh the screen
          // await CheckResignation($accessToken);
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      rethrow;
    }
  }

  Future<void> withdrawApi(Map<String, dynamic> matchingResignation) async {
    if (_withdrawreasontext.text.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Withdraw Reason', context, 1, 4);
      return;
    }
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }

    DateTime currentTime = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentTime);
    String message = _withdrawreasontext.text.trim().toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    try {
      final url = Uri.parse(baseUrl + WithdrawResignation);
      final request = {
        "resignationId": matchingResignation['resignationId'],
        "employeeId": matchingResignation['employeeId'],
        "employeeName": matchingResignation['employeeName'],
        "reasonId": matchingResignation['reasonId'],
        "description": matchingResignation['description'],
        "otherReason": matchingResignation['otherReason'],
        "isActive": false,
        "rejectedBy": matchingResignation['employeeId'],
        "rejectedAt": formattedDate,
        "reviewDescription": message,
      };
      print('===WithdrawResignation${json.encode(request)}');
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': '$APIKey',
        },
      );

      if (response.statusCode == 200) {
        bool isSuccess = json.decode(response.body);

        if (isSuccess) {
          // Close the dialog
          Navigator.of(context).pop();

          Commonutils.showCustomToastMessageLong(
              'Resignation Withdrawn Successfully', context, 0, 2);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );
        } else {
          Commonutils.showCustomToastMessageLong(
              'Failed to withdraw resignation', context, 1, 4);
        }
      } else if (response.statusCode == 520) {
        Commonutils.showCustomToastMessageLong(response.body, context, 1, 3);
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
