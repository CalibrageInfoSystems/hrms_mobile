import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hrms/Model%20Class/login%20model%20class.dart';
import 'package:hrms/Splash_screen.dart';
import 'package:hrms/changepassword.dart';
import 'package:hrms/custom_dialog.dart';
import 'package:hrms/security_questions.dart';
import 'package:hrms/security_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

/* 
class LoginScreen2 extends StatefulWidget {
  @override
  _LoginScreen2State createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  String? selectedPhoneNumber;
  List<loginmodel> loginlist = [];
  String? employeeId;
  bool isLoading = false;
  String? accessToken;
  bool _obscureText = true;
  String isfirst_time = "";
  bool _isLoading = false;
  String userid = '';
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
      } else {
        Commonutils.showCustomToastMessageLong(
            'Not connected to the internet', context, 1, 4);
        print('The Internet Is not  Connected');
      }
    });
    // requestPhonePermission();
    _usernamecontroller.text = 'CIS00054'; // CIS00033
    // _usernamecontroller.text = 'CIS00167';
    _passwordcontroller.text = 'Ranjith@469';
  }

  Future<void> validate() async {
    bool isValid = true;
    bool hasValidationFailed = false;
    bool apiCallCompleted = false;
    if (isValid && _usernamecontroller.text.isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Username', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      FocusScope.of(context).unfocus();
    }
    if (isValid && _passwordcontroller.text.isEmpty) {
      isValid = false;
      hasValidationFailed = true;
      Commonutils.showCustomToastMessageLong(
          'Please Enter Password', context, 1, 4);
      FocusScope.of(context).unfocus();
    } else {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (isConnected) {
        print('Connected to the internet');
      } else {
        Commonutils.showCustomToastMessageLong(
            'No Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        print('Not connected to the internet');
      }
    }

    String username = _usernamecontroller.text.toString().trim();
    String password = _passwordcontroller.text.toString().trim();

    if (isValid && !hasValidationFailed) {
      final request = {
        "userName": username,
        "password": password,
        "rememberMe": true
      };
      setState(() {
        //_isLoading = true;
      });
      print('Request Body: ${json.encode(request)}');
      ProgressDialog progressDialog = ProgressDialog(context);
      FocusScope.of(context).unfocus();

      // Show the progress dialog
      progressDialog.show();
      try {
        final url = Uri.parse(baseUrl + getlogin);
        print('LoginUrl: $url');

        // Send the POST request
        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
          },
        ).timeout(Duration(seconds: 10), onTimeout: () {
          apiCallCompleted = false;
          progressDialog.dismiss();
          FocusScope.of(context).unfocus();
          Commonutils.showCustomToastMessageLong(
              'Something Went Wrong Please Login Again', context, 1, 4);
          return http.Response('Timeout', HttpStatus.requestTimeout);
        });
        // if (apiCallCompleted == false) {
        //   Commonutils.showCustomToastMessageLong('Something Went Wrong Please Login Again', context, 1, 4);
        // }

        print('loginreponse$response');
        print('login response: ${response.statusCode}');
        print('statusCode=====>${response.statusCode}');

        if (response.statusCode == 200) {
          //  FocusScope.of(context).unfocus();
          //  Map<String, dynamic> jsonResponse = json.decode(response.body);
          Map<String, dynamic> jsonResponse = json.decode(response.body);

          accessToken = jsonResponse['accessToken'];
          String refreshToken = jsonResponse['refreshToken'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("accessToken", accessToken!);
          print('accesstokensaved');

          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);

          isfirst_time = decodedToken['IsFirstTimeLogin'];
          print('isfirst_timeloginornot:$isfirst_time');
          userid = decodedToken['Id'];
          print('useridfromjwttoken:$userid');
          // if (isfirst_time == 'True') {
          //   navigate to next screen
          //   print('navigate to next screen');
          //   Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(
          //         builder: (context) => security_questionsscreen(
          //               userid: '$userid',
          //             )),
          //   );
          // } else {
          employeeId = decodedToken['EmployeeId'];
          SharedPreferences emplyid = await SharedPreferences.getInstance();
          await emplyid.setString(SharedKeys.employeeId, employeeId!);

          SharedPreferences userId = await SharedPreferences.getInstance();
          await userId.setString(SharedKeys.userId, userid!);
          print('EmployeeIdsaved');

          print('AccessToken: $accessToken');
          print('RefreshToken: $refreshToken');
          print('EmployeeId: $employeeId');

          setState(() {
            // _isLoading = false;
            apiCallCompleted = true;
            progressDialog.dismiss();
            FocusScope.of(context).unfocus();
          });
          empolyelogin(employeeId!, isfirst_time, userid, progressDialog);

          // }
        } else {
          FocusScope.of(context).unfocus();
          Commonutils.showCustomToastMessageLong(
              'Invalid Username or Password ', context, 1, 4);
          print('response is not success');
          setState(() {
            apiCallCompleted = false;
            progressDialog.dismiss();
            // _isLoading = false;
          });

          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        // apiCallCompleted = false;
        print('Error: $e');
      }
    }
  }

  Future<void> empolyelogin(String empolyeid, String isfirst_time,
      String userid, ProgressDialog progressDialog) async {
    FocusScope.of(context).unfocus();
    progressDialog.show();
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      progressDialog.dismiss();
      return;
    }
    // setState(() {
    //  // _isLoading = true;
    // });
    try {
      final url = Uri.parse(baseUrl + getselfempolyee + empolyeid);
      print(
          'xyz: $url'); // http://182.18.157.215/HRMS/API/hrmsapi/Employee/GetSelfEmployeeData/131

      final response = await http.get(
        url,
        headers: {
          'Authorization': '$accessToken',
        },
      );
      print('login response: ${response.body}');

      // ProgressDialog progressDialog = ProgressDialog(context);
      //
      // // Show the progress dialog
      progressDialog.show();

      // Check the response status code
      if (response.statusCode == 200) {
        fetchLookupKeys();
        // Save the response data to shared preferences
        final Map<String, dynamic> responseData = json.decode(response.body);

        //await AuthService.saveSecondApiResponse(responseData);
        print('Savedresponse: ${responseData}');
        await SharedPreferencesHelper.saveCategories(responseData);

        if (isfirst_time == 'True') {
          setState(() {
            //   _isLoading = false;
            progressDialog.dismiss();
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => ChangePasword(
                      userid: '$userid',
                      newpassword: '',
                      confirmpassword: '',
                    )),
          );
          // Get.to( ChangePasword(
          //   userid: '$userid',
          //   newpassword: '',
          //   confirmpassword: '',
          // ));
        } else if (isfirst_time == 'False') {
          DateTime loginTime = DateTime.now();
          String formattedTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(loginTime);
          print('formattedTimelogin:$formattedTime');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(SharedKeys.loginTime, formattedTime);
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
          setState(() {
            //      _isLoading = false;
            progressDialog.dismiss();
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );

          //   Get.to( home_screen());
        }

        // Navigate to the home screen
      } else {
        Commonutils.showCustomToastMessageLong(
            'Error  ${response.statusCode}', context, 1, 4);
        print('response is not success');
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
        // Handle error scenarios
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _loadNextPage() {
    // Show progress indicator
    // setState(() {
    //   _isLoading = true;
    // });
    // // Simulate a delay to mimic loading
    // Future.delayed(Duration(seconds: 2), () {
    //   // Navigate to the next page when loading is complete
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => securityscreen()),
    //   ).then((_) {
    //     // Hide progress indicator when returning from the next page
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   });
    // });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => securityscreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: MaterialApp(
          color: Colors.transparent,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Stack(
              children: [
                // Background Image

                Positioned.fill(
                  child: Image.asset(
                    'assets/background_layer_2.png',
                    fit: BoxFit.cover,
                  ),
                ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SvgPicture.asset(
                          'assets/cislogo-new.svg',
                          height: 120.0,
                          width: 55.0,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'HRMS',
                        style: TextStyle(
                          color: Color(0xFFf15f22),
                          fontSize: 26.0,
                          fontFamily: 'Calibri',
                          fontWeight:
                              FontWeight.bold, // Set the font weight to bold
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 25.0, left: 40.0, right: 40.0),
                        child: TextFormField(
                          ///     keyboardType: TextInputType.name,
                          ///
                          keyboardType: TextInputType.name,
                          maxLength: 8,
                          controller: _usernamecontroller,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[a-zA-Z0-9]')), // Allow only alphanumeric characters
// Allow only alphanumeric characters
                          ],
                          onChanged: (value) {
                            // Handle onChanged event to ensure the text stays when special characters are entered
                            if (value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
                              // If the text contains characters other than alphanumeric, remove those characters
                              _usernamecontroller.text =
                                  value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                              _usernamecontroller.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _usernamecontroller.text
                                          .length)); // Keep the cursor at the end
                            }
                          },
                          decoration: InputDecoration(
                              hintText: 'User Name',
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFf15f22),
                                ),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFf15f22),
                                ),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black26, // Label text color
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              alignLabelWithHint: true,
                              counterText: ""),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Calibri',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
                        child: TextFormField(
                          // keyboardType: TextInputType.phone,

                          controller: _passwordcontroller,
                          obscureText: _obscureText,
                          onTap: () {
                            //requestPhonePermission();
                            //requestPhonePermission();
                          },

                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFf15f22),
                              ),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFf15f22),
                              ),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.black26, // Label text color
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15.0), // Center-left alignment

                            ///      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            alignLabelWithHint: true,
                            counterText: "",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                // Toggle the password visibility
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          maxLength: 25,

                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Calibri',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 6.0, left: 45.0, right: 43.0),
                        child: GestureDetector(
                          onTap: _loadNextPage,
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          // builder: (context) => security_questionsscreen(
                          //               newpassword: '',
                          //               confirmpassword: '',
                          //               userid: '',
                          //             )),
                          //   );
                          // },
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Color(0xFFf15f22),
                                  fontSize: 14,
                                  fontFamily: 'Calibri'),
                            ),
                          ),
                        ),
                      ),
                      // Login Button
                      Padding(
                        padding:
                            EdgeInsets.only(top: 35.0, left: 40.0, right: 40.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFf15f22),
                            borderRadius: BorderRadius.circular(6.0),
                            // Adjust the border radius as needed
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              validate();
                            },
                            child: Text(
                              'Sign In',
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
              ],
            ),
          ),
        ));
  }

  Future<void> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", token);
  }

  // Future<List<dynamic>> fetchLookupKeys() async {
  //   final response = await http.get(Uri.parse(baseUrl + lookupkeys));
  //   // final response = await http.get(Uri.parse('http://182.18.157.215/HRMS/API/hrmsapi/Lookup/LookupKeys'));
  //
  //   if (response.statusCode == 200) {
  //     // Parse the JSON response
  //     Map<String, dynamic> jsonData = json.decode(response.body);
  //     Map<String, dynamic> lookups = jsonData['Lookups'];
  //
  //     // Save DayWorkStatus in SharedPreferences
  //     saveDayWorkStatus(lookups['DayWorkStatus']);
  //     saveLeaveReasons(lookups['LeaveReasons']);
  //     // Return the entire response as a List<dynamic>
  //     return json.decode(response.body);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // throw an exception.
  //     throw Exception('Failed to load Lookup Keys. Status Code: ${response.statusCode}');
  //   }
  // }
  Future<Map<String, dynamic>> fetchLookupKeys() async {
    // bool isConnected = await Commonutils.checkInternetConnectivity();
    // if (!isConnected) {
    //   Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context, 1, 4);
    //   FocusScope.of(context).unfocus();
    //   return;
    // }
    final url = Uri.parse(baseUrl + lookupkeys);
    print('LookupdetailsApi: $url');
    // Send the POST request
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );
    print('Lookupdetailsresponse:$response');
    //  final response = await http.get(Uri.parse(baseUrl + lookupkeys));
    // final url = Uri.parse(baseUrl + getlogin);
    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonData = json.decode(response.body);
      Map<String, dynamic> lookups = jsonData['Lookups'];

      // Save DayWorkStatus in SharedPreferences
      saveDayWorkStatus(lookups['DayWorkStatus']);
      saveLeaveReasons(lookups['LeaveReasons']);
      saveResignationReason(lookups['ResignationReasons']);
      saveBloodGroups(lookups['BloodGroups']);
      // Return the entire response as a Map<String, dynamic>
      return jsonData;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception(
          'Failed to load Lookup Keys. Status Code: ${response.statusCode}');
    }
  }

// Function to save DayWorkStatus in SharedPreferences
  Future<void> saveDayWorkStatus(int dayWorkStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dayWorkStatus', dayWorkStatus);
  }

  Future<void> saveResignationReason(int Resignationreq) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ResignationReasons', Resignationreq);
  }

  Future<void> saveBloodGroups(int Resignationreq) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('BloodGroups', Resignationreq);
  }

  Future<void> saveLeaveReasons(int LeaveReasons) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('leavereasons', LeaveReasons);
  }
}
 */
