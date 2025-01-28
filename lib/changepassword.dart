import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/security_questions.dart';

import 'Commonutils.dart';
import 'main.dart';

class ChangePasword extends StatefulWidget {
  final String newpassword;
  final String confirmpassword;
  final String userid;
  ChangePasword(
      {required this.newpassword,
      required this.confirmpassword,
      required this.userid});
  @override
  _changepasswordState createState() => _changepasswordState();
}

class _changepasswordState extends State<ChangePasword> {
  late TextEditingController _passwordcontroller = TextEditingController();
  late TextEditingController _confirmpasswordcontroller =
      TextEditingController();
  bool _newpassword = true;
  bool _confirmpassword = true;

  void _togglePasswordVisibilitynewpassword() {
    setState(() {
      _newpassword = !_newpassword;
    });
  }

  void _togglePasswordVisibilityconfirmpassword() {
    setState(() {
      _confirmpassword = !_confirmpassword;
    });
  }

  @override
  void initState() {
    _passwordcontroller = TextEditingController(text: widget.newpassword);
    _confirmpasswordcontroller =
        TextEditingController(text: widget.confirmpassword);
    print('useridchangepassword:${widget.userid}');
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: MaterialApp(
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

                // Your Login Screen Widgets
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text Field for Username or Email

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
                      Text(
                        'Change Password',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Calibri',
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 25.0, left: 40.0, right: 40.0),
                        child: TextFormField(
                          ///     keyboardType: TextInputType.name,

                          controller: _passwordcontroller,
                          obscureText: _newpassword,
                          onTap: () {
                            // requestPhonePermission();
                          },
                          decoration: InputDecoration(
                            hintText: 'New Password',
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
                            counterText: "",
                            suffixIcon: GestureDetector(
                              onTap: _togglePasswordVisibilitynewpassword,
                              child: Icon(
                                _newpassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
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
                            EdgeInsets.only(top: 10.0, left: 40.0, right: 40.0),
                        child: TextFormField(
                          // keyboardType: TextInputType.phone,

                          controller: _confirmpasswordcontroller,
                          obscureText: _confirmpassword,
                          onTap: () {
                            //requestPhonePermission();
                          },

                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
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
                            counterText: "",
                            suffixIcon: GestureDetector(
                              onTap: _togglePasswordVisibilityconfirmpassword,
                              child: Icon(
                                _confirmpassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
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

                      // Login Button
                      Padding(
                        padding:
                            EdgeInsets.only(top: 30.0, left: 40.0, right: 40.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFf15f22),
                            borderRadius: BorderRadius.circular(6.0),
                            // Adjust the border radius as needed
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              textvalidate();
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

                      Padding(
                        padding:
                            EdgeInsets.only(top: 35.0, left: 90.0, right: 90.0),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6.0),
                          // Adjust the border radius as needed
                          elevation:
                              4.0, // Add elevation for a subtle shadow effect
                          shadowColor: Colors
                              .grey, // Customize the shadow color if needed
                          child: Container(
                            height: 35,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                  color: Color(0xFFf15f22), width: 1.5),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              child: Text(
                                'Back to Sign In',
                                style: TextStyle(
                                  color: Color(
                                      0xFFf15f22), // Change text color to contrast with white background
                                  fontSize: 16,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Set button color to transparent
                                elevation: 0, // Remove button elevation
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
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

  // Future<void> textvalidate() async {
  //   String password1 = _passwordcontroller.text.toString();
  //   String password2 = _confirmpasswordcontroller.text.toString();
  //
  //   bool isValid = true;
  //   bool hasValidationFailed = false;
  //   if (isValid && password1.trim().isEmpty) {
  //     Commonutils.showCustomToastMessageLong('Please Enter New Password', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //     FocusScope.of(context).unfocus();
  //   }
  //   if (isValid && password2.trim().isEmpty) {
  //     isValid = false;
  //     hasValidationFailed = true;
  //     Commonutils.showCustomToastMessageLong('Please Enter Confirm Password', context, 1, 4);
  //     FocusScope.of(context).unfocus();
  //   }
  //
  //   if (!hasValidationFailed && password1.trim() == password2.trim()) {
  //     FocusScope.of(context).unfocus();
  //     Commonutils.showCustomToastMessageLong('Passwords match', context, 0, 4);
  //   } else {
  //     FocusScope.of(context).unfocus();
  //     setState(() {
  //       _passwordcontroller.clear(); // Clear the text in the TextEditingController
  //       _confirmpasswordcontroller.clear(); // Clear the text in the TextEditingController
  //     });
  //     Commonutils.showCustomToastMessageLong('Passwords do not match. Please correct it', context, 1, 4);
  //   }
  //
  //   bool isConnected = await Commonutils.checkInternetConnectivity();
  //   if (isConnected) {
  //     print('Connected to the internet');
  //   } else {
  //     Commonutils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
  //     FocusScope.of(context).unfocus();
  //     print('Not connected to the internet');
  //   }
  // }
  Future<void> textvalidate() async {
    String password1 = _passwordcontroller.text.toString();
    String password2 = _confirmpasswordcontroller.text.toString();

    bool isValid = true;
    bool hasValidationFailed = false;

    if (password2.trim().isEmpty) {
      isValid = false;
      hasValidationFailed = true;
      Commonutils.showCustomToastMessageLong(
          'Please Enter Confirm Password', context, 1, 4);
      FocusScope.of(context).unfocus();
    }
    if (password1.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter New Password', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      FocusScope.of(context).unfocus();
    }
    if (isValid && password1.trim() == password2.trim()) {
      FocusScope.of(context).unfocus();
      if (isPasswordValid(password2.trim())) {
        //Commonutils.showCustomToastMessageLong('Passwords are Matched', context, 0, 4);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => security_questionsscreen(
                    newpassword: '$password1',
                    confirmpassword: '$password2',
                    userid: '${widget.userid}',
                  )),
        );
      } else {
        Commonutils.showCustomToastMessageLong(
            'Password must Contain 1 Lowercase, 1 Uppercase, Numbers, Special Characters, and be Between 8 to 25 Characters in Length. Please Correct it.',
            context,
            1,
            6);
      }
      // Commonutils.showCustomToastMessageLong('Passwords match', context, 0, 4);
    } else if (!hasValidationFailed) {
      FocusScope.of(context).unfocus();
      // setState(() {
      //   _passwordcontroller.clear(); // Clear the text in the TextEditingController
      //   _confirmpasswordcontroller.clear(); // Clear the text in the TextEditingController
      // });
      Commonutils.showCustomToastMessageLong(
          "Passwords Doesn't Match", context, 1, 4);
    }

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

  bool isPasswordValid(String password) {
    // Password must contain 1 lowercase, 1 uppercase, numbers, special characters, and be between 8 to 20 characters in length.
    RegExp passwordRegex = RegExp(
        r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,25}$');
    return passwordRegex.hasMatch(password);
  }
}
