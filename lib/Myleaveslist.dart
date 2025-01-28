import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/personal_details.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Commonutils.dart';
import 'Constants.dart';
import 'Model Class/EmployeeLeave.dart';
import 'SharedPreferencesHelper.dart';
import 'main.dart';

class Myleaveslist extends StatefulWidget {
  @override
  Myleaveslist_screenState createState() => Myleaveslist_screenState();
}

class Myleaveslist_screenState extends State<Myleaveslist> {
  String accessToken = '';
  String empolyeid = '';
  String todate = "";
  String logintime = "";

  // List<Map<String, dynamic>> leaveData = [];
  List<EmployeeLeave> leaveData = [];
  bool isLoading = true;
  bool ismatchedlogin = false;

  late Future<List<EmployeeLeave>> EmployeeLeaveData;
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
        loademployeid();
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

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninapplyleave:$accessToken");
  }

  Future<void> loademployeid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
      //_loadleaveslist(empolyeid);
      EmployeeLeaveData = _loadleaveslist(empolyeid);
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  Future<List<EmployeeLeave>> _loadleaveslist(String empolyeid) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
    } else {
      Commonutils.showCustomToastMessageLong(
          'No Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }
    // Specify the API endpoint
    // final String apiUrl =
    //     'http://182.18.157.215/HRMS/API/hrmsapi/Attendance/GetLeavesForSelfEmployee/' + '$empolyeid';
    // print('API apiUrl: $apiUrl');

    // final url = Uri.parse(baseUrl + getleavesapi + empolyeid);
    // print('myleavesapi$url');
    // Check if accessToken is not null before using it

    // Get the current date and time
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    // Print the current year
    print('Current Year: $currentYear');

    if (accessToken != null) {
      try {
        final url =
            Uri.parse(baseUrl + getleavesapi + empolyeid + '/$currentYear');
        print('myleavesapi$url');
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        };
        print('API headers: $accessToken');

        final response = await http.get(url, headers: headers);
        print('response body : ${response.body}');
        //  final response = await http.get(Uri.parse(url), headers: headers);
        print("responsecode ${response.statusCode}");
        // Check if the request was successful (status code 200)
        if (response.statusCode == 200) {
          // Parse the JSON response
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            //leaveData = data.map((json) => EmployeeLeave.fromJson(json)).toList();
            //leaveDataexcludingdeleted.clear();
            isLoading = false;
            List<EmployeeLeave> validLeaves = [];
            data.forEach((leave) {
              if (leave['isDeleted'] == false || leave['isDeleted'] == null) {
                validLeaves.add(EmployeeLeave.fromJson(leave));
              }
            });
            leaveData = validLeaves;
          });
          print('leaveData${leaveData.length}');
          // Process the data as needed
          print('API Response jsonList : $data');
          print('API Response leaveData: $leaveData');
          print('API Response leaveData: ${leaveData.length}');
          return leaveData;
        } else {
          Commonutils.showCustomToastMessageLong(
              'Error: ${response.body}', context, 1, 4);
          // Handle error if the request was not successful
          print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        }
      } catch (error) {
        // Handle any exceptions that occurred during the request
        print('Error: $error');
      }
    } else {
      // Handle the case where accessToken is null
      print('Error: accessToken is null');
    }
    return [];
  }
  // void _loadleaveslist(String empolyeid) async {
  //   // Specify the API endpoint
  //   // final String apiUrl =
  //   //     'http://182.18.157.215/HRMS/API/hrmsapi/Attendance/GetLeavesForSelfEmployee/' + '$empolyeid';
  //   // print('API apiUrl: $apiUrl');
  //
  //   // final url = Uri.parse(baseUrl + getleavesapi + empolyeid);
  //   // print('myleavesapi$url');
  //   // Check if accessToken is not null before using it
  //
  //   // Get the current date and time
  //   DateTime now = DateTime.now();
  //
  //   // Extract the current year
  //   int currentYear = now.year;
  //
  //   // Print the current year
  //   print('Current Year: $currentYear');
  //
  //   if (accessToken != null) {
  //     try {
  //       final url = Uri.parse(baseUrl + getleavesapi + empolyeid + '/$currentYear');
  //       print('myleavesapi$url');
  //       Map<String, String> headers = {
  //         'Content-Type': 'application/json',
  //         'Authorization': '$accessToken',
  //       };
  //       print('API headers: $accessToken');
  //
  //       final response = await http.get(url, headers: headers);
  //       print('response body : ${response.body}');
  //       //  final response = await http.get(Uri.parse(url), headers: headers);
  //       print("responsecode ${response.statusCode}");
  //       // Check if the request was successful (status code 200)
  //       if (response.statusCode == 200) {
  //         // Parse the JSON response
  //         final List<dynamic> data = json.decode(response.body);
  //         setState(() {
  //           // leaveData = data.map((json) => EmployeeLeave.fromJson(json)).toList();
  //           List<EmployeeLeave> validLeaves = [];
  //           data.forEach((leave) {
  //             if (leave['isDeleted'] == false || leave['isDeleted'] == null) {
  //               validLeaves.add(EmployeeLeave.fromJson(leave));
  //             }
  //           });
  //           leaveData = validLeaves;
  //           isLoading = false;
  //         });
  //         print('leaveData${leaveData.length}');
  //         // Process the data as needed
  //         print('API Response jsonList : $data');
  //         print('API Response leaveData: $leaveData');
  //         print('API Response leaveData: ${leaveData.length}');
  //       } else {
  //         Commonutils.showCustomToastMessageLong('Error: ${response.body}', context, 1, 4);
  //         // Handle error if the request was not successful
  //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //       }
  //     } catch (error) {
  //       // Handle any exceptions that occurred during the request
  //       print('Error: $error');
  //     }
  //   } else {
  //     // Handle the case where accessToken is null
  //     print('Error: accessToken is null');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final textscale = MediaQuery.of(context).textScaleFactor;
    // TextDirection? textDirection = Directionality.maybeOf(context);
    if (ismatchedlogin) {
      Future.microtask(() => _showtimeoutdialog(context));
    }
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: Scaffold(
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
            body:
                // isLoading
                //     ? Center(child: CircularProgressIndicator())
                //     : leaveData.isEmpty
                //         ? Center(child: Text('No Leaves Applied!'))
                //         :
                FutureBuilder(
              future: EmployeeLeaveData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CustomCircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  // EmployeeLeave employeeLeave = EmployeeLeaveData
                  List<EmployeeLeave> data = snapshot.data!;
                  if (data.isEmpty) {
                    return Center(
                        child: Container(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text('No Leaves Applied!'),
                    ));
                  } else {
                    return ListView.builder(
                      itemCount: leaveData.length,
                      itemBuilder: (context, index) {
                        final leave = leaveData[index];
                        final borderColor = _getStatusBorderColor(leave.status);
                        String? leavetodate;
                        DateTime from_date = DateTime.parse(leave.fromDate);
                        String leavefromdate =
                            DateFormat('dd MMM yyyy').format(from_date);
                        if (leave.toDate != null) {
                          todate = leave.toDate!;
                          DateTime to_date = DateTime.parse(todate);
                          leavetodate =
                              DateFormat('dd MMM yyyy').format(to_date);
                        } else {
                          leavetodate = leavefromdate;
                        }
                        // Color backgroundColor = leave.isDeleted == null || leave.isDeleted == false
                        //     ? Color(0xFFfbf2ed) // Default color
                        //     : Colors.grey.shade300;
                        Color backgroundColor = leave.isMarkedForDeletion
                            ? Colors.grey
                                .shade300 // Grey background if marked for deletion
                            : leave.isDeleted == null ||
                                    leave.isDeleted == false
                                ? Color(0xFFfbf2ed) // Default color
                                : Colors.grey.shade300;

                        DateTime from_datefordelete =
                            DateFormat('yyyy-MM-dd').parse(leave.fromDate);

                        bool hideDeleteIcon =
                            from_datefordelete.isBefore(DateTime.now());

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border:
                                  Border.all(color: borderColor, width: 1.5),
                            ),
                            child: ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 5.0, bottom: 0.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Leave Type: ',
                                          style: TextStyle(
                                            color: Color(0xFFf37345),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        Text(
                                          '${leave.leaveType}',
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(width: 16.0),
                                        GestureDetector(
                                          onTap: () {
                                            _showConfirmationDialog(leave);
                                          },
                                          // child: leave.isLeaveUsed == true // Check if isLeaveUsed is true
                                          //     ? Container() // Hide the delete icon if isLeaveUsed is true
                                          //     : Icon(
                                          //   CupertinoIcons.delete,
                                          //   color: leave.isDeleted == null || leave.isDeleted == false ? Colors.red : Colors.transparent,
                                          // ),
                                          child: hideDeleteIcon
                                              ? Container()
                                              : Icon(
                                                  CupertinoIcons.delete,
                                                  color: Colors.red,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Half Day Leave :',
                                          style: TextStyle(
                                            color: Color(0xFFf37345),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        leave.isHalfDayLeave == null ||
                                                leave.isHalfDayLeave == false
                                            ? Text(
                                                ' No',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri',
                                                ),
                                              )
                                            : Text(
                                                ' Yes',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri',
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Leave Status :',
                                            style: TextStyle(
                                                color: Color(0xFFf37345),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri'),
                                          ),
                                          TextSpan(
                                            text: ' ${leave.status}',
                                            style: TextStyle(
                                                color: _getStatusColor(
                                                    leave.status),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Calibri'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'From Date: ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${leavefromdate}',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: '   To Date:  ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: {leavetodate} != null
                                                ? leavetodate
                                                : '${leavefromdate}',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              fontFamily: 'Calibri',
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Leave Description : ',
                                            style: TextStyle(
                                                color: Color(0xFFF44614),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri'),
                                          ),
                                          TextSpan(
                                            text: '${leave.note}',
                                            style: TextStyle(
                                                color: Color(0xFF000000),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(bottom: 4.0),
                                  //   child: Row(
                                  //     children: [
                                  //       Text('Leave Description :',
                                  //           style: TextStyle(
                                  //               color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri')),
                                  //       Text(
                                  //         '${leave.note}',
                                  //         style:
                                  //             TextStyle(color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri'),
                                  //       )
                                  //     ],
                                  //   ),
                                  // )
                                ],
                              ),
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
            )));
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange; // Orange border for 'Pending' status
      case 'Approved':
        return Colors.green.shade600;
      case 'Accepted':
        return Colors.blueAccent;
      case 'Rejected':
        return Colors.red;
      // Add more cases for other statuses if needed
      default:
        return Colors.white; // Red border for other statuses
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green.shade600;
      case 'Accepted':
        return Colors.blueAccent;
      case 'Rejected':
        return Colors.red;

      default:
        return Colors.red;
    }
  }

  void _showConfirmationDialog(EmployeeLeave leave) {
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
              content:
                  /* Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/caution-sign.png',
                        height: 30,
                        width: 30,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Are You Sure You Want To Delete?')
                    ],
                  )
                ],
              ), */

                  SizedBox(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/caution-sign.png',
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Flexible(
                      child: Text(
                        'Are You Sure You Want To Delete?',
                        style:
                            TextStyle(fontSize: 16), // Add any desired styling
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    deleteapi(leave.employeeLeaveId);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Yes',
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
                    'No',
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

  String _formatDate(String dateString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateFormat('dd-mm-yyyy').parse(dateString);

    // Format the DateTime object into the desired format
    return DateFormat('dd-mm-yyyy').format(dateTime);
  }

  Future<void> deleteapi(int leaveid) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    setState(() {
      isLoading = true; // Show circular progress indicator
    });
    final url = Uri.parse(baseUrl + deleteleave + "/" + leaveid.toString());
    print('deleteleaveapi:$url');
    print('API headers:1 $accessToken');
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        bool isSuccess = responseData['isSuccess'];
        String message = responseData['message'];
        if (isSuccess) {
          int index =
              leaveData.indexWhere((leave) => leave.employeeLeaveId == leaveid);

          if (index != -1) {
            // Mark the item for deletion
            setState(() {
              leaveData[index].isMarkedForDeletion = true;
            });
          }
          Commonutils.checkInternetConnectivity().then((isConnected) {
            if (isConnected) {
              print('The Internet Is Connected');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Myleaveslist()),
              );
            } else {
              Commonutils.showCustomToastMessageLong(
                  'Please Check Your Internet Connection', context, 1, 4);
            }
          });
          // Close dialog
          ///  Navigator.of(context).pop();

          Commonutils.showCustomToastMessageLong('$message', context, 0, 4);
        } else {
          Commonutils.showCustomToastMessageLong('$message', context, 1, 4);
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false; // Show circular progress indicator
      });
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
