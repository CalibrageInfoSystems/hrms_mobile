import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/Database/HRMSDatabaseHelper.dart';
import 'package:hrms/Model%20Class/birthday_banner_model.dart';
import 'package:hrms/Myleaveslist.dart';
import 'package:hrms/login_screen.dart';

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
import 'package:skeletonizer/skeletonizer.dart';

import 'package:workmanager/workmanager.dart';

import '../../Commonutils.dart';
import '../../Database/SyncService.dart';
import '../../Database/SyncServiceB.dart';

import '../../Model Class/LeadsModel.dart';
import '../../SharedPreferencesHelper.dart';
import '../../api config.dart';
import '../../common_widgets/PermissionManager.dart';
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
  String _latitude = "";
  String _longitude = "";
  String _address = "";
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
  String employee_designation = '';
  String empolyeid = '';
  String accessToken = '';
  String APIKey = '';
  bool? isPunchIn = false;
  int employeid = 0;
  double allottedPriviegeLeaves = 0.0;
  String? PunchinTime;
  double usedCasualLeavesInYear = 0.0;
  double allotcausalleaves = 0.0;
  double availablepls = 0.0;
  double availablecls = 0.0;
  double usedCasualLeavesInMonth = 0.0;
  late Future<void> futureCheckInOutStatus;
  bool ismatchedlogin = false;
  bool? showAddClient; // Toggle visibility for Add Client
  late Future<List<BirthdayBanner>> futureBirthdayBanners;

  late Future<Map<String, dynamic>> futureEmployeeShiftDetails;

  late Future<String> futureTrackingInfo;
  late Future<Map<String, dynamic>> futureLatestPunchAndShift;

  @override
  void initState() {
    super.initState();
    futureLatestPunchAndShift = getLatestPunchAndShiftForInit();
    // futureCheckInOutStatus = fetchCheckInOutStatus();
    // futureEmployeeShiftDetails = getEmployeeShiftDetails();
    loadCurrentLocation();
    getuserdata();
    futureBirthdayBanners = fetchBirthBanners();
    _loademployeleaves();
    fetchLeadCounts();
    futureTrackingInfo = getTrackingInfo();
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

  Future<void> getLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final logintime = prefs.getString('loginTime') ?? 'Unknown';
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime);
    DateTime loginTime = formattedlogintime;

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

  Future<Map<String, dynamic>> getLatestPunchAndShiftForInit() async {
    try {
      final dataAccessHandler = DataAccessHandler();
      Map<String, dynamic> results =
          await dataAccessHandler.fetchLatestPunchAndShift();
      //MARK: check status and display dilaog
      await fetchCheckInOutStatus(results);
      return results.cast<String, dynamic>();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLatestPunchAndShift() async {
    try {
      final dataAccessHandler = DataAccessHandler();
      Map<String, dynamic> results =
          await dataAccessHandler.fetchLatestPunchAndShift();
      //MARK: check status and display dilaog
      return results.cast<String, dynamic>();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getTrackingInfo() async {
    try {
      final dataAccessHandler = DataAccessHandler();
      List<Map<String, dynamic>> results =
          await dataAccessHandler.getTrackingInfo();
      return results.first['TrackType'];
    } catch (e) {
      rethrow;
    }
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

  Future<void> fetchCheckInOutStatus(Map<String, dynamic> results) async {
    try {
      final data = results.cast<String, dynamic>();
      final dailyPunch = data['dailyPunch'] ?? {};
      final shiftDetail = data['shiftDetail'] ?? {};
      // final shiftIn = shiftDetail['ShiftIn'] ??= '08:00:00';
      // final shiftOut = shiftDetail['ShiftOut'] ??= '17:00:00';
      final shiftIn = shiftDetail['ShiftIn'];
      final shiftOut = shiftDetail['ShiftOut'];
      final isPunchedIn = dailyPunch['IsPunchIn'] == 1;

      final now = DateTime.now();
      final int currentHour = now.hour;
      // print('fetchCheckInOutStatus:1 ${int.parse(shiftIn.split(":")[0])}');
      // print('fetchCheckInOutStatus:2 ${int.parse(shiftOut.split(":")[0])}');
      if (shiftIn == null && shiftOut == null) {
        return;
      }
      if (currentHour >= int.parse(shiftIn.split(":")[0]) &&
          currentHour < int.parse(shiftIn.split(":")[0]) + 1) {
        if (!isPunchedIn) {
          setState(() {
            isRequestProcessing = true;
          });

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => punchInOutDialog(context, isPunchedIn),
          );
        }
      } else if (currentHour >= int.parse(shiftOut.split(":")[0]) &&
          currentHour < int.parse(shiftOut.split(":")[0]) + 1) {
        if (isPunchedIn) {
          setState(() {
            isRequestProcessing = true;
          });

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => punchInOutDialog(context, isPunchedIn),
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /*  Future<void> fetchCheckInOutStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        isPunchedIn = prefs.getBool(Constants.isPunchIn) ?? false;
      });

      _time = prefs.getString(Constants.punchTime) ?? 'Invalid Time';
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
    } catch (e) {
      rethrow;
    }
  }
 */

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    showAddClient = PermissionManager.hasPermission("CanManageClientVisits");
    return RefreshIndicator(
      onRefresh: () async {
        fetchpendingrecordscount();
        setState(() {
          futureLatestPunchAndShift = getLatestPunchAndShift();
        });
      },
      child: WillPopScope(
        onWillPop: () async {
          exit(0);
        },
        child: Scaffold(
          backgroundColor: CommonStyles.appBgColor,
          body: Column(
            children: [
              header(),
              SizedBox(height: isTablet ? 20 : 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isTablet ? 20 : 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: futureLatestPunchAndShift,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Skeletonizer(
                                  enabled: true,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      shiftTimingAndStatus({}),
                                      const SizedBox(height: 5),
                                      checkInNOut({}),
                                    ],
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    snapshot.error.toString(),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final result = snapshot.data ?? {};

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  shiftTimingAndStatus(result),
                                  const SizedBox(height: 5),
                                  checkInNOut(result),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        hrmsSection(size),
                        const SizedBox(height: 10),
                        sgtSection(size),
                        const SizedBox(height: 10),
                        bannersCarosuel(context, size),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ), /* 
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: bannersCarosuel(context, size),
              ),
              const SizedBox(height: 10), */
            ],
          ),
        ),
      ),
    );
  }

/*
  Row hrmsSection(Size size) {
    final isTablet = size.width > 600;
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'PL\'s',
          size: size,
          data: "$usedPrivilegeLeavesInYear/$allottedPrivilegeLeaves",
          assetName: 'assets/pl.svg',
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
        SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
        customLeaveTypeBox(
          leaveType: 'CL\'s',
          size: size,
          data: "$usedCasualLeavesInYear/$allotcausalleaves",
          assetName: 'assets/cl.svg',
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
        SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
        customLeaveTypeBox(
          leaveType: 'Comp Off',
          data: '1/0',
          size: size,
          assetName: 'assets/comp-off.svg',
          themeColor: const Color(0xff9333EA),
        ),
      ],
    );
  }

  Row sgtSection(Size size) {
    final isTablet = size.width > 600;
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'Travelled',
          size: size,
          data: '${totalDistance.toStringAsFixed(2)} KM',
          assetName: 'assets/travelled.svg',
          themeColor: const Color(0xffFBBF24),
          hasToolTipRequired: true,
        ),
        SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
        customLeaveTypeBox(
          leaveType: 'Today Visits',
          size: size,
          data: '$todayLeadsCount',
          assetName: 'assets/today-visit.svg',
          themeColor: const Color(0xff16A34A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewLeads(isToday: true),
              ),
            );
          },
        ),
        SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
        customLeaveTypeBox(
          leaveType: 'Total Visits',
          size: size,
          data: '$totalLeadsCount',
          assetName: 'assets/total-visits.svg',
          themeColor: const Color(0xff4F46E5),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ViewLeads(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget customLeaveTypeBox({
    required String leaveType,
    required String data,
    required Color themeColor,
    required String assetName,
    void Function()? onTap,
    required Size size,
    bool hasToolTipRequired = false,
  }) {
    final isTablet = size.width > 600;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: size.height * 0.19,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: /* Image.asset(
                        'assets/pl_vector.png',
                        fit: BoxFit.cover,
                        width: 30,
                        height: 30,
                      ), */
                          SvgPicture.asset(
                        assetName,
                        fit: BoxFit.cover,
                        width: isTablet ? 40 : 30,
                        height: isTablet ? 40 : 30,
                      ),

                      /*  Icon(
                        icon ?? Icons.check_circle_outline,
                        color: themeColor,
                        size: isTablet ? 40 : 30,
                      ), */
                    ),
                    const SizedBox(height: 5),
                    Text(
                      leaveType,
                      style: CommonStyles.txStyF14CbFcF5.copyWith(
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                    Text(
                      data,
                      style: CommonStyles.txStyF20CbFcF5.copyWith(
                        fontSize: isTablet ? 16 : 14,
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
 */

  Row hrmsSection(Size size) {
    final isTablet = size.width > 600;
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'PL\'s',
          size: size,
          data: "$usedPrivilegeLeavesInYear/$allottedPrivilegeLeaves",
          assetName: 'assets/pl.svg',
          iconColor: CommonStyles.plBgColor,
          iconBgColor: CommonStyles.plColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Myleaveslist(leaveType: 'PL'),
              ),
            );
          },
        ),
        SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
        customLeaveTypeBox(
          leaveType: 'CL\'s',
          size: size,
          iconColor: CommonStyles.clBgColor,
          iconBgColor: CommonStyles.clColor,
          data: "$usedCasualLeavesInYear/$allotcausalleaves",
          assetName: 'assets/cl.svg',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Myleaveslist(leaveType: 'CL'),
              ),
            );
          },
        ),
        SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
        customLeaveTypeBox(
          leaveType: 'Comp Off',
          data: '0/0',
          size: size,
          assetName: 'assets/comp-off.svg',
          iconColor: CommonStyles.compoffColor,
          iconBgColor: CommonStyles.compoffBgColor,
        ),
      ],
    );
  }

  Row sgtSection(Size size) {
    final isTablet = size.width > 600;
    return Row(
      children: [
        customLeaveTypeBox(
          leaveType: 'Travelled',
          size: size,
          data: '${totalDistance.toStringAsFixed(2)} KM',
          assetName: 'assets/travelled.svg',
          iconColor: CommonStyles.travelledColor,
          iconBgColor: CommonStyles.travelledBgColor,
          hasToolTipRequired: true,
        ),
        /* if (showAddClient!) ...[
          SizedBox(width: isTablet ? 20 : 12), // Adjust spacing for tablets
          customLeaveTypeBox(
            leaveType: 'Today Visits',
            size: size,
            data: '$todayLeadsCount',
            assetName: 'assets/today-visit.svg',
            iconColor: CommonStyles.todaysVisitColor,
            iconBgColor: CommonStyles.todaysVisitBgColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewLeads(isToday: true),
                ),
              );
            },
          ),
        ], */
        SizedBox(width: isTablet ? 20 : 12),
        (showAddClient != null && showAddClient!)
            ? customLeaveTypeBox(
                leaveType: 'Total Visits',
                size: size,
                data: '$totalLeadsCount',
                assetName: 'assets/total-visits.svg',
                iconColor: CommonStyles.totalVisitColor,
                iconBgColor: CommonStyles.totalVisitBgColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewLeads(),
                    ),
                  );
                },
              )
            : const Expanded(
                child: SizedBox(),
              ),
        SizedBox(width: isTablet ? 20 : 12),
        (showAddClient != null && showAddClient!)
            ? customLeaveTypeBox(
                leaveType: 'Total Visits',
                size: size,
                data: '$totalLeadsCount',
                assetName: 'assets/total-visits.svg',
                iconColor: CommonStyles.totalVisitColor,
                iconBgColor: CommonStyles.totalVisitBgColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewLeads(),
                    ),
                  );
                },
              )
            : const Expanded(
                child: SizedBox(),
              ),
        /*  if (showAddClient!) ...[
          SizedBox(width: isTablet ? 20 : 12),
          customLeaveTypeBox(
            leaveType: 'Total Visits',
            size: size,
            data: '$totalLeadsCount',
            assetName: 'assets/total-visits.svg',
            iconColor: CommonStyles.totalVisitColor,
            iconBgColor: CommonStyles.totalVisitBgColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewLeads(),
                ),
              );
            },
          ),
        ], */
      ],
    );
  }

  Widget customLeaveTypeBox({
    required String leaveType,
    required String data,
    required Color iconColor,
    required Color iconBgColor,
    required String assetName,
    void Function()? onTap,
    required Size size,
    bool hasToolTipRequired = false,
  }) {
    final isTablet = size.width > 600;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: size.height * 0.19,
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: /* Image.asset(
                        'assets/pl_vector.png',
                        fit: BoxFit.cover,
                        width: 30,
                        height: 30,
                      ), */
                          SvgPicture.asset(
                        assetName,
                        color: iconColor,
                        fit: BoxFit.cover,
                        width: isTablet ? 40 : 30,
                        height: isTablet ? 40 : 30,
                      ),

                      /*  Icon(
                        icon ?? Icons.check_circle_outline,
                        color: themeColor,
                        size: isTablet ? 40 : 30,
                      ), */
                    ),
                    const SizedBox(height: 5),
                    Text(
                      leaveType,
                      style: CommonStyles.txStyF14CbFcF5.copyWith(
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                    Text(
                      data,
                      style: CommonStyles.txStyF20CbFcF5.copyWith(
                        fontSize: isTablet ? 16 : 14,
                      ),
                    )
                  ],
                ),
              ),
              if (hasToolTipRequired)
                FutureBuilder(
                    future: futureTrackingInfo,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return const SizedBox();
                      }
                      final String employeeTrackType = snapshot.data!;
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Tooltip(
                          message: employeeTrackType,
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.grey[700],
                            size: 20,
                          ),
                        ),
                      );
                    }),
            ],
          ),
        ),
      ),
    );
  }

