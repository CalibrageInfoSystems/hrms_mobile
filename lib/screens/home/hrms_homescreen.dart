import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/Database/HRMSDatabaseHelper.dart';
import 'package:hrms/Myleaveslist.dart';

import 'package:hrms/screens/AddLeads.dart';
import 'package:hrms/screens/BatteryOptimization.dart';
import 'package:hrms/screens/ViewLeads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workmanager/workmanager.dart';

import '../../Commonutils.dart';
import '../../Database/SyncService.dart';
import '../../Database/SyncServiceB.dart';

import '../../Model Class/LeadsModel.dart';
import '../../SharedPreferencesHelper.dart';
import '../../api config.dart';
import '../../common_widgets/common_styles.dart';
import '../../common_widgets/custom_lead_template.dart';
import 'dart:ui' as ui;
import '../../location_service/logic/location_controller/location_controller_cubit.dart';
import '../../location_service/notification/notification.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:hrms/database/DataAccessHandler.dart';

import '../../shared_keys.dart';

import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'package:hrms/common_widgets/custom_btn.dart';

class HrmsHomeSreen extends StatefulWidget {
  const HrmsHomeSreen({super.key});

  @override
  State<HrmsHomeSreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HrmsHomeSreen> {
  late BackgroundService backgroundService;
  late double lastLatitude;
  late double lastLongitude;
  DateTime? initialDateOnDatePicker;
  static const double MAX_ACCURACY_THRESHOLD = 10.0;
  static const double MAX_SPEED_ACCURACY_THRESHOLD = 5.0;
  static const double MIN_DISTANCE_THRESHOLD = 50.0;
  static const double MIN_SPEED_THRESHOLD = 0.2;
  double usedPrivilegeLeavesInYear = 0.0;
  double allottedPrivilegeLeaves = 0.0;
  final dbHelper = HRMSDatabaseHelper();
  final dataAccessHandler = DataAccessHandler();
  String? username;
  String? formattedDate;
  String? calenderDate;
  bool isLocationEnabled = false;
  String? userID;
  int? RoleId;
  int? totalLeadsCount = 0;
  int? todayLeadsCount = 0;
  int? pendingleadscount;
  int? pendingfilerepocount;
  int? pendingboundarycount;
  int? pendingweekoffcount;
  int? dateRangeLeadsCount = 0;
  late Future<List<LeadsModel>> futureLeads;
  bool isLoading = true;
  double totalDistance = 0.0;
  bool isButtonEnabled = false;
  String? selectedOptionbottom = null; // Default selected option
  DateTime selectedDatemark =
      DateTime.now().add(const Duration(days: 1)); // Default current date
  TextEditingController remarksController = TextEditingController();
  bool? isLeave;
  int? toastcount = 0; // Controller for remarks
  String _currentDateTime = "";
  String _currentLocation = "Fetching location...";
  TextEditingController dateController =
      TextEditingController(); // Controller for displaying date
  List<int> userActivityRights = [];
  List<String> menuItems = [];
  static const String PREVIOUS_SYNC_DATE = 'previous_sync_date';
  late Future<List<int>> futureSync;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  String _latitude = "Fetching...";
  String _longitude = "Fetching...";
  String _address = "Fetching address...";
  String _time = "";
  bool isPunchedIn = false;
  bool isRequestProcessing = false;
  String base64Image = '';
  File? _imageFile;
  String filename = '';
  String fileExtension = '';
  String employecode = '';
  String? userid;
  String? photoData;
  String Gender = '';
  String EmployeName = '';
  String? employee_designation;
  String empolyeid = '';
  String accessToken = '';
  bool? isPunchIn = false;
  int employeid = 0;
  double allottedPriviegeLeaves = 0.0;

  double usedCasualLeavesInYear = 0.0;
  double allotcausalleaves = 0.0;
  double availablepls = 0.0;
  double availablecls = 0.0;
  double usedCasualLeavesInMonth = 0.0;

  @override
  void initState() {
    super.initState();
    print('www: initState called');
    loadPunchInfo();
    loadCurrentLocation();
    getuserdata();
    _loademployeleaves();
    fetchLeadCounts();
    fetchpendingrecordscount();
    backgroundService =
        BackgroundService(userId: userID, dataAccessHandler: dataAccessHandler);
    backgroundService.initializeService();
    checkLocationEnabled();
    startService();
    _getCurrentDateTime();
    _getCurrentLocation();
    /*  WidgetsBinding.instance.addPostFrameCallback((_) {
      showShiftPopup(context, _currentDateTime, _currentLocation);
    }); */

    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        _loademployeresponse();
        loademployeeimage();
        // loadAccessToken();
        // loadUserid();
        // getLoginTime();
        // getBloodlookupid();
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
    // Refresh the screen after data loading is complete
    /*  Future.delayed(Duration.zero, () {
      setState(() {
        isLoading = true; // Update loading state
      });
    }); */

    //  dateController.text = DateFormat('dd-MM-yyyy').format(selectedDatemark);
  }

  Future<void> loadCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserActivityRights();
    //   initializeBackgroundService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      WakelockPlus.enable();
    } else {
      // App is in the background
      WakelockPlus.disable();
    }
  }

  Future<void> loadPunchInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isPunchedIn = prefs.getBool(Constants.isPunchIn) ?? false;
      _time = prefs.getString(Constants.punchTime) ?? 'Invalid Time';
    });
    final now = DateTime.now();
    final int currentHour = now.hour;
    if (currentHour >= 9 && currentHour < 12) {
      if (!isPunchedIn) {
        setState(() {
          isRequestProcessing = true;
        });

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => punchInOutDialog(context),
        );
      }
    } else if (currentHour >= 18) {
      if (isPunchedIn) {
        setState(() {
          isRequestProcessing = true;
        });

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => punchInOutDialog(context),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return RefreshIndicator(
      onRefresh: () async {
        // Re-fetch data and refresh UI
        fetchpendingrecordscount();
        setState(() {});
      },
      child: WillPopScope(
        onWillPop: () async {
          exit(0);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFf2f2f2),
          body: Column(
            children: [
              header(),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 14.0, right: 14.0, top: 10, bottom: 10),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shiftTimingAndStatus(),
                            const SizedBox(height: 10),
                            checkInNOut(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      hrmsSection(),
                      const SizedBox(height: 10),
                      sgtSection(),
                      const SizedBox(height: 10),
                      bannersCarosuel(context),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              String to_day = DateFormat('dd/MM/yyyy').format(DateTime.now());
              setState(() {
                //  selectedOption = 'Today'; // Reset the dropdown to "Today"
                calenderDate = to_day; // Set calendar to today's date
                fetchdatewiseleads(today, today); // Fetch date-wise leads
                fetchpendingrecordscount(); // Fetch other counts
              });
            },
            child: const Icon(Icons.refresh), // Refresh icon
            tooltip: 'Refresh',
          ),
        ),
      ),
    );
  }

  Row hrmsSection() {
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'PL\'s',
          data: "$usedPrivilegeLeavesInYear/$allottedPrivilegeLeaves",
          icon: Icons.edit_calendar_outlined,
          themeColor: const Color(0xffDC2626),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Myleaveslist(leaveType: 'PL'),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'CL\'s',
          data: "$usedCasualLeavesInYear/$allotcausalleaves",
          icon: Icons.calendar_month,
          themeColor: const Color(0xff2563EB),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Myleaveslist(leaveType: 'CL'),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'Comp Off',
          data: '1/0',
          icon: Icons.calendar_today_rounded,
          themeColor: const Color(0xff9333EA),
          // themeColor: CommonStyles.blueColor,background: #9333EA;
        ),
      ],
    );
  }

  Row sgtSection() {
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'Travelled',
          data: totalDistance.toStringAsFixed(2) + ' KM',
          icon: Icons.mode_of_travel_outlined,
          themeColor: const Color(0xffFBBF24),
          // themeColor: Color(0xffFBBF24),
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'Today Visits',
          data: '$totalLeadsCount',
          icon: Icons.calendar_month,
          themeColor: const Color(0xff16A34A),
          // themeColor: CommonStyles.greenColor,background: #16A34A;background: #;
        ),
        const SizedBox(width: 12),
        customLeaveTypeBox(
          leaveType: 'Total Visits',
          data: '$totalLeadsCount',
          icon: Icons.calendar_today_rounded,
          themeColor: const Color(0xff4F46E5),
          // themeColor: CommonStyles.blueColor,background: #9333EA;
        ),
      ],
    );
  }

  Widget customLeaveTypeBox({
    required String leaveType,
    required String data,
    required Color themeColor,
    IconData? icon,
    void Function()? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.check_circle_outline,
                  color: themeColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                leaveType,
              ),
              const SizedBox(height: 2),
              Text(
                data,
                style: const TextStyle(
                    color: CommonStyles.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row checkInNOut() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPunchedIn ? "Punch In" : "Shift Timings",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                isPunchedIn
                    ? "at ${formatPunchTime(_time)}"
                    : "09:00 AM to 6:00 PM",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        isPunchedIn
            ? CustomBtn(
                icon: Icons.logout_outlined,
                btnText: 'Check Out',
                isLoading: isRequestProcessing,
                backgroundColor: CommonStyles.whiteColor,
                btnTextColor: CommonStyles.primaryColor,
                onTap: checkInOut,
                /* onTap: () async {
                  setState(() {
                    isRequestProcessing = true;
                  });

                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => punchInOutDialog(context),
                  );
                }, */
              )
            : CustomBtn(
                btnText: 'Check In',
                isLoading: isRequestProcessing,
                onTap: checkInOut,
              ),
        /* CustomBtn(
          btnText: isRequestProcessing
              ? "Checking..."
              : (isPunchedIn ? "Check Out" : "Check In"),
          isLoading: isRequestProcessing,
          icon: isPunchedIn ? Icons.logout_outlined : Icons.camera_alt_outlined,
          backgroundColor: isPunchedIn ? null : CommonStyles.whiteColor,
          btnTextColor: isPunchedIn ? null : CommonStyles.primaryColor,
          onTap: () async {
            setState(() {
              isRequestProcessing = true;
            });

            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => punchInOutDialog(context),
            );

            /* setState(() {
              isRequestProcessing = false;
            }); */
          },
        ), */ /* Column(
                            children: [
                              CustomBtn(
                                btnText: 'Check In',
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomBtn(
                                icon: Icons.logout_outlined,
                                btnText: 'Check Out',
                                backgroundColor: CommonStyles.whiteColor,
                                btnTextColor: CommonStyles.primaryColor,
                              ),
                            ],
                          ), */
      ],
    );
  }

  Future<void> checkInOut() async {
    setState(() {
      isRequestProcessing = true;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => punchInOutDialog(context),
    );
  }

  Row shiftTimingAndStatus() {
    return Row(
      children: [
        const Icon(
          Icons.calendar_month_outlined,
          color: CommonStyles.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 5),
        Text(
          _getFormattedDate(),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: CommonStyles.primaryColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Shift Morning',
            style: TextStyle(
              color: CommonStyles.primaryColor,
            ),
          ),
        )
      ],
    );
  }

  Container header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$EmployeName',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '$employee_designation',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          /*  const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ), */
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _items = [
    {
      'img':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
    },
    {
      'img':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
    },
    {
      'img':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
    },
  ];

  Widget bannersCarosuel(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 150,
      child: FlutterCarousel(
        options: FlutterCarouselOptions(
          floatingIndicator: true,
          height: 150,
          viewportFraction: 1.0,
          enlargeCenterPage: true,
          autoPlay: _items.length > 1,
          enableInfiniteScroll: _items.length > 1,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          slideIndicator: CircularSlideIndicator(
            slideIndicatorOptions: const SlideIndicatorOptions(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
              itemSpacing: 12,
              indicatorRadius: 4,
            ),
          ),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
        ),
        items: _items.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item['img'],
                    height: 200,
                    fit: BoxFit
                        .cover, // Use cover instead of fill for better aspect ratio handling
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> startService() async {
    // await Fluttertoast.showToast(
    //     msg: "Wait for a while, Initializing the service...");
    appendLog("Wait for a while, Initializing the service...");
    try {
      // Step 1: Request location permissions (foreground & background)
      final permission = await context
          .read<LocationControllerCubit>()
          .enableGPSWithPermission();
      appendLog('Foreground location permission: $permission.');
      print('Foreground location permission: $permission');

      // Step 2: Check if foreground location permission is granted
      if (permission) {
        // Check background permission
        LocationPermission backgroundPermission =
            await Geolocator.checkPermission();
        print('Initial background permission check: $backgroundPermission');
        appendLog('Initial background permission check: $backgroundPermission');

        // Request background permission if it's denied or deniedForever
        if (backgroundPermission == LocationPermission.denied ||
            backgroundPermission == LocationPermission.deniedForever) {
          backgroundPermission = await Geolocator.requestPermission();
          print('Requested background permission: $backgroundPermission');
          appendLog('Requested background permission: $backgroundPermission');
        }

        // If the background permission is not granted
        if (backgroundPermission != LocationPermission.always) {
          print('Background permission not granted.');
          appendLog('Background permission not granted.');
          // await Fluttertoast.showToast(
          //     msg: "Background location permission denied. Service could not start.");
          return;
        }
        if (!await BatteryOptimization.isIgnoringBatteryOptimizations()) {
          BatteryOptimization.openBatteryOptimizationSettings();
        }

        // Step 3: Fetch the current location
        Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        lastLatitude = currentPosition.latitude;
        lastLongitude = currentPosition.longitude;

        // Step 4: Initialize the background service and set it as foreground
        await context
            .read<LocationControllerCubit>()
            .locationFetchByDeviceGPS();
        await backgroundService.initializeService();
        backgroundService.setServiceAsForeground();

        // Debug prints to check the current position
        print('Location permission granted');
        print(
            'Current Position: Latitude: ${currentPosition.latitude}, Longitude: ${currentPosition.longitude}');

        // Show success toast
        //   await Fluttertoast.showToast(msg: "Service started successfully!");
        appendLog('Service started successfully!');
        // Debug logs for location
        appendLog(
            'Last known position: Latitude: $lastLatitude, Longitude: $lastLongitude');
      } else {
        // Handle the case where location permission is denied
        appendLog('Foreground location permission denied.');
        // await Fluttertoast.showToast(
        //     msg: "Location permission denied. Service could not start.");
      }
    } catch (e) {
      // Handle any exceptions and log the error
      print('Error starting service: $e');
      appendLog('Error starting service: $e');
      // await Fluttertoast.showToast(
      //     msg: "Error: Service could not start due to an error.");
    }
  }

  void stopService() {
    backgroundService.stopService();
    context.read<LocationControllerCubit>().stopLocationFetch();

    // Show Toast after service stops
    Fluttertoast.showToast(msg: "Service stopped successfully!");
    appendLog('Service stopped successfully!');
  }

  // Ensure you have intl package

  void appendLog(String text) async {
    const String folderName = 'SmartGeoTrack';
    const String fileName = 'UsertrackinglogTest.file';
    //  final appFolderPath = await getApplicationDocumentsDirectory();
    // Directory appFolderPath = Directory(
    //     '/storage/emulated/0/Download/$folderName');
    Directory appFolderPath =
        Directory('/storage/emulated/0/Download/SmartGeoTrack');
    if (!appFolderPath.existsSync()) {
      appFolderPath.createSync(recursive: true);
    }

    final logFile = File('${appFolderPath.path}/$fileName');
    if (!logFile.existsSync()) {
      logFile.createSync();
    }

    // Get the current date and time in a readable format
    String currentDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      final buf = logFile.openWrite(mode: FileMode.append);
      // Prepend the timestamp to the log message
      buf.writeln('$currentDateTime: $text');
      await buf.close();
    } catch (e) {
      print("Error appending to log file: $e");
    }
  }

  Future<void> getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString(SharedKeys.userId) ?? "";
    //   userID = prefs.getInt('userID');
    RoleId = prefs.getInt('roleID');
    username = prefs.getString('username') ?? '';

    String firstName = prefs.getString('firstName') ?? '';
    String email = prefs.getString('email') ?? '';
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    String roleName = prefs.getString('roleName') ?? '';
    DateTime now = DateTime.now();
    formattedDate = formatDate(now);
    //  calenderDate = formattedDate;
    futureLeads = loadleads();
    print(' formattedDate==$formattedDate'); // Example output: "25th Sep 2024"
  }

  String formatDate(DateTime date) {
    String day = DateFormat('d').format(date);
    String suffix = getDaySuffix(int.parse(day));
    String formattedDate =
        '$day$suffix ${DateFormat('MMM').format(date)} ${DateFormat('y').format(date)}';
    return formattedDate;
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> checkLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      isLocationEnabled = serviceEnabled;
    });
    if (!serviceEnabled) {
      // If location services are disabled, prompt the user to enable them
      await _promptUserToEnableLocation();
    }
  }

  Future<void> _promptUserToEnableLocation() async {
    bool locationEnabled = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Services Disabled"),
          content:
              const Text("Please enable location services to use this app."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );

    if (locationEnabled) {
      // Redirect the user to the device settings to enable location services
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> fetchLeadCounts() async {
    setState(() {
      isLoading = true; // Start loading
    });

    String currentDate =
        getCurrentDate(); // Assuming this returns a string in 'YYYY-MM-DD' format
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //   userID = prefs.getInt('userID'); //TODO
    RoleId = prefs.getInt('roleID');

    // Fetch total lead counts based on CreatedByUserId
    totalLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS totalLeadsCount FROM Leads WHERE CreatedByUserId = '$userID'");

    // Fetch today's lead counts for the current date and userID
    todayLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS todayLeadsCount FROM Leads WHERE DATE(CreatedDate) = '$currentDate' AND CreatedByUserId = '$userID'");

    // Fetch lead counts within a date range for userID (you can modify the date range logic as needed)
    dateRangeLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS dateRangeLeadsCount FROM Leads WHERE DATE(CreatedDate) BETWEEN '$currentDate' AND '$currentDate' AND CreatedByUserId = '$userID'");

    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295; // Pi/180 to convert degrees to radians
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a)); // Radius of Earth * arc
    }

    // Replace this list with dynamically fetched data
    // Fetch latitude and longitude data for the given date range
    List<Map<String, double>> data = await dataAccessHandler
        .fetchLatLongsFromDatabase(currentDate, currentDate);

    print('Data: $data km');

    for (var i = 0; i < data.length - 1; i++) {
      totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
          data[i + 1]["lat"], data[i + 1]["lng"]);
    }
    print('Total Distance: $totalDistance km');

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  Future<List<LeadsModel>> TodayloadLeads(String today) async {
    try {
      // final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads = await dataAccessHandler.getTodayLeads(today);
      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<List<LeadsModel>> loadleads() async {
    String currentDate = getCurrentDate();
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads =
          await dataAccessHandler.getTodayLeadsuser(currentDate, userID);
      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<void> fetchdatewiseleads(String startday, String today) async {
    setState(() {
      isLoading = true; // Start loading
    });
    dateRangeLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS dateRangeLeadsCount FROM Leads WHERE DATE(CreatedDate) BETWEEN '$startday' AND '$today'");
    print('dateRangeLeadsCount==1240 :  $dateRangeLeadsCount');
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295; // Pi/180 to convert degrees to radians
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a)); // Radius of Earth * arc
    }

    // Replace this list with dynamically fetched data
    // Fetch latitude and longitude data for the given date range
    List<Map<String, double>> data =
        await dataAccessHandler.fetchLatLongsFromDatabase(startday, today);

    print('Data: $data km');
    totalDistance = 0.0;

    for (var i = 0; i < data.length - 1; i++) {
      totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
          data[i + 1]["lat"], data[i + 1]["lng"]);
    }
    print('Total Distance: $totalDistance km');
    setState(() {
      isLoading = false; // Stop loading
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
    pendingweekoffcount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        'SELECT Count(*) AS pendingweekoffcount FROM UserWeekOffXref WHERE ServerUpdatedStatus = 0');
    print('pendingleadscount: $pendingleadscount ');
    print('pendingfilerepocount: $pendingfilerepocount');
    print('pendingboundarycount: $pendingboundarycount ');

    // Enable button if any of the counts are greater than 0
    // isButtonEnabled = pendingleadscount! > 0 ||
    //     pendingfilerepocount! > 0 ||
    //     pendingboundarycount! > 0 ||
    //     pendingweekoffcount! > 0;

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Downloading data..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideProgressDialog(BuildContext context) {
    Navigator.pop(context); // Close the dialog
  }

  String getCurrentDateInDDMMYY() {
    final DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = (now.year % 100).toString().padLeft(2, '0');
    return '$day$month$year';
  }

  Future<List<int>> _loadUserActivityRights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedList = prefs.getStringList('userActivityRights');
    userActivityRights = storedList?.map(int.parse).toList() ?? [];
    print('===> storedList: $storedList');

    return storedList?.map(int.parse).toList() ?? [];
  }

  void showShiftPopup(BuildContext context, String dateTime, String location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "NEXT SHIFT",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              const Text(
                "9am-5pm",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.blue),
                  const SizedBox(width: 5),
                  Expanded(
                      child: Text(dateTime, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.blue),
                  const SizedBox(width: 5),
                  Expanded(
                      child: Text(location, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.blue),
                  SizedBox(width: 5),
                  Text("Client Care"),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Punch in"),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text("Punch out"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Unscheduled punch",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _getCurrentDateTime() {
    final now = DateTime.now();
    _currentDateTime = DateFormat('EEEE, MMM d, yyyy – hh:mm a').format(now);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      // Check for location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks.first;
      String currentTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _currentLocation = "${position.latitude}, ${position.longitude}";
        _currentPosition = position;
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _address =
            "${place.thoroughfare} ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        _time = currentTime;
      });

      // Move the map camera to the user's location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _currentLocation = "Location unavailable";
      });
      rethrow;
    }
  }

  Future<void> _captureAndProcessImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image captured!")),
        );
        throw Exception("No image captured!");
      }

      // await _getCurrentLocation();

      final File imageFile = File(pickedFile.path);
      final ui.Image capturedImage =
          await decodeImageFromList(await imageFile.readAsBytes());

      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      canvas.drawImage(capturedImage, Offset.zero, Paint());

      double textStyleHeight = capturedImage.height * 0.09;
      TextStyle textStyle = TextStyle(
        color: Colors.white,
        fontSize: textStyleHeight * 0.16,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
        ],
      );

      String textContent =
          "Time: $_time\nLocation: $_latitude, $_longitude\n$_address";

      TextPainter textPainter = TextPainter(
        text: TextSpan(text: textContent, style: textStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
      );

      textPainter.layout(maxWidth: capturedImage.width.toDouble() - 20);

      double textBoxHeight = textPainter.height + 20;

      Paint rectPaint = Paint()..color = Colors.black.withOpacity(0.7);
      canvas.drawRect(
        Rect.fromLTWH(0, capturedImage.height - textBoxHeight,
            capturedImage.width.toDouble(), textBoxHeight),
        rectPaint,
      );

      textPainter.paint(
          canvas, Offset(20, capturedImage.height - textBoxHeight + 10));

      ui.Image finalImage = await recorder
          .endRecording()
          .toImage(capturedImage.width, capturedImage.height);
      ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      // Save the processed image
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/hrms_emp.png';
      File file = File(filePath);
      await file.writeAsBytes(pngBytes);
      // Insert into DailyPunchInAndOut table
      await _insertPunchData(
        DateTime.now().toIso8601String(),
        _latitude,
        _longitude,
        _address,
        isPunchedIn,
        filePath,
      );

      await updatePunchStatus(isPunchedIn ? false : true);

      /* if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved successfully at: $filePath")),
      ); */
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget punchInOutDialog(BuildContext context) {
    String currentTime = DateFormat('HH:mm').format(DateTime.now());

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
                setState(() {
                  isRequestProcessing = false;
                });
              },
            ),
          ),
          Container(
            height: 350, // Adjust height to match the design
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPunchedIn ? "Check Out" : "Check In",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Map view
                Expanded(
                  child: FutureBuilder<Position>(
                    future: _getInitialPosition(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                snapshot.data!.latitude,
                                snapshot.data!.longitude,
                              ),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('current_location'),
                                position: LatLng(
                                  snapshot.data!.latitude,
                                  snapshot.data!.longitude,
                                ),
                              ),
                            },
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                              // Fetch the current location in the background
                              _updateCurrentLocationOnMap();
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  // findChildWidget(),

                  /* _currentPosition == null
                      ? const Center(child: CircularProgressIndicator())
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('current_location'),
                                position: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                              ),
                            },
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        ), */
                ),
                const SizedBox(height: 10),
                // Sample text
                Text(
                  isPunchedIn
                      ? 'Time to go home!'
                      : "It's time for another great day!",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                // Current time with pencil icon
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _captureAndProcessImage();

                      /* await _captureAndProcessImage().whenComplete(() {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }); */
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CommonStyles.primaryColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Capture Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> _getInitialPosition() async {
    // Try to get the last known position for instant display
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();

    if (lastKnownPosition != null) {
      return lastKnownPosition;
    }

    // If no last known position is available, fetch the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _updateCurrentLocationOnMap() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(currentPosition.latitude, currentPosition.longitude),
          ),
        );

        setState(() {
          // Update the marker with the current location
          _currentPosition = currentPosition;
        });
      }
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  Widget headerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $EmployeName! 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              _buildProfileImage(),
              /*  CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: _buildProfileImage(),
                ),
              ), */
            ],
          ),
        ],
      ),
    );
  }

  Image backgroundGredient(BuildContext context) {
    return Image.asset(
      'assets/background_layer_2.png',
      fit: BoxFit.cover,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
  }

  showBottomSheetForImageSelection(BuildContext context) {}

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

  void _loademployeresponse() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final dateofbirth = loadedData['originalDOB'];
      final emailid = loadedData['emailId'];
      final officemailid = loadedData['officeEmailId'];
      final expincompany = loadedData['experienceInCompany'];
      final mobilenum = loadedData['mobileNumber'];
      final bloodgroup = loadedData['bloodGroup'];
      final gender = loadedData["gender"];
      final dateofjoining = loadedData['dateofJoin'];
      final code = loadedData['code'];
      final designation = loadedData['designation'];
      final reportingTo = loadedData['reportingTo'];
      final nationality = loadedData['nationality'];

      //   "gender"
      // : "Male"
      print('employeeName: $employeeName');
      print('dob: $dateofbirth');
      print('emailid: $emailid');
      print('officemail: $officemailid');
      print('expincompany: $expincompany');
      print('mobilenum: $mobilenum');
      print('bloodgroup: $bloodgroup');

      // Format the date of birth into "dd/MM/yyyy"
      DateTime dobDate = DateTime.parse(dateofbirth);
      String formattedDOB = DateFormat('dd MMM yyyy').format(dobDate);
      print('formattedDOB: $formattedDOB');

      setState(() {
        if (employeeName != null) {
          EmployeName = employeeName;
        } else {
          EmployeName = '';
        }
        // EmployeName = employeeName;

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
      });
    }
  }

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
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("empolyeidinapplyleave:$empolyeid");
    final url = Uri.parse(baseUrl + GetEmployeePhoto + '$empolyeid');
    print('loademployeeimage  $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
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

  /// Returns the current date in "Thursday, June 8th 2023" format
  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d yyyy').format(DateTime.now());
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      /*  return Image.file(
        _imageFile!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ); */
      /* return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        ),
      ); */
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: CommonStyles.primaryColor),
        ),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: Image.file(
            _imageFile!,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (photoData != null && photoData!.isNotEmpty) {
      return FutureBuilder<Uint8List>(
        future: _decodeBase64(photoData!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Center(child: CircularProgressIndicator.adaptive());
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CommonStyles.primaryColor),
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child:
                    const Center(child: CircularProgressIndicator.adaptive()),
              ),
            );
          } else if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CommonStyles.primaryColor),
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CommonStyles.primaryColor),
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    snapshot.data != null ? MemoryImage(snapshot.data!) : null,
                child: snapshot.data == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
            );
          }
        },
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: CommonStyles.primaryColor),
        ),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
      );
    }
  }

  /*  Widget _buildProfileImage() {
    if (_imageFile != null) {
      /*  return Image.file(
        _imageFile!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ); */
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        child: Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        ),
      );
    } else if (photoData != null && photoData!.isNotEmpty) {
      return FutureBuilder<Uint8List>(
        future: _decodeBase64(photoData!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return _getDefaultImage(Gender, context);
          } else {
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: CommonStyles.primaryColor), // Blue Border
              ),
              child: CircleAvatar(
                radius: 25, // Adjust size
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    snapshot.data != null ? MemoryImage(snapshot.data!) : null,
                child: snapshot.data == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            );
            /*  return Image.memory(
              snapshot.data!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ); */
          }
        },
      );
    } else {
      return _getDefaultImage(Gender, context);
    }
  }
 */

  Widget _getDefaultImage(String gender, BuildContext context) {
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

  String formatPunchTime(String? dateTimeString) {
    try {
      print('xxx5: $dateTimeString');
      if (dateTimeString == null) return "Invalid Date";
      DateTime dateTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTimeString);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Future<void> updatePunchStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.isPunchIn, status);
    await prefs.setString(Constants.punchTime, _time);
    setState(() {
      isPunchedIn = status;
      isRequestProcessing = false;
    });
  }

  Future<bool> _insertPunchData(
      String punchTime,
      String latitude,
      String longitude,
      String address,
      bool isPunchedIn,
      String? filePath) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      final db = await dbHelper.database;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString(SharedKeys.userId) ?? "";
      // Ensure UserId is set correctly
      // String userId =
      //     "e939b672-84ed-45ed-ba3a-b7a372403ad3"; // Replace with actual User ID

      if (userId.isEmpty) {
        print("❌ Error: User ID is missing!");
        return false;
      }

      int punchResult = 0;

      if (!isPunchedIn) {
        // **Punch In: Insert new record in DailyPunchInAndOut**
        Map<String, dynamic> punchInData = {
          'UserId': userId,
          'PunchInTime': punchTime,
          'PunchInLatitude': latitude,
          'PunchInLongitude': longitude,
          'PunchInAddress': address,
          'CreatedByUserId': userId,
          'CreatedDate': punchTime,
          'UpdatedByUserId': userId,
          'UpdatedDate': punchTime,
          'ServerUpdatedStatus': false, // Unsynced data
        };

        punchResult = await db.insert('DailyPunchInAndOut', punchInData);
        print("✅ Punch In inserted successfully: $punchResult");
      } else {
        // **Punch Out: Update last Punch In record**
        punchResult = await db.rawUpdate(
          '''
        UPDATE DailyPunchInAndOut
        SET PunchOutTime = ?, PunchOutLatitude = ?, PunchOutLongitude = ?, PunchOutAddress = ?, 
            UpdatedByUserId = ?, UpdatedDate = ?, ServerUpdatedStatus = ?
        WHERE UserId = ? AND PunchOutTime IS NULL
        ''',
          [
            punchTime,
            latitude,
            longitude,
            address,
            userId,
            punchTime,
            false,
            userId
          ],
        );

        print(punchResult > 0
            ? "✅ Punch Out updated successfully!"
            : "⚠️ No matching Punch In found!");
      }

      if (punchResult > 0) {
        // **Check if File Already Exists Before Inserting**
        if (filePath != null && filePath.isNotEmpty) {
          String fileName = filePath.split('/').last;

          // **Prevent duplicate inserts**
          List<Map<String, dynamic>> existingFiles = await db.rawQuery(
              "SELECT * FROM FileRepository WHERE FileName = ? AND LookupType = ? AND ServerUpdatedStatus = 0",
              [fileName, isPunchedIn ? 24 : 23]);

          if (existingFiles.isEmpty) {
            Map<String, dynamic> fileData = {
              'leadsCode': null,
              'FileName': fileName,
              'FileLocation': filePath,
              'FileExtension': '.png',
              'IsActive': 1,
              'CreatedByUserId': userId,
              'CreatedDate': punchTime,
              'UpdatedByUserId': userId,
              'UpdatedDate': punchTime,
              'ServerUpdatedStatus': 0, // Ensure it's marked for sync
              'LookupType':
                  isPunchedIn ? 376 : 377, // 23 for Punch In, 24 for Punch Out
            };

            // **Insert Image (Only One at a Time)**
            int fileResult = await db.insert('fileRepository', fileData);
            print("✅ File stored in FileRepository: $fileResult");
          } else {
            print("⚠️ Duplicate image detected, skipping insert: $fileName");
          }
        }

        // **Check internet connection before syncing**
        bool isConnected = await CommonStyles.checkInternetConnectivity();
        if (isConnected) {
          final syncService = SyncService(dataAccessHandler);

          // **Sync FileRepositorys**
          int? unsyncedFileCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
              "SELECT COUNT(*) FROM fileRepository WHERE ServerUpdatedStatus = 0")!;

          if (unsyncedFileCount! > 0) {
            await syncService.performRefreshTransactionsSync(context, 8);

            print("✅ Data synced successfully to the server.");
          } else {
            print("⚠️ No unsynced files found for syncing.");
          }
        } else {
          print("⚠️ No internet connection. Data will sync later.");
        }

        return true;
      }

      return false;
    } catch (e) {
      print("❌ _insertPunchData: Error -> $e");
      return false;
    }
  }

  Future<void> startTransactionSync(BuildContext context) async {
    final syncService = SyncService(dataAccessHandler);

    // **Sync FileRepositorys**
    int? unsyncedFileCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) FROM FileRepositorys WHERE ServerUpdatedStatus = 0")!;

    if (unsyncedFileCount! > 0) {
      await syncService.performRefreshTransactionsSync(context, 8);
    }
  }

  void _loademployeleaves() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final emplyeid = loadedData["employeeId"];
      final usedprivilegeleavesinyear = loadedData['usedPrivilegeLeavesInYear'];
      final allotedprivilegeleaves = loadedData['allottedPrivilegeLeaves'];
      final usedcausalleavesinmonth = loadedData['usedCasualLeavesInMonth'];
      final usedPrivilegeLeavesInMonth =
          loadedData['usedPrivilegeLeavesInMonth'];
      final usedcasualleavesinyear = loadedData['usedCasualLeavesInYear'];
      final usdl = loadedData['allottedCasualLeaves'];
      // final mobilenum = loadedData['mobileNumber'];
      // final bloodgroup = loadedData['bloodGroup'];
      print('allottedCasualLeaves: $usdl');

      print('usedprivilegeleavesinyear: $usedprivilegeleavesinyear');
      print('allotedprivilegeleaves: $allotedprivilegeleaves');
      print('usedcausalleavesinmonth: $usedcausalleavesinmonth');
      //  print('allotedpls: $allotedpls');
      print('usedcasualleavesinyear: $usedcasualleavesinyear');
      // print('mobilenum: $mobilenum');
      // print('bloodgroup: $bloodgroup');

      setState(() {
        employeid = emplyeid;
        print('employeid: $employeid');
        allotcausalleaves = usdl.toDouble();
        EmployeName = employeeName;
        usedPrivilegeLeavesInYear = usedprivilegeleavesinyear.toDouble();
        allottedPrivilegeLeaves = allotedprivilegeleaves.toDouble();
        usedCasualLeavesInMonth = usedcausalleavesinmonth.toDouble();
        usedCasualLeavesInYear = usedcasualleavesinyear.toDouble();
        // allottedPriviegeLeaves = allotedpls;
        //  usedCasualLeavesInYear = usedcasualleavesinyear;
        availablepls = allottedPrivilegeLeaves.toDouble() -
            usedPrivilegeLeavesInYear.toDouble();

        print("Available Privilege Leaves: $availablepls");

        availablecls =
            allotcausalleaves.toDouble() - usedCasualLeavesInYear.toDouble();

        //  print('availablecls: $availablecls');
      });
    }
    // availablepls = allottedPrivilegeLeaves - usedPrivilegeLeavesInYear;
    // availablecls = allotcausalleaves - usedCasualLeavesInYear;
  }

  Widget findChildWidget() {
    if (_currentPosition != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
            ),
          },
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
// Future<void> _loadUserActivityRights() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   setState(() {
//     List<String>? storedList = prefs.getStringList('userActivityRights');
//     userActivityRights = storedList?.map(int.parse).toList() ?? [];
//   });
//   initializeMenuItems();
//   // Print in console
//   print("User Activity Rights: $userActivityRights");
// }
//   Future<void> _loadUserActivityRights() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     RoleId = prefs.getInt('roleID');
//     userActivityRights= await dataAccessHandler.getSingleListData('''
//   SELECT ar.Name
//   FROM RoleActivityRightXrefs rarx
//   INNER JOIN ActivityRights ar ON ar.Id = rarx.ActivityRightId
//   WHERE rarx.RoleId = ${RoleId}
//   ORDER BY rarx.ActivityRightId
// ''');
//
//     print("User Activity Rights: $userActivityRights");
//
//   }