// class AuthService {
//   static Future<void> saveAuthData(
//       String accessToken, String refreshToken, String employeeId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('accessToken', accessToken);
//     prefs.setString('refreshToken', refreshToken);
//     prefs.setString('employeeId', employeeId);
//   }
//
//   static Future<void> saveSecondApiResponse(
//       Map<String, dynamic> responseData) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('secondApiResponse', json.encode(responseData));
//   }
// }
class CustomCircularProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 50, // Adjust the width as needed
        height: 50, // Adjust the height as needed
        // decoration: BoxDecoration(
        // color: Colors.white,
        //  shape: BoxShape.circle,
        // gradient: LinearGradient(
        //   colors: [
        //     Colors.blue,
        //     Colors.green,
        //   ],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
        //),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 33.0,
              width: 33.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/cislogo-new.svg',
                height: 30.0,
                width: 30.0,
              ),
            ),
            CircularProgressIndicator(
              strokeWidth:
                  3, // Adjust the stroke width of the CircularProgressIndicator
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFf15f22),
              ), // Color for the progress indicator itself
            ),
          ],
        ),
      ),
    );
  }
}

// class ProgressDialog {
//   final BuildContext context;
//   late bool _isShowing;
//
//   ProgressDialog(this.context) {
//     _isShowing = false;
//     show();
//   }
//
//   Future<void> show() async {
//     if (!_isShowing) {
//       _isShowing = true;
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//        useRootNavigator: true,
//        useSafeArea: true,
//       ///  barrierColor:  Colors.grey.shade50.withOpacity(0.35),
//        // barrierColor:  Colors.transparent,
//         builder: (BuildContext context) {
//           return  Center(
//               child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                    /// color: Colors.grey.shade50.withOpacity(0.001),
//                     color: Colors.transparent
//
//                   ),
//                   padding: const EdgeInsets.all(20),
//                  // child: const CircularProgressIndicator.adaptive()));
//                   child:  Container(
//                   width: MediaQuery.of(context).size.width/1.8, // Adjust the width as needed
//             height: MediaQuery.of(context).size.height/4, // Adjust the height as needed
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               shape: BoxShape.rectangle,
//               // gradient: LinearGradient(
//               //   colors: [
//               //     Colors.blue,
//               //     Colors.green,
//               //   ],
//               //   begin: Alignment.topCenter,
//               //   end: Alignment.bottomCenter,
//               // ),
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   height: 40.0,
//                   width: 40.0,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                   ),
//                   child: SvgPicture.asset(
//                     'assets/cislogo-new.svg',
//                     height: 35.0,
//                     width: 35.0,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 40.0,
//                   width: 40.0,
//                   child:    CircularProgressIndicator(
//                     strokeWidth: 3, // Adjust the stroke width of the CircularProgressIndicator
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Color(0xFFf15f22),
//                     ), // Color for the progress indicator itself
//                   ),
//                 )
//
//               ],
//             ),
//           )));
//           //   Center(
//           //   child:
//           //   Container(
//           //     width: MediaQuery.of(context).size.width/1.8, // Adjust the width as needed
//           //     height: MediaQuery.of(context).size.height/4, // Adjust the height as needed
//           //     decoration: BoxDecoration(
//           //     color: Colors.transparent,
//           //      shape: BoxShape.rectangle,
//           //     // gradient: LinearGradient(
//           //     //   colors: [
//           //     //     Colors.blue,
//           //     //     Colors.green,
//           //     //   ],
//           //     //   begin: Alignment.topCenter,
//           //     //   end: Alignment.bottomCenter,
//           //     // ),
//           //     ),
//           //     child: Stack(
//           //       alignment: Alignment.center,
//           //       children: [
//           //         Container(
//           //           height: 33.0,
//           //           width: 33.0,
//           //           decoration: BoxDecoration(
//           //             color: Colors.white,
//           //             shape: BoxShape.circle,
//           //           ),
//           //           child: SvgPicture.asset(
//           //             'assets/cislogo-new.svg',
//           //             height: 30.0,
//           //             width: 30.0,
//           //           ),
//           //         ),
//           //         CircularProgressIndicator(
//           //           strokeWidth: 3, // Adjust the stroke width of the CircularProgressIndicator
//           //           valueColor: AlwaysStoppedAnimation<Color>(
//           //             Color(0xFFf15f22),
//           //           ), // Color for the progress indicator itself
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // );
//         },
//       );
//       _isShowing = false; // Set isShowing back to false after dialog is dismissed
//     }
//   }
//
//   void dismiss() {
//     if (_isShowing) {
//       _isShowing = false;
//       Navigator.of(context).pop();
//     }
//   }
// }
//
