import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Notifications_screen.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/apply_leave.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/personal_details.dart';
import 'package:hrms/projects_screen.dart';
import 'package:hrms/screens/AddLeads.dart';
import 'package:hrms/screens/employee_profile.dart';
import 'package:hrms/screens/home/hrms_homescreen.dart';
import 'package:hrms/screens/home/sync_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:hrms/test_apply_leave.dart';
import 'package:hrms/test_projects.dart';
import 'package:hrms/screens/test_hrms.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common/sqlite_api.dart';
import 'Constants.dart';

import 'Database/DataAccessHandler.dart';
import 'Database/HRMSDatabaseHelper.dart';
import 'Holiday_screen.dart';
import 'Model Class/EmployeeInfo.dart';
import 'common_widgets/CommonUtils.dart';
import 'common_widgets/PermissionManager.dart';
import 'screens/home/HomeScreen.dart';
import 'Myleaveslist.dart';
import 'Resginaton_request.dart';
import 'feedback_Screen.dart';
import 'leaves_screen.dart';
import 'main.dart';
import 'package:flutter/services.dart';

// const CURVE_HEIGHT = 320.0;
// const AVATAR_RADIUS = CURVE_HEIGHT * 0.23;
// const AVATAR_DIAMETER = AVATAR_RADIUS * 2.5;

class home_screen extends StatefulWidget {
  @override
  _home_screenState createState() => _home_screenState();
}