class DataCountModel {
  final int count;
  final String tableName;
  final String methodName;

  DataCountModel({
    required this.count,
    required this.tableName,
    required this.methodName,
  });

  factory DataCountModel.fromJson(Map<String, dynamic> json) {
    return DataCountModel(
      count: json['count'],
      tableName: json['tableName'],
      methodName: json['methodName'],
    );
  }
}

class BackgroundService {
  String? userId;
  final DataAccessHandler dataAccessHandler; // Declare DataAccessHandler
  late SyncServiceB syncService; // Declare SyncService
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();

  static const double MAX_ACCURACY_THRESHOLD = 10.0;
  static const double MIN_DISTANCE_THRESHOLD = 50.0;
  Timer? locationTimer;
  BackgroundService({required this.userId, required this.dataAccessHandler}) {
    syncService = SyncServiceB(dataAccessHandler);

    // Initialize SyncService
  }

  FlutterBackgroundService get instance => flutterBackgroundService;

  Future<void> initializeService() async {
    print('Initializing service...');
    appendLog('Initializing service...');

    await NotificationService(FlutterLocalNotificationsPlugin()).createChannel(
      const AndroidNotificationChannel(
        'location_channel',
        'Location Channel',
        importance: Importance.high,
      ),
    );

    await flutterBackgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'location_channel',
        foregroundServiceNotificationId: 888,
        // initialNotificationTitle: 'Location Service',
        // initialNotificationContent: 'Tracking location in background',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
      ),
    );

    await flutterBackgroundService.startService();
    print('Service initialized and started.');
    appendLog('Service initialized and started.');
  }

  void setServiceAsForeground() async {
    print('Setting service as foreground...');
    appendLog('Setting service as foreground...');
    flutterBackgroundService.invoke("setAsForeground");
  }

  void stopService() {
    print('Stopping service...');
    appendLog('Stopping service...');
    flutterBackgroundService.invoke("stop_service");
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  appendLog('Service started...');
  Timer? locationTimer;
  // Initialize Dart environment and acquire wake lock
  appendLog('Initializing DartPluginRegistrant and acquiring wake lock...');
  DartPluginRegistrant.ensureInitialized();
  acquireWakeLock();
  appendLog('Wake lock acquired.');
  double lastLatitude = 0.0;
  double lastLongitude = 0.0;
  bool isFirstLocationLogged = false;

  try {
    // Initialize your database and shared preferences
    appendLog('Getting instance of Palm3FoilDatabase...');
    HRMSDatabaseHelper? hrmsDatabase = await HRMSDatabaseHelper();
    appendLog('Palm3FoilDatabase instance obtained.');

    appendLog('Fetching SharedPreferences...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //  int? userID = prefs.getInt('userID');
    String? userID = prefs.getString(SharedKeys.userId) ?? "";
//    int? userID = 101;
    appendLog('SharedPreferences fetched, userID: $userID.');

    final dataAccessHandler = DataAccessHandler();
    final SyncServiceB syncService = SyncServiceB(dataAccessHandler);
    appendLog('DataAccessHandler and SyncService initialized.');

    // Check and request location permissions
    appendLog('Checking location permissions...');
    LocationPermission permission = await Geolocator.checkPermission();
    appendLog('Location permission status: $permission.');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      appendLog('Permission denied. Requesting permission...');
      permission = await Geolocator.requestPermission();
      appendLog('Permission requested. New status: $permission.');

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        appendLog('Permission still denied. Showing notification.');
        _showNotification(
            "Permission Denied", "Location permission not granted.");
        return; // Exit if permission is not granted
      }
    }

    appendLog(
        'Location permission granted. Starting Geolocator stream for location updates.');

    // Start Geolocator stream for location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((Position position) async {
      appendLog(
          'Received new position: Lat ${position.latitude}, Lon ${position.longitude}.');

      if (permission == LocationPermission.always) {
        DateTime now = DateTime.now();

        // Fetch shift timings and weekoffs from the database
        final shiftFromTime =
            await dataAccessHandler.getShiftFromTime(); // Example user ID 13
        final shiftToTime =
            await dataAccessHandler.getShiftToTime(); // Example user ID 13
        //  final weekoffs = await dataAccessHandler.getweekoffs();            // List of week-off days (e.g., [DateTime.monday, DateTime.friday])

        // Parse the shift times into DateTime objects for comparison
        DateTime shiftStart = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(shiftFromTime.split(":")[0]),
            int.parse(shiftFromTime.split(":")[1]));
        DateTime shiftEnd = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(shiftToTime.split(":")[0]),
            int.parse(shiftToTime.split(":")[1]));
        print('shiftStart==========>${shiftStart}');
        print('shiftEnd==========>${shiftEnd}');
        // Check if the current time is within the shift hours
        bool isWithinTrackingHours =
            now.isAfter(shiftStart) && now.isBefore(shiftEnd);
        //  bool isWeekend = now.weekday == DateTime.sunday;
        final String weekoffsString = await dataAccessHandler.getweekoffs();
        // Map weekday names to their corresponding integer values (1 = Monday, ..., 7 = Sunday)
        final Map<String, int> dayToIntMap = {
          'Monday': 1,
          'Tuesday': 2,
          'Wednesday': 3,
          'Thursday': 4,
          'Friday': 5,
          'Saturday': 6,
          'Sunday': 7
        };

        // Convert the weekoffs string to a list of integers
        final List<int> weekoffs = weekoffsString
            .split(',')
            .map((day) => day.trim())
            .where((day) => day.isNotEmpty)
            .map((day) => dayToIntMap[day]) // Map day names to integers
            .where((day) =>
                day != null && day >= 1 && day <= 7) // Only valid weekdays
            .cast<int>()
            .toList();
        print('weekoffs==========>${weekoffs}');
        bool isWeekOff = weekoffs.contains(now.weekday);
        print("track condition for isWeekOff: $weekoffs");
        print("Today==========> ${now.weekday}");
        // Check if the current date is a holiday (excluded date)
        bool isExcludedDate = await dataAccessHandler.checkIfExcludedDate();

        appendLog("track condition for data insert: $isExcludedDate");
        print("track condition for data insert: $isExcludedDate");

        appendLog(
            "track condition for data insert: $isWithinTrackingHours   ====== $weekoffsString");
        print(
            "track condition for data insert: $isWithinTrackingHours   ====== $weekoffsString");

        // Check if tracking is allowed
        // if (isWithinTrackingHours && !isExcludedDate && !isWeekOff) {
        //   //   if ( !isExcludedDate ) {
        //   service.invoke('on_location_changed', position.toJson());
        //
        bool hasPointToday = await dataAccessHandler.hasPointForToday();
        //   bool hasleaveToday = await dataAccessHandler.hasleaveForToday();
        //
        //   print(
        //       "track condition hasleaveToday: $hasleaveToday  hasPointToday ======> $hasPointToday");
        //
        //   if (!hasleaveToday) {
        if (!hasPointToday) {
          if (_isPositionAccurate(position)) {
            if (!isFirstLocationLogged) {
              lastLatitude = position.latitude;
              lastLongitude = position.longitude;
              isFirstLocationLogged = true;

              // Insert the first location
              await insertLocationToDatabase(
                  hrmsDatabase, position, userID, syncService);
            }
          }
        }

        if (_isPositionAccurate(position)) {
          final distance = Geolocator.distanceBetween(
            lastLatitude,
            lastLongitude,
            position.latitude,
            position.longitude,
          );

          if (distance >= 20.0) {
            lastLatitude = position.latitude;
            lastLongitude = position.longitude;

            // Insert location points when the distance exceeds the threshold
            await insertLocationToDatabase(
                hrmsDatabase, position, userID, syncService);
          } else {
            appendLog("Skipping insert: Distance too short (${distance}m)");
          }
        } else {
          appendLog("Skipping insert: Position inaccurate or speed is 0");
        }
      } else {
        appendLog("Tracking not allowed: User has leave today");
        print("Tracking not allowed: User has leave today");
      }
      //   }
      // else {
      //     appendLog(
      //         'Tracking not allowed: isWithinTrackingHours: $isWithinTrackingHours, isWeekend: $weekoffsString, isWeekOff: $isWeekOff');
      //     print(
      //         'Tracking not allowed: isWithinTrackingHours: $isWithinTrackingHours, isWeekend: $weekoffsString, isWeekOff: $isWeekOff');
      //   }
      //  }
    }, onError: (e) {
      appendLog('Error in Geolocator stream: $e');
    });
    // Handle the "stop_service" event to properly stop the service
    appendLog('Listening for stop_service event...');
    if (service is AndroidServiceInstance) {
      service.on("stop_service").listen((event) async {
        appendLog('stop_service event received. Stopping the service...');
        releaseWakeLock();
        await service.stopSelf();
        _showNotification(
            "Service Stopped", "Background service has been stopped.");
        appendLog('Service stopped.');
      });

      service.on('start').listen((event) async {
        Timer.periodic(const Duration(minutes: 1), (timer) async {
          bool isConnected = await CommonStyles.checkInternetConnectivity();
          if (isConnected) {
            appendLog("Network is  available.1343");
            // Perform sync operation
            await syncService.performRefreshTransactionsSync();
          }
          appendLog("Network is not available. Sync will retry later.1347");
        });
      });
    }

    // Set foreground notification info
    if (service is AndroidServiceInstance) {
      appendLog('Setting foreground notification...');
      service.setForegroundNotificationInfo(
        title: "Location Service",
        content: "Tracking your location in the background.",
      );
      appendLog('Foreground notification set.');
    }
  } catch (e) {
    appendLog('Error during onStart initialization: $e');
  }

  appendLog('Service initialization complete.');
}

