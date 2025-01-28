import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/login_screen.dart';
import 'package:http/http.dart' as http;

import 'Commonutils.dart';
import 'main.dart';

class securityscreen extends StatefulWidget {
  @override
  _securityscreenscreenState createState() => _securityscreenscreenState();
}

class _securityscreenscreenState extends State<securityscreen>
    with TickerProviderStateMixin {
  int currentstep = 0;
  bool isCompleted = false;
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _confirmcontroller = TextEditingController();
  final TextEditingController _reconfirmcontroller = TextEditingController();
  final TextEditingController _answer_1_controller = TextEditingController();
  final TextEditingController _answer_2_controller = TextEditingController();
  bool isLoading = false;
  bool isFirstApiCall = true;
  bool _obscureText_confirm = true;
  bool _obscureText_reconfirm = true;
  List<Map<String, dynamic>> questionsAndAnswers = [];
  List<Map<String, dynamic>> additionalQuestionsAndAnswers = [];
  int noofquestionavaiable = 0;
  String? Question_1,
      Question_2,
      Answer_1,
      Answer_2,
      api_answer_1,
      api_answer_2;
  Map<int, TextEditingController> _answerControllers = {};

  @override
  void initState() {
    // username = _usernamecontroller.text;
    for (var qa in questionsAndAnswers) {
      _answerControllers[qa['questionId']] = TextEditingController();
    }
  }

  void _togglePasswordVisibilityconfrim() {
    setState(() {
      _obscureText_confirm = !_obscureText_confirm;
    });
  }

  void _togglePasswordVisibilityreconfrim() {
    setState(() {
      _obscureText_reconfirm = !_obscureText_reconfirm;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          // Handle back button press here
          // You can add any custom logic before closing the app
          return true; // Return true to allow back button press and close the app
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0, top: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            // Handle the back button press here
                            // Navigator.pop(context);
                            Navigator.maybePop(context);
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // Change the color as needed
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(
                                  0xFFF44614), // Change the color as needed
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
            body: Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: Color(0xFFf15f22))),
              child: SingleChildScrollView(
                child: Container(
                  height: screenHeight,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/background_layer_2.png',
                      ), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Container(
                      //       padding: EdgeInsets.only(left: 25.0, top: 25.0),
                      //       child: GestureDetector(
                      //         onTap: () {
                      //           // Handle the back button press here
                      //           Navigator.pop(context);
                      //         },
                      //         child: Container(
                      //           width: 40.0,
                      //           height: 40.0,
                      //           decoration: BoxDecoration(
                      //             shape: BoxShape.circle,
                      //             color: Colors.white, // Change the color as needed
                      //           ),
                      //           child: Icon(
                      //             Icons.arrow_back,
                      //             color: Color(
                      //                 0xFFF44614), // Change the color as needed
                      //           ),
                      //         ),
                      //       ),
                      //     )),
                      Padding(
                        padding: EdgeInsets.only(top: 35.0),
                        child: SvgPicture.asset(
                          'assets/cislogo-new.svg',
                          height: 120.0,
                          width: 55.0,
                          //  color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Calibri',
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      SingleChildScrollView(
                          child: Stepper(
                        type: StepperType.vertical,
                        currentStep: currentstep,
                        onStepTapped: (step) {
                          List<bool> completedSteps = List.generate(
                              getSteps().length, (index) => false);

                          //setState(() => currentstep = step);
                          if (step > 0 && !completedSteps[step - 1]) {
                            Commonutils.showCustomToastMessageLong(
                                'Please Complete Previous Steps',
                                context,
                                1,
                                4);
                            // You may show a message or take other actions to inform the user
                            // that they need to complete the previous step first.
                            return;
                          }
                          if (currentstep == 0) {
                            // Check if the username field is empty
                            if (_usernamecontroller.text.isEmpty) {
                              // Show a toast message indicating that the username field is required
                              Commonutils.showCustomToastMessageLong(
                                  'Complete the Username', context, 1, 4);
                              return; // Return to prevent proceeding to the next step
                            }
                          }
                        },
                        controlsBuilder:
                            (BuildContext context, ControlsDetails details) {
                          // if (currentstep == getSteps().length - 1) {
                          //   return SizedBox(); // Return an empty container if it's the last step
                          // } else {
                          if (currentstep == 0) {
                            // Hide the "Previous" button in the first step
                            return Row(
                              children: <Widget>[
                                Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: details.onStepContinue,
                                      child: Text(
                                        'Next',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else if (currentstep == 2) {
                            return Row(
                              children: <Widget>[
                                Spacer(),
                                // TextButton(
                                //   onPressed: details.onStepContinue,
                                //   child: const Text('NEXT'),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    //  width: double.infinity,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // Adjust the border radius as needed
                                    ),
                                    child: ElevatedButton(
                                      onPressed: details.onStepCancel,
                                      child: Text(
                                        'Previous',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 25.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    //  width: double.infinity,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // Adjust the border radius as needed
                                    ),
                                    child: ElevatedButton(
                                      onPressed: details.onStepContinue,
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // TextButton(
                                //   onPressed: details.onStepCancel,
                                //   child: const Text('Previous'),
                                // ),
                              ],
                            );
                          } else {
                            return Row(
                              children: <Widget>[
                                Spacer(),
                                // TextButton(
                                //   onPressed: details.onStepContinue,
                                //   child: const Text('NEXT'),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    //  width: double.infinity,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // Adjust the border radius as needed
                                    ),
                                    child: ElevatedButton(
                                      onPressed: details.onStepCancel,
                                      child: Text(
                                        'Previous',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 25.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    //  width: double.infinity,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // Adjust the border radius as needed
                                    ),
                                    child: ElevatedButton(
                                      onPressed: details.onStepContinue,
                                      child: Text(
                                        'Next',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // TextButton(
                                //   onPressed: details.onStepCancel,
                                //   child: const Text('Previous'),
                                // ),
                              ],
                            );
                          }
                        },
                        // controlsBuilder: (context, {onStepContinue, onStepCancel}) {},
                        onStepContinue: () async {
                          // final islaststep = currentstep == getSteps().length - 1;
                          // if (islaststep) {
                          //   // Handle last step
                          //   //setState(() => isCompleted = true);
                          //   return;
                          // }
                          //  else {
                          // setState(() => currentstep += 1);
                          switch (currentstep) {
                            case 0:
                              // Call API for Step 1
                              if (_usernamecontroller.text.trim().isEmpty) {
                                FocusScope.of(context).unfocus();
                                Commonutils.showCustomToastMessageLong(
                                    'Please Enter The User Name',
                                    context,
                                    1,
                                    4);

                                return; // Return to prevent proceeding to the next step
                              } else {
                                await fetchquestion(
                                    _usernamecontroller.text.trim());
                              }

                              // setState(() => currentstep += 1);

                              break;
                            case 1:
                              // Call API for Step 2
                              await validatinganswer();
                              //  setState(() => currentstep += 1);
                              break;
                            case 2:
                              // Call API for Step 3.

                              await checkingpassword();
                              // Call API for Step 3 and validate passwords

                              // Commonutils.showCustomToastMessageLong(
                              //     'it is clicked', context, 1, 4);
                              // setState(() => currentstep += 1);
                              break;

                            // Add more cases for additional steps as needed
                          }
                          // }
                        },

                        onStepCancel: () {
                          setState(() => currentstep -= 1);
                        },
                        steps: getSteps(),
                      )),
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
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Back to SignIn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Calibri',
                              ),
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
            ),
          ),
        ));
  }

  List<Step> getSteps() => [
        Step(
          state: currentstep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentstep >= 0,
          title: Text('User Name'),
          content: Padding(
            padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0),
            child: TextFormField(
              ///     keyboardType: TextInputType.name,
              maxLength: 8,
              controller: _usernamecontroller,
              onTap: () {
                // requestPhonePermission();
              },
              decoration: InputDecoration(
                  hintText: 'Enter User Name',
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
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        ),
        Step(
          isActive: currentstep >= 1,
          state: currentstep > 1 ? StepState.complete : StepState.indexed,
          title: Text('Security Questions'),
          content: SingleChildScrollView(
              child: Column(
            children: [
              Visibility(
                visible: noofquestionavaiable > 2,
                child: Row(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Available Questions: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Calibri',
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            ' $noofquestionavaiable',
                            style: TextStyle(
                                color: Color(0xFFf15f22),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Calibri'),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        fetchrefreshquestion(_usernamecontroller.text)
                            .then((_) {
                          setState(() {
                            isLoading = false;
                          });
                        });
                        print('Floating Action Button Pressed');
                      },
                      child: isLoading
                          ? RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  curve: Curves.fastOutSlowIn,
                                  parent: AnimationController(
                                    vsync: this,
                                    duration: Duration(seconds: 1),
                                  )..repeat(),
                                ),
                              ),
                              child: Icon(Icons.refresh),
                            )
                          : Icon(Icons.refresh),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${Question_1}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Calibri'),
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0),
                    child: TextFormField(
                      controller: _answer_1_controller,
                      decoration: InputDecoration(
                        hintText: 'Please Enter your Answer',
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
                          color: Colors.black26,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        alignLabelWithHint: true,
                        counterText: "",
                      ),
                      maxLength: 50,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Calibri',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${Question_2}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Calibri'),
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0),
                    child: TextFormField(
                      controller: _answer_2_controller,
                      decoration: InputDecoration(
                        hintText: 'Please Enter your Answer',
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
                          color: Colors.black26,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        alignLabelWithHint: true,
                        counterText: "",
                      ),
                      maxLength: 50,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Calibri',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ],
          )),
        ),
        Step(
          isActive: currentstep >= 2,
          state: currentstep > 2 ? StepState.complete : StepState.indexed,
          title: Text('Change Password'),
          content: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0),
                child: TextFormField(
                  ///     keyboardType: TextInputType.name,
                  obscureText: _obscureText_confirm,
                  controller: _confirmcontroller,
                  onTap: () {},

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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    alignLabelWithHint: true,
                    counterText: "",
                    suffixIcon: GestureDetector(
                      onTap: _togglePasswordVisibilityconfrim,
                      child: Icon(
                        _obscureText_confirm
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
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.0, left: 0.0, right: 0.0),
                child: TextFormField(
                  ///     keyboardType: TextInputType.name,
                  obscureText: _obscureText_reconfirm,
                  controller: _reconfirmcontroller,
                  onTap: () {
                    // requestPhonePermission();
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    alignLabelWithHint: true,
                    counterText: "",
                    suffixIcon: GestureDetector(
                      onTap: _togglePasswordVisibilityreconfrim,
                      child: Icon(
                        _obscureText_reconfirm
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
            ],
          ),
        ),
        // Step(
        //   isActive: currentstep >= 3,
        //   state: currentstep > 3 ? StepState.complete : StepState.indexed,
        //   title: Text('Success'),
        //   content: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       SvgPicture.asset(
        //         "assets/right_n.svg",
        //         width: 80.0,
        //         height: 70.0,
        //         color: Colors.green,
        //       ),
        //       Padding(
        //         padding: EdgeInsets.only(top: 35.0, left: 40.0, right: 40.0),
        //         child: Container(
        //           width: 130,
        //           decoration: BoxDecoration(
        //             color: Color(0xFFf15f22),
        //             borderRadius: BorderRadius.circular(6.0),
        //             // Adjust the border radius as needed
        //           ),
        //           child: ElevatedButton(
        //             onPressed: () async {

        //             },
        //             child: Text(
        //               'Back to Login',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 16,
        //                 fontFamily: 'hind_semibold',
        //               ),
        //             ),
        //             style: ElevatedButton.styleFrom(
        //               primary: Colors.transparent,
        //               elevation: 0,
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(4.0),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ];

  // Future<void> fetchquestion(String username) async {
  //   try {
  //     final apiUrl = baseUrl + getquestions + username;
  //     print('API Request: $apiUrl');
  //
  //     final response = await http.get(Uri.parse(apiUrl));
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       print('API Response: $data');
  //       setState(() {
  //         questionsAndAnswers = List<Map<String, dynamic>>.from(data);
  //       });
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  Future<void> fetchquestion(String username) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    //FocusScope.of(context).unfocus();
    try {
      final apiUrl = baseUrl + getquestions + username;
      print('API Request: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Username is valid, navigate to another screen and increment currentstep only on the first API call
          // if (isFirstApiCall) {
          //   Commonutils.showCustomToastMessageLong(
          //       'Username Successful', context, 0, 2);
          //   setState(() => currentstep += 1);
          //
          //   isFirstApiCall =
          //       false; // Set the flag to false after the first API call
          // }
          if (data.isNotEmpty) {
            // Commonutils.showCustomToastMessageLong('${response.body}', context, 0, 2);
            setState(() => currentstep += 1);

            // isFirstApiCall =
            //     false; // Set the flag to false after the first API call
          }
          // setState(() => currentstep -= 1);
          setState(() {
            questionsAndAnswers = List<Map<String, dynamic>>.from(data);
            print('questions${questionsAndAnswers}');
            if (questionsAndAnswers.isNotEmpty) {
              String questionString =
                  questionsAndAnswers[0]['question'].toString();
              String questionString_1 =
                  questionsAndAnswers[1]['question'].toString();
              api_answer_1 = questionsAndAnswers[0]['answer'].toString();
              api_answer_2 = questionsAndAnswers[1]['answer'].toString();
              noofquestionavaiable =
                  questionsAndAnswers[0]['userSecureQuestionsCount'];
              print('noofquestionavailable:$noofquestionavaiable');
              Question_1 = questionString;
              Question_2 = questionString_1;
              Answer_1 = api_answer_1;
              Answer_2 = api_answer_2;

              print('Question_1: $Question_1');
              print('Question_2: $Question_2');
              print('Answer_1: $api_answer_1');
              print('Answer_2: $api_answer_2');
            }
          });
        } else {
          // Commonutils.showCustomToastMessageLong('You Are Trying To Login For The First Time, So Get Credentials From Admin', context, 1, 4);
          print('Invalid username');
        }
      } else {
        Commonutils.showCustomToastMessageLong(
            '${response.body}', context, 1, 2);
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error, show an error message, etc.
    }
  }

  Future<void> fetchrefreshquestion(String username) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    try {
      final apiUrl = baseUrl + getquestions + username;
      print('API Request: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Username is valid, navigate to another screen and increment currentstep only on the first API call
          // if (isFirstApiCall) {
          //   Commonutils.showCustomToastMessageLong(
          //       'Username Successful', context, 0, 2);
          //   setState(() => currentstep += 1);
          //
          //   isFirstApiCall =
          //   false; // Set the flag to false after the first API call
          // }
          // if (data.isNotEmpty) {
          //   Commonutils.showCustomToastMessageLong(
          //       'Username Successful', context, 0, 2);
          //   setState(() => currentstep += 1);
          //
          //   // isFirstApiCall =
          //   //     false; // Set the flag to false after the first API call
          // }
          // setState(() => currentstep -= 1);
          setState(() {
            questionsAndAnswers = List<Map<String, dynamic>>.from(data);
            print('questions${questionsAndAnswers}');
            if (questionsAndAnswers.isNotEmpty) {
              String questionString =
                  questionsAndAnswers[0]['question'].toString();
              String questionString_1 =
                  questionsAndAnswers[1]['question'].toString();
              api_answer_1 = questionsAndAnswers[0]['answer'].toString();
              api_answer_2 = questionsAndAnswers[1]['answer'].toString();
              noofquestionavaiable =
                  questionsAndAnswers[1]['userSecureQuestionsCount'];
              Question_1 = questionString;
              Question_2 = questionString_1;
              Answer_1 = api_answer_1;
              Answer_2 = api_answer_2;

              _answer_1_controller.clear();
              _answer_2_controller.clear();
              print('Question_1: $Question_1');
              print('Question_2: $Question_2');
              print('Answer_1: $api_answer_1');
              print('Answer_2: $api_answer_2');
            }
          });
        } else {
          // Username is not valid, show an error message
          //    Commonutils.showCustomToastMessageLong('Please Enter Valid Username', context, 1, 4);
          print('Invalid username');
          // You can show an error message or handle it as needed.
        }
      } else {
        // Commonutils.showCustomToastMessageLong('Please Enter Valid Username', context, 1, 4);
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // Handle the error, show an error message, etc.
    }
  }

  Future<void> validatinganswer() async {
    FocusScope.of(context).unfocus();
    String answer1 = _answer_1_controller.text.trim();
    String answer2 = _answer_2_controller.text.trim();

    if (answer1.isEmpty || answer2.isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Your Answer', context, 1, 4);
      return;
    }

    if (answer1 == api_answer_1 && answer2 == api_answer_2) {
      // Answers match, navigate to the next step
      setState(() {
        currentstep += 1;
        //  Commonutils.showCustomToastMessageLong('Answers are Correct', context, 0, 2);
      });
    } else {
      // Answers do not match, show an error message
      Commonutils.showCustomToastMessageLong(
          'Incorrect Answers. Please try again.', context, 1, 4);
    }
  }

  // Future<void> validatinganswer() async {
  //   _answer_1_controller.clear();
  //   _answer_2_controller.clear();
  //   bool isValid = true;
  //   bool hasValidationFailed = false;
  //   if (isValid && _answer_1_controller.text.trim().isEmpty) {
  //     Commonutils.showCustomToastMessageLong(
  //         'Please Enter Your Answer ', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //     FocusScope.of(context).unfocus();
  //   }
  //   if (isValid && _answer_2_controller.text.trim().isEmpty) {
  //     Commonutils.showCustomToastMessageLong(
  //         'Please Enter Your Answer ', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //     FocusScope.of(context).unfocus();
  //   }
  //   if (isValid) {
  //     if (_answer_1_controller.text.trim() == api_answer_1 &&
  //         _answer_2_controller.text.trim() == api_answer_2) {
  //       // Answers match, navigate to the next step
  //       setState(() {
  //         currentstep += 1;
  //         Commonutils.showCustomToastMessageLong(
  //             ' Answers are Correct', context, 0, 2);
  //         _answer_1_controller.clear();
  //         _answer_2_controller.clear();
  //       });
  //     } else {
  //       // setState(() {
  //       //   _answer_1_controller.clear();
  //       //   _answer_2_controller.clear();
  //       // });
  //       // Answers do not match, show an error message
  //       Commonutils.showCustomToastMessageLong(
  //           'Incorrect Answers. Please try again.', context, 1, 4);
  //     }
  //   } else {}
  // }

  Future<void> checkingpassword() async {
    String password1 = _confirmcontroller.text.trim().toString();
    String password2 = _reconfirmcontroller.text.trim().toString();

    // if (password1.isEmpty || password2.isEmpty) {
    //   if (password1.isEmpty) {
    //     Commonutils.showCustomToastMessageLong(
    //         'Please enter Confirm Password', context, 1, 4);
    //   }
    //   if (password2.isEmpty) {
    //     Commonutils.showCustomToastMessageLong(
    //         'Please enter Re Confirm Password', context, 1, 4);
    //   }
    // }
    // if (password1.trim().isEmpty && password2.trim().isEmpty) {
    //   Commonutils.showCustomToastMessageLong(
    //       'Please Enter password', context, 1, 4);
    //   return;
    // } else

    if (password1.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter New Password', context, 1, 4);
      return;
    } else if (password2.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Confirm Password', context, 1, 4);
      return;
    }
    if (password1.trim() == password2.trim()) {
      if (isPasswordValid(password2.trim())) {
        changepasswordapi(password2.trim());
      } else {
        Commonutils.showCustomToastMessageLong(
            'Password must Contain 1 Lowercase, 1 Uppercase, Numbers, Special Characters, and be Between 8 to 25 Characters in Length. Please Correct it.',
            context,
            1,
            6);
      }
    } else {
      // setState(() {
      //   _confirmcontroller.clear(); // Clear the text in the TextEditingController
      //   _reconfirmcontroller.clear(); // Clear the text in the TextEditingController
      // });
      Commonutils.showCustomToastMessageLong(
          'Passwords do not match Please Correct it', context, 1, 4);
    }
  }

  bool isPasswordValid(String password) {
    // Password must contain 1 lowercase, 1 uppercase, numbers, special characters, and be between 8 to 20 characters in length.
    RegExp passwordRegex = RegExp(
        r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,25}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> changepasswordapi(String reconfrimpassword) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final request = {
      "userName": _usernamecontroller.text.trim(),
      "password": reconfrimpassword.trim(),
    };
    try {
      final url = Uri.parse(baseUrl + changepassword);
      print('changepasswordurl: $url');
      // Send the POST request
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json', // Set the content type header
        },
      );
      print('changepasswordresponse$response');
      print('request$request');
      print('login response: ${response.statusCode}');
      print('statusCode=====>${response.statusCode}');

      if (response.statusCode == 200) {
        Commonutils.showCustomToastMessageLong(
            'Password Changed Succesfully!', context, 0, 4);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        setState(() {
          //  currentstep += 1;
        });
      } else {
        FocusScope.of(context).unfocus();

        print('response is not success');

        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

// Future<void> fetchquestion(String username) async {
//   try {
//     final apiUrl = baseUrl + getquestions + username;
//     print('API Request: $apiUrl');
//
//     final response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//
//       if (data.isNotEmpty) {
//         // Username is valid, navigate to another screen
//
//         Commonutils.showCustomToastMessageLong(
//             'Username Successful', context, 0, 2);
//         setState(() => currentstep += 1);
//         setState(() {
//           questionsAndAnswers = List<Map<String, dynamic>>.from(data);
//         });
//       } else {
//         // Username is not valid, show an error message
//         Commonutils.showCustomToastMessageLong(
//             'Please Enter Valid Username', context, 1, 4);
//         print('Invalid username');
//         // You can show an error message or handle it as needed.
//       }
//     } else {
//       Commonutils.showCustomToastMessageLong(
//           'Please Enter Valid Username', context, 1, 4);
//       throw Exception('Failed to load data');
//     }
//   } catch (e) {
//     print('Error: $e');
//     // Handle the error, show an error message, etc.
//   }
// }
}
// Future<void> fetchquestion(String username) async {
//   try {
//     final apiUrl = baseUrl + getquestions + username;
//     print('API Request: $apiUrl');
//
//     final response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print('API Response: $data');
//
//       // Check if the data is valid (customize this based on your API response structure)
//       if (data[0] == 'valid') {
//         // Navigate to another screen if the username is valid
//         setState(() => currentstep += 1);
//       } else {
//         // Handle the case when the username is not valid (show error message, etc.)
//         print('Invalid username');
//         // You can show an error message or handle it as needed.
//       }
//     } else {
//       throw Exception('Failed to load data');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }
