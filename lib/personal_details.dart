import 'dart:convert';

import 'dart:io';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/database/ApiKeyManager.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Commonutils.dart';
import 'Constants.dart';
import 'Model Class/LookupDetail.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'home_screen.dart';
import 'main.dart';

class PersonalDetails extends StatefulWidget {
  // final String logintime;
  // personal_details({required this.logintime});
  @override
  _personal_screen_screenState createState() => _personal_screen_screenState();
}

class _personal_screen_screenState extends State<PersonalDetails> {
  int currentTab = 0;
  bool isLoading = false;
  String EmployeName = '';
  String dob = '';
  String EmailId = '';
  String? OfficeEmailid;
  String? Expincomapny;
  String? Mobilenum;
  String? Bloodgroup;
  String formattedDOB = '';
  String Gender = '';
  String? photoData;

  String empolyeid = '';
  String _nationality = '';
  String APIKey = '';
  String accessToken = '';
  String? Dateofjoining;
  String? formatteddateofjoining;
  DateTime? dateofjoin;
  String? logintime;
  String? cisid;
  String? employee_designation;
  String? ReportingTo;
  String base64Image = '';
  File? _imageFile;
  String filename = '';
  String fileExtension = '';
  String employecode = '';
  String? userid;
  int? loggedInEmployeeId;
  String? stringdob;
  String? stringsigndate;
  bool ismatchedlogin = false;
  int bloodlookupid = 0;
  String? ApiKey;
  int bloodmatchid = 0;
  List<LookupDetail> lookupDetails = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        _loademployeresponse();
        loademployeeimage();
        loadAccessToken();
        loadUserid();
        getLoginTime();
        getBloodlookupid();
        //  _checkLoginTime();
      } else {
        print('The Internet Is not  Connected');
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection',
            context as BuildContext,
            1,
            4);
      }
    });
  }

  // Future<String> getLoginTime() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('loginTime') ?? 'Unknown';
  // }
  Future<void> getBloodlookupid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      bloodlookupid = prefs.getInt('BloodGroups') ?? 0;
       ApiKey = prefs.getString(SharedKeys.APIKey) ?? "";
    });
    print("bloodlookupid:$bloodlookupid");
    fetchBloodGroups(bloodlookupid);
  }

  Future<void> fetchBloodGroups(int bloodlookupid) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection',
          context as BuildContext,
          1,
          4);
      FocusScope.of(context as BuildContext).unfocus();
      return;
    }
    final url = Uri.parse('$baseUrl$getdropdown$bloodlookupid');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ApiKey': '$ApiKey',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData == 'Token invalid !!!') {
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
          Commonutils.showCustomToastMessageLong(
              "Token is Expired", context as BuildContext, 0, 3);

          Navigator.of(context as BuildContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
          return;
        }

        if (jsonData is List<dynamic>) {
          setState(() {
            lookupDetails =
                jsonData.map((data) => LookupDetail.fromJson(data)).toList();
          });

          // Assuming you have the logged-in user's blood group name stored in a variable
          // String loggedInBloodGroupName = "O+ve"; // Replace this with the actual value

          for (var detail in lookupDetails) {
            if (detail.name == Bloodgroup) {
              setState(() {
                bloodmatchid = detail.lookupDetailId;
                print('Matched Blood Group ID: ${detail.lookupDetailId}');
              });

              break;
            }
          }
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
      print('SocketException: $e');
    } catch (e) {
      print('Error: $e');
      Commonutils.showCustomToastMessageLong(
          'An unexpected error occurred. Please try again later.',
          context as BuildContext,
          0,
          3);
    }
  }

  // Future<void> fetchBloodGroups(int bloodlookupid) async {
  //   bool isConnected = await Commonutils.checkInternetConnectivity();
  //   if (!isConnected) {
  //     Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context as BuildContext, 1, 4);
  //     FocusScope.of(context as BuildContext).unfocus();
  //     return;
  //   }
  //   final url = Uri.parse('$baseUrl$getdropdown$bloodlookupid');
  //   print('fetchBloodGroups :$url');
  //
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': '$accessToken',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final dynamic jsonData = json.decode(response.body);
  //
  //       if (jsonData == 'Token invalid !!!') {
  //         SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
  //         Commonutils.showCustomToastMessageLong("Token is Expired", context as BuildContext, 0, 3);
  //
  //         Navigator.of(context as BuildContext).pushAndRemoveUntil(
  //           MaterialPageRoute(builder: (context) => LoginPage()),
  //               (route) => false,
  //         );
  //         return;
  //       }
  //
  //       if (jsonData is List<dynamic>) {
  //         setState(() {
  //           lookupDetails = jsonData.map((data) => LookupDetail.fromJson(data)).toList();
  //         });
  //       } else {
  //         print('Unexpected response format: $jsonData');
  //         throw Exception('Failed to load data. Unexpected response format.');
  //       }
  //     } else {
  //       print('HTTP error: ${response.statusCode}');
  //       throw Exception('Failed to load data. Status Code: ${response.statusCode}');
  //     }
  //   } on SocketException catch (e) {
  //
  //     print('SocketException: $e');
  //   } catch (e) {
  //     print('Error: $e');
  //     Commonutils.showCustomToastMessageLong('An unexpected error occurred. Please try again later.', context as BuildContext, 0, 3);
  //   }
  // }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      employedata(accessToken);
    });
    print("accestokeninpersonaldetails:$accessToken");
  }

  Future<void> loadUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString("UserId") ?? "";
    setState(() {
      loggedInEmployeeId = int.tryParse(empolyeid);
    });
    print("UserId:$userid");
  }

  void _loademployeresponse() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final designation = loadedData['designation'];
      final code = loadedData['code'];
      final gender = loadedData["gender"];
      final emailid = loadedData['emailId'];
      final officemailid = loadedData['officeEmailId'];
      final dateofbirth = loadedData['originalDOB'];
      final mobilenum = loadedData['mobileNumber'];
      final reportingTo = loadedData['reportingTo'];

      final expincompany = loadedData['experienceInCompany'];
      final bloodgroup = loadedData['bloodGroup'];
      final dateofjoining = loadedData['dateofJoin'];
      final nationality = loadedData['nationality'];
/* 
      //   "gender"
      // : "Male"
      print('employeeName: $employeeName');
      print('dob: $dateofbirth');
      print('emailid: $emailid');
      print('officemail: $officemailid');
      print('expincompany: $expincompany');
      print('mobilenum: $mobilenum');
      print('bloodgroup: $bloodgroup'); */

      // Format the date of birth into "dd/MM/yyyy"
      DateTime dobDate = DateTime.parse(dateofbirth);
      String formattedDOB = DateFormat('dd MMM yyyy').format(dobDate);
      print('formattedDOB: $formattedDOB');

      // DateTime dateofjoin = DateTime.parse(dateofjoining);

// Check if dateofjoining is not null before parsing
      if (dateofjoining != null) {
        dateofjoin = DateTime.parse(dateofjoining!);
      }
      if (code != null) {
        employecode = code;
      } else {
        employecode = '';
      }

      if (nationality != null) {
        _nationality = nationality;
      } else {
        _nationality = '';
      }
      // String formatteddateofjoining =
      //     DateFormat('dd-MM-yyyy').format(dateofjoin!);

// Check if dateofjoin is not null before formatting
      if (dateofjoin != null) {
        formatteddateofjoining = DateFormat('dd MMM yyyy').format(dateofjoin!);
        print('formatteddateofjoining$formatteddateofjoining');
      } else {
        formatteddateofjoining = ''; // Handle the case when dateofjoin is null
        // For example, you could provide a default value or show an error message
      }

      print('formatteddateofjoining: $formatteddateofjoining');

      setState(() {
        if (employeeName != null) {
          EmployeName = employeeName;
        } else {
          EmployeName = '';
        }
        // EmployeName = employeeName;
        stringdob = dateofbirth;
        if (formattedDOB != null) {
          dob = formattedDOB;
        } else {
          dob = '';
        }
        // dob = formattedDOB;
        EmailId = emailid;
        // OfficeEmailid = officemailid;
        if (loadedData['officeEmailId'] != null) {
          OfficeEmailid = loadedData['officeEmailId'] as String;
          print('OfficeEmailid$OfficeEmailid');
        } else {
          OfficeEmailid = '';
          // Handle the case when loadedData['experienceInCompany'] is null
          // For example, you could provide a default value or show an error message
        }
        print('OfficeEmailid$OfficeEmailid');

        if (loadedData['reportingTo'] != null) {
          ReportingTo = reportingTo;
          print('reportingTo$reportingTo');
        } else {
          ReportingTo = '';
          // Handle the case when loadedData['experienceInCompany'] is null
          // For example, you could provide a default value or show an error message
        }
        if (loadedData['experienceInCompany'] != null) {
          Expincomapny = loadedData['experienceInCompany'] as String;
          print('Expincomapny$Expincomapny');
        } else {
          Expincomapny = '';
          // Handle the case when loadedData['experienceInCompany'] is null
          // For example, you could provide a default value or show an error message
        }
        Mobilenum = mobilenum;
        Bloodgroup = bloodgroup;
        if (code != null) {
          cisid = code;
        } else {
          cisid = '';
        }
        if (designation != null) {
          employee_designation = designation;
        } else {
          employee_designation = '';
        }

        // Gender = gender;
        if (gender != null) {
          Gender = gender;
        } else {
          // Handle the case where gender is null, maybe assign a default value
          Gender = "Unknown";
        }
// Check if formatteddateofjoining is not null before using it
        if (formatteddateofjoining != null) {
          Dateofjoining = formatteddateofjoining;
          print('Dateofjoining$Dateofjoining');
        } else {
          Dateofjoining = '';
          // Handle the case when formatteddateofjoining is null
          // For example, you could provide a default value or show an error message
        }
      });
    }
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

  void onConfirmLogout(BuildContext context) {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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

  @override
  Widget build(BuildContext context) {
    // if (ismatchedlogin) {
    //   Future.microtask(() => _showtimeoutdialog(context));
    // }
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => home_screen()),
        ); // Navigate to the previous screen
        return true; // Prevent default back navigation behavior
      },
      child: Scaffold(
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Color(0xFFf15f22),
        //   title: Text(
        //     'HRMS',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   centerTitle: true,
        //   leading: IconButton(
        //     icon: Icon(
        //       Icons.arrow_back,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).pushReplacement(
        //         MaterialPageRoute(builder: (context) => home_screen()),
        //       );
        //       // Implement your logic to navigate back
        //     },
        //   ),
        // ),
        body:
            // SingleChildScrollView(
            //   physics: NeverScrollableScrollPhysics(),
            // child:
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      // Background Image
                      Image.asset(
                        'assets/background_layer_2.png', // Replace with your image path
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height / 3.0,
                                child: ClipPath(
                                  clipper: CurvedBottomClipper(),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFf15f22),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height /
                                        3.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, top: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Container(
                                          //   child: Text(
                                          //     "Welcome!",
                                          //     style: TextStyle(fontSize: 22, color: Colors.black, fontFamily: 'Calibri'),
                                          //   ),
                                          // ),
                                          const SizedBox(height: 8.0),
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3.2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      // alignment: AlignmentDirectional.center,
                                                      children: [
                                                        if (_imageFile !=
                                                            null) ...{
                                                          Image.file(
                                                            _imageFile!,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                3.8,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                6.5,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        } else if (photoData !=
                                                                null &&
                                                            photoData!
                                                                .isNotEmpty) ...{
                                                          // photoData != null && photoData!.isNotEmpty
                                                          //     ?
                                                          FutureBuilder<
                                                              Uint8List>(
                                                            future:
                                                                _decodeBase64(
                                                                    photoData!),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return Center(
                                                                  child:
                                                                      Container(
                                                                    width: 32,
                                                                    height: 32,
                                                                    child: const CircularProgressIndicator
                                                                        .adaptive(),
                                                                  ), // Optionally, show a message if photoData is empty
                                                                );
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return getDefaultImage(
                                                                    Gender,
                                                                    context);
                                                              } else {
                                                                return Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width /
                                                                        3.8,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        6.5,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            3.0),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(
                                                                                3.5)),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width: 2.0)),
                                                                    child: ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4.0), // Adjust the radius as needed
                                                                      child: Image
                                                                          .memory(
                                                                        snapshot
                                                                            .data!,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        filterQuality:
                                                                            FilterQuality.high,
                                                                        // fit: BoxFit.fitWidth,
                                                                      ),
                                                                    ));
                                                              }
                                                            },
                                                          )
                                                        } else if (photoData ==
                                                            null) ...{
                                                          getDefaultImage(
                                                              Gender, context),
                                                        },

                                                        // : photoData != null && photoData != ""
                                                        //     ?

                                                        const SizedBox(
                                                          width: 2,
                                                        ),

                                                        // : getDefaultImage(Gender, context),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              6.2,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            child: InkWell(
                                                              onTap: () async {
                                                                await showBottomSheetForImageSelection(
                                                                    context);
                                                              },
                                                              child: const Icon(
                                                                Icons
                                                                    .camera_alt_outlined,
                                                                size: 22.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5.0),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      child: Text(
                                                        "$EmployeName",
                                                        softWrap: true,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Calibri'),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2.0),
                                                    Text(
                                                      "$employee_designation",
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Calibri'),
                                                    ),
                                                  ],
                                                )),
                                          ),

                                          // SizedBox(
                                          //   height: 8.0,
                                          // ),

                                          // Add more widgets if needed
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Align(
                              //     alignment: Alignment.center,
                              //     child:
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  //height: MediaQuery.of(context).size.height,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // SizedBox(
                                      //   height: 35.0,
                                      // ),

                                      // if (Gender == "Male")
                                      //   Image.asset(
                                      //     'assets/men_emp.jpg',
                                      //     width: 90,
                                      //     height: 110,
                                      //   )
                                      // else if (Gender == "Female")
                                      //   Image.asset(
                                      //     'assets/women-emp.jpg',
                                      //     width: 90,
                                      //     height: 110,
                                      //   ),

                                      //  SizedBox(height: 40.0),
                                      // SizedBox(height: 40.0),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: const BorderSide(
                                              color: Color(0xFFf15f22),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 5,
                                                                    0, 0),
                                                            child: Text(
                                                              "Employee Id",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 5, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Calibri',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    5,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$cisid",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 0,
                                                                    0, 0),
                                                            child: Text(
                                                              "Gender",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Calibri',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$Gender",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 0,
                                                                    0, 0),
                                                            child: Text(
                                                              "Office Email Id ",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Calibri',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$OfficeEmailid",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 0,
                                                                    0, 0),
                                                            child: Text(
                                                              "DOJ",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Calibri',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$formatteddateofjoining",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 0,
                                                                    0, 0),
                                                            child: Text(
                                                              "Mobile Number ",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Calibri',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$Mobilenum",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 0,
                                                                    0, 0),
                                                            child: Text(
                                                              "DOB",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Calibri',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$dob",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(12, 0,
                                                                    0, 0),
                                                            child: Text(
                                                              "Reporting To",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Calibri'),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Expanded(
                                                      flex: 0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 0, 0, 0),
                                                            child: Text(
                                                              ":",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              "$ReportingTo",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'Calibri',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                                // Row(
                                                //   children: [
                                                //     Expanded(
                                                //       flex: 4,
                                                //       child: Column(
                                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                                //         children: [
                                                //           const Padding(
                                                //             padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                                //             child: Text(
                                                //               "Experience In Company",
                                                //               style: TextStyle(color: Color(0xFFf15f22), fontWeight: FontWeight.bold, fontFamily: 'Calibri'),
                                                //             ),
                                                //           ),
                                                //         ],
                                                //       ),
                                                //     ),
                                                //     Expanded(
                                                //       flex: 0,
                                                //       child: Column(
                                                //         crossAxisAlignment: CrossAxisAlignment.center,
                                                //         children: [
                                                //           Padding(
                                                //             padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                //             child: Text(
                                                //               ":",
                                                //               style: TextStyle(
                                                //                 color: Colors.black54,
                                                //                 fontSize: 16,
                                                //                 fontFamily: 'Calibri',
                                                //                 fontWeight: FontWeight.bold,
                                                //               ),
                                                //             ),
                                                //           ),
                                                //         ],
                                                //       ),
                                                //     ),
                                                //     Expanded(
                                                //       flex: 5,
                                                //       child: Column(
                                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                                //         children: [
                                                //           Padding(
                                                //             padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                //             child: Text(
                                                //               "$Expincomapny",
                                                //               style: TextStyle(
                                                //                 color: Colors.black54,
                                                //                 fontSize: 14,
                                                //                 fontWeight: FontWeight.bold,
                                                //                 fontFamily: 'Calibri',
                                                //               ),
                                                //             ),
                                                //           ),
                                                //         ],
                                                //       ),
                                                //     )
                                                //   ],
                                                // ),
                                                // SizedBox(height: 5.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                                    ],
                                  ))
                              //)
                            ],
                          )),

                      // ClipPath for the curved bottom
                    ],
                  ),
      ),
    );
    // );
  }

  Future<void> employedata(String accesstoken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    // bool isConnected = await Commonutils.checkInternetConnectivity();
    // if (!isConnected) {
    //   Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context, 1, 4);
    //   FocusScope.of(context).unfocus();
    //   return;
    // }
    // bool isConnected = await Commonutils.checkInternetConnectivity();
    // if (isConnected) {
    //   print('Connected to the internet');
    // } else {
    //   Commonutils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
    //   FocusScope.of(context).unfocus();
    //   print('Not connected to the internet');
    // }
    try {
      final url = Uri.parse(baseUrl + getemployedata + empolyeid);
      print('getemployedata: $url');

      final response = await http.get(
        url,
        headers: {
          'APIKey': '$APIKey',
        },
      );
      print('login response: ${response.body}');

      // Check the response status code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Access and print the signDate
        final signDate = data['signDate'];
        print('signDate: $signDate');
        setState(() {
          stringsigndate = signDate;
        });
        // Navigate to the home screen
      } else {
        print('response is not success');
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
        // Handle error scenarios
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> showBottomSheetForImageSelection(BuildContext context) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color(0xFFF2713B),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.camera, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFf15f22),
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.gallery, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder,
                        color: Color(0xFFf15f22),
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // filename = basename(_imageFile!.path);
  //   fileExtension = extension(_imageFile!.path);
  //   if (fileExtension == '.jpeg' || fileExtension == '.jpg') {
  //     print('===> Image Type: JPEG');
  //   } else if (fileExtension == '.png') {
  //     print('===> Image Type: PNG');
  //   } else {
  //     print('===> Image Type: Unknown');
  //   }
  //
  //   List<int> imageBytes = await _imageFile!.readAsBytes();
  //   Uint8List compressedBytes = Uint8List.fromList(imageBytes);
  //   compressedBytes = await FlutterImageCompress.compressWithList(
  //     compressedBytes,
  //     minHeight: 800,
  //     minWidth: 800,
  //     quality: 80,
  //   );
  //
  //   base64Image = base64Encode(compressedBytes);
  //
  //   print('===> Filename: $filename');
  //   print('===> File Extension: $fileExtension');
  //   print('===> Base64 Image: $base64Image');

  // Navigator.pop(context);
  // showImageUploadedDialog(context);
  pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);

          print('===> _imageFile: $_imageFile');
        });

        File? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          androidUiSettings: const AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              showCropGrid: true,
              lockAspectRatio: true),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        );

        if (croppedFile != null) {
          filename = basename(croppedFile!.path);
          fileExtension = extension(croppedFile!.path);
          if (fileExtension == '.jpeg' || fileExtension == '.jpg') {
            print('===> Image Type: JPEG');
          } else if (fileExtension == '.png') {
            print('===> Image Type: PNG');
          } else {
            print('===> Image Type: Unknown');
          }

          List<int> imageBytes = await croppedFile!.readAsBytes();
          Uint8List compressedBytes = Uint8List.fromList(imageBytes);
          compressedBytes = await FlutterImageCompress.compressWithList(
            compressedBytes,
            minHeight: 800,
            minWidth: 800,
            quality: 80,
          );

          base64Image = base64Encode(compressedBytes);

          print('===> File Extension: $fileExtension');
          print('===> Base64 Image: $base64Image');
          setState(() {
            _imageFile = croppedFile;

            uploadimgimageapi(context);
          });
        } else {
          setState(() {
            _imageFile = null;
            print('===> Image cropping canceled, reverting to original image.');
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> uploadImage(BuildContext context) async {
    // Your image uploading logic here

    // After the image is successfully uploaded
    showImageUploadedDialog(context);
  }

  void showImageUploadedDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Uploaded'),
          content: const Text('Your image has been successfully uploaded.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                //uploadimgimageapi(context);
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void _checkLoginTime() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     DateTime currentTime = DateTime.now();
  //     DateTime formattedLoginTime = DateTime.parse(logintime!);
  //
  //     Duration timeDifference = currentTime.difference(formattedLoginTime);
  //
  //     if (timeDifference.inSeconds > 3600) {
  //       _showtimeoutdialog(context);
  //     }
  //   });
  // }

  Future<void> loademployeeimage() async {
    // bool isConnected = await Commonutils.checkInternetConnectivity();
    // if (!isConnected) {
    //   Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context, 1, 4);
    //   FocusScope.of(context).unfocus();
    //   return;
    // }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
       APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    });
    print("empolyeidinapplyleave:$empolyeid");
    final url = Uri.parse(baseUrl + GetEmployeePhoto + '$empolyeid');
    print('loademployeeimage  $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'APIKey': '$APIKey',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        photoData =
            data['ImageData']; // Initialize with an empty string if null
        print('photoData==== $photoData');
      });
    } else {
      // Handle error
      print('Failed to load employee photo');
    }
  }

  Widget getDefaultImage(String gender, BuildContext context) {
    return gender == "Male"
        ? Container(
            width: MediaQuery.of(context).size.width / 3.8,
            height: MediaQuery.of(context).size.height / 6.5,
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                border: Border.all(color: Colors.white, width: 2.0)),
            child: Image.asset(
              'assets/men_emp.jpg',
              // width: MediaQuery.of(context).size.width / 4.5,
              // height: MediaQuery.of(context).size.height / 6.5,
            ))
        : gender == "Female"
            ? Container(
                width: MediaQuery.of(context).size.width / 3.8,
                height: MediaQuery.of(context).size.height / 6.5,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(color: Colors.white, width: 2.0)),
                child: Image.asset(
                  'assets/women-emp.jpg',
                  // width: MediaQuery.of(context).size.width / 3.8,
                  // height: MediaQuery.of(context).size.height / 6.5,
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width / 3.8,
                height: MediaQuery.of(context).size.height / 6.5,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(color: Colors.white, width: 2.0)),
                child: Image.asset(
                  'assets/app_logo.png',
                  // width: MediaQuery.of(context).size.width / 3.8,
                  // height: MediaQuery.of(context).size.height / 6.5,
                  // height: 90,
                ),
              ); // You can replace Container() with another default image or widget
  }

  Future<Uint8List> _decodeBase64(String base64String) async {
    final List<String> parts = base64String.split(',');
    print('====>${parts.length}');

    if (parts.length != 2) {
      throw const FormatException(
          'Invalid base64 string: Incorrect number of parts');
    }

    final String dataPart = parts[1];

    try {
      return const Base64Codec().decode(dataPart);
    } catch (e) {
      throw FormatException('Invalid base64 string: $e');
    }
  }

  Future<void> uploadimgimageapi(BuildContext context) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    // ProgressDialog progressDialog = ProgressDialog(context);
    bool apiCallCompleted = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    // Show the progress dialog
    //  progressDialog.show();
    try {
      final url = Uri.parse(baseUrl + uploadimage);
      print('uploadimage url: $url');
      final request = {
        "alternateMobileNumber": "",
        "bloodGroupId": bloodmatchid,
        "certificateDob": "$stringdob",
        "code": "$employecode",
        "emailId": "$EmailId",
        "employeeId": "$loggedInEmployeeId",
        "firstName": "$EmployeName",
        "gender": Gender,
        "isAFresher": false,
        "isActive": true,
        "isFromRecruitment": false,
        "lastName": "",
        "maritalStatus": "Single",
        "middleName": "",
        "mobileNumber": Mobilenum,
        "nationality": "Indian",
        "originalDob": "$stringdob",
        "photo": "data:image/$fileExtension;base64,$base64Image",
        "signDate": "$stringsigndate"
      };

      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'APIKey': '$APIKey',
        },
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        apiCallCompleted = false;
        //   progressDialog.dismiss();
        Commonutils.showCustomToastMessageLong(
            'Something Went Wrong Please Login Again', context, 1, 4);
        return http.Response('Timeout', HttpStatus.requestTimeout);
      });
      print('requestobject ${json.encode(request)}');
      print('response ${response.body}');
      //   if (response.statusCode == 200) {
      //     // Map<String, dynamic> responseMap = json.decode(response.body);
      //     // print('responseMap ${responseMap}');
      //     if (response.body != null && response.body.isNotEmpty) {
      //       try {
      //         int responseInt = int.parse(response.body);
      //         print('Response as int: $responseInt');
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => home_screen()),
      //         );
      //         apiCallCompleted = true;
      //       } catch (e) {
      //         apiCallCompleted = false;
      //         print('Error parsing response as int: $e');
      //         Commonutils.showCustomToastMessageLong('Invalid response format', context, 1, 4);
      //       }
      //     } else {
      //       print('Response body is null or empty');
      //       Commonutils.showCustomToastMessageLong('No response from server', context, 1, 4);
      //     }
      //    //  try {
      //    //    int responseInt = int.parse(response.body);
      //    //    print('Response as int: $responseInt');
      //    //   Navigator.of(context).pop();
      //    //   //  Navigator.of(context).pushReplacement(
      //    //   //    MaterialPageRoute(builder: (context) => home_screen()),
      //    //   //  );
      //    //    apiCallCompleted = true;
      //    // //   progressDialog.dismiss();
      //    //  } catch (e) {
      //    //    apiCallCompleted = false;
      //    // //    progressDialog.dismiss();
      //    //     print('Error parsing response as int: $e');
      //    //  }
      //     // int responseInt = int.parse(response.body);
      //     // print('Response as int: $responseInt');
      //     // Navigator.of(context).pop();
      //   } else if (response.statusCode == 520) {
      //       Commonutils.showCustomToastMessageLong(response.body, context, 1, 3);
      //   } else {
      //     print('Failed to send the request. Status code: ${response.statusCode}');
      //   }
      // } catch (e) {
      //   print('Error: $e');
      // }
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            int? responseInt = int.parse(response.body);
            if (responseInt != null) {
              print('Response as int: $responseInt');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => home_screen()),
              );
              apiCallCompleted = true;
              // onSucces();
            } else {
              _imageFile == null;
              print('Response parsing resulted in null');
              Commonutils.showCustomToastMessageLong(
                  'Please try again', context, 1, 4);
            }
          } catch (e) {
            apiCallCompleted = false;
            print('Error parsing response as int: $e');
            _imageFile == null;
            Commonutils.showCustomToastMessageLong(
                'Invalid response format', context, 1, 4);
          }
        } else {
          print('Response body is null or empty');
          _imageFile == null;
          Commonutils.showCustomToastMessageLong(
              'No response from server', context, 1, 4);
        }
      } else if (response.statusCode == 520) {
        _imageFile == null;
        Commonutils.showCustomToastMessageLong(response.body, context, 1, 3);
      } else {
        _imageFile == null;
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
        Commonutils.showCustomToastMessageLong(
            'Failed to send the request. Status code: ${response.statusCode}',
            context,
            1,
            4);
      }
    } catch (e) {
      print('Error: $e');
      Commonutils.showCustomToastMessageLong(
          'An error occurred: $e', context, 1, 4);
    }
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // I've taken approximate height of curved part of view
    // Change it if you have exact spec for it
    final roundingHeight = size.height * 6 / 5;
    //   final roundingHeight =  size.height ;

    // this is top part of path, rectangle without any rounding
    final filledRectangle =
        Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    // this is rectangle that will be used to draw arc
    // arc is drawn from center of this rectangle, so it's height has to be twice roundingHeight
    // also I made it to go 5 units out of screen on left and right, so curve will have some incline there
    final roundingRectangle = Rect.fromLTRB(
        -5, size.height - roundingHeight * 2, size.width + 5, size.height);

    final path = Path();
    path.addRect(filledRectangle);

    // so as I wrote before: arc is drawn from center of roundingRectangle
    // 2nd and 3rd arguments are angles from center to arc start and end points
    // 4th argument is set to true to move path to rectangle center, so we don't have to move it manually
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // returning fixed 'true' value here for simplicity, it's not the part of actual question, please read docs if you want to dig into it
    // basically that means that clipping will be redrawn on any changes
    return true;
  }
}

