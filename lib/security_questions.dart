import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Model%20Class/login%20model%20class.dart';
import 'package:hrms/changepassword.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/questions_model.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'main.dart';

class security_questionsscreen extends StatefulWidget {
//  final String userid;

  // security_questionsscreen({required this.userid});
  final String newpassword;
  final String confirmpassword;
  final String userid;
  security_questionsscreen({required this.newpassword, required this.confirmpassword, required this.userid});
  @override
  _securityscreenscreenState createState() => _securityscreenscreenState();
}

class _securityscreenscreenState extends State<security_questionsscreen> {
  List<Map<String, dynamic>> questions = [];
  List<Map<dynamic, dynamic>> selectedQuestionsAndAnswers = [];
  int? question_id;
  int selectedTypeCdId = -1;
  String? answerinlistview;
  int selectedValue = 0;
  late String selectedName;
  List<dynamic> responseData = [];
  String accessToken = '';
  List<int> answeredQuestionIds = [];
  List<int> deletedQuestionIndices = [];

  // String selectedQuestion =
  //     'Select a question'; // Initially, no question is selected
  List<questionmodel> questionlist = [];
  String? selectedQuestion;
  questionmodel? selectedquestionmodel;
  int? selectedQuestionId; // Initialize selectedQuestionId with null
  TextEditingController answercontroller = new TextEditingController();

  Future<void> fetchQuestions() async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    //  String apiUrl = 'http://182.18.157.215/HRMS/API/hrmsapi/Security/SecureQuestions';
    final response = await http.get(Uri.parse(baseUrl + fetchquestion));
    print('url>>>$response');
    // final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // setState(() {
      //   questions = (jsonDecode(response.body) as List<dynamic>)
      //       .cast<Map<String, dynamic>>();
      // });
      responseData = json.decode(response.body);

