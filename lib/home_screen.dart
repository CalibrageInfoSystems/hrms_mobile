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
import 'package:hrms/test_apply_leave.dart';
import 'package:hrms/test_projects.dart';
import 'package:hrms/ui_screens/test_hrms.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Constants.dart';

import 'Holiday_screen.dart';
import 'HomeScreen.dart';
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

  @override
  void initState() {
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
        onWillPop: _onWillPop
        //   async {
        // if (currentTab != 0) {
        //   setState(() {
        //     currentTab = 0;
        //   });
        //   return Future.value(false);
        //
        // }
        //
        //     else {
        //       bool confirmClose = await showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return AlertDialog(
        //             title: const Text('Confirm Exit'),
        //             content: const Text('Are you sure you want to close the app?'),
        //             actions: <Widget>[
        //               TextButton(
        //                 onPressed: () => Navigator.of(context).pop(false),
        //                 child: const Text('No'),
        //               ),
        //               TextButton(
        //                 onPressed: () => Navigator.of(context).pop(true),
        //                 child: const Text('Yes'),
        //               ),
        //             ],
        //           );
        //         },
        //       );
        //
        //       if (confirmClose == true) {
        //         SystemNavigator.pop();
        //       }
        //
        //       return false;
        //     }
        //     // return false; // Prevent default back navigation behavior
        //   }
        ,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: const Color(0xFFf15f22),
                title: const Text(
                  'HRMS',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Notifications()),
                      );
                    },
                    child: const Icon(
                      Icons.notification_important,
                      //  size: 15.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15.0,
                  )
                ],
              ),
              drawer: Drawer(
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
                        'My Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => personal_details()),
                        );
                      },
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
                          MaterialPageRoute(
                              builder: (context) => Myleaveslist()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.star,
                        color: Colors.black,
                      ), // Change the icon as needed
                      title: const Text(
                        'Feedback',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => feedback_Screen()),
                        );
                        // Handle the onTap action for Logout
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
                          MaterialPageRoute(
                              builder: (context) => HolidaysScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.notification_important,
                        color: Colors.black,
                        weight: 20,
                      ),
                      // SvgPicture.asset(
                      //   'assets/atten.svg',
                      //   width: 20,
                      //   height: 20,
                      //   fit: BoxFit.contain,
                      //   color: Colors.black,
                      // ),
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
                          MaterialPageRoute(
                              builder: (context) => const Notifications()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.copy,
                        color: Colors.black,
                        weight: 20,
                      ),
                      // SvgPicture.asset(
                      //   'assets/atten.svg',
                      //   width: 20,
                      //   height: 20,
                      //   fit: BoxFit.contain,
                      //   color: Colors.black,
                      // ),
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
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      title: const Text(
                        'Test',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TestHrms()),
                        );
                      },
                    ),

                    //MARK: Test Apply Leave
                    /* ListTile(
                      leading: SvgPicture.asset(
                        'assets/atten.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Test Apply Leave',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TestApplyLeave()),
                        );
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'assets/atten.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        color: Colors.black,
                      ),
                      title: Text(
                        'Test Projects',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TestProjectsScreen()),
                        );
                      },
                    ),
                 */
                  ],
                ),
              ),
              body: _buildBody(),
              floatingActionButton: FloatingActionButton(
                elevation: 0,
                //   mini: true,
                child: Image.asset(
                  'assets/app_logo.png',
                  // 'assets/user_1.png',
                  width: 18,
                  height: 23,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    currentTab = 0;
                    //_selectTab(0);
                  });
                },
                backgroundColor: const Color(0xFFf15f22),
                // Set the background color to orange
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.white,
                      width: 3.0), // Set border color and width
                  borderRadius:
                      BorderRadius.circular(60), // Adjust the radius as needed
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                height: 58,
                shape: const CircularNotchedRectangle(),
                padding: const EdgeInsets.only(bottom: 10.0),
                notchMargin: currentTab == 0 ? 8 : 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                currentTab = 1;
                                //    _selectTab(1  );
                              });
                              _projectsFocusNode.requestFocus();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3 / 1,
                              //    padding: EdgeInsets.only(left: 25.0),
                              margin: const EdgeInsets.only(left: 25.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentTab = 1;
                                    //  _selectTab(1);
                                  });
                                  _projectsFocusNode.requestFocus();
                                },
                                // child: Container(
                                // width: MediaQuery.of(context).size.width,

                                child: Focus(
                                    focusNode: _projectsFocusNode,
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentTab = 1;
                                              //  _selectTab(1);
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: SvgPicture.asset(
                                                  'assets/2560114.svg', // Replace with the actual path to your SVG icon
                                                  height:
                                                      20, // Adjust the height as needed
                                                  width:
                                                      20, // Adjust the width as needed
                                                  color:
                                                      const Color(0xFFf15f22),
                                                ),
                                              ),
                                              const Text(
                                                "Projects",
                                                style: TextStyle(
                                                    color: Color(0xFFf15f22),
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Calibri'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3 /
                                              1,
                                          height: 4,
                                          child: Container(
                                            color: currentTab == 1
                                                ? const Color(0xFFf15f22)
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    )),
                                // ),
                              ),
                            )),

                        // SizedBox(width: 10.0),
                        InkWell(
                          onTap: () {
                            setState(() {
                              currentTab = 2;
                              //  _selectTab(2);
                            });
                            _leavesFocusNode.requestFocus();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.7 / 1,
                            padding: const EdgeInsets.only(right: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentTab = 2;
                                  // _selectTab(2);
                                });
                                _leavesFocusNode.requestFocus();
                              },
                              child: Container(
                                // padding: EdgeInsets.only(right: 20.0),
                                child: Focus(
                                    focusNode: _leavesFocusNode,
                                    child: Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(13.0),
                                              child: SvgPicture.asset(
                                                'assets/leave_8.svg', // Replace with the actual path to your SVG icon
                                                height:
                                                    22, // Adjust the height as needed
                                                width:
                                                    20, // Adjust the width as needed
                                                color: const Color(0xFFf15f22),
                                              ),
                                            ),
                                            const Text(
                                              "Leaves",
                                              style: TextStyle(
                                                  color: Color(0xFFf15f22),
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri'),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5 /
                                              1,
                                          height: 4,
                                          child: Container(
                                            color: currentTab == 2
                                                ? const Color(0xFFf15f22)
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                // BottomNavigationBar(
                //   currentIndex: currentTab,
                //   items: [
                //     BottomNavigationBarItem(
                //       icon: Icon(Icons.home),
                //       label: 'Home',
                //     ),
                //     BottomNavigationBarItem(
                //       icon: Icon(Icons.search),
                //       label: 'Search',
                //     ),
                //   ],
                //   onTap: _onNavItemTapped,
                // ),
              ),
            )));
  }

  // void _onNavItemTapped(int index) {
  //   setState(() {
  //     currentTab = index;
  //   });
  // }

  // Widget _buildBody() {
  //   switch (currentTab) {
  //     case 0:
  //       return personal_details();
  //     case 1:
  //       return projects_screen();
  //     case 2:
  //       return leaves_screen();
  //
  //     default:
  //       return home_screen();
  //     //return Container();
  //   }
  // }
  Widget _buildBody() {
    Widget bodyContent;
    switch (currentTab) {
      case 0:
        bodyContent = const HomeScreen();
        break;
      case 1:
        bodyContent = const TestProjectsScreen();
        // bodyContent = projects_screen();
        break;
      case 2:
        bodyContent = leaves_screen();
        break;
      default:
        bodyContent = home_screen();
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (currentTab != 0 && details.primaryVelocity! > 0) {
          // Swipe right detected
          setState(() {
            currentTab = 0;
          });
        }
      },
      child: bodyContent,
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

  void onConfirmLogout() {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => LoginPage()));

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
