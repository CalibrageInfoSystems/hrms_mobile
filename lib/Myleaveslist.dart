import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/common_widgets/CommonUtils.dart';
import 'package:hrms/common_widgets/common_styles.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Commonutils.dart';
import 'Constants.dart';
import 'Model Class/EmployeeLeave.dart';
import 'SharedPreferencesHelper.dart';

class Myleaveslist extends StatefulWidget {
  final String? leaveType;
  const Myleaveslist({super.key, this.leaveType});

  @override
  State<Myleaveslist> createState() => _MyleaveslistState();
}

class _MyleaveslistState extends State<Myleaveslist> {
  String accessToken = '';
  String empolyeid = '';
  String todate = "";
  String logintime = "";
  final _fromToDatesController = TextEditingController();
  int? _selectedLeave;
  DateTime? selectedDate;
  String showYear = 'Select Year';
  String tempShowYear = 'Select Year';
  DateTime _selectedYear = DateTime.now();
  static const List<String> leavesList = [
    'Pending',
    'Accepted',
    'Approved',
    'Rejected',
    'Cancelled'
  ];

  // List<Map<String, dynamic>> leaveData = [];
  List<EmployeeLeave> leaveData = [];
  bool isLoading = true;
  bool ismatchedlogin = false;

  late Future<List<EmployeeLeave>> employeeLeaves;
  List<EmployeeLeave> allLeaves = [];
  List<EmployeeLeave> filteredLeaves = [];
  @override
  void initState() {
    super.initState();

    getLoginTime();
    employeeLeaves =
        fetchLeavesInYear(empolyeid, leaveTypeValue: widget.leaveType);
  }

  Future<void> getLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logintime = prefs.getString('loginTime') ?? 'Unknown';
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime!);
    DateTime loginTime = formattedlogintime /* Replace with your login time */;

    // Calculate the time difference
    Duration timeDifference = currentTime.difference(loginTime);

    // Check if the time difference is less than or equal to 1 hour (3600 seconds)
    if (timeDifference.inSeconds > 3600) {
      print("Login is more than 1 hour from current time.");
      setState(() {
        ismatchedlogin = true;
      });
    }
  }