Future<void> _showNotification(String title, String content) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('location_channel', 'Location Channel',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    content,
    platformChannelSpecifics,
  );
}

// void _showNotification(String title, String content) {
//   // Implement a notification here to show alerts when issues arise
//   print('Notification: $title - $content');
//   appendLog('Notification: $title - $content');
// }

void acquireWakeLock() {
  WakelockPlus.enable();
}

// To release the wake lock (allow the device to sleep):
void releaseWakeLock() {
  WakelockPlus.disable();
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  return formattedDate;
}

Future<void> insertLocationToDatabase(HRMSDatabaseHelper? database,
    Position position, String? userID, SyncServiceB syncService) async {
  if (database == null) {
    appendLog("Error: Database instance is null.");
    return;
  }

  print('Inserting location into database...');
  // appendLog('Inserting location into database...');

  bool locationExists = await checkIfLocationExists(
      database, position.latitude, position.longitude);
  //
  if (!locationExists) {
    try {
      // Insert the location data into the database
      await database.insertLocationValues(
        latitude: position.latitude,
        longitude: position.longitude,
        createdByUserId: userID!,
        serverUpdatedStatus:
            false, // Initially false, will be updated after successful sync
        from: '997', // Replace with appropriate source if needed
      );

      appendLog(
          'Location inserted: Latitude: ${position.latitude}, Longitude: ${position.longitude}.');

      // Check if the network is available and then sync data
      bool isConnected = await CommonStyles.checkInternetConnectivity();
      if (isConnected) {
        appendLog("Network is  available. Sync");
        try {
          // Perform the sync operation
          await syncService.performRefreshTransactionsSync();
          //   print("Location data synced successfully.");
          //  appendLog("Location data synced successfully.");
        } catch (e, stackTrace) {
          print("Error syncing location data: $e");
          appendLog("Error syncing location data: $e");
          print("Error syncing location data stackTrace: $stackTrace");
          appendLog("Error syncing location data stackTrace: $stackTrace");
        }
      } else {
        // Schedule a background task to retry sync when network is available
        Workmanager().registerOneOffTask(
          "sync-task", // Unique task name
          "syncLocationData", // The function defined in WorkManager
          initialDelay: const Duration(minutes: 10), // Retry after 10 minutes
          constraints: Constraints(
              networkType:
                  NetworkType.connected), // Only run if network is available
        );

        Fluttertoast.showToast(
          msg: "No network. Sync will retry later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print("Network is not available. Sync will retry later.");
        appendLog("Network is not available. Sync will retry later.");
      }
    } catch (e) {
      appendLog('Error inserting location: $e');
      print("Error inserting location into database: $e");
    }
  } else {
    print("Location already exists in the database.");
    appendLog("Location already exists in the database.");
  }
}

Future<bool> checkNetworkAvailability() async {
  // Add your logic here to check for network availability
  // Example: Use Connectivity package or similar
  return true; // Assume network is available for this example
}

Future<bool> checkIfLocationExists(
    HRMSDatabaseHelper? database, double latitude, double longitude) async {
  final queryResult = await database!.getLocationByLatLong(latitude, longitude);
  return queryResult.isNotEmpty;
}

const double POSITION_ACCURACY_THRESHOLD =
    20.0; // Threshold for position accuracy
const double SPEED_ACCURACY_THRESHOLD = 10.0; // Threshold for speed accuracy
const double MINIMUM_MOVEMENT_SPEED = 1.0; // Minimum speed to consider movement

// Function to check if the position is accurate
bool _isPositionAccurate(Position position) {
  print('Position Accuracy: ${position.accuracy}');
  print('Speed Accuracy: ${position.speedAccuracy}');
  print('Speed: ${position.speed}');

  if (position.accuracy > POSITION_ACCURACY_THRESHOLD) {
    appendLog('Position accuracy too low: ${position.accuracy}');
  }

  if (position.speed < MINIMUM_MOVEMENT_SPEED) {
    appendLog('Speed too low: ${position.speed}');
  }

  // Return true only if accuracy and movement speed conditions are met
  return position.accuracy <= POSITION_ACCURACY_THRESHOLD &&
      position.speed >= MINIMUM_MOVEMENT_SPEED;
}

void appendLog(String text) async {
  const String fileName = 'hrmstracking.file';
  // final appFolderPath = await getApplicationDocumentsDirectory();
  Directory appFolderPath = Directory('/storage/emulated/0/Download/HRMS');
  if (!appFolderPath.existsSync()) {
    appFolderPath.createSync(recursive: true);
  }

  final logFile = File('${appFolderPath.path}/$fileName');
  if (!logFile.existsSync()) {
    logFile.createSync();
  }

  // Get the current date and time
  String currentDateTime = DateTime.now().toString();

  try {
    final buf = logFile.openWrite(mode: FileMode.append);
    // Prepend the timestamp to the log message
    buf.writeln('$currentDateTime: $text');
    await buf.close();
  } catch (e) {
    print("Error appending to log file: $e");
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.pink[50],
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