class _home_screenState extends State<home_screen>
    with SingleTickerProviderStateMixin {
  int currentTab = 0;
  bool islogin = false;
  FocusNode _projectsFocusNode = FocusNode();
  FocusNode _leavesFocusNode = FocusNode();

  final PageController _pageController = PageController();

  //int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _currentIndex = 0;
  bool? showAddClient; // Toggle visibility for Add Client
  bool isLoading = true;
  int? pendingleadscount;
  int? pendingfilerepocount;
  int? pendingboundarycount;
  int? pendingAttendencecount;
  bool isButtonEnabled = false;
  final dbHelper = HRMSDatabaseHelper();
  final dataAccessHandler = DataAccessHandler();
  @override
  void initState() {
    checkLoginuserdata();
    fetchpendingrecordscount();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) async {
      if (isConnected) {
        print('The Internet Is Connected');
        DateTime startDate = new DateTime.now().toLocal();
        int offset = await NTP.getNtpOffset(localTime: startDate);
        print(
            'NTP DateTime offset align: ${startDate.add(new Duration(milliseconds: offset))}');
        //   WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
      } else {
        print('The Internet Is not  Connected');
      }
    });
    // TODO: implement initState
  }

  Future<bool> _onWillPop() async {
    if (currentTab != 0) {
      setState(() {
        currentTab = 0;
      });
      return Future.value(false);
    } else {
      bool confirmClose = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to close the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

      if (confirmClose == true) {
        SystemNavigator.pop();
      }

      return false;
    }
  }

  void _selectTab(int index) {
    setState(() {
      currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: appBar(context, isButtonEnabled),
          drawer: drawer(context),
          body: _buildScreens(_currentIndex),
          bottomNavigationBar: bottomNavigationBar(),
        ),
      ),
    );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() {
        _currentIndex = index;
      }),
      selectedItemColor: const Color(0xFFf15f22),
      items: [
        _buildNavItem('assets/home.svg', 'Home'),
        _buildNavItem('assets/overview.svg', 'Projects'),
        _buildNavItem('assets/calendar-day.svg', ' Leaves'),
        _buildNavItem('assets/circleuser.svg', 'Profile'),
        // if (showAddClient!)
        _buildNavItem('assets/addlead.svg', 'Add Client Visits'),
      ],
    );
  }

  Drawer drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
                // Remove the DecorationImage with AssetImage
                ),
            child: SvgPicture.asset(
              'assets/cislogo-new.svg', // Replace with the path to your SVG icon
              width: 80, // Adjust the width as needed
              height: 100, // Adjust the height as needed
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/atten.svg',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              color: Colors.black,
            ),
            title: const Text(
              'My Leaves',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Myleaveslist()),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/holiday.png',
              width: 22,
              height: 22,
              color: Colors.black,
            ),
            title: const Text(
              'Holidays',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HolidaysScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.notification_important,
              color: Colors.black,
              weight: 20,
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.copy,
              color: Colors.black,
              weight: 20,
            ),
            title: const Text(
              'Resignation Request',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Resgination_req()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.black,
            ), // Change the icon as needed
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'hind_semibold',
              ),
            ),
            onTap: () {
              logOutDialog();
              // Handle the onTap action for Logout
            },
          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context, bool isButtonEnabled) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFf15f22),
      title: const Text(
        'HRMS',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Notifications(),
              ),
            );
          },
          child: const Icon(
            Icons.notification_important,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 15.0),
        if (isButtonEnabled) // Show only if isButtonEnabled is true
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncScreen(),
                ),
              );
            },
            child: SvgPicture.asset(
              'assets/backup.svg',
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        if (isButtonEnabled) const SizedBox(width: 15.0),
      ],
    );
  }

  void logOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are You Sure You Want to Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirmLogout(); // Perform logout action
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> onConfirmLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    SharedPreferencesHelper.putBool(Constants.isPunchIn, false);
    prefs.remove(Constants.punchTime);
    Commonutils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => LoginPage()));

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void checkLoginuserdata() async {

    _initializeData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showAddClient = PermissionManager.hasPermission("CanManageClientVisits");
      print('showAddClient: $showAddClient');
    });
  }

  void fetchpendingrecordscount() async {
    setState(() {
      isLoading = true; // Start loading
    });

    // Fetch pending counts
    pendingleadscount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingLeadsCount FROM Leads WHERE ServerUpdatedStatus = 0');
    pendingfilerepocount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingrepoCount FROM FileRepository WHERE ServerUpdatedStatus = 0');
    pendingboundarycount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingboundaryCount FROM GeoBoundaries WHERE ServerUpdatedStatus = 0');
    pendingAttendencecount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingAttendencecount FROM DailyPunchInAndOutDetails WHERE ServerUpdateStatus = 0');
    print('pendingleadscount: $pendingleadscount ');
    print('pendingfilerepocount: $pendingfilerepocount');
    print('pendingboundarycount: $pendingboundarycount ');
    print('pendingweekoffcount: $pendingAttendencecount');
    // Enable button if any of the counts are greater than 0
    isButtonEnabled = pendingleadscount! > 0 || pendingAttendencecount! > 0 || pendingfilerepocount! > 0 || pendingboundarycount! > 0;

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        width: 20,
        height: 20,
        color: Colors.black.withOpacity(0.6),
      ),
      activeIcon: SvgPicture.asset(
        iconPath,
        width: 20,
        height: 20,
        color: CommonUtils.primaryTextColor,
      ),
      label: label,
    );
  }

  Widget _buildScreens(int index) {
    switch (index) {
      case 0:
        return const HrmsHomeSreen();
      case 1:
        return const TestProjectsScreen();
      case 2:
        return leaves_screen();
      case 3:
        return const EmployeeProfile();
      case 4:
        return const AddLeads();
      default:
        return const HrmsHomeSreen();
    }
  }

  String buildTitle(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Projects';
      case 2:
        return 'Apply Leave';
      case 3:
        return 'Profile';
      case 4:
        return 'Add Client Visits';
      default:
        return '';
    }
  }

  Future<void> _initializeData() async {
    String currentDate = getCurrentDate();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString(SharedKeys.userId) ?? "";
    final db = await dbHelper.database; // Replace with your database initialization
    final employeeInfos = await fetchEmployeeInfo(userID,currentDate);
    await clearAllTables(db);
    for (var info in employeeInfos) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLeaveToday', info.isLeaveToday);
      print('isleave: ${info.isLeaveToday}');
      await insertEmployeeInfo(db, info);
    }
  }

  Future<List<EmployeeInfo>> fetchEmployeeInfo(String userID, String currentDate,) async {
    final response = await http.get(Uri.parse('http://182.18.157.215/HRMS/API/hrmsapi/Employee/GetEmployeeInfoForMobile/$userID/$currentDate'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => EmployeeInfo.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employee info');
    }
  }

  Future<void> insertEmployeeInfo(Database db, EmployeeInfo info) async {

    // Insert ShiftDetails
    for (var shift in info.shiftDetails) {
      await db.insert('ShiftDetails', {

        'ShiftId': shift.shiftId,
        'ShiftIn': shift.shiftIn,
        'ShiftOut': shift.shiftOut,
        'MinimumWorkingHours': shift.minimumWorkingHours,
        'GraceTime': shift.graceTime,
        'RecreationTime': shift.recreationTime,
        'ShiftName': shift.shiftName,
        'ShiftTypeName': shift.shiftTypeName,
        'WorkingDays': shift.workingDays,
      });
    }


    // Insert TrackingInfo
    for (var track in info.trackingInfo) {
      await db.insert('TrackingInfo', {
        'canTrackEmployee': track.canTrackEmployee ? 1 : 0,
        'trackTypeId': track.trackTypeId,
        'trackType': track.trackType,
        'trackInTime': track.trackInTime,
        'trackOutTime': track.trackOutTime,
      });
    }

    // Insert Holidays
    for (var holiday in info.holidays) {
      await db.insert('Holidays', {

        'Id': holiday.id,
        'name': holiday.name,
        'fromDate': holiday.fromDate,
        'toDate': holiday.toDate,
      });
    }
  }

  Future<void> clearAllTables(Database db) async {

    await db.delete('ShiftDetails');
    await db.delete('TrackingInfo');
    await db.delete('Holidays');
  }

}