/*   Future<String?> getLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Login Time: $logintime');
    login(logintime!);
    return logintime;
  } */

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
                  SizedBox(
                    height: 50.0,
                    width: 60.0,
                    child: SvgPicture.asset(
                      'assets/cislogo-new.svg',
                      height: 120.0,
                      width: 55.0,
                    ),
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  const Text(
                    "Session Time Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 3.0,
                  ),
                  const Text(
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
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
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

/*   Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
    });
    print("accestokeninapplyleave:$accessToken");
  }

  Future<void> loademployeid() async {
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
      employeeLeaveData = _loadleaveslist(empolyeid);
    });
    print("empolyeidinapplyleave:$empolyeid");
  } */
/* 
  Future<List<EmployeeLeave>> fetchLeavesInYear2(String empolyeid,
      {String? leaveTypeValue, String? selectedYear}) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      throw Exception('No Internet Connection');
    } else {
      try {
        await getLoginTime();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          accessToken = prefs.getString("accessToken") ?? "";
          logintime = prefs.getString('loginTime') ?? 'Unknown';
          empolyeid = prefs.getString("employeeId") ?? "";
        });
        if (accessToken.isNotEmpty) {
          DateTime now = DateTime.now();
          String currentYear = selectedYear ?? now.year.toString();
          final url = Uri.parse('$baseUrl$getleavesapi$empolyeid/$currentYear');
          Map<String, String> headers = {
            'Content-Type': 'application/json',
            'Authorization': accessToken,
          };
          final response = await http.get(url, headers: headers);
          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            setState(() {
              List<EmployeeLeave> validLeaves = [];
              data.forEach((leave) {
                if (leave['isDeleted'] == false || leave['isDeleted'] == null) {
                  validLeaves.add(EmployeeLeave.fromJson(leave));
                }
              });
              if (leaveTypeValue != null) {
                validLeaves = validLeaves
                    .where((leave) => leave.leaveType == leaveTypeValue)
                    .toList();
              }
              leaveData = validLeaves;
              allLeaves = leaveData;
              filteredLeaves = leaveData;
            });
            return leaveData;
          } else {
            Commonutils.showCustomToastMessageLong(
                response.body, context, 1, 4);
            throw Exception(response.body);
          }
        } else {
          throw Exception('Invalid access token');
        }
      } catch (e) {
        rethrow;
      }
    }
  }
 */
  Future<List<EmployeeLeave>> fetchLeavesInYear(String empolyeid,
      {String? leaveTypeValue,
      String? selectedYear,
      String? selectedStatus}) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      throw Exception('No Internet Connection');
    } else {
      try {
        await getLoginTime();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          accessToken = prefs.getString("accessToken") ?? "";
          logintime = prefs.getString('loginTime') ?? 'Unknown';
          empolyeid = prefs.getString("employeeId") ?? "";
        });
        if (accessToken.isNotEmpty) {
          DateTime now = DateTime.now();
          String currentYear = selectedYear ?? now.year.toString();
          final url = Uri.parse('$baseUrl$getleavesapi$empolyeid/$currentYear');
          Map<String, String> headers = {
            'Content-Type': 'application/json',
            'Authorization': accessToken,
          };
          final response = await http.get(url, headers: headers);
          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            setState(() {
              List<EmployeeLeave> validLeaves = [];
              data.forEach((leave) {
                if (leave['isDeleted'] == false || leave['isDeleted'] == null) {
                  validLeaves.add(EmployeeLeave.fromJson(leave));
                }
              });
              if (leaveTypeValue != null) {
                validLeaves = validLeaves
                    .where((leave) => leave.leaveType == leaveTypeValue)
                    .toList();
              }
              leaveData = validLeaves;
              allLeaves = leaveData;
              if (selectedStatus != null) {
                filteredLeaves = leaveData
                    .where((leave) => leave.status == selectedStatus)
                    .toList();
              } else {
                filteredLeaves = leaveData;
              }
            });
            return leaveData;
          } else {
            Commonutils.showCustomToastMessageLong(
                response.body, context, 1, 4);
            throw Exception(response.body);
          }
        } else {
          throw Exception('Invalid access token');
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textscale = MediaQuery.of(context).textScaleFactor;
    if (ismatchedlogin) Future.microtask(() => _showtimeoutdialog(context));
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
            backgroundColor: const Color(0xFFf15f22),
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
            ),
            title: const Text(
              'HRMS',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              //MARK: Filter
              IconButton(
                icon: const Icon(
                  Icons.filter,
                  color: Colors.white,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: filterMyLeaves(),
                    ),
                  );
                },
              ),
            ]),
        body: FutureBuilder(
          future: employeeLeaves,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomCircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', '')),
              );
            } else {
              // EmployeeLeave employeeLeave = EmployeeLeaveData
              // List<EmployeeLeave> data = snapshot.data ?? [];

              List<EmployeeLeave> data = filteredLeaves;
              if (data.isEmpty) {
                return Center(
                    child: Container(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: const Text('No Leaves Found'),
                ));
              } else {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final leave = data[index];
                    final borderColor = _getStatusBorderColor(leave.status);
                    String? leavetodate;
                    DateTime from_date = DateTime.parse(leave.fromDate);
                    String leavefromdate =
                        DateFormat('dd MMM yyyy').format(from_date);
                    if (leave.toDate != null) {
                      todate = leave.toDate!;
                      DateTime to_date = DateTime.parse(todate);
                      leavetodate = DateFormat('dd MMM yyyy').format(to_date);
                    } else {
                      leavetodate = leavefromdate;
                    }
                    // Color backgroundColor = leave.isDeleted == null || leave.isDeleted == false
                    //     ? Color(0xFFfbf2ed) // Default color
                    //     : Colors.grey.shade300;
                    Color backgroundColor = leave.isMarkedForDeletion
                        ? Colors.grey
                            .shade300 // Grey background if marked for deletion
                        : leave.isDeleted == null || leave.isDeleted == false
                            ? const Color(0xFFfbf2ed) // Default color
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
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, bottom: 0.0),
                                child: Row(
                                  children: [
                                    const Text(
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
                                      style: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(width: 16.0),
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
                                          : const Icon(
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
                                    const Text(
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
                                        ? const Text(
                                            ' No',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          )
                                        : const Text(
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
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
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
                                            color:
                                                _getStatusColor(leave.status),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Calibri'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
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
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Calibri',
                                        ),
                                      ),
                                      const TextSpan(
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
                                        style: const TextStyle(
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
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Leave Description : ',
                                        style: TextStyle(
                                            color: Color(0xFFF44614),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Calibri'),
                                      ),
                                      TextSpan(
                                        text: '${leave.note}',
                                        style: const TextStyle(
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
            }
          },
        ),
      ),
    );
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
                  const Text(
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
                    child: const Icon(
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
                    const SizedBox(
                      width: 8.0,
                    ),
                    const Flexible(
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
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
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
                  child: const Text(
                    'No',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
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
                MaterialPageRoute(builder: (context) => const Myleaveslist()),
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

  Widget filterMyLeaves() {
    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Filter By',
                  ),
                  GestureDetector(
                    onTap: onClearAllFilters,
                    //MARK: Clear all filters
                    child: const Text(
                      'Clear All Filters',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  width: double.infinity,
                  height: 0.3,
                  color: CommonUtils.primaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _fromToDatesController,
                      keyboardType: TextInputType.visiblePassword,
                      onTap: () => showYearPicker(context),
                      readOnly: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                            top: 15, bottom: 10, left: 15, right: 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: CommonStyles.primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: CommonUtils.primaryTextColor,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        counterText: "",
                        hintText: 'Select Year',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      spacing: 5.0,
                      children: List<ChoiceChip>.generate(
                        leavesList.length,
                        (int index) => ChoiceChip(
                          selectedColor: _selectedLeave == index
                              ? CommonStyles.primaryColor.withOpacity(0.4)
                              : CommonStyles.primaryColor,
                          backgroundColor: Colors.white,
                          label: Text(
                            leavesList[index],
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: CommonStyles.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          side: const BorderSide(
                              color: CommonStyles.primaryColor),
                          selected: _selectedLeave == index,
                          showCheckmark: false,
                          onSelected: (bool selected) {
                            setState(() {
                              print('Selected Leave22: ${leavesList[index]}');
                              _selectedLeave = selected ? index : null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                color: CommonUtils.primaryTextColor,
                              ),
                              side: const BorderSide(
                                color: CommonUtils.primaryTextColor,
                              ),
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: CommonUtils.primaryTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (showYear != 'Select Year') {
                                    // api call with status filter
                                    setState(() {
                                      employeeLeaves = fetchLeavesInYear(
                                          empolyeid,
                                          leaveTypeValue: widget.leaveType,
                                          selectedYear: showYear,
                                          selectedStatus: _selectedLeave == null
                                              ? null
                                              : leavesList[_selectedLeave!]);
                                    });
                                  }
                                  if (_selectedLeave != null) {
                                    // filter status
                                    setState(() {
                                      filteredLeaves
                                          .where((leave) =>
                                              leave.status ==
                                              leavesList[_selectedLeave!])
                                          .toList();
                                    });
                                  }
                                  /*  filterLeaves(
                                    empolyeid,
                                    leaveTypeValue: widget.leaveType,
                                    selectedYear: showYear == 'Select Year'
                                        ? null
                                        : showYear,
                                    selectedStatus: _selectedLeave == null
                                        ? null
                                        : leavesList[_selectedLeave!],
                                  ); */
                                },
                                //MARK: Apply Filter
                                child: Container(
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: CommonUtils.primaryTextColor,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

/*   void filterLeaves(String? selectedYear, String? selectedStatus) {
    setState(() {
      if (showYear != tempShowYear) {
        tempShowYear = showYear;
        employeeLeaves = fetchLeavesInYear(empolyeid,
            leaveTypeValue: widget.leaveType, selectedYear: selectedYear);
      }

      // If both are null, close the filter and display all data
      if ((selectedYear == null || selectedYear == 'Select Year') &&
          selectedStatus == null) {
        filteredLeaves = allLeaves;
        return;
      }

      // If only selectedYear is null, filter by status
      if (selectedYear == null || selectedYear == 'Select Year') {
        filteredLeaves = allLeaves.where((leave) {
          return leave.status == selectedStatus;
        }).toList();
        return;
      }

      // If only selectedStatus is null, filter by year
      if (selectedStatus == null) {
        filteredLeaves = allLeaves.where((leave) {
          DateTime fromDate = DateTime.parse(leave.fromDate);
          return fromDate.year.toString() == selectedYear;
        }).toList();
        return;
      }

      // If both are not null, filter by both year and status
      filteredLeaves = allLeaves.where((leave) {
        DateTime fromDate = DateTime.parse(leave.fromDate);
        bool matchesYear = fromDate.year.toString() == selectedYear;
        bool matchesStatus = leave.status == selectedStatus;
        return matchesYear && matchesStatus;
      }).toList();
    });

    print('Filtered Leaves: ${filteredLeaves.length}');
  } */

  Future<void> showYearPicker(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10, 1),
              // lastDate: DateTime.now(),
              lastDate: DateTime(2025),
              initialDate: DateTime.now(),
              selectedDate: _selectedYear,
              onChanged: (DateTime dateTime) {
                print(dateTime.year);
                setState(() {
                  _selectedYear = dateTime;
                  showYear = "${dateTime.year}";
                  _fromToDatesController.text = showYear;
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  void onClearAllFilters() {
    Navigator.of(context).pop();
    setState(() {
      showYear = 'Select Year';
      _selectedLeave = null;
      _fromToDatesController.clear();

      // filteredLeaves = allLeaves;
      employeeLeaves =
          fetchLeavesInYear(empolyeid, leaveTypeValue: widget.leaveType);
    });
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
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
  }
}
