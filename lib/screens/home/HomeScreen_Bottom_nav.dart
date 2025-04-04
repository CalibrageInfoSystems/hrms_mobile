// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:hrms/screens/AddLeads.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Commonutils.dart';
// import '../../Constants.dart';
// import '../../Holiday_screen.dart';
// import '../../Myleaveslist.dart';
// import '../../Notifications_screen.dart';
// import '../../Resginaton_request.dart';
// import '../../SharedPreferencesHelper.dart';
// import '../../common_widgets/CommonUtils.dart';
// import '../../common_widgets/common_styles.dart';
// import '../../feedback_Screen.dart';
// import '../../leaves_screen.dart';
// import '../../login_screen.dart';
// import '../../personal_details.dart';
// import '../../test_projects.dart';
// import '../test_hrms.dart';
// import 'HomeScreen.dart';
//
// class HomeScreen_Bottom_nav extends StatefulWidget {
//
//
//   const HomeScreen_Bottom_nav({super.key});
//
//   @override
//   State<HomeScreen_Bottom_nav> createState() => _HomeState();
// }
//
// class _HomeState extends State<HomeScreen_Bottom_nav> {
//   String userFullName = '';
//   int _currentIndex = 0;
//   bool? showAddClient ; // Toggle visibility for Add Client
//
//   @override
//   void initState() {
//     super.initState();
//     checkLoginuserdata();
//     print(' Home_____');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_currentIndex != 0) {
//           setState(() {
//             _currentIndex = 0;
//           });
//           return Future.value(false);
//         } else {
//           bool confirmClose = await showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Confirm Exit'),
//                 content: const Text('Are You Sure You Want to Close The App?'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text('No'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     child: const Text('Yes'),
//                   ),
//                 ],
//               );
//             },
//           );
//           if (confirmClose == true) {
//             SystemNavigator.pop();
//           }
//           return Future.value(false);
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: const Color(0xFFf15f22),
//           title: const Text(
//             'HRMS',
//             style: TextStyle(color: Colors.white),
//           ),
//           centerTitle: true,
//           actions: [
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const Notifications()),
//                 );
//               },
//               child: const Icon(
//                 Icons.notification_important,
//                 //  size: 15.0,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(
//               width: 15.0,
//             )
//           ],
//         ),
//         drawer: Drawer(
//           child: ListView(
//             children: [
//               DrawerHeader(
//                 decoration: const BoxDecoration(
//                   // Remove the DecorationImage with AssetImage
//                 ),
//                 child: SvgPicture.asset(
//                   'assets/cislogo-new.svg', // Replace with the path to your SVG icon
//                   width: 80, // Adjust the width as needed
//                   height: 100, // Adjust the height as needed
//                 ),
//               ),
//               ListTile(
//                 leading: SvgPicture.asset(
//                   'assets/atten.svg',
//                   width: 20,
//                   height: 20,
//                   fit: BoxFit.contain,
//                   color: Colors.black,
//                 ),
//                 title: const Text(
//                   'My Profile',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => personal_details()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: SvgPicture.asset(
//                   'assets/atten.svg',
//                   width: 20,
//                   height: 20,
//                   fit: BoxFit.contain,
//                   color: Colors.black,
//                 ),
//                 title: const Text(
//                   'My Leaves',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => Myleaveslist()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.star,
//                   color: Colors.black,
//                 ), // Change the icon as needed
//                 title: const Text(
//                   'Feedback',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => feedback_Screen()),
//                   );
//                   // Handle the onTap action for Logout
//                 },
//               ),
//               ListTile(
//                 leading: Image.asset(
//                   'assets/holiday.png',
//                   width: 22,
//                   height: 22,
//                   color: Colors.black,
//                 ),
//                 title: const Text(
//                   'Holidays',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => HolidaysScreen()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.notification_important,
//                   color: Colors.black,
//                   weight: 20,
//                 ),
//                 // SvgPicture.asset(
//                 //   'assets/atten.svg',
//                 //   width: 20,
//                 //   height: 20,
//                 //   fit: BoxFit.contain,
//                 //   color: Colors.black,
//                 // ),
//                 title: const Text(
//                   'Notifications',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const Notifications()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.copy,
//                   color: Colors.black,
//                   weight: 20,
//                 ),
//                 // SvgPicture.asset(
//                 //   'assets/atten.svg',
//                 //   width: 20,
//                 //   height: 20,
//                 //   fit: BoxFit.contain,
//                 //   color: Colors.black,
//                 // ),
//                 title: const Text(
//                   'Resignation Request',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const Resgination_req()),
//                   );
//                 },
//               ),
//
//               ListTile(
//                 leading: const Icon(
//                   Icons.logout,
//                   color: Colors.black,
//                 ), // Change the icon as needed
//                 title: const Text(
//                   'Logout',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//              logOutDialog();
//                   // Handle the onTap action for Logout
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.logout,
//                   color: Colors.black,
//                 ),
//                 title: const Text(
//                   'Test',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: 'hind_semibold',
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const TestHrms()),
//                   );
//                 },
//               ),
//
//               //MARK: Test Apply Leave
//               /* ListTile(
//                       leading: SvgPicture.asset(
//                         'assets/atten.svg',
//                         width: 20,
//                         height: 20,
//                         fit: BoxFit.contain,
//                         color: Colors.black,
//                       ),
//                       title: Text(
//                         'Test Apply Leave',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontFamily: 'hind_semibold',
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => TestApplyLeave()),
//                         );
//                       },
//                     ),
//                     ListTile(
//                       leading: SvgPicture.asset(
//                         'assets/atten.svg',
//                         width: 20,
//                         height: 20,
//                         fit: BoxFit.contain,
//                         color: Colors.black,
//                       ),
//                       title: Text(
//                         'Test Projects',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontFamily: 'hind_semibold',
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => TestProjectsScreen()),
//                         );
//                       },
//                     ),
//                  */
//             ],
//           ),
//         ),
//         body: _buildScreens(_currentIndex),
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           onTap: (index) => setState(() {
//             _currentIndex = index;
//           }),
//           selectedItemColor:  const Color(0xFFf15f22),
//           items: [
//             _buildNavItem('assets/home.svg', 'Home'),
//             _buildNavItem('assets/2560114.svg', 'Projects'),
//             _buildNavItem('assets/leave_8.svg', ' Leaves'),
//             if (showAddClient!) _buildNavItem('assets/atten.svg', 'Add Client'),
//             _buildNavItem('assets/Profile_new.svg', 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
//     return BottomNavigationBarItem(
//       icon: SvgPicture.asset(
//         iconPath,
//         width: 20,
//         height: 20,
//         color: Colors.black.withOpacity(0.6),
//       ),
//       activeIcon: SvgPicture.asset(
//         iconPath,
//         width: 20,
//         height: 20,
//         color: CommonUtils.primaryTextColor,
//       ),
//       label: label,
//     );
//   }
//
//   Widget _buildScreens(int index) {
//     switch (index) {
//       case 0:
//         return HomeScreen();
//       case 1:
//         return TestProjectsScreen();
//       case 2:
//         return leaves_screen();
//       case 3:
//         return AddLeads();
//       case 4:
//         return personal_details();
//       default:
//         return HomeScreen();
//     }
//   }
//
//   void checkLoginuserdata() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userFullName = prefs.getString('userFullName') ?? '';
//       showAddClient = prefs.getBool('canAddClient') ;
//       print('showAddClient: $showAddClient');
//     });
//   }
//
//   String buildTitle(int currentIndex) {
//     switch (currentIndex) {
//       case 0:
//         return 'Home';
//       case 1:
//         return 'Projects';
//       case 2:
//         return 'Apply Leave';
//       case 3:
//         return 'Add Client Visits';
//       case 4:
//         return 'Profile';
//       default:
//         return '';
//     }
//   }
//
//   void logOutDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Logout'),
//           content: const Text('Are You Sure You Want to Logout?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 onConfirmLogout(); // Perform logout action
//               },
//               child: const Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void onConfirmLogout() {
//     SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
//     Commonutils.showCustomToastMessageLong(
//         "Logout Successfully", context, 0, 3);
//     // Navigator.pushReplacement(
//     //     context, MaterialPageRoute(builder: (context) => LoginPage()));
//
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (route) => false,
//     );
//   }
// }