class ProgressDialog {
  final BuildContext context;
  late bool _isShowing;

  ProgressDialog(this.context) {
    _isShowing = false;
    show();
  }

  Future<void> show() async {
    if (!_isShowing) {
      _isShowing = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width /
                  1.8, // Adjust the width as needed
              height: MediaQuery.of(context).size.height /
                  4, // Adjust the height as needed
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                // gradient: LinearGradient(
                //   colors: [
                //     Colors.blue,
                //     Colors.green,
                //   ],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 33.0,
                    width: 33.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/cislogo-new.svg',
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
                  const CircularProgressIndicator(
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
        },
      );
      _isShowing =
          false; // Set isShowing back to false after dialog is dismissed
    }
  }

  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context).pop();
    }
  }
}


// ignore_for_file: deprecated_member_use
//MARK: New Screen
/* 
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/common_widgets/common_styles.dart';
import 'package:hrms/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:convert';

import '../api config.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  String accessToken = '';

  late Future<Map<String, dynamic>> futureEmployeeInfo;
  late Future<Uint8List> futureEmployeeImage;

  @override
  void initState() {
    super.initState();
    futureEmployeeInfo = loadEmployeeInfo();
    futureEmployeeImage = fetchEmployeeImage();
  }

  Future<Map<String, dynamic>> loadEmployeeInfo() async {
    final loadedData = await SharedPreferencesHelper.getCategories();
    if (loadedData != null) {
      return {
        'employeeName': loadedData['employeeName'],
        'designation': loadedData['designation'],
        'code': loadedData['code'],
        'gender': loadedData["gender"],
        'emailId': loadedData['emailId'],
        'officeEmailId': loadedData['officeEmailId'],
        'originalDOB': DateFormat('dd MMM yyyy')
            .format(DateTime.parse(loadedData['originalDOB'])),
        'mobileNumber': loadedData['mobileNumber'],
        'reportingTo': loadedData['reportingTo'],
        'experienceInCompany': loadedData['experienceInCompany'],
        'bloodGroup': loadedData['bloodGroup'],
        'dateofJoin': DateFormat('dd MMM yyyy')
            .format(DateTime.parse(loadedData['dateofJoin'])),
        'nationality': loadedData['nationality'],
      };
    } else {
      throw Exception('Failed to load employee information');
    }
  }

  Future<Uint8List> fetchEmployeeImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final empolyeid = prefs.getString("employeeId") ?? "";

      final url = Uri.parse(baseUrl + GetEmployeePhoto + empolyeid);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        final imageData = data['ImageData'];
        final List<String> parts = imageData.split(',');
        if (parts.length != 2) {
          throw const FormatException('Invalid base64 string');
        }
        final String dataPart = parts[1];
        return const Base64Codec().decode(dataPart);
      } else {
        throw Exception('Failed to load employee image');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => home_screen()),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: CommonStyles.bgColor,
        // appBar: appBar(),
        body: SafeArea(
          child: Column(
            children: [
              headerSection(context),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: FutureBuilder(
                            future: futureEmployeeInfo,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData) {
                                return const Center(
                                    child: Text('No data available'));
                              }
                              final employeeInfo =
                                  snapshot.data as Map<String, dynamic>;
                              if (employeeInfo.isEmpty) {
                                return const Center(
                                    child: Text('No data available'));
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Employee Information',
                                    style: CommonStyles.txStyF20CbFcF5.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  /*  customBox(
                                      context,
                                      employeeInfo['employeeName'],
                                      'Employee Id'),
                                  const SizedBox(height: 5),
                                  customBox(
                                      context,
                                      employeeInfo['designation'],
                                      'designation'),
                                  const SizedBox(height: 5), */
                                  customBox(context, employeeInfo['code'],
                                      'Employee Id'),
                                  customBox(context, employeeInfo['gender'],
                                      'Gender'),
                                  customBox(context, employeeInfo['dateofJoin'],
                                      'Date of Join'),
                                  customBox(
                                      context,
                                      employeeInfo['officeEmailId'],
                                      'Office Email Id'),
                                  customBox(
                                      context,
                                      employeeInfo['originalDOB'],
                                      'Date of Birth'),
                                  customBox(
                                      context,
                                      employeeInfo['mobileNumber'],
                                      'Mobile Number'),
                                  // const SizedBox(height: 5),
                                  customBox(
                                      context,
                                      employeeInfo['reportingTo'],
                                      'Reporting To'),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFf15f22),
      title: const Text(
        'HRMS',
        style: TextStyle(color: Colors.white),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      // automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  Row customBox(
    BuildContext context,
    String? title,
    String? subTitle,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: CommonStyles.primaryColor.withOpacity(0.4),
          child: const Icon(
            Icons.home,
            size: 25,
            color: CommonStyles.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ListTile(
            onTap: () {},
            contentPadding: const EdgeInsets.all(0),
            style: ListTileStyle.drawer,
            title: Text('$title'),
            subtitle: Text(
              '$subTitle',
              style: CommonStyles.txStyF20CbFcF5.copyWith(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            titleTextStyle: CommonStyles.txStyF20CbFcF5,
          ),
        ),
        /* const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            
          },
          icon: const Icon(
            Icons.arrow_right_rounded,
            size: 26,
          ),
        ), */
      ],
    );
  }

  Widget headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      width: MediaQuery.of(context).size.width,
      color: CommonStyles.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder(
                      future: futureEmployeeImage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Skeletonizer(
                            child: employeeImageTemplate(context, Uint8List(0)),
                          );
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error);
                        }
                        Uint8List employeeImage = snapshot.data as Uint8List;
                        return employeeImageTemplate(context, employeeImage);
                      }),
                  Positioned(
                    bottom: 0,
                    right: 12,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () async {
                          await showBottomSheetForImageSelection(context);
                        },
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5.0),
          FutureBuilder(
              future: futureEmployeeInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final employeeInfo = snapshot.data as Map<String, dynamic>;
                if (employeeInfo.isEmpty) {
                  return const SizedBox();
                }
                return Column(
                  children: [
                    Text(
                      '${employeeInfo['employeeName']}',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: CommonStyles.txStyF20CpFF5.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${employeeInfo['designation']}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'Calibri'),
                    ),
                    Text(
                      '${employeeInfo['dateofJoin']}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Calibri'),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  Container employeeImageTemplate(
      BuildContext context, Uint8List employeeImage) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      height: MediaQuery.of(context).size.height / 8.0,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: MemoryImage(employeeImage),
          fit: BoxFit.fill,
        ),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
    );
  }

  Future<void> showBottomSheetForImageSelection(BuildContext context) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 4,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: Color(0xFFF2713B),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.camera, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFf15f22),
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    pickImage(ImageSource.gallery, context);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.folder,
                        color: Color(0xFFf15f22),
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void pickImage(ImageSource gallery, BuildContext context) {}
}
 */