/*  Widget checkInNOut(Map<String, dynamic> shiftDetails) {
    return checkInNOutTemplate(shiftDetails);
    */ /*  return FutureBuilder(
      future: futureCheckInOutStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Skeletonizer(
            enabled: true,
            child: checkInNOutTemplate(true, shiftDetails),
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        }
        return checkInNOutTemplate(isPunchedIn, shiftDetails);
      },
    ); */ /*
  }

  Row checkInNOutTemplate(Map<String, dynamic> result) {
    final dailyPunch = result['dailyPunch'] ?? {};
    final shiftDetail = result['shiftDetail'] ?? {};
    print('shiftDetail==$shiftDetail');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result['IsPunchIn'] != null || result['IsPunchIn'] == true
                    ? "Check In"
                    : "Shift Timings",
                style: CommonStyles.txStyF16CbFFb.copyWith(
                  fontSize: 18,
                ),
              ),
              Text(
                result['IsPunchIn'] != null || result['IsPunchIn'] == true
                    ? "at ${formatPunchTime(result['PunchDate'])}"
                    : shiftDetail != null
                        ? "${formatShiftTime(shiftDetail['ShiftIn'])} to ${formatShiftTime(shiftDetail['ShiftOut'])}"
                        : "No Shift Timings",
                // : "09:00 AM to 6:00 PM",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        result['IsPunchIn'] != null || result['IsPunchIn'] == true
            ? CustomBtn(
                icon: Icons.logout_outlined,
                btnText: 'Check Out',
                isLoading: isRequestProcessing,
                backgroundColor: CommonStyles.whiteColor,
                btnTextColor: CommonStyles.primaryColor,
                onTap: checkInOut,
                */ /* onTap: () async {
                    setState(() {
                      isRequestProcessing = true;
                    });

                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => punchInOutDialog(context),
                    );
                  }, */ /*
              )
            : CustomBtn(
                btnText: 'Check In',
                isLoading: isRequestProcessing,
                onTap: checkInOut,
              ),
      ],
    );
  }*/

