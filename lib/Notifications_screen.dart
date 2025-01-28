import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/NotificationReply.dart';
import 'package:hrms/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/Commonutils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Constants.dart';
import 'Notification_Model.dart';
import 'SharedPreferencesHelper.dart';
import 'UpComingbdays.dart';
import 'api config.dart';
import 'home_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'main.dart';

// const CURVE_HEIGHT = 320.0;
// const AVATAR_RADIUS = CURVE_HEIGHT * 0.23;
// const AVATAR_DIAMETER = AVATAR_RADIUS * 2.5;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _Notifications_screenState createState() => _Notifications_screenState();
}

class _Notifications_screenState extends State<Notifications> {
  String? accessToken;
  String sharedEmpId = '';
  bool isSentWishes = false;
  List<Notification_model> NotificationData = [];
  List<Notification_model> birthdayNotifications = [];
  List<UpComingbirthdays> upcoming_model = [];
  List<bool> isExpanded = [false, false, false, false];
  Notification_model? empData;
  List<NotificationReply> notificationreplylist = [];
  String? userid;
  String? logintime;
  bool isWishesSent = false;
  bool isLoginUserBirthDay = false;
  bool ismatchedlogin = false;
  TextEditingController messagecontroller = TextEditingController();
  int? emplyeidfromapi;
  int? loggedInEmployeeId;
  bool shouldHideSendWishesButton = false;
  late Future<List<List<Notification_model>>>? apiData;

  // Set<int> wishedEmployeeIds = {}; // Define this in your widget's state or as a global variable
  Set<int> repliedNotificationIds =
      {}; // Define this in your widget's state or as a global variable
  final borderSide = BorderSide(
    color:
        const Color(0xFFf15f22).withOpacity(0.8), // Adjust the color as needed
    width: 1.0, // Adjust the width as needed
  );

