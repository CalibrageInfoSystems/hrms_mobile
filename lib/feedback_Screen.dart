import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/leave_model.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'home_screen.dart';
import 'main.dart';

class feedback_Screen extends StatefulWidget {
  @override
  _feedback_Screen_screenState createState() => _feedback_Screen_screenState();
}

class _feedback_Screen_screenState extends State<feedback_Screen> {
  TextEditingController _commentstexteditcontroller = TextEditingController();
  double rating_star = 0.0;
  String? logintime;
  String accessToken = '';
  bool ismatchedlogin = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        loadAccessToken();
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

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninfeedbackscreen$accessToken");
  }

  @override
  Widget build(BuildContext context) {
    if (ismatchedlogin) {
      Future.microtask(() => _showtimeoutdialog(context));
    }
    return WillPopScope(
        onWillPop: () async {
          // Handle back button press here
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          ); //
          // You can add any custom logic before closing the app
          return true; // Return true to allow back button press and close the app
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color(0xFFf15f22),
              title: Text(
                'HRMS',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => home_screen()),
                  );
                  // Implement your logic to navigate back
                },
              ),
            ),
            body: Stack(
              children: [
                Image.asset(
                  'assets/background_layer_2.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),

                // SingleChildScrollView for scrollable content
                SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.only(
                        top: 15.0, left: 15.0, right: 15.0, bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feedback',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFFf15f22),
                            fontFamily: 'Calibri',
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          'Rating',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFf15f22),
                            fontFamily: 'Calibri',
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: RatingBar.builder(
                              initialRating: 0,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  rating_star = rating;
                                  print('rating_star$rating_star');
                                });
                              },
                            )),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: GestureDetector(
                            onTap: () async {},
                            child: Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                controller: _commentstexteditcontroller,
                                style: TextStyle(
                                  fontFamily: 'Calibri',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: null,

                                // Set maxLines to null for multiline input
                                decoration: InputDecoration(
                                  hintText: 'Comment',
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
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFf15f22),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                validaterating();
                              },
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Calibri'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> validaterating() async {
    bool isValid = true;
    bool hasValidationFailed = false;
    if (rating_star != null && rating_star <= 0.0) {
      Commonutils.showCustomToastMessageLong(
          'Please Share Us Your Valuable Feedback', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      FocusScope.of(context).unfocus();
    }

    if (isValid && _commentstexteditcontroller.text.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Comment', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      FocusScope.of(context).unfocus();
    }
    if (isValid) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? storedEmployeeId = sharedPreferences.getString("employeeId");
      print('employidinfeedback$storedEmployeeId');

      String APIKey = sharedPreferences.getString(SharedKeys.APIKey) ?? "";
      String comments = _commentstexteditcontroller.text.toString();
      int myInt = rating_star.toInt();
      print('changedintoint$myInt');

      int employeid = int.parse(storedEmployeeId!);
      print('employeid$employeid');
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (!isConnected) {
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        return;
      }
      try {
        final url = Uri.parse(baseUrl + feedbackapi);
        print('feedbackapi: $url');
        final request = {
          "feedbackId": null,
          "employeeId": employeid,
          "rating": myInt,
          "comments": comments,
          "updatedBy": "Mobile",
          "updatedAt": "2024-03-12T11:26:35.115Z"
        };

        print('Request Body: ${json.encode(request)}');

        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
            'APIKey': '$APIKey',
          },
        );

        print('feedbackresponse: ${response.body}');
        if (response.statusCode == 200) {
          Map<String, dynamic> responseMap = json.decode(response.body);

          if (responseMap.containsKey('isSuccess')) {
            bool isSuccess = responseMap['isSuccess'];
            if (isSuccess == true) {
              Commonutils.showCustomToastMessageLong(
                  'Thankyou For Your Valuable Feedback', context, 0, 4);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => home_screen()),
              );
            } else {
              Commonutils.showCustomToastMessageLong(
                  '${responseMap['message']}', context, 1, 4);
              print('Feedback Failed: ${response.body}');
            }
          } else {
            if (response.body.toLowerCase().contains('invalid token')) {
              // Invalid token scenario
              Commonutils.showCustomToastMessageLong(
                  'Invalid Token. Please Login Again.', context, 1, 4);
            } else {
              // Other scenarios with success status code
              // Handle as needed, for example, showing the response message
              String message = responseMap['message'] ?? 'No message provided';
              Commonutils.showCustomToastMessageLong(
                  '${response.body}', context, 0, 3);
            }
          }
        } else if (response.statusCode == 520) {
          // Scenario with status code 520
          // Show the response body as a toast
          Commonutils.showCustomToastMessageLong(
              '${response.body}', context, 0, 3);
        } else {
          // Handle other status codes if needed
          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
        // if (response.statusCode == 200) {
        //   Map<String, dynamic> responseMap = json.decode(response.body);
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => home_screen()),
        //   );
        //   Commonutils.showCustomToastMessageLong('Thankyou For Your Valuable Feedback', context, 0, 4);
        // } else {
        //   // Handle other status codes if needed
        //   Commonutils.showCustomToastMessageLong('Something Went Wrong', context, 1, 4);
        //   print('Failed to send the request. Status code: ${response.statusCode}');
        // }
      } catch (e) {
        print('Error: $e');
      }
    }
  }
}