/*
  Row checkInNOutTemplate(bool isCheckIn) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCheckIn ? "Check In" : "Shift Timings",
                style: CommonStyles.txStyF16CbFFb.copyWith(
                  fontSize: 18,
                ),
              ),
              Text(
                isCheckIn
                    ? "at ${formatPunchTime(_time)}"
                    : "09:00 AM to 6:00 PM",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        isCheckIn
            ? CustomBtn(
          icon: Icons.logout_outlined,
          btnText: 'Check Out',
          isLoading: isRequestProcessing,
          backgroundColor: CommonStyles.whiteColor,
          btnTextColor: CommonStyles.primaryColor,
          onTap: checkInOut,
          */ /* onTap: () async {
                    setState(() {
                      isRequestProcessing = true;
                    });

                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => punchInOutDialog(context),
                    );
                  }, */ /*
        )
            : CustomBtn(
          btnText: 'Check In',
          isLoading: isRequestProcessing,
          onTap: checkInOut,
        ),
      ],
    );
  }*/
  Widget checkInNOut(Map<String, dynamic> result) {
    return checkInNOutTemplate(result);
    /* return FutureBuilder(
      future: futureCheckInOutStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Skeletonizer(
            enabled: true,
            child: checkInNOutTemplate(shiftDetails),
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        }
        return checkInNOutTemplate(shiftDetails);
      },
    ); */
  }

  Row checkInNOutTemplate(Map<String, dynamic> result) {
    final dailyPunch = result['dailyPunch'] ?? {};
    final shiftDetail = result['shiftDetail'] ?? {};
    final isCheckIn =
        (dailyPunch['IsPunchIn'] != null && dailyPunch['IsPunchIn'] == 1);
    print('wqwq: ${shiftDetail['ShiftIn']} | ${shiftDetail['ShiftOut']}');

    print(
        'checkInNOutTemplate: ${shiftDetail.isNotEmpty ? jsonEncode(shiftDetail) : {}}');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCheckIn ? "Check In" : "Shift Timings",
                style: CommonStyles.txStyF16CbFFb.copyWith(
                  fontSize: 18,
                ),
              ),
              Text(
                isCheckIn
                    ? "at ${formatPunchTime(dailyPunch['PunchDate'])}"
                    : shiftDetail['ShiftIn'] != null &&
                            shiftDetail['ShiftOut'] != null
                        ? "${formatShiftTime(shiftDetail['ShiftIn'])} to ${formatShiftTime(shiftDetail['ShiftOut'])}"
                        : "No Shift Timings",
                // : "09:00 AM to 6:00 PM",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        isCheckIn
            ? CustomBtn(
                icon: Icons.logout_outlined,
                btnText: 'Check Out',
                isLoading: isRequestProcessing,
                backgroundColor: CommonStyles.whiteColor,
                btnTextColor: CommonStyles.primaryColor,
                onTap: () {
                  checkInOut(isCheckIn);
                },
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
                onTap: () {
                  checkInOut(isCheckIn);
                },
              ),
      ],
    );
  }
  // isCheckIn
  //     ? CustomBtn(
  //         icon: Icons.logout_outlined,
  //         btnText: 'Check Out',
  //         isLoading: isRequestProcessing,
  //         backgroundColor: CommonStyles.whiteColor,
  //         btnTextColor: CommonStyles.primaryColor,
  //         onTap: checkInOut,
  //         /* onTap: () async {
  //             setState(() {
  //               isRequestProcessing = true;
  //             });
  //
  //             await showDialog(
  //               context: context,
  //               barrierDismissible: false,
  //               builder: (context) => punchInOutDialog(context),
  //             );
  //           }, */
  //       )
  //     : CustomBtn(
  //         btnText: 'Check In',
  //         isLoading: isRequestProcessing,
  //         onTap: checkInOut,
  //       ),

  String? formatShiftTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null; // Return null if the input is null or empty
    }

    try {
      // Parse the input string into a DateTime object
      final DateTime time = DateFormat('HH:mm:ss').parse(timeString);

      // Format the time into the desired format (e.g., 09:00 AM / 6:00 PM)
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      // Handle parsing errors
      print('Error formatting time: $e');
      return null;
    }
  }

  Future<void> checkInOut(bool isPunchIn) async {
    setState(() {
      isRequestProcessing = true;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => punchInOutDialog(context, isPunchIn),
    );
  }

  Row shiftTimingAndStatus(Map<String, dynamic> result) {
    final shiftDetails = result['shiftDetail'] ?? {};
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
          style: CommonStyles.txStyF16CbFFb.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        shiftType(shiftDetails['ShiftTypeName'] ?? 'No Shift Allocated'),
        /* FutureBuilder(
            future: futureEmployeeShiftDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Skeletonizer(
                  enabled: true,
                  child: shiftType('Morning Shift'),
                );
              } else if (snapshot.hasError) {
                return const SizedBox();
              }
              final Map<String, dynamic> shiftDetails = snapshot.data!;
              return shiftType(shiftDetails['ShiftTypeName'] ?? 'Null');
            }) */
      ],
    );
  }

  Container shiftType(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: CommonStyles.primaryColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Calibri',
          color: CommonStyles.primaryColor,
        ),
      ),
    );
  }