      setState(() {
        questionlist = (responseData).map((item) => questionmodel.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('useridinsecurityquestionscree:${widget.userid}');
    fetchQuestions();
    loadAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => ChangePasword(
                      newpassword: '${widget.newpassword}',
                      confirmpassword: '${widget.confirmpassword}',
                      userid: '${widget.userid}',
                    )),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: MaterialApp(
            // color: Color(0xFFF05F22),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: SingleChildScrollView(
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
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: [
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
                            'HRMS',
                            style: TextStyle(color: Color(0xFFf15f22), fontSize: 18, fontFamily: 'Calibri'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Security Questions',
                            style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Calibri', fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Note:',
                                  style: TextStyle(color: Color(0xFFf15f22), fontSize: 18, fontFamily: 'Calibri'),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  '1. A Minimum of Two Questions Need To Be Answered Out of 15 to Recover The Password When You Lose It.',
                                  style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Calibri'),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  '2. When You Select More Questions While Recovering a Password, The System Randomly Requests Only 2 Questions.',
                                  style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Calibri'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 35.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // Adjust the border radius as needed
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        _showAddQuestionDialog(context);
                                        fetchQuestions();
                                      },
                                      child: Text(
                                        'Add Question',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Calibri'),
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

                                // SizedBox(height: 10.0),
                              ],
                            )),
                        // SizedBox(height: 10.0),
                        Expanded(
                            child: FutureBuilder(
                          future: Future.value(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CustomCircularProgressIndicator();
                            } else if (snapshot.connectionState == ConnectionState.done) {
                              if (selectedQuestionsAndAnswers.isEmpty) {
                                return Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Text('Answered Questions Will Be Displayed Here'),
                                    ));
                              } else {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: selectedQuestionsAndAnswers.length,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  //physics: PageScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Handle tap on item if needed
                                        //  setState(() {
                                        question_id = int.tryParse(selectedQuestionsAndAnswers[index]['id']!);
                                        answerinlistview = selectedQuestionsAndAnswers[index]['answer'];
                                        //  });
                                        print('answerinlistview:${answerinlistview}');
                                        print('questionidclicked:${question_id}');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.orange,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        margin: EdgeInsets.only(bottom: 10.0),
                                        padding: EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  // Wrap the Text widget with Flexible
                                                  // flex: 1,
                                                  // fit: FlexFit.tight,
                                                  flex: 5,
                                                  child: Text(
                                                    '${selectedQuestionsAndAnswers[index]['question']}',
                                                    style: TextStyle(
                                                      color: Color(0xFFf15f22),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Calibri',
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    _removeQuestion(index);
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${selectedQuestionsAndAnswers[index]['answer']}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Calibri',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            } else {
                              return Text('Error: Unable to fetch data');
                            }
                          },
                        )),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              //        decoration: BoxDecoration(color: Colors.transparent),
                              //   color: Color(0xFFf0ab91),
                              padding: EdgeInsets.only(top: 12.0, left: 0.0, right: 0.0, bottom: 0.0),
                              child: Container(
                                width: double.infinity,
                                //color: Color(0x00ffffff),
                                decoration: BoxDecoration(
                                  color: Color(0xFFf15f22),
                                  borderRadius: BorderRadius.circular(5.0),
                                  // Adjust the border radius as needed
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    sendingQuestion();
                                  },
                                  child: Text(
                                    'Submit Security Questions',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Calibri'),
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
                            ))
                      ],
                    ),
                  ),
                ),
              ),
              // bottomNavigationBar: Container(
              //   //        decoration: BoxDecoration(color: Colors.transparent),
              //   color: Color(0xFFf0ab91),
              //   padding: EdgeInsets.only(
              //       top: 12.0, left: 10.0, right: 10.0, bottom: 10.0),
              //   child: Container(
              //     width: double.infinity,
              //     //color: Color(0x00ffffff),
              //     decoration: BoxDecoration(
              //       color: Color(0xFFf15f22),
              //       borderRadius: BorderRadius.circular(5.0),
              //       // Adjust the border radius as needed
              //     ),
              //     child: ElevatedButton(
              //       onPressed: () async {
              //         sendingQuestion();
              //       },
              //       child: Text(
              //         'Submit Security Questions',
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 16,
              //             fontFamily: 'Calibri'),
              //       ),
              //       style: ElevatedButton.styleFrom(
              //         primary: Colors.transparent,
              //         elevation: 0,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(4.0),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            )));
  }

  void _showAddQuestionDialog(BuildContext context) {
    answercontroller.text = '';
    selectedTypeCdId = -1;
    showDialog(
      // barrierDismissible: false,
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
                  Text(
                    "Select Security Questions",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Color(0xFFf15f22),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     // Navigator.of(context).pop();
                  //     Navigator.of(context).pop();
                  //     Navigator.of(context, rootNavigator: true).pop(context);
                  //     // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //     //     builder: (context) => security_questionsscreen(
                  //     //           newpassword: '${widget.newpassword}',
                  //     //           confirmpassword: '${widget.confirmpassword}',
                  //     //           userid: '${widget.userid}',
                  //     //         )));
                  //   },
                  //   child: Icon(
                  //     CupertinoIcons.multiply,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    //width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          // width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFf15f22),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedTypeCdId,
                              iconSize: 30,
                              icon: null,
                              isExpanded: true,
                              style: TextStyle(
                                color: Color(0xFFFB4110),
                                fontFamily: 'Calibri',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedTypeCdId = value!;
                                  print('selectedTypeCdId$selectedTypeCdId');
                                });
                              },
                              items: [
                                DropdownMenuItem<int>(
                                  value: -1,
                                  child: Text(
                                    '   Choose Your Question',
                                    style: TextStyle(
                                      color: Colors.black26, // Label text color
                                    ),
                                  ),
                                ),
                                // Filter out answered questions from responseData
                                ...responseData.where((question) => !answeredQuestionIds.contains(question['questionId'])).map((question) {
                                  return DropdownMenuItem<int>(
                                      value: question['questionId'],
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          question['question'],
                                          style: TextStyle(fontFamily: 'Calibri'),
                                        ),
                                      ));
                                }).toList(),
                              ],
                            ),
                          ),

                          //working code commented by Arun on 21st at 9:42
                          // child: DropdownButtonHideUnderline(
                          //   child: DropdownButton<int>(
                          //     value: selectedTypeCdId,
                          //     iconSize: 30,
                          //     icon: null,
                          //     isExpanded: true,
                          //     style: TextStyle(
                          //       color: Color(0xFFFB4110),
                          //       fontFamily: 'Calibri',
                          //     ),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         selectedTypeCdId = value!;
                          //         print('selectedTypeCdId$selectedTypeCdId');
                          //       });
                          //     },
                          //     items: [
                          //       DropdownMenuItem<int>(
                          //         value: -1,
                          //         child: Text(
                          //           'Choose Your Question',
                          //           style: TextStyle(
                          //             color: Colors.black26, // Label text color
                          //           ),
                          //         ),
                          //       ),
                          //       // Assuming responseData is your list of questions
                          //       ...responseData
                          //           .asMap()
                          //           .entries
                          //           .where((entry) =>
                          //               !answeredQuestionIds.contains(entry
                          //                   .key)) // Filter out answered questions
                          //           .map((entry) {
                          //         final index = entry.key;
                          //         final item = entry.value;
                          //         return DropdownMenuItem<int>(
                          //           value: item[
                          //               'questionId'], // Use question ID instead of index
                          //           child: Text(
                          //             item['question'],
                          //             style: TextStyle(fontFamily: 'Calibri'),
                          //           ),
                          //         );
                          //       }).toList(),
                          //     ],
                          //   ),
                          // ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          ///     keyboardType: TextInputType.name,

                          controller: answercontroller,
                          onTap: () {
                            // requestPhonePermission();
                          },
                          decoration: InputDecoration(
                            hintText: 'Please Enter Your Answer',
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
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            alignLabelWithHint: true,
                          ),
                          maxLength: 50,
                          textAlign: TextAlign.start,
                          style: TextStyle(
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
                  onPressed: () {
                    //    Navigator.of(context, rootNavigator: true).pop(context);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    _addQuestion();
                  },
                  child: Text(
                    'Add Question',
                    style: TextStyle(color: Colors.white, fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Set border radius
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

  void _addQuestion() {
    if (selectedTypeCdId == -1) {
      // Show toast or error message
      Commonutils.showCustomToastMessageLong('Please Select Question', context, 1, 4);
      return;
    }

    if (answercontroller.text.trim().isEmpty) {
      // Show toast or error message
      Commonutils.showCustomToastMessageLong('Please Enter Answer', context, 1, 4);
      return;
    }

    setState(() {
      final selectedQuestion = responseData.firstWhere((question) => question['questionId'] == selectedTypeCdId);
      selectedQuestionsAndAnswers.add({
        'question': selectedQuestion['question'], // Store the question text
        'questionId': selectedTypeCdId, // Store the question ID
        'answer': answercontroller.text.trim(),
        'id': selectedTypeCdId.toString()
      });

      // Add the ID of the answered question to the list of answered question IDs
      answeredQuestionIds.add(selectedQuestion['questionId']);
      // Remove deleted question indices from the list
      deletedQuestionIndices.remove(selectedTypeCdId);

      Navigator.of(context).pop();
    });
  }

  void _removeQuestion(int index) {
    if (selectedQuestionsAndAnswers.isNotEmpty && index >= 0 && index < selectedQuestionsAndAnswers.length) {
      setState(() {
        final removedQuestion = selectedQuestionsAndAnswers.removeAt(index);
        final removedQuestionId = removedQuestion['questionId'];
        if (!deletedQuestionIndices.contains(index)) {
          deletedQuestionIndices.add(index);
        }
        // Add the removed question's ID back to the list of answered question IDs
        answeredQuestionIds.remove(removedQuestionId);
      });
    }
  }

  // void _removeQuestion(int index) {
  //   if (selectedQuestionsAndAnswers.isNotEmpty &&
  //       index >= 0 &&
  //       index < selectedQuestionsAndAnswers.length) {
  //     setState(() {
  //       selectedQuestionsAndAnswers.removeAt(index);
  //       if (!deletedQuestionIndices.contains(index)) {
  //         deletedQuestionIndices.add(index);
  //         answeredQuestionIds.removeAt(index);
  //       }
  //     });
  //   }
  // }

  // Future<void> sendingQuestion() async {
  //   try {
  //     final url = Uri.parse(baseUrl + sendingquestionapi);
  //     print('Sending questions API: $url');
  //     if (selectedQuestionsAndAnswers.length < 2) {
  //       // Show an error message or handle the case where the size is less than 2
  //       print('Error: At least 2 questions and answers are required.');
  //       Commonutils.showCustomToastMessageLong('Please Answer Atleast Two Questions', context, 1, 4);
  //       return;
  //     }
  //
  //     List<Map<String, dynamic>> requestBodies = [];
  //
  //     for (int index = 0; index < selectedQuestionsAndAnswers.length; index++) {
  //       final selectedQuestion = selectedQuestionsAndAnswers[index];
  //       final questionId = selectedQuestion['questionId'];
  //       final questionText = selectedQuestion['question'];
  //       final answer = selectedQuestion['answer'];
  //
  //       Map<String, dynamic> requestBody = {
  //         "userQuestionId": 0, // Assuming this value needs to be set
  //         //   "userId": "${widget.userid}",
  //         "questionId": questionId,
  //         "answer": answer,
  //       };
  //
  //       requestBodies.add(requestBody);
  //     }
  //
  //     // Encode the list of request bodies as JSON
  //     String requestBodyJson = jsonEncode(requestBodies);
  //     print('requestBodyJson$requestBodyJson');
  //     // Send the POST request with the JSON body
  //     final response = await http.post(
  //       url,
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: requestBodyJson,
  //     );
  //
  //     print('Response: ${response.body}');
  //
  //     // Check the response status code
  //     if (response.statusCode == 200) {
  //       // Handle successful response
  //       Commonutils.showCustomToastMessageLong('Questions Added Successfully', context, 0, 4);
  //       SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => home_screen()),
  //       );
  //     } else {
  //       // Handle error scenarios
  //       Commonutils.showCustomToastMessageLong('Error ${response.statusCode}', context, 1, 4);
  //       print('Failed to send the request. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle any errors that occur during the process
  //     print('Error: $e');
  //     Commonutils.showCustomToastMessageLong('Error: $e', context, 1, 4);
  //   }
  // }
  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninsecurity:$accessToken");
  }

  Future<void> sendingQuestion() async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    try {
      final url = Uri.parse(baseUrl + addquestionsuser);
      print('addquestionstouser $url');
      if (selectedQuestionsAndAnswers.length < 2) {
        print('Error: At least 2 questions and answers are required.');
        Commonutils.showCustomToastMessageLong('Please Answer Atleast Two Questions', context, 1, 4);
        return;
      }

      List<Map<String, dynamic>> userAnswers = [];

      for (int index = 0; index < selectedQuestionsAndAnswers.length; index++) {
        final selectedQuestion = selectedQuestionsAndAnswers[index];
        final questionId = selectedQuestion['questionId'];
        final answer = selectedQuestion['answer'];

        Map<String, dynamic> userAnswer = {
          "userId": widget.userid,
          "questionId": questionId,
          "answer": answer,
        };

        userAnswers.add(userAnswer);
      }

      // Construct the request body JSON
      Map<String, dynamic> requestBody = {
        "password": "${widget.newpassword}",
        "confirmPassword": "${widget.confirmpassword}",
        "userAnswers": userAnswers,
      };
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      // Encode the request body as JSON
      String requestBodyJson = jsonEncode(requestBody);
      print('requestBodyJson: $requestBodyJson');

      final response = await http.post(
        url,
        headers: headers,
        body: requestBodyJson,
      );
      print('headers: ${headers}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        Commonutils.showCustomToastMessageLong('Password Changed Successfully', context, 0, 4);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        // print('api is succeessfull');
        // print('${response}');
      } else {
        Commonutils.showCustomToastMessageLong('Error ${response.statusCode}', context, 1, 4);
        print('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      Commonutils.showCustomToastMessageLong('Error: $e', context, 1, 4);
    }
  }
}

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
              strokeWidth: 3, // Adjust the stroke width of the CircularProgressIndicator
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
