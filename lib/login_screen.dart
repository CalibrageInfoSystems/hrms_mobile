import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/changepassword.dart';
import 'package:hrms/common_widgets/custom_textfield.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/security_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:hrms/styles.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool isRequestProcessing = false;
  bool _commonError = false;
  String? _commonErrorMsg;

  @override
  void initState() {
    super.initState();

    // _userNameController.text = 'BakiHanm';
    // _passwordController.text = 'Test@123';

    _userNameController.text = 'CIS00054';
    _passwordController.text = 'Ranjith@469';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_layer_2.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      logoNdTitle(),
                      const SizedBox(height: 20),
                      userNameField(),
                      const SizedBox(height: 20),
                      passwordField(),
                      const SizedBox(height: 15),
                      forgotpasswordField(),
                      const SizedBox(height: 30),
                      signinBtn(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column logoNdTitle() {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/cislogo-new.svg',
          height: 120.0,
          width: 55.0,
        ),
        const SizedBox(height: 2.0),
        const Text(
          'TEST HRMS',
          style: TextStyle(
            color: Color(0xFFf15f22),
            fontSize: 26.0,
            fontFamily: 'Calibri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  //MARK: Sign in
  SizedBox signinBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isRequestProcessing
            ? null
            : () async {
                if (validateForm()) {
                  signIn();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isRequestProcessing ? Colors.grey.shade400 : Styles.primaryColor,
          elevation: isRequestProcessing ? 0 : 2,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: const Text(
          'Sign in',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontFamily: 'Calibri'),
        ),
      ),
    );
  }

  Row forgotpasswordField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => securityscreen()),
            );
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
                color: Color(0xFFf15f22), fontSize: 14, fontFamily: 'Calibri'),
          ),
        ),
      ],
    );
  }

  CustomTextField userNameField() {
    return CustomTextField(
      hintText: 'User Name',
      readOnly: false,
      controller: _userNameController,
      errorText: _commonError ? _commonErrorMsg : null,
      maxLength: 8,
      inputFormatters: [
        // Allow only alphanumeric characters
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      onChanged: (value) {
        if (value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
          // If the text contains characters other than alphanumeric, remove those characters
          _userNameController.text =
              value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          _userNameController.selection = TextSelection.fromPosition(
            TextPosition(offset: _userNameController.text.length),
          );
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          _commonError = false;
          return 'Please enter user name';
        }
        return null;
      },
    );
  }

  CustomTextField passwordField() {
    return CustomTextField(
      hintText: 'Password',
      readOnly: false,
      controller: _passwordController,
      errorText: _commonError ? _commonErrorMsg : null,
      maxLength: 25,
      counterText: '',
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.black,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          _commonError = false;
          return 'Please enter password';
        }
        return null;
      },
    );
  }

  bool validateForm() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        isRequestProcessing = true;
        _commonError = false;
      });
      return true;
    }
    return false;
  }

  Future<void> signIn() async {
    FocusScope.of(context).unfocus();
    ProgressDialog progressDialog = ProgressDialog(context);
    try {
      final isConnected = await Commonutils.checkInternetConnectivity();
      if (!isConnected) {
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection', context, 1, 4);
        return;
      }

      setState(() {
        progressDialog.show();
      });

      String username = _userNameController.text.toString().trim();
      String password = _passwordController.text.toString().trim();

      final apiUrl = Uri.parse('$baseUrl$getlogin');
      final requestBody = jsonEncode(
          {"userName": username, "password": password, "rememberMe": true});
      print('signIn: $apiUrl');
      print('signIn: $requestBody');
      final jsonResponse = await http.post(
        apiUrl,
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = json.decode(jsonResponse.body);

        final accessToken = response['accessToken'];
        // final refreshToken = response['refreshToken'];

        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);

        final isFirstTimeLogin = decodedToken['IsFirstTimeLogin'];
        final userid = decodedToken['Id'];
        final employeeId = decodedToken['EmployeeId'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("accessToken", accessToken!);
        prefs.setString(SharedKeys.employeeId, employeeId!);
        prefs.setString(SharedKeys.userId, userid!);

        empolyelogin(
            employeeId!, isFirstTimeLogin, userid, progressDialog, accessToken);
      } else {
        setState(() {
          progressDialog.dismiss();
          isRequestProcessing = false;
          _commonError = true;
          _commonErrorMsg = 'Invalid Username or Password ';
        });
        Commonutils.showCustomToastMessageLong(
            'Invalid Username or Password ', context, 1, 4);
      }
    } catch (e) {
      setState(() {
        progressDialog.dismiss();
        isRequestProcessing = false;
      });

      print('catch: $e');
      rethrow;
    }
  }

  Future<void> empolyelogin(String empolyeid, String isfirstTime, String userid,
      ProgressDialog progressDialog, String? accessToken) async {
    try {
      final url = Uri.parse(baseUrl + getselfempolyee + empolyeid);
      final response = await http.get(
        url,
        headers: {
          'Authorization': '$accessToken',
        },
      );
      setState(() {
        progressDialog.dismiss();
        isRequestProcessing = false;
      });
      if (response.statusCode == 200) {
        fetchLookupKeys(accessToken);
        final Map<String, dynamic> responseData = json.decode(response.body);

        await SharedPreferencesHelper.saveCategories(responseData);

        if (isfirstTime == 'True') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => ChangePasword(
                      userid: userid,
                      newpassword: '',
                      confirmpassword: '',
                    )),
          );
        } else if (isfirstTime == 'False') {
          DateTime loginTime = DateTime.now();
          String formattedTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(loginTime);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(SharedKeys.loginTime, formattedTime);
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );
        }
      } else {
        Commonutils.showCustomToastMessageLong(
            'Error  ${response.statusCode}', context, 1, 4);
      }
    } catch (e) {
      setState(() {
        progressDialog.dismiss();
        isRequestProcessing = false;
      });
      print('catch: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchLookupKeys(String? accessToken) async {
    final url = Uri.parse(baseUrl + lookupkeys);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      Map<String, dynamic> lookups = jsonData['Lookups'];

      // Save DayWorkStatus in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('dayWorkStatus', lookups['DayWorkStatus']);
      prefs.setInt('leavereasons', lookups['LeaveReasons']);
      prefs.setInt('ResignationReasons', lookups['ResignationReasons']);
      prefs.setInt('BloodGroups', lookups['BloodGroups']);
      return jsonData;
    } else {
      throw Exception(
          'Failed to load Lookup Keys. Status Code: ${response.statusCode}');
    }
  }
}