/*   Container header() {
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
                style: CommonStyles.txStyF20CbFcF5.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('$employee_designation',
                  style: CommonStyles.txStyF20CbFcF5.copyWith(
                    fontSize: 12,
                    color: Colors.grey[700],
                  )),
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
  } */

  Container header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EmployeName,
                  style: CommonStyles.txStyF20CbFcF5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$employee_designation',
                  style: CommonStyles.txStyF20CbFcF5.copyWith(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1, // Limit to 1 line
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if text exceeds
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<BirthdayBanner>> fetchBirthBanners() async {
    try {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      if (!isConnected) {
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        throw Exception('No Internet Connection');
      } else {
        await getLoginTime();
        final apiUrl = Uri.parse('$baseUrl$getSlideShowData');
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'APIKey': APIKey,
        };
        final jsonString = await http.get(apiUrl, headers: headers);
        if (jsonString.statusCode == 200) {
          Map<String, dynamic> response = jsonDecode(jsonString.body);
          if (response['birthdayWishes'] != null &&
              response['birthdayWishes'].isNotEmpty) {
            final List<dynamic> birthdayWishesData = response['birthdayWishes'];
            return birthdayWishesData
                .map((data) => BirthdayBanner.fromJson(data))
                .toList();
            //  return birthdayBannerFromJson(jsonString.body);
          } else {
            throw Exception('No Birthday Wishes Found');
          }
        } else {
          throw Exception('Failed to fetch birthday wishes');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget bannersCarosuel(BuildContext context, Size size) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: size.height * 0.18,
      // color: Colors.red,
      child: FutureBuilder(
          future: futureBirthdayBanners,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return bannerLoading();
            } else if (snapshot.hasError) {
              return const SizedBox();
              /*  return Center(
                child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', '')),
              ); */
            } else {
              final List<BirthdayBanner> birthdayBanners = snapshot.data!;
              if (birthdayBanners.isEmpty) {
                return const Center(
                  child: Text('No Birthday Wishes Found'),
                );
              } else {
                return _buildCarousel(birthdayBanners, size);
              }
            }
          }),
    );
  }

  Skeletonizer bannerLoading() {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Expanded(
              flex: 3,
              child: SizedBox(
                height: double.infinity,
                child: Text(
                  "Wishing you a very Happy Birthday! Your dedication and hard work are truly valued. We hope this special day is filled with joy and celebration.",
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/birthday_cake2.jpg',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),

      /* Container(
                height: size.height * 0.18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/birthday_cake2.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ), */
    );
  }

  FlutterCarousel _buildCarousel(
      List<BirthdayBanner> birthdayBanners, Size size) {
    return FlutterCarousel(
      options: FlutterCarouselOptions(
        floatingIndicator: true,
        height: size.height * 0.18,
        viewportFraction: 1.0,
        enlargeCenterPage: true,
        autoPlay: birthdayBanners.length > 1,
        enableInfiniteScroll: birthdayBanners.length > 1,
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
      items: birthdayBanners.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.center,
                      height: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.employeeName}',
                                style: CommonStyles.txStyF20CbFcF5),
                            Text('${item.wish}',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: CommonStyles.txStyF20CbFcF5
                                    .copyWith(fontSize: 14)),
                          ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: item.photo != null
                          ? Image.memory(
                              formatBase64Image(item.photo!),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/birthday_cake2.jpg',
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ],
              ),
            );
            /*  return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: item.photo != null
                    ? Image.memory(
                        formatBase64Image(item.photo!),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        },
                      ),
              ),
            ); */
          },
        );
      }).toList(),
    );
  }

  Uint8List formatBase64Image(String base64String) {
    // String formattedString = base64String.replaceAll('\n', '');
    String cleanedBase64 = base64String.split('base64,').last.trim();
    Uint8List bytes = base64Decode(cleanedBase64);
    return bytes;
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
    await PermissionManager.loadPermissions();
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
    showAddClient = PermissionManager.hasPermission("CanManageClientVisits");
    print('showAddClient: $showAddClient');
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

    userID = prefs.getString(SharedKeys.userId) ?? "";
    // Fetch today's lead counts for the current date and userID
    todayLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS todayLeadsCount FROM Leads WHERE DATE(CreatedDate) = '$currentDate' AND CreatedByUserId = '$userID'");
    totalLeadsCount = await dataAccessHandler.getOnlyOneIntValueFromDb(
        "SELECT COUNT(*) AS totalLeadsCount FROM Leads WHERE CreatedByUserId = '$userID'");

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

    _time = (await dataAccessHandler.getOnlyStringValueFromDb(
        "SELECT PunchDate FROM DailyPunchInAndOutDetails  WHERE DATE(CreatedDate) ='$currentDate' AND CreatedByUserId = '$userID'"))!;
    print('_time == $_time');

    bool isPunchIn = _time != null && _time.isNotEmpty;

    await prefs.setBool(Constants.isPunchIn, isPunchIn);

    setState(() {
      isPunchedIn = isPunchIn; // Local state variable that drives the UI
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

  void _getCurrentDateTime() {
    final now = DateTime.now();
    _currentDateTime = DateFormat('EEEE, MMM d, yyyy – hh:mm a').format(now);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = "${position.latitude}, ${position.longitude}";
        _currentPosition = position;
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });

      // ✅ Print coordinates regardless of address resolution
      debugPrint("Latitude: $_latitude, Longitude: $_longitude");

      // Now try to get the address (requires internet)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        Placemark place = placemarks.first;

        setState(() {
          _address =
              "${place.thoroughfare} ${place.subLocality}, ${place.locality}, "
              "${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        });
      } catch (e) {
        debugPrint("Failed to fetch address: $e");
        setState(() {
          _address = "Address unavailable (offline)";
        });
      }

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

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     bool serviceEnabled;
  //     LocationPermission permission;
  //
  //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       return Future.error('Location services are disabled.');
  //     }
  //
  //     permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         return Future.error('Location permissions are denied');
  //       }
  //     }
  //
  //     if (permission == LocationPermission.deniedForever) {
  //       return Future.error('Location permissions are permanently denied.');
  //     }
  //
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);
  //
  //     Placemark place = placemarks.first;
  //
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _currentLocation = "${position.latitude}, ${position.longitude}";
  //       _currentPosition = position;
  //       _latitude = position.latitude.toString();
  //       _longitude = position.longitude.toString();
  //       _address = "${place.thoroughfare} ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
  //     });
  //
  //     /// ✅ Check if values are still empty
  //     if (_latitude.isEmpty || _longitude.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to fetch location coordinates.')),
  //       );
  //       return;
  //     }
  //
  //     if (_mapController != null) {
  //       _mapController!.animateCamera(
  //         CameraUpdate.newLatLng(
  //           LatLng(position.latitude, position.longitude),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _currentLocation = "Location unavailable";
  //     });
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   SnackBar(content: Text('Error fetching location: $e')),
  //     // );
  //     rethrow;
  //   }
  // }

  Future<void> _captureAndProcessImage(bool isPunchIn) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front, // Request front camera
        imageQuality: 30,
      );
      if (pickedFile == null) {
        if (!mounted) return;
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
      file.writeAsBytes(pngBytes);
      // Insert into DailyPunchInAndOutDetails table
      await _insertPunchData(
        DateTime.now().toIso8601String(),
        _latitude,
        _longitude,
        _address,
        isPunchIn,
        filePath,
      );

      await updatePunchStatus(isPunchIn ? false : true);

      /* if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved successfully at: $filePath")),
      ); */
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget punchInOutDialog(BuildContext context, bool isPunchIn) {
    String currentTime = DateFormat('hh:mm a').format(DateTime.now());

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
                  isPunchIn ? "Check Out" : "Check In",
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
                          child: Text(snapshot.error
                              .toString()
                              .replaceFirst('Exception: ', '')),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isPunchIn
                      ? 'Time to go home!'
                      : "It's time for another great day!",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _captureAndProcessImage(isPunchIn);
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
          _time = DateTime.now().toIso8601String();
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

  String formatPunchTime(String? dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString!);

      // String formattedTime = DateFormat('hh:mm a').format(dateTime);
      // print('xxx5: $dateTimeString');
      // if (dateTimeString == null) return "Invalid Date";
      // DateTime dateTime =
      //     DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTimeString);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  Future<void> updatePunchStatus(bool status) async {
    /*  SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.isPunchIn, status);
    await prefs.setString(Constants.punchTime, DateTime.now().toString()); */
    setState(() {
      isPunchedIn = status;
      isRequestProcessing = false;
      futureLatestPunchAndShift = getLatestPunchAndShift();
    });
  }

  Future<bool> _insertPunchData(
      String punchTime,
      String latitude,
      String longitude,
      String address,
      bool isCheckedIn,
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

      // if (!isCheckedIn) {
      // **Punch In: Insert new record in DailyPunchInAndOutDetails**
      print('_insertPunchData: $isCheckedIn');
      Map<String, dynamic> punchInData = {
        'UserId': userId,
        'PunchDate': punchTime,
        'IsPunchIn': isCheckedIn ? 0 : 1,
        'Latitude': latitude,
        'Longitude': longitude,
        'Address': address,
        'Remarks': "",
        'PunchMode': 410,
        'CreatedByUserId': userId,
        'CreatedDate': punchTime,
        'ServerUpdateStatus': false, // Unsynced data
      };

      punchResult = await db.insert('DailyPunchInAndOutDetails', punchInData);
      // }

      // else {
      //   // **Punch Out: Update last Punch In record**
      //   punchResult = await db.rawUpdate(
      //     '''
      //   UPDATE DailyPunchInAndOut
      //   SET PunchOutTime = ?, PunchOutLatitude = ?, PunchOutLongitude = ?, PunchOutAddress = ?,
      //       UpdatedByUserId = ?, UpdatedDate = ?, ServerUpdatedStatus = ?
      //   WHERE UserId = ? AND PunchOutTime IS NULL
      //   ''',
      //     [
      //       punchTime,
      //       latitude,
      //       longitude,
      //       address,
      //       userId,
      //       punchTime,
      //       false,
      //       userId
      //     ],
      //   );
      //
      //   print(punchResult > 0
      //       ? "✅ Punch Out updated successfully!"
      //       : "⚠️ No matching Punch In found!");
      // }

      if (punchResult > 0) {
        // **Check if File Already Exists Before Inserting**
        if (filePath != null && filePath.isNotEmpty) {
          String fileName = filePath.split('/').last;

          // **Prevent duplicate inserts**
          List<Map<String, dynamic>> existingFiles = await db.rawQuery(
              "SELECT * FROM FileRepository WHERE FileName = ? AND LookupType = ? AND ServerUpdatedStatus = 0",
              [fileName, isCheckedIn ? 376 : 377]);

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
                  isCheckedIn ? 376 : 377, // 23 for Punch In, 24 for Punch Out
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
                    onConfirmLogout(context);
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

  Future<void> onConfirmLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginTime');
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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

Future<Map<String, dynamic>> getEmployeeShiftDetails() async {
  try {
    final dataAccessHandler = DataAccessHandler();
    List<Map<String, dynamic>> results =
        await dataAccessHandler.getEmployeeShiftDetails();
    return results.first;
  } catch (e) {
    rethrow;
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
        String? shiftFromTime;
        String? shiftToTime;
        DateTime? shiftStart;
        DateTime? shiftEnd;
        String trackCondition = await dataAccessHandler.gettracktype();
        print("track condition for tracktype: $trackCondition");
        if (trackCondition == 'Shift Timings') {
          shiftFromTime = await dataAccessHandler.getShiftinTime();
          shiftToTime = await dataAccessHandler.getShiftoutTime();

          shiftStart = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(shiftFromTime.split(":")[0]),
            int.parse(shiftFromTime.split(":")[1]),
          );
          shiftEnd = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(shiftToTime.split(":")[0]),
            int.parse(shiftToTime.split(":")[1]),
          );
        } else if (trackCondition == 'Timings') {
          shiftFromTime = await dataAccessHandler.getTrackinTime();
          shiftToTime = await dataAccessHandler.getTrackoutTime();

          shiftStart = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(shiftFromTime.split(":")[0]),
            int.parse(shiftFromTime.split(":")[1]),
          );
          shiftEnd = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(shiftToTime.split(":")[0]),
            int.parse(shiftToTime.split(":")[1]),
          );
        } else {
          // shiftFromTime = await dataAccessHandler.getpuchinTime();
          // shiftToTime = await dataAccessHandler.getpunchoutTime();
          shiftFromTime = await dataAccessHandler.getpuchinTime();
          shiftToTime = await dataAccessHandler.getpunchoutTime();

          print("shiftFromTime: $shiftFromTime");
          print("shiftToTime $shiftToTime");
          // Parse full datetime
          DateTime fromDateTime = DateTime.parse(shiftFromTime);
          DateTime toDateTime = DateTime.parse(shiftToTime);

          // Rebuild with today's date and extracted time
          shiftStart = DateTime(
            now.year,
            now.month,
            now.day,
            fromDateTime.hour,
            fromDateTime.minute,
          );

          shiftEnd = DateTime(
            now.year,
            now.month,
            now.day,
            toDateTime.hour,
            toDateTime.minute,
          );
          print("Formatted shiftStart: $shiftStart");
          print("Formatted shiftEnd: $shiftEnd");
          // Format output
          final formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
          print("Formatted shiftStart: ${formatter.format(shiftStart)}");
          print("Formatted shiftEnd: ${formatter.format(shiftEnd)}");
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLeaveToday = prefs.getBool('isLeaveToday') ?? false;
        bool canTrackEmployee = await dataAccessHandler.canTrackEmployee();
        bool isExcludedDate = await dataAccessHandler.checkIfExcludedDate();
        bool isWithinTrackingHours =
            now.isAfter(shiftStart!) && now.isBefore(shiftEnd!);
        bool hasPointToday = await dataAccessHandler.hasPointForToday();

        /*    canTrackEmployee == true

        isLeaveToday == false

        isExcludedDate == false (not a holiday)

        isWithinTrackingHours == true*/

        print("canTrackEmployee: $canTrackEmployee");
        print("isLeaveToday: $isLeaveToday");
        print("isExcludedDate: $isExcludedDate");
        print("isWithinTrackingHours: $isWithinTrackingHours");

        /// Final condition check TODO
        if (canTrackEmployee &&
            !isLeaveToday &&
            !isExcludedDate &&
            isWithinTrackingHours) {
          if (!hasPointToday && _isPositionAccurate(position)) {
            if (!isFirstLocationLogged) {
              lastLatitude = position.latitude;
              lastLongitude = position.longitude;
              isFirstLocationLogged = true;

              await insertLocationToDatabase(
                  hrmsDatabase, position, userID, syncService);
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

              await insertLocationToDatabase(
                  hrmsDatabase, position, userID, syncService);
            } else {
              appendLog("Skipping insert: Distance too short (${distance}m)");
            }
          } else {
            appendLog("Skipping insert: Position inaccurate or speed is 0");
          }
        } else {
          appendLog("Tracking not allowed due to conditions not met.");
          print("❌ Tracking not allowed due to one or more conditions:");
          print("canTrackEmployee: $canTrackEmployee");
          print("isLeaveToday: $isLeaveToday");
          print("isExcludedDate: $isExcludedDate");
          print("isWithinTrackingHours: $isWithinTrackingHours");
        }
      }

      //  }
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