  final outlineInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color(0xFFf15f22),
    ),
    borderRadius: BorderRadius.circular(6.0),
  );

  final notificationIndicator = Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      border: Border.all(
        // color: const Color.fromARGB(
        //     255, 239, 112, 112),
        color: Color.fromARGB(255, 3, 155, 44),
        width: 2,
      ),
      shape: BoxShape.circle,
      color: Color.fromARGB(255, 92, 233, 106),
      // color: const Color.fromARGB(
      //     255, 237, 8, 8),
    ),
  );

  // final notificationIndicator = Container(
  //   padding: const EdgeInsets.all(3),
  //   decoration: BoxDecoration(
  //     border: Border.all(
  //       // color: const Color.fromARGB(
  //       //     255, 239, 112, 112),
  //       color: const Color.fromARGB(255, 237, 8, 8),
  //       width: 2,
  //     ),
  //     shape: BoxShape.circle,
  //     color: const Color.fromARGB(255, 249, 79, 79),
  //     // color: const Color.fromARGB(
  //     //     255, 237, 8, 8),
  //   ),
  // );

  @override
  void initState() {
    super.initState();
    apiData = fetchNotifications();
    getLoginTime();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.portraitUp,
    // ]);
    // Commonutils.checkInternetConnectivity().then((isConnected) {
    //   if (isConnected) {
    //     apiData = fetchNotifications();
    //     // loadAccessToken();
    //     // loademployeid();
    //     // loadUserid();
    //   } else {
    //     print('The Internet Is not  Connected');
    //     Commonutils.showCustomToastMessageLong(
    //         'Please check internet connection', context, 1, 4);
    //   }
    // });
  }

  void updateIsExpandedList(int index) {
    setState(() {
      isExpanded = List.generate(isExpanded.length, (i) => i == index);
    });
  }

  void loademployeid() {
    getNotificationsRepliesByEmployes(accessToken!, loggedInEmployeeId!);
    GetUpcomingbdays(accessToken!);
  }

  Future<void> loadUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString("UserId") ?? "";
    print("UserId:$userid");
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
            appBar: _appBar(context),
            body: SingleChildScrollView(
              child: FutureBuilder(
                future: apiData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('snapshot.hasError ${snapshot.error}'));
                  } else {
                    List<List<Notification_model>> snapShot = snapshot.data!;
                    List<Notification_model> notifyData = snapShot[0];
                    print('notifyData=====>${notifyData.length}');
                    List<Notification_model> birthdayNotifyData = snapShot[1];
                    print(
                        'birthdayNotifyData=====>${birthdayNotifyData.length}');
                    if (snapShot.isNotEmpty) {
                      return Container(
                          // width: MediaQuery.of(context).size.width,
                          // height: MediaQuery.of(context).size.height/0.2,
                          // child: SingleChildScrollView(
                          // width: MediaQuery.of(context).size.width,
                          // height: MediaQuery.of(context).size.height,
                          child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            //  height: MediaQuery.of(context).size.height,
                            child: Column(
                              children: [
                                CustomExpansionTile(
                                  title: Row(
                                    children: [
                                      const Text(
                                        "HR Notifications",
                                        style: TextStyle(color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // / const Spacer(),
                                      //  notifyData.isNotEmpty ? notificationIndicator : const SizedBox(),
                                      //  const SizedBox(width: 10),
                                    ],
                                  ),
                                  content: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        left: borderSide,
                                        right: borderSide,
                                        bottom: borderSide,
                                      ),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ), //MARK: Hr notifications
                                      child: notifyData.isEmpty
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5, bottom: 2.5),
                                              color: const Color(0xFFf15f22)
                                                  .withOpacity(0.1),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'There are no HR notifications',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: notifyData.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final notification =
                                                    notifyData[index];
                                                print(
                                                    'messagefromapi:${notification.message}');

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5, bottom: 2.5),
                                                  color: const Color(0xFFf15f22)
                                                      .withOpacity(0.1),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.9,
                                                          child: Text(
                                                            notification
                                                                .message,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ),
                                                        Text(
                                                          formatTimeAgo(
                                                              notification
                                                                  .createdAt),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  initiallyExpanded: isExpanded[0],
                                  onTap: () {
                                    setState(() {
                                      isExpanded[0] = !isExpanded[0];
                                      isExpanded[1] = false;
                                      isExpanded[2] = false;
                                      isExpanded[3] = false;
                                    });
                                  },
                                ),
                                CustomExpansionTile(
                                  title: Row(
                                    children: [
                                      const Text(
                                        "Today Birthdays",
                                        style: TextStyle(color: Colors.white),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // const Spacer(),
                                      // birthdayNotifyData.isNotEmpty ? notificationIndicator : const SizedBox(),
                                      // const SizedBox(width: 10),
                                    ],
                                  ),
                                  // const Text(
                                  //   "Today Birthdays",
                                  //   style: TextStyle(color: Colors.white),
                                  //   maxLines: 2,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  content: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(0.8)),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: birthdayNotifyData.isEmpty
                                          ? Container(
                                              margin: const EdgeInsets.all(5),
                                              color: const Color(0xFFf15f22)
                                                  .withOpacity(0.1),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const Text(
                                                'There are no Birthdays',
                                                style: TextStyle(
                                                    color: Colors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  birthdayNotifyData.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final notification =
                                                    birthdayNotifyData[index];
                                                bool hideButton =
                                                    repliedNotificationIds
                                                        .contains(notification
                                                            .notificationId);

                                                bool isCurrentUser =
                                                    notification.employeeId ==
                                                        int.parse(sharedEmpId);

                                                return Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      20,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 2.5),
                                                  color: const Color(0xFFf15f22)
                                                      .withOpacity(0.1),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        notification.code!,
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .lightBlueAccent),
                                                      ),
                                                      const SizedBox(
                                                          width: 7.0),
                                                      Expanded(
                                                        child: Text(
                                                          notification
                                                              .employeeName,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      !hideButton
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                showDialogForWish(
                                                                    notification
                                                                        .notificationId,
                                                                    notification
                                                                        .employeeName);
                                                              },
                                                              child: Container(
                                                                  // padding:  EdgeInsets.all(4),
                                                                  // decoration: BoxDecoration(
                                                                  //   color: const Color(0xFFf15f22).withOpacity(0.2),
                                                                  //   borderRadius: BorderRadius.circular(10.0),
                                                                  // ),
                                                                  child: isCurrentUser
                                                                      // notification
                                                                      //             .employeeId ==
                                                                      //         int.parse(
                                                                      //             sharedEmpId)
                                                                      ? Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              4),
                                                                        )
                                                                      : Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              4),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                const Color(0xFFf15f22).withOpacity(0.2),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/cakedecoration.png',
                                                                                width: 15,
                                                                                height: 21,
                                                                                color: const Color(0xFFf15f22),
                                                                              ),
                                                                              const SizedBox(width: 5),
                                                                              const Icon(
                                                                                Icons.send_outlined,
                                                                                size: 18,
                                                                                color: Color(0xFFf15f22),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )),
                                                            )
                                                          : const SizedBox()
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  initiallyExpanded: isExpanded[1],
                                  onTap: () {
                                    setState(() {
                                      isExpanded[1] = !isExpanded[1];
                                      isExpanded[0] = false;
                                      isExpanded[2] = false;
                                      isExpanded[3] = false;
                                    });
                                    // updateIsExpandedList(1);
                                  },
                                  // initiallyExpanded:
                                  //     getNotificationResult == birthdayNotification,
                                ),
                                CustomExpansionTile(
                                  title: Row(
                                    children: [
                                      const Text(
                                        "Upcoming Birthdays",
                                        maxLines: 2,
                                        style: TextStyle(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // const Spacer(),
                                      // upcoming_model.isNotEmpty ? notificationIndicator : const SizedBox(),
                                      // const SizedBox(width: 10),
                                    ],
                                  ),

                                  // const Text(
                                  //   "Up Coming Birthdays",
                                  //   maxLines: 2,
                                  //   style: TextStyle(color: Colors.white),
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  content: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        left: borderSide,
                                        right: borderSide,
                                        bottom: borderSide,
                                      ),
                                    ),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.only(
                                            left: 5.0, right: 5.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: upcoming_model.isEmpty
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 2.5),
                                                color: const Color(0xFFf15f22)
                                                    .withOpacity(0.1),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  //height: MediaQuery.of(context).size.height,
                                                  // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                  child: const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'There are no Up Coming Birthdays',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount:
                                                    upcoming_model.length,
                                                shrinkWrap: true,
                                                physics: PageScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final notification =
                                                      upcoming_model[index];
                                                  print(
                                                      'employeeNamefromapi${notification.employeeName}');

                                                  String formattedDate =
                                                      DateFormat('dd MMM')
                                                          .format(notification
                                                              .originalDOB);

                                                  return SingleChildScrollView(
                                                      // scrollbarOrientation: ScrollbarOrientation.top,
                                                      // thumbVisibility: true,
                                                      // thickness: 2.0,

                                                      child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    //   height: MediaQuery.of(context).size.height/20,
                                                    margin: EdgeInsets.only(
                                                        top: 5, bottom: 1),
                                                    color: Color(0xFFf15f22)
                                                        .withOpacity(0.1),
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,

                                                      // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // Image.asset(
                                                          //   'assets/cake.png',
                                                          //   width: 20,
                                                          //   height: 20,
                                                          //   color: Color(0xFFf15f22),
                                                          // ),
                                                          // SizedBox(
                                                          //   width: 10.0,
                                                          // ),
                                                          Container(
                                                            //  padding: EdgeInsets.all(3.0),
                                                            // decoration: BoxDecoration(
                                                            //     color: Colors.lightBlueAccent, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                            child: Text(
                                                              notification
                                                                  .employeeCode,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .lightBlueAccent),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 7.0,
                                                          ),
                                                          // Container(
                                                          //   width: MediaQuery.of(context).size.width / 2,
                                                          //   child: Text(
                                                          //     notification.employeeName,
                                                          //     style: TextStyle(color: Colors.black),
                                                          //     maxLines: 1,
                                                          //     overflow: TextOverflow.ellipsis,
                                                          //     textAlign: TextAlign.start,
                                                          //   ),
                                                          // ),
                                                          Expanded(
                                                            child: Text(
                                                              notification
                                                                  .employeeName,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),

                                                          // SizedBox(
                                                          //   width: 10.0,
                                                          // ),
                                                          Container(
                                                            //width: MediaQuery.of(context).size.width / 1.9,
                                                            child: Text(
                                                              formattedDate,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                          ),
                                                          // if (emplyeidfromapi == sharedEmpId)
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                                },
                                              )),
                                  ),

                                  initiallyExpanded: isExpanded[2],
                                  onTap: () {
                                    setState(() {
                                      isExpanded[2] = !isExpanded[2];
                                      isExpanded[0] = false;
                                      isExpanded[1] = false;
                                      isExpanded[3] = false;
                                    });
                                    // updateIsExpandedList(2);
                                  },
                                  // initiallyExpanded:
                                  //     getNotificationResult == upComingNotifications,
                                ),
                                notificationreplylist.isNotEmpty
                                    ? CustomExpansionTile(
                                        title: Row(
                                          children: [
                                            const Text(
                                              "Greetings",
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            // const Spacer(),
                                            // notificationreplylist.isNotEmpty ? notificationIndicator : const SizedBox(),
                                            // const SizedBox(width: 10),
                                          ],
                                        ),
                                        content: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                              left: BorderSide(
                                                color: const Color(0xFFf15f22)
                                                    .withOpacity(
                                                        0.8), // Adjust the color as needed
                                                width:
                                                    1.0, // Adjust the width as needed
                                              ),
                                              right: BorderSide(
                                                color: const Color(0xFFf15f22)
                                                    .withOpacity(
                                                        0.8), // Adjust the color as needed
                                                width:
                                                    1.0, // Adjust the width as needed
                                              ),
                                              bottom: BorderSide(
                                                color: const Color(0xFFf15f22)
                                                    .withOpacity(
                                                        0.8), // Adjust the color as needed
                                                width:
                                                    1.0, // Adjust the width as needed
                                              ),
                                            ),
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 5.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: notificationreplylist.isEmpty
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5,
                                                            bottom: 2.5),
                                                    color:
                                                        const Color(0xFFf15f22)
                                                            .withOpacity(0.1),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                      child: const Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            '',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    itemCount:
                                                        notificationreplylist
                                                            .length,
                                                    shrinkWrap: true,
                                                    physics:
                                                        AlwaysScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      final notification =
                                                          notificationreplylist[
                                                              index];
                                                      print(
                                                          'messagefromapi:${notification.message}');

                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            bottom: 2.5),
                                                        color: const Color(
                                                                0xFFf15f22)
                                                            .withOpacity(0.1),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Birthday Wishes from ${notification.employeeName}',
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.grey),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 7.0,
                                                                  ),
                                                                  Container(
                                                                    child: Text(
                                                                      notification
                                                                          .code,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.lightBlueAccent),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 7.0,
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                  notification
                                                                      .message,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ),
                                        initiallyExpanded: isExpanded[3],
                                        onTap: () {
                                          setState(() {
                                            isExpanded[3] = !isExpanded[3];
                                            isExpanded[0] = false;
                                            isExpanded[1] = false;
                                            isExpanded[2] = false;
                                          });
                                        },
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          )
                        ],
                      )
                          //   ),
                          //  ),
                          );
                    } else {
                      return const Center(
                        child: Text('No Notifications'),
                      );
                    }
                  }
                },
              ),
            )

            /*
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          CustomExpansionTile(
                            title: const Text(
                              "HR Notifications",
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: borderSide,
                                  right: borderSide,
                                  bottom: borderSide,
                                ),
                              ),
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ), //MARK: Hr notifications
                                  child: FutureBuilder(
                                    future: apiData,
                                    builder: (context, snapshot) {
                                      List<List<Notification_model>> snapShot =
                                          snapshot.data!;
                                      List<Notification_model> notifyData =
                                          snapShot[0];
                                      // List<Notification_model>
                                      //     birthdayNotifyData = snapShot[1];
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator
                                            .adaptive();
                                      } else if (snapshot.hasError) {
                                        return Text('${snapshot.error}');
                                      } else {
                                        if (notifyData.isNotEmpty) {
                                          return ListView.builder(
                                            itemCount: NotificationData.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final notification =
                                                  NotificationData[index];
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5, bottom: 2.5),
                                                color: const Color(0xFFf15f22)
                                                    .withOpacity(0.1),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.9,
                                                        child: Text(
                                                          notification.message,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                      Text(
                                                        formatTimeAgo(
                                                            notification
                                                                .createdAt),
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 2.5),
                                            color: const Color(0xFFf15f22)
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: const Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'There are no hr notifications',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  ),
                            ),
                            initiallyExpanded: isExpanded[0],
                            onTap: () {
                              setState(() {
                                isExpanded[0] = !isExpanded[0];
                                isExpanded[1] = false;
                                isExpanded[2] = false;
                                isExpanded[3] = false;
                              });
                            },
                          ),
                          CustomExpansionTile(
                            title: const Text(
                              "Today Birthdays",
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFFf15f22)
                                        .withOpacity(0.8)),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: birthdayNotifications.isEmpty
                                    ? Container(
                                        margin: const EdgeInsets.all(5),
                                        color: const Color(0xFFf15f22)
                                            .withOpacity(0.1),
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'There are no Birthdays',
                                          style: TextStyle(color: Colors.black),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: birthdayNotifications.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final notification =
                                              birthdayNotifications[index];
                                          bool hideButton =
                                              shouldHideSendWishesButton ||
                                                  repliedNotificationIds
                                                      .contains(notification
                                                          .notificationId);
                                          print(
                                              'empData2: ${notification.code}');
                                          print(
                                              'empData2: ${notification.employeeName}');
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 2.5),
                                            color: const Color(0xFFf15f22)
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  notification.code!,
                                                  style: const TextStyle(
                                                      color: Colors
                                                          .lightBlueAccent),
                                                ),
                                                const SizedBox(width: 7.0),
                                                Expanded(
                                                  child: Text(
                                                    notification.employeeName,
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !hideButton,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showdialogmethod(
                                                          notification
                                                              .notificationId,
                                                          notification
                                                              .employeeName);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFFf15f22)
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      child: empData?.employeeId !=
                                                                  null &&
                                                              empData!.employeeId ==
                                                                  notification
                                                                      .employeeId
                                                          ? const SizedBox()
                                                          : Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/cakedecoration.png',
                                                                  width: 15,
                                                                  height: 21,
                                                                  color: const Color(
                                                                      0xFFf15f22),
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                                const Icon(
                                                                  Icons
                                                                      .send_outlined,
                                                                  size: 18,
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                ),
                                                              ],
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            initiallyExpanded: isExpanded[1],
                            onTap: () {
                              setState(() {
                                isExpanded[1] = !isExpanded[1];
                                isExpanded[0] = false;
                                isExpanded[2] = false;
                                isExpanded[3] = false;
                              });
                              // updateIsExpandedList(1);
                            },
                            // initiallyExpanded:
                            //     getNotificationResult == birthdayNotification,
                          ),
                          CustomExpansionTile(
                            title: const Text(
                              "Up Coming Birthdays",
                              maxLines: 2,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: borderSide,
                                  right: borderSide,
                                  bottom: borderSide,
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: upcoming_model.isEmpty
                                    ? Container(
                                        margin: const EdgeInsets.only(
                                            top: 5, bottom: 2.5),
                                        color: const Color(0xFFf15f22)
                                            .withOpacity(0.1),
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'There are no Up Coming Birthdays',
                                                style: TextStyle(
                                                    color: Colors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: upcoming_model.length,
                                        shrinkWrap: true,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final notification =
                                              upcoming_model[index];
                                          print(
                                              'employeeNamefromapi${notification.employeeName}');

                                          String formattedDate =
                                              DateFormat('dd MMM').format(
                                                  notification.originalDOB);

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 2.5),
                                            color: const Color(0xFFf15f22)
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Image.asset(
                                                  //   'assets/cake.png',
                                                  //   width: 20,
                                                  //   height: 20,
                                                  //   color: Color(0xFFf15f22),
                                                  // ),
                                                  // SizedBox(
                                                  //   width: 10.0,
                                                  // ),
                                                  Container(
                                                    //  padding: EdgeInsets.all(3.0),
                                                    // decoration: BoxDecoration(
                                                    //     color: Colors.lightBlueAccent, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                    child: Text(
                                                      notification.employeeCode,
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .lightBlueAccent),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 7.0,
                                                  ),
                                                  // Container(
                                                  //   width: MediaQuery.of(context).size.width / 2,
                                                  //   child: Text(
                                                  //     notification.employeeName,
                                                  //     style: TextStyle(color: Colors.black),
                                                  //     maxLines: 1,
                                                  //     overflow: TextOverflow.ellipsis,
                                                  //     textAlign: TextAlign.start,
                                                  //   ),
                                                  // ),
                                                  Expanded(
                                                    child: Text(
                                                      notification.employeeName,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                  // SizedBox(
                                                  //   width: 10.0,
                                                  // ),
                                                  Container(
                                                    //width: MediaQuery.of(context).size.width / 1.9,
                                                    child: Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                  // if (emplyeidfromapi == sharedEmpId)
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            initiallyExpanded: isExpanded[2],
                            onTap: () {
                              setState(() {
                                isExpanded[2] = !isExpanded[2];
                                isExpanded[0] = false;
                                isExpanded[1] = false;
                                isExpanded[3] = false;
                              });
                              // updateIsExpandedList(2);
                            },
                            // initiallyExpanded:
                            //     getNotificationResult == upComingNotifications,
                          ),
                          notificationreplylist.isNotEmpty
                              ? CustomExpansionTile(
                                  title: const Text(
                                    "Greetings",
                                    maxLines: 2,
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  content: Container(
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    // ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        left: BorderSide(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(
                                                  0.8), // Adjust the color as needed
                                          width:
                                              1.0, // Adjust the width as needed
                                        ),
                                        right: BorderSide(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(
                                                  0.8), // Adjust the color as needed
                                          width:
                                              1.0, // Adjust the width as needed
                                        ),
                                        bottom: BorderSide(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(
                                                  0.8), // Adjust the color as needed
                                          width:
                                              1.0, // Adjust the width as needed
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: notificationreplylist.isEmpty
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5, bottom: 2.5),
                                              color: const Color(0xFFf15f22)
                                                  .withOpacity(0.1),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                child: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  notificationreplylist.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final notification =
                                                    notificationreplylist[
                                                        index];
                                                print(
                                                    'messagefromapi:${notification.message}');

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5, bottom: 2.5),
                                                  color: const Color(0xFFf15f22)
                                                      .withOpacity(0.1),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'Birthday Wishes from ${notification.employeeName}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 7.0,
                                                            ),
                                                            Container(
                                                              child: Text(
                                                                notification
                                                                    .code,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .lightBlueAccent),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 7.0,
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            notification
                                                                .message,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  initiallyExpanded: isExpanded[3],
                                  onTap: () {
                                    setState(() {
                                      isExpanded[3] = !isExpanded[3];
                                      isExpanded[0] = false;
                                      isExpanded[1] = false;
                                      isExpanded[2] = false;
                                    });
                                  },
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    )
                  ],
                ),
                //  ),
              ),
             */
            ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
        backgroundColor: const Color(0xFFf15f22),
        title: const Text(
          'Notifications',
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
        ));
  }

  String formatTimeAgo(String createdAt) {
    DateTime createdTime = DateTime.parse(createdAt);
    return timeago.format(createdTime);
  }

  Future<void> sendgreetings(int notificationid, String empname) async {
    print('sendgreetings notificationid: $notificationid | empname: $empname');
    if (messagecontroller.text.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Wishes', context, 1, 4);
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
    String message = messagecontroller.text.trim().toString();

    try {
      final url = Uri.parse(baseUrl + sendgreeting);
      print('sendgreetings url: $url');
      final request = {
        "createdAt": formattedDate,
        "updatedAt": formattedDate,
        "createdBy": "$userid",
        "updatedBy": "$userid",
        "notificationReplyId": 0,
        "notificationId": notificationid,
        "message": message,
        "employeeId": sharedEmpId,
        "isActive": true
      };

      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );
      print('sendgreetings requestobject ${json.encode(request)}');
      print('sendgreetings response ${response.body}');
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Map<String, dynamic> responseMap = json.decode(response.body);
        if (responseMap['isSuccess'] == true) {
          //  Navigator.of(context).pop();
          // Commonutils.showCustomToastMessageLong('${responseMap['message']}', context, 1, 4);
          setState(() {
            isSentWishes = responseMap['isSuccess'];
          });
          Commonutils.showCustomToastMessageLong(
              'Wishes Sent to ${empname}Successfully', context, 0, 4);
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => home_screen()),
          );
        } else {
          Commonutils.showCustomToastMessageLong(
              '${responseMap['message']}', context, 1, 4);
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

  Future<List<List<Notification_model>>> fetchNotifications() async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
    } else {
      Commonutils.showCustomToastMessageLong(
          'No Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString("accessToken") ?? "";
      sharedEmpId = prefs.getString("employeeId") ?? "";
      loggedInEmployeeId = int.tryParse(sharedEmpId);
      userid = prefs.getString("UserId") ?? "";
      loademployeid();
      final url = Uri.parse(baseUrl + getnotification);
      print('fetchNotifications url: $url');
      print('fetchNotifications accessToken: $accessToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken!,
        },
      );
      print('fetchNotifications res: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('fetchNotifications jsonData: $jsonData');
        List<Notification_model> data =
            jsonData.map((json) => Notification_model.fromJson(json)).toList();

        // setState(() { });
        //MARK: HR Notifications(164)
        //  List<Notification_model> notifyData = data.where((notification) => notification.messageType != 'Birthday').toList();
        //    List<Notification_model> notifyData = data.where((notification) => notification.messageType != 'Birthday').toList();
        List<Notification_model> notifyData = data
            .where((notification) =>
                notification.messageType == 'Company Anniversary Day')
            .toList();
        // List<Notification_model> notifyData = data.where((notification) => notification.messageTypeId == 147).toList();

        //MARK: Today Notifications(168)
        // List<Notification_model> birthdayNotifyData = data.where((notification) => notification.messageTypeId == 168).toList();
        List<Notification_model> birthdayNotifyData = data
            .where((notification) => notification.messageType == 'Birthday')
            .toList();

        checkNotificationsAndOpenExpandedView(notifyData, birthdayNotifyData);

        setState(() {
          for (var notification in birthdayNotifyData) {
            getNotificationsReplies(accessToken!, notification.employeeId);
          }
        });
        return [notifyData, birthdayNotifyData];
      } else {
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('catch: $error');
      rethrow;
    }
  }

  Future<void> getNotificationsReplies(
      String accessToken, int employeeId) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse('$baseUrl$getnotificationreplies$employeeId');
    print('url:$url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          // Check if any employeeId from jsonData matches loggedInEmployeeId
          bool isMatchingEmployeeId = jsonData
              .any((reply) => reply['employeeId'] == loggedInEmployeeId);

          if (isMatchingEmployeeId) {
            // If any employeeId matches, add notification IDs to repliedNotificationIds
            for (var reply in jsonData) {
              repliedNotificationIds.add(reply['notificationId']);
            }
          }
        });
      } else {
        // Handle error if the request was not successful
        print(
            'Error in replies API: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
    }
  }

  Future<void> getNotificationsRepliesByEmployes(
      String accessToken, int employeeId) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse('$baseUrl$getnotificationreplies$employeeId');
    print('getNotificationsRepliesByEmployee: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );

      print('response body for replies: ${response.body}');
      print('response code for replies: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<NotificationReply> notifiReply =
            jsonData.map((json) => NotificationReply.fromJson(json)).toList();
        print('notifiReply: $notifiReply');
        setState(() {
          notificationreplylist = notifiReply;
          // Check if any employeeId from jsonData matches loggedInEmployeeId
        });
      } else {
        // Handle error if the request was not successful
        print(
            'Error in replies API: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
    }
  }

  Future<void> GetUpcomingbdays(String accessToken) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse(baseUrl + getupcomingbirthdays);
    print('getupcomingbirthdays: $url');
    try {
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Authorization': '$accessToken',
      // };
      print('API headers: $accessToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      print('response body: ${response.body}');
      print('response code: ${response.statusCode}');

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        print('xxx: ${response.body}');
        final List<dynamic> jsonData = json.decode(response.body);
        print('getupcomingbirthdaysResponse: $jsonData');

        List<UpComingbirthdays> bdaymodel =
            jsonData.map((json) => UpComingbirthdays.fromJson(json)).toList();
        //   print('Notification models: $bdaymodel');

        setState(() {
          upcoming_model = bdaymodel;
        });
      } else {
        // Handle error if the request was not successful
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('ErrorGetnotificationreplies: $error');

      // Handle any exceptions that occurred during the reque
    }
  }

  void showDialogForWish(int notificationId, String employeeId) {
    messagecontroller.clear();
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
                  const Text(
                    "Send Wishes",
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
                    //width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.name,
                          controller: messagecontroller,
                          // inputFormatters: [
                          //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                          // ],
                          inputFormatters: [OnlyTextInputFormatter()],
                          onTap: () {},
                          decoration: InputDecoration(
                            hintText: 'Enter Wishes',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: outlineInputBorder,
                            enabledBorder: outlineInputBorder,
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
                    Navigator.of(context).pop();
                    sendgreetings(notificationId, employeeId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf15f22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Send Wishes',
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

  void checkNotificationsAndOpenExpandedView(
      List<Notification_model> notificationData,
      List<Notification_model> birthdayNotifications) {
    if (notificationData.isNotEmpty) {
      isExpanded[0] = true;
    } else if (birthdayNotifications.isNotEmpty) {
      // empData = birthdayNotifications
      //     .firstWhere((e) => e.employeeId.toString() == sharedEmpId);
      empData = birthdayNotifications.firstWhere(
        (e) => e.employeeId.toString() == sharedEmpId,
        orElse: () => Notification_model(
          notificationId: -1,
          employeeId: -1,
          employeeName: 'test',
          code: 'test',
          message: 'test',
          messageTypeId: -1,
          messageType: 'test',
          notifyTill: 'test',
          isActive: false,
          createdAt: 'test',
          createdBy: 'test',
        ),
      );
      print('empData: ${empData?.employeeId}');
      // bool result = birthdayNotifications.map((e) => e.employeeId.toString() == sharedEmpId,);
      isExpanded[1] = true;
    } else {
      isExpanded[2] = true;
    }
  }
}

class CustomExpansionTile extends StatelessWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;
  final Function()? onTap;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.content,
    required this.initiallyExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.white,
      //elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: const BoxDecoration(
                //  borderRadius: BorderRadius.circular(10.0),
                color: Color(0xFFf15f22),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: title),
                  Icon(
                    initiallyExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (initiallyExpanded) content,
        ],
      ),
    );
  }
}

class OnlyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filteredText = newValue.text.replaceAll(RegExp('[^a-zA-Z ]'), '');
    return newValue.copyWith(
      text: filteredText,
      selection: newValue.selection,
    );
  }
}
