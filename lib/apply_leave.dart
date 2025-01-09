import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/leaves_screen.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
import 'Model Class/EmployeeLeave.dart';
import 'Model Class/HolidayResponse.dart';
import 'Model Class/LookupDetail.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'holiday_model.dart';
import 'main.dart';

class apply_leave extends StatefulWidget {
  final String buttonName;
  final int lookupDetailId;
  final String employename;

  apply_leave(
      {required this.buttonName,
      required this.lookupDetailId,
      required this.employename});

  @override
  _apply_leaveeState createState() => _apply_leaveeState();
}

class _apply_leaveeState extends State<apply_leave> {
  int selectedTypeCdId = -1;
  List<dynamic> dropdownItems = [];
  String accessToken = '';
  String? empolyeid;
  TextEditingController _fromdateController = TextEditingController();
  TextEditingController _todateController = TextEditingController();
  TextEditingController _leavetext = TextEditingController();
  DateTime? selectedDate;
  String? logintime;
  FocusNode _focusNode = FocusNode();
  DateTime? selectedToDate;
  bool isButtonEnabled = true;
  bool isTodayHoliday = false;
  bool _isTodayHoliday = false;
  bool isChecked = false;
  List<Holiday_Model> holidayList = [];
  int selectedValue = 0;
  int selectedleaveValue = -1;
  String selectedName = "";
  String selectedleaveName = "";
  int Leavereasonlookupid = 0;
  bool isLoading = false;
  int DayWorkStatus = 0;
  List<LookupDetail> lookupDetails = [];
  int selectedleaveTypeId = -1;
  int defaultLookupDetailId = -1; // Replace with the actual default ID
  String defaultButtonName =
      'Select Leave Type'; // Replace with the actual default name
  double availablepls = 0.0;
  double availablecls = 0.0;
  double usedPrivilegeLeavesInYear = 0.0;
  double allottedPrivilegeLeaves = 0.0;
  double usedCasualLeavesInYear = 0.0;
  double allotcausalleaves = 0.0;
  String hintText = 'Leave Reason Description';
  int? DaysToConsiderAsLongLeave;
  List<Map<String, dynamic>> wfhLeavesList = []; // List to store "WFH" leaves
  List<Map<String, dynamic>> otherLeavesList =
      []; // Create a list for other leave types
  List<Map<String, dynamic>> CLLeavesList =
      []; // Create a list for other leave types

  bool fromDateSelected = false;
  bool ismatchedlogin = false;

  List<EmployeeLeave> leaveData = [];
  // TextEditingController _emailController3 = TextEditingController();
  @override
  void initState() {
    loadAccessToken();
    loademployeid();
    getleavereasonlookupid();
    _loademployeleaves();
    getDayWorkStatus();
    getLoginTime();
    _fromdateController.clear();
    _todateController.clear();
    selectedToDate = null;
    selectedDate = null;
    selectedleaveTypeId = -1;
    selectedleaveValue = -1;
    print('buttonName===${widget.buttonName}');
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
      MaterialPageRoute(builder: (context) => LoginPage()),
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
        allotcausalleaves = usdl.toDouble();
        usedPrivilegeLeavesInYear = usedprivilegeleavesinyear.toDouble();
        allottedPrivilegeLeaves = allotedprivilegeleaves.toDouble();
        usedCasualLeavesInYear = usedcasualleavesinyear.toDouble();
        availablepls = allottedPrivilegeLeaves.toDouble() -
            usedPrivilegeLeavesInYear.toDouble();

        print("Available Privilege Leaves: $availablepls");
        print("availablepls:$availablepls");
        availablecls =
            allotcausalleaves.toDouble() - usedCasualLeavesInYear.toDouble();

        print('availablecls:$availablecls');
        DateTime now = DateTime.now();
        // Extract the current month from the DateTime object
        int currentMonth = now.month;
        // Print the current month
        print('Current month: $currentMonth');
        //  print('availablecls: $availablecls');
      });
    }
    // availablepls = allottedPrivilegeLeaves - usedPrivilegeLeavesInYear;
    // availablecls = allotcausalleaves - usedCasualLeavesInYear;
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      fetchHolidayList(accessToken);
      _getadminsettings(accessToken);
    });
    print("accestokeninapplyleave:$accessToken");
  }

  Future<void> loademployeid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
      _loadleaveslist(empolyeid!);
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  // Future<void> _selectDate(bool isTodayHoliday) async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //
  //   DateTime initialDate = selectedDate;
  //
  //   // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
  //   if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
  //     initialDate = DateTime.now().add(const Duration(days: 1));
  //   }
  //
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: DateTime(2023),
  //     lastDate: DateTime(2125),
  //     // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.
  //
  //     selectableDayPredicate: (DateTime date) {
  //       print('Checking date: $date');
  //       //  final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
  //
  //       final saturday = date.weekday == DateTime.saturday; // Change to DateTime.sunday
  //       final sunday = date.weekday == DateTime.sunday;
  //
  //       final isHoliday = holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);
  //
  //       // If today is a holiday and the selected date is a past date, allow selecting the holiday date
  //       if (_isTodayHoliday && isHoliday) {
  //         return true;
  //       }
  //
  //       final isPreviousYear = date.year < DateTime.now().year;
  //
  //       // Return false if any of the conditions are met
  //       return !saturday && !sunday && !isHoliday && !isPreviousYear && date.year >= DateTime.now().year;
  //     },
  //   );
  //
  //   if (pickedDate != null) {
  //     setState(() {
  //       selectedDate = pickedDate;
  //       _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       //  onDateSelected(pickedDate);
  //     });
  //   }
  // }
  // Future<void> _selectDate(bool isTodayHoliday) async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //   selectedDate = DateTime.now();
  //
  //   DateTime initialDate = selectedDate!;
  //
  //   // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
  //   if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
  //     initialDate = DateTime.now().add(const Duration(days: 1));
  //   }
  //
  //   // Find the next selectable date after the initialDate
  //   while (!selectableDayPredicate(initialDate)) {
  //     initialDate = initialDate.add(const Duration(days: 1));
  //   }
  //   DateTime endDate = initialDate.add(Duration(days: 7));
  //   // DateTime tempEndDate = endDate; // Store the original end date
  //
  //   // Check for holidays within the 7-day range and adjust the end date accordingly
  //   // for (int i = 0; i < 7; i++) {
  //   //   if (_isHoliday(endDate)) {
  //   //     endDate = endDate.add(const Duration(days: 1));
  //   //   }
  //   // }
  //   if (_isHoliday(endDate)) {
  //     endDate = endDate.add(const Duration(days: 1));
  //   }
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2125),
  //     selectableDayPredicate: selectableDayPredicate,
  //   );
  //
  //   if (pickedDate != null) {
  //     setState(() {
  //       // if (selectedleaveName == 'PL') {
  //       //   selectedDate = pickedDate;
  //       //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       //   selectedToDate = pickedDate.add(Duration(days: 7));
  //       // } else {
  //       //   selectedDate = pickedDate;
  //       //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       // }
  //       // if (selectedleaveName == 'LL') {
  //       //   selectedDate = pickedDate;
  //       //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       //
  //       //   // Check if the original end date was a holiday and adjust the selectedToDate accordingly
  //       //   if (_isHoliday(tempEndDate)) {
  //       //     selectedToDate = tempEndDate.add(Duration(days: 1));
  //       //   } else {
  //       //     selectedToDate = tempEndDate;
  //       //   }
  //       // } else {
  //       //   selectedDate = pickedDate;
  //       //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       // }
  //       selectedDate = pickedDate;
  //       _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
  //       fromDateSelected = true;
  //       // if (selectedleaveName == 'LL') {
  //       //   selectedDate = pickedDate;
  //       //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       //   selectedToDate = pickedDate.add(Duration(days: 7)); // Adjust the end date accordingly
  //       //
  //       //   // Check if the adjusted end date is a holiday and adjust it accordingly
  //       //   if (_isHoliday(selectedToDate!)) {
  //       //     selectedToDate = selectedToDate!.add(const Duration(days: 1));
  //       //   }
  //       // } else {
  //       //   selectedDate = pickedDate;
  //       //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
  //       // }
  //     });
  //   }
  // }// working code hidden by manohar on 9- may -2024
  // DateTime _getNextSelectableDate(DateTime startDate, int offset) {
  //   DateTime nextDate = startDate;
  //   for (int i = 0; i < offset; ) {
  //     nextDate = nextDate.add(const Duration(days: 1));
  //     if (nextDate.weekday != DateTime.saturday &&
  //         nextDate.weekday != DateTime.sunday &&
  //         !_isHoliday(nextDate)) {
  //       i++; // Only increment if it's a business day and not a holiday
  //     }
  //   }
  //   return nextDate;
  // }
  // DateTime _getNextSelectableDate(DateTime startDate, int offset) {
  //   DateTime nextDate = startDate;
  //
  //   // Skip the start date if it's Saturday or Sunday
  //   if (nextDate.weekday == DateTime.saturday || nextDate.weekday == DateTime.sunday) {
  //     // If it's Saturday, move to Monday; if it's Sunday, move to Monday
  //     nextDate = nextDate.add(Duration(days: nextDate.weekday == DateTime.saturday ? 2 : 1));
  //   }
  //
  //   for (int i = 0; i < offset; ) {
  //     nextDate = nextDate.add(Duration(days: 1));
  //
  //     // Check if the next date is a business day and not a holiday
  //     if (nextDate.weekday != DateTime.saturday &&
  //         nextDate.weekday != DateTime.sunday &&
  //         !_isHoliday(nextDate)) {
  //       i++; // Only increment if it's a business day and not a holiday
  //     }
  //   }
  //
  //   return nextDate;
  // }
  DateTime _getNextSelectableDate(DateTime startDate, int offset) {
    DateTime nextDate = startDate;

    // Skip the start date if it's a Saturday, Sunday, or a holiday
    if (nextDate.weekday == DateTime.saturday ||
        nextDate.weekday == DateTime.sunday ||
        _isHoliday(nextDate)) {
      // Move to the next Monday if it's Saturday or Sunday, or to the next business day if it's a holiday
      while (nextDate.weekday == DateTime.saturday ||
          nextDate.weekday == DateTime.sunday ||
          _isHoliday(nextDate)) {
        nextDate = nextDate.add(Duration(days: 1));
      }
    }

    // Move to the next selectable date based on the offset
    for (int i = 0; i < offset;) {
      nextDate = nextDate.add(Duration(days: 1));

      // Check if the next date is a business day and not a holiday
      if (nextDate.weekday != DateTime.saturday &&
          nextDate.weekday != DateTime.sunday &&
          !_isHoliday(nextDate)) {
        i++; // Only increment if it's a business day and not a holiday
      }
    }

    return nextDate;
  }

  bool disableDaysPredicateForCl(DateTime date, DateTime initialDate) {
    // Check if date is a holiday based on fetched holidayList
/*     for (final holiday in holidayList) {
      if (holiday.fromDate.year == date.year &&
          holiday.fromDate.month == date.month &&
          holiday.fromDate.day == date.day) {
        return false;
      }
    }

    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    } */

    if (date.isBefore(initialDate)) {
      return false;
    }

    return true;
  }

  Future<void> _selectDate(bool isTodayHoliday) async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    if (widget.buttonName == "test" && selectedleaveValue == -1) {
      print("Leave Type not selected");
      Commonutils.showCustomToastMessageLong(
          "Please Select Leave Type To Select From Date", context, 1, 5);
    } else {
      DateTime lastDate = DateTime(DateTime.now().year + 10);
      if (widget.buttonName == "CL" || selectedleaveName == "CL") {
        DateTime today = DateTime.now();
        DateTime initialDate = DateTime.now();

/*         initialDate = _getNextSelectableDate(initialDate, 3);
        // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
        if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
          initialDate = _getNextSelectableDate(DateTime.now(), 1);

          /// initialDate = DateTime.now().add(const Duration(days: 1));
        }

        // Find the next selectable date after the initialDate
        while (!selectableDayPredicate(initialDate)) {
          initialDate = initialDate.add(const Duration(days: 1));
        }
        DateTime endDate = initialDate.add(Duration(days: 7));
       
        if (_isHoliday(endDate)) {
          endDate = endDate.add(const Duration(days: 1));
        } */

        initialDate = calculateCLInitialDate(holidayList);
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: initialDate,
          firstDate: today,
          lastDate: lastDate,
          selectableDayPredicate: selectableDayPredicate,
          /* selectableDayPredicate: (DateTime date) =>
              disableDaysPredicateForFromDate(date, initialDate), */
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFFf15f22),
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            // if (selectedleaveName == 'PL') {
            //   selectedDate = pickedDate;
            //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
            //   selectedToDate = pickedDate.add(Duration(days: 7));
            // } else {
            //   selectedDate = pickedDate;
            //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
            // }
            // if (selectedleaveName == 'LL') {
            //   selectedDate = pickedDate;
            //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
            //
            //   // Check if the original end date was a holiday and adjust the selectedToDate accordingly
            //   if (_isHoliday(tempEndDate)) {
            //     selectedToDate = tempEndDate.add(Duration(days: 1));
            //   } else {
            //     selectedToDate = tempEndDate;
            //   }
            // } else {
            //   selectedDate = pickedDate;
            //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
            // }
            selectedDate = pickedDate;
            _fromdateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate!);
            fromDateSelected = true;
            // if (selectedleaveName == 'LL') {
            //   selectedDate = pickedDate;
            //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
            //   selectedToDate = pickedDate.add(Duration(days: 7)); // Adjust the end date accordingly
            //
            //   // Check if the adjusted end date is a holiday and adjust it accordingly
            //   if (_isHoliday(selectedToDate!)) {
            //     selectedToDate = selectedToDate!.add(const Duration(days: 1));
            //   }
            // } else {
            //   selectedDate = pickedDate;
            //   _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
            // }
          });
        }
      } else {
        DateTime initialDate = DateTime.now();
        DateTime today = DateTime.now();
/* 
        if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
          initialDate = DateTime.now().add(const Duration(days: 1));
        }

        while (!selectableDayPredicate(initialDate)) {
          initialDate = initialDate.add(const Duration(days: 1));
        }
        DateTime endDate = initialDate.add(Duration(days: 7));

        if (_isHoliday(endDate)) {
          endDate = endDate.add(const Duration(days: 1));
        } */
        DateTime initialDateForPl = today.add(const Duration(days: 1));

        initialDate = calculatePLInitialDate(holidayList);
        print('xxx: $initialDate');
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: initialDate,
          firstDate: today,
          lastDate: lastDate,
          selectableDayPredicate: (DateTime date) =>
              disableDaysPredicateForFromDate(date, initialDateForPl),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFf15f22),
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            print('open todate picker: fromdate: $pickedDate');
            selectedDate = pickedDate;
            _todateController.clear();
            _fromdateController.text =
                DateFormat('dd-MM-yyyy').format(selectedDate!);
            fromDateSelected = true;
          });
        }
      }
    }
  }

  bool disableDaysPredicateForFromDate(
      DateTime date, DateTime initialDateForPl) {
    print('disableDaysPredicateForFromDate: $initialDateForPl');

    // Check if date is a holiday based on fetched holidayList
    for (final holiday in holidayList) {
      if (holiday.isActive) {
        final fromDate = holiday.fromDate;
        final toDate = holiday.toDate;

        // Case 1: Single-day holiday
        if (fromDate.year == date.year &&
            fromDate.month == date.month &&
            fromDate.day == date.day) {
          return false; // Disable this date (holiday)
        }

        // Case 2: Range of holidays
        if (date.isAfter(fromDate.subtract(const Duration(days: 1))) &&
            date.isBefore(toDate!.add(const Duration(days: 1)))) {
          return false; // Disable this date (holiday within range)
        }
      }
    }

    // Additional checks (e.g., disable weekends or earlier dates)
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }
    if (date.isBefore(initialDateForPl)) {
      return false;
    }

    return true;
  }

/* 
  bool disableDaysPredicateForFromDate(
      DateTime date, DateTime initialDateForPl) {
    print('disableDaysPredicateForFromDate: $initialDateForPl');
    // Check if date is a holiday based on fetched holidayList
    for (final holiday in holidayList) {
      if (holiday.fromDate.year == date.year &&
          holiday.fromDate.month == date.month &&
          holiday.fromDate.day == date.day) {
        return false;
      }
    }

    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }

    if (date.isBefore(initialDateForPl)) {
      return false;
    }

    return true;
  }
   */
  bool _isHoliday(DateTime date) {
    // Check if date is a holiday based on fetched holidayList
    for (final holiday in holidayList) {
      if (holiday.fromDate.year == date.year &&
          holiday.fromDate.month == date.month &&
          holiday.fromDate.day == date.day) {
        return true; // Date is a holiday
      }
    }
    return false; // Date is not a holiday
  }

  DateTime calculatePLInitialDate(List<Holiday_Model> leaves) {
    // Step 1: Initialize the initialDate to the next day from the current date.
    DateTime now = DateTime.now();
    DateTime initialDate = now.add(Duration(days: 1));

    // Step 2: Create a set of all leave dates from the Holiday_Model list.
    Set<DateTime> leaveDates = {};
    for (var leave in leaves) {
      DateTime fromDate = leave.fromDate;
      DateTime toDate = leave.toDate ?? leave.fromDate;
      for (var date = fromDate;
          date.isBefore(toDate.add(Duration(days: 1)));
          date = date.add(Duration(days: 1))) {
        leaveDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    // Step 3: Loop until initialDate is neither a Saturday, Sunday, nor a leave day.
    while (initialDate.weekday == DateTime.saturday ||
        initialDate.weekday == DateTime.sunday ||
        leaveDates.contains(
            DateTime(initialDate.year, initialDate.month, initialDate.day))) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    return initialDate;
  }

  DateTime calculateCLInitialDate(List<Holiday_Model> leaves) {
    // Step 1: Initialize the initialDate to the current date.
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    // Step 2: Create a set of all leave dates from the Holiday_Model list.
    Set<DateTime> leaveDates = {};
    for (var leave in leaves) {
      DateTime fromDate = leave.fromDate;
      DateTime toDate = leave.toDate ??
          leave.fromDate; // Handle null `toDate` as single-day leave.
      for (var date = fromDate;
          date.isBefore(toDate.add(Duration(days: 1)));
          date = date.add(Duration(days: 1))) {
        leaveDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    // Step 3: Add three working days.
    int workingDaysAdded = 0;

    while (workingDaysAdded < 3) {
      initialDate = initialDate.add(Duration(days: 1));
      if (initialDate.weekday != DateTime.saturday &&
          initialDate.weekday != DateTime.sunday &&
          !leaveDates.contains(
              DateTime(initialDate.year, initialDate.month, initialDate.day))) {
        workingDaysAdded++;
      }
    }

    return initialDate;
  }

  // bool selectableDayPredicate(DateTime date) {
  //   final saturday = date.weekday == DateTime.saturday;
  //   final sunday = date.weekday == DateTime.sunday;
  //
  //   final isHoliday =
  //       holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);
  //
  //   // Return true if it's not Saturday, not Sunday, not a holiday, and not before today
  //   return !saturday && !sunday && !isHoliday && date.isAfter(DateTime.now().subtract(Duration(days: 1)));
  // }
  // bool selectableToDayPredicate(DateTime date) {
  //   final fromDate = selectedDate ?? DateTime.now();
  //
  //   // Block dates before the selected from date
  //   if (date.isBefore(fromDate)) {
  //     return false;
  //   }
  //
  //   // Add your other conditions if needed, such as excluding weekends and holidays
  //   final saturday = date.weekday == DateTime.saturday;
  //   final sunday = date.weekday == DateTime.sunday;
  //
  //   final isHoliday = holidayList.any((holiday) {
  //     DateTime holidayFromDate = holiday.fromDate;
  //     DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
  //
  //     return date.isAfter(holidayFromDate.subtract(Duration(days: 1))) && date.isBefore(holidayToDate.add(Duration(days: 1)));
  //   });
  //
  //   // Return true if it's not Saturday, not Sunday, not a holiday, and not before the selected from date
  //   return !saturday && !sunday && !isHoliday;
  // }

  //Working code commented by Arun after restricting holiday in both from and to dates and current day blocking
  // bool selectableDayPredicate(DateTime date) {
  //   final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
  //
  //   // Check if it's today and a holiday
  //   if (isToday && _isTodayHoliday) {
  //     return false; // Disable selection for today if it's a holiday
  //   }
  //
  //   final saturday = date.weekday == DateTime.saturday;
  //   final sunday = date.weekday == DateTime.sunday;
  //
  //   final isHoliday = holidayList.any((holiday) {
  //     DateTime holidayFromDate = holiday.fromDate;
  //     DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
  //
  //     return date.isAfter(holidayFromDate.subtract(Duration(days: 1))) && date.isBefore(holidayToDate.add(Duration(days: 1)));
  //   });
  //
  //   // Return true if it's not Saturday, not Sunday, not a holiday, and not before today
  //   return !saturday && !sunday && !isHoliday && date.isAfter(DateTime.now().subtract(Duration(days: 1)));
  // }

  bool selectableDayPredicate(DateTime date) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    // Check if it's today anda holiday
    if (isToday && _isTodayHoliday) {
      return false; // Disable selection for today if it's a holiday
    }

    final saturday = date.weekday == DateTime.saturday;
    final sunday = date.weekday == DateTime.sunday;

    final isHoliday = holidayList.any((holiday) {
      DateTime holidayFromDate = holiday.fromDate;
      DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;

      return date.isAfter(holidayFromDate.subtract(Duration(days: 1))) &&
          date.isBefore(holidayToDate.add(Duration(days: 1)));
    });
    if (widget.buttonName == "CL" || selectedleaveName == "CL") {
      // Calculate cutoff date (3 business days ahead)
      DateTime cutoffDate = _getNextSelectableDate(DateTime.now(), 3);

      // Return true only if the date is after cutoffDate
      return !saturday &&
          !sunday &&
          !isHoliday &&
          date.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
          date.isAfter(cutoffDate.subtract(const Duration(days: 1)));
    } else {
      // If the condition is false, use your default logic (allowing all dates)
      return !saturday &&
          !sunday &&
          !isHoliday &&
          date.isAfter(DateTime.now().subtract(Duration(days: 1)));
    }
    // Calculate cutoff date (3 business days ahead)
    // DateTime cutoffDate = _getNextSelectableDate(DateTime.now(), 3);
    //
    // // Return true if it's not Saturday, not Sunday, not a holiday, not before today, and after cutoffDate
    // return !saturday && !sunday && !isHoliday && date.isAfter(DateTime.now().subtract(Duration(days: 1))) && date.isAfter(cutoffDate.subtract(const Duration(days: 1)));
  }

  // bool selectableDayPredicate(DateTime date) {//working code i have edited
  //   final saturday = date.weekday == DateTime.saturday;
  //   final sunday = date.weekday == DateTime.sunday;
  //
  //   final isHoliday = holidayList.any((holiday) {
  //     DateTime holidayFromDate = holiday.fromDate;
  //     DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
  //
  //     return date.isAfter(holidayFromDate.subtract(Duration(days: 1))) && date.isBefore(holidayToDate.add(Duration(days: 1)));
  //   });
  //
  //   // Return true if it's not Saturday, not Sunday, not a holiday, and not before today
  //   return !saturday && !sunday && !isHoliday && date.isAfter(DateTime.now().subtract(Duration(days: 1)));
  // }

  // Future<void> _selectToDate() async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //
  //   // DateTime initialDate = selectedToDate!;
  //   DateTime initialDate = selectedToDate ?? DateTime.now();
  //   // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
  //   if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
  //     initialDate = DateTime.now().add(const Duration(days: 1));
  //   }
  //
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: DateTime.now().subtract(Duration(days: 0)),
  //     lastDate: DateTime(2125),
  //     // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.
  //     selectableDayPredicate: (DateTime date) {
  //       final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
  //
  //       final saturday = date.weekday == DateTime.saturday;
  //       final sunday = date.weekday == DateTime.sunday;
  //
  //       final isHoliday = holidayList
  //           .any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);
  //
  //       if (_isTodayHoliday && isHoliday && isPastDate) {
  //         return true;
  //       }
  //
  //       final isPreviousYear = date.year < DateTime.now().year;
  //
  //       // Return false if any of the conditions are met
  //       return !isPastDate && !saturday && !sunday && !isHoliday && !isPreviousYear && date.year >= DateTime.now().year;
  //     //   final saturday = date.weekday == DateTime.saturday;
  //     //   final sunday = date.weekday == DateTime.sunday;
  //     //
  //     //   final isHoliday = holidayList.any((holiday) {
  //     //     DateTime holidayFromDate = holiday.fromDate;
  //     //     DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
  //     //
  //     //     return date.isAfter(holidayFromDate.subtract(Duration(days: 1))) && date.isBefore(holidayToDate.add(Duration(days: 1)));
  //     //   });
  //     //
  //     //   // Return true if it's not Saturday, not Sunday, not a holiday, and not before today
  //     //   return !saturday && !sunday && !isHoliday && date.isAfter(DateTime.now().subtract(Duration(days: 1)));
  //     // },
  // }
  //   );
  //
  //   if (pickedDate != null) {
  //     setState(() {
  //       selectedToDate = pickedDate;
  //       _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
  //       //  onDateSelected(pickedDate);
  //     });
  //   }
  // }

  Future<void> _selectToDate() async {
    print('open todate picker: $selectedDate');
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    DateTime initialDate = selectedDate ?? DateTime.now();

    if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    while (!selectableDayPredicate(initialDate)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedDate ?? initialDate,
      firstDate: selectedDate ?? initialDate,
      lastDate: DateTime(DateTime.now().year + 10),
      selectableDayPredicate: selectableDayPredicate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFf15f22), // header background color
              // onPrimary: Colors.white, // header text color
              // onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white, // background color
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedToDate = pickedDate;
        _todateController.text =
            DateFormat('dd-MM-yyyy').format(selectedToDate!);
      });
    }
  }

  void _getadminsettings(String accessToken) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    try {
      final url = Uri.parse(baseUrl + getadminsettings);
      print('AdminSettings: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      };

      final response = await http.get(url, headers: headers);
      print('Response: $response');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('Response Data: $responseData');

        if (responseData.containsKey('mininumDaysToConsiderAsLongLeave')) {
          final minimumDaysToConsiderAsLongLeave =
              responseData['mininumDaysToConsiderAsLongLeave'];
          if (minimumDaysToConsiderAsLongLeave is int) {
            print(
                'Minimum Days to Consider as Long Leave: $minimumDaysToConsiderAsLongLeave');
            setState(() {
              DaysToConsiderAsLongLeave = minimumDaysToConsiderAsLongLeave;
              print('DaysToConsiderLongLeave: $DaysToConsiderAsLongLeave');
            });
          } else {
            print(
                'Error: Value for mininumDaysToConsiderAsLongLeave is not an integer');
          }
        } else {
          print('Error: mininumDaysToConsiderAsLongLeave key is missing');
        }
      } else {
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error in Admin API: $error');
    }
  }

  void _loadleaveslist(String empolyeeId) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    // Get the current date and time
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    if (accessToken != null) {
      try {
        final url =
            Uri.parse(baseUrl + getleavesapi + empolyeeId + '/$currentYear');
        print('myLeavesApi$url');
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        };

        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            leaveData =
                data.map((json) => EmployeeLeave.fromJson(json)).toList();
            isLoading = false;
          });

          wfhLeavesList.clear(); // Clear the WFH list before adding new entries
          otherLeavesList
              .clear(); // Clear the WFH list before adding new entries
          CLLeavesList.clear();
          data.forEach((leave) {
            print('leave====>${leave['leaveType']}');
            if (leave['leaveType'] == 'CL' &&
                leave['status'] == 'Pending' &&
                leave['rejected'] == null &&
                leave['isDeleted'] == null) {
              print('CL====985leave====>${leave['leaveType']}');

              CLLeavesList.add({
                'fromDate': leave['fromDate'],
                'toDate': leave['toDate'],
                'leaveType': leave['leaveType'],
                'status': leave['status']
              });
              print('CLleavelength====993>${CLLeavesList.length}');
            }

            if (leave['leaveType'] == 'WFH' &&
                (leave['rejected'] == null || !leave['rejected']) &&
                (leave['isDeleted'] == null || !leave['isDeleted'])) {
              wfhLeavesList.add({
                'fromDate': leave['fromDate'],
                'toDate': leave['toDate'],
              });
            }

            if ((leave['status'] == 'Accepted' ||
                    leave['status'] == 'Approved' ||
                    leave['status'] == 'Pending') &&
                (leave['isDeleted'] == false || leave['isDeleted'] == null)) {
              otherLeavesList.add({
                'fromDate': leave['fromDate'],
                'toDate': leave['toDate'],
                'leaveType': leave['leaveType'],
                'status': leave['status']
              });
            }
          });

          // Print all "WFH" from dates and to dates
          wfhLeavesList.forEach((wfhEntry) {
            print('WFH From Date: ${wfhEntry['fromDate']}');
            print('WFH To Date: ${wfhEntry['toDate']}');
          });
          CLLeavesList.forEach((ClEntry) {
            print('CL From Date: ${ClEntry['fromDate']}');
            print('CL To Date: ${ClEntry['toDate']}');
            print('CL Status: ${ClEntry['status']}');
          });
          // Print all other leave types with Accepted and Approved status
          otherLeavesList.forEach((otherLeave) {
            print(
                '${otherLeave['leaveType']} From Date: ${otherLeave['fromDate']}');
            print(
                '${otherLeave['leaveType']} To Date: ${otherLeave['toDate']}');
          });

          print('API Response WFH Leaves List length: ${wfhLeavesList.length}');
          print(
              'API Response Other Leaves List length: ${otherLeavesList.length}');
        } else {
          Commonutils.showCustomToastMessageLong(
              'Error: ${response.body}', context, 1, 4);
          print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        }
      } catch (error) {
        print('Error: $error');
      }
    } else {
      print('Error: accessToken is null');
    }
  }

//Working code for wfh restriction, commented to add other leave types by Arun
  // void _loadleaveslist(String empolyeid) async {
  //   // Get the current date and time
  //   DateTime now = DateTime.now();
  //
  //   // Extract the current year
  //   int currentYear = now.year;
  //
  //   if (accessToken != null) {
  //     try {
  //       final url = Uri.parse(baseUrl + getleavesapi + empolyeid + '/$currentYear');
  //       print('myleavesapi$url');
  //       Map<String, String> headers = {
  //         'Content-Type': 'application/json',
  //         'Authorization': '$accessToken',
  //       };
  //
  //       final response = await http.get(url, headers: headers);
  //
  //       if (response.statusCode == 200) {
  //         final List<dynamic> data = json.decode(response.body);
  //         setState(() {
  //           leaveData = data.map((json) => EmployeeLeave.fromJson(json)).toList();
  //           isLoading = false;
  //         });
  //
  //         wfhLeavesList.clear(); // Clear the list before adding new entries
  //
  //         // data.forEach((leave) {
  //         //   if (leave['leaveType'] == 'WFH') {
  //         //     wfhLeavesList.add({
  //         //       'fromDate': leave['fromDate'],
  //         //       'toDate': leave['toDate'],
  //         //     });
  //         //   }
  //         // });
  //         data.forEach((leave) {
  //           if (leave['leaveType'] == 'WFH' &&
  //               (leave['rejected'] == null || !leave['rejected']) &&
  //               (leave['isDeleted'] == null || !leave['isDeleted'])) {
  //             wfhLeavesList.add({
  //               'fromDate': leave['fromDate'],
  //               'toDate': leave['toDate'],
  //             });
  //           }
  //         });
  //
  //         // Print all "WFH" from dates and to dates
  //         wfhLeavesList.forEach((wfhEntry) {
  //           print('WFH From Date: ${wfhEntry['fromDate']}');
  //           print('WFH To Date: ${wfhEntry['toDate']}');
  //         });
  //
  //         print('API Response wfhLeavesList length: ${wfhLeavesList.length}');
  //       } else {
  //         Commonutils.showCustomToastMessageLong('Error: ${response.body}', context, 1, 4);
  //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //       }
  //     } catch (error) {
  //       print('Error: $error');
  //     }
  //   } else {
  //     print('Error: accessToken is null');
  //   }
  // }
  // Future<void> _selectToDate() async {
  //   DateTime initialDate = selectedToDate ?? DateTime.now();
  //
  //   final DateTime? picked = await showDatePicker(
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     context: context,
  //     initialDate: initialDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     selectableDayPredicate: (DateTime date) {
  //       // Exclude weekends (Saturday and Sunday)
  //       if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
  //         return false;
  //       }
  //
  //       // Enable only the selected "From" date and the next date
  //       if (selectedDate != null && (date.isAtSameMomentAs(selectedDate) || date.isAfter(selectedDate))) {
  //         return true;
  //       }
  //
  //       return false;
  //     },
  //   );
  //
  //   if (picked != null && picked != selectedToDate) {
  //     setState(() {
  //       selectedToDate = picked;
  //       print('todate$selectedToDate');
  //       _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
  //     });
  //   }
  // }
  void disableButton() {
    setState(() {
      isButtonEnabled = false;
    });
  }

  // void onConfirmLogout() {
  //   SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
  //   Commonutils.showCustomToastMessageLong("Logout Successful", context, 0, 3);
  //   // Navigator.pushReplacement(
  //   //     context, MaterialPageRoute(builder: (context) => LoginPage()));
  //
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //     (route) => false,
  //   );
  // }
  Future<void> applyleave() async {
    bool confirmedToSplitWFH = false;
    bool isValid = true;
    bool hasValidationFailed = false;
    //
    // if (widget.buttonName == "test") if (isValid && selectedleaveValue == -1) {
    //   Commonutils.showCustomToastMessageLong('Please Select Leave Type', context, 1, 4);
    //   isValid = false;
    //   isLoading = false;
    //
    //   hasValidationFailed = true;
    // }
    // if (widget.buttonName == "test") if (isValid && selectedleaveValue == -1) {
    //   Commonutils.showCustomToastMessageLong('Please Select Leave Reason', context, 1, 4);
    //   isValid = false;
    //   isLoading = false;
    //
    //   hasValidationFailed = true;
    // }
    // if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL") if (isValid &&
    //     selectedValue == 0) {
    //   Commonutils.showCustomToastMessageLong('Please Select Leave Reason', context, 1, 4);
    //   isLoading = false;
    //   isValid = false;
    //   hasValidationFailed = true;
    // }

    // if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL") if (
    //     selectedValue == 0) {
    //   Commonutils.showCustomToastMessageLong('Please Select Leave Reason', context, 1, 4);
    //   isLoading = false;
    //   isValid = false;
    //   hasValidationFailed = true;
    // }

    // if (isValid && _fromdateController.text.isEmpty && selectedDate == null) {
    //   Commonutils.showCustomToastMessageLong('Please Select From Date', context, 1, 4);
    //   isValid = false;
    //   isLoading = false;
    //   hasValidationFailed = true;
    // }
    // if (isValid && _todateController.text.isEmpty) if (widget.buttonName == "PL" ||
    //     selectedleaveName == "PL" ||
    //     selectedleaveName == "LWP" ||
    //     selectedleaveName == "WFH") {
    //   Commonutils.showCustomToastMessageLong('Please Select To Date', context, 1, 4);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (isValid &&
    //     _todateController.text.isEmpty &&
    //     !isChecked && // Add this condition
    //     (widget.buttonName == "PL" || selectedleaveName == "PL" || selectedleaveName == "LWP" || selectedleaveName == "WFH")) {
    //   Commonutils.showCustomToastMessageLong('Please Select To Date', context, 1, 4);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (isValid &&
    //     _todateController.text.isEmpty &&
    //     !isChecked && // Add this condition
    //     (selectedleaveName == "LL")) {
    //   Commonutils.showCustomToastMessageLong('Please Select To Date', context, 1, 4);
    //   isValid = false;
    //   isLoading = false;
    //   hasValidationFailed = true;
    // }

    // if (selectedleaveName == "LL") {
    //
    //   print('selectedDate:$selectedDate');
    //   if (selectedDate! == null) {
    //     Commonutils.showCustomToastMessageLong('Please Select From Date', context, 1, 4);
    //     isValid = false;
    //     isLoading = false;
    //     hasValidationFailed = true;
    //   }
    //
    //   if (selectedToDate == null) {
    //     Commonutils.showCustomToastMessageLong('Please Select To Date', context, 1, 4);
    //     isValid = false;
    //     isLoading = false;
    //     hasValidationFailed = true;
    //   }
    // }

    // if (isValid && _leavetext.text.trim().isEmpty) {
    //   Commonutils.showCustomToastMessageLong('Please Enter the Leave Reason Description', context, 1, 4);
    //   isValid = false;
    //   isLoading = false;
    //   hasValidationFailed = true;
    // }
    if (widget.buttonName == "PL" ||
        selectedleaveName == "PL" ||
        selectedleaveName == "LL" ||
        selectedleaveName == "LWP" ||
        selectedleaveName == "WFH") {
      String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
      _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      if (_todateController.text == currentDate &&
          _fromdateController.text == currentDate) {
        Commonutils.showCustomToastMessageLong(
            'In any Situation Where Leave or Work From Home is Required for the Current date Please Contact the HR Manager or Admin',
            context,
            1,
            6);
        return;
      }
    }
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String? todate = null;
    print('tosendtodate:$selectedToDate');
    // if (isChecked)
    //   todate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // else if (selectedToDate != null) todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
    // if (widget.buttonName != 'CL' && selectedleaveName != "CL") {
    //   if (isChecked)
    //     todate = DateFormat('yyyy-MM-dd').format(selectedDate);
    //   else if (selectedToDate != null) todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
    // } else {
    //   setState(() {
    //     selectedToDate = selectedDate;
    //     todate = fromdate;
    //   });
    // }

    if (selectedToDate != null) {
      if (isChecked)
        todate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      else if (selectedToDate != null)
        todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
    } else {
      setState(() {
        selectedToDate = selectedDate!;
        todate = fromdate;
      });
    }

    print('tosendfromdate:$fromdate');
    print('tosendtodate:$todate');
    //
    // if (!isChecked) {
    //   // if (isValid && _todateController.text.isEmpty) {
    //   //   Commonutils.showCustomToastMessageLong('Please Select To Date', context, 1, 4);
    //   //   isValid = false;
    //   //   hasValidationFailed = true;
    //   // }
    //   if (widget.buttonName == 'PL' || selectedleaveName == 'PL' || selectedleaveName == 'WFH' || selectedleaveName == 'LWP') {
    //     if (todate != null) {
    //       if (isValid && todate!.compareTo(fromdate) < 0) {
    //         Commonutils.showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
    //         isValid = false;
    //         hasValidationFailed = true;
    //       }
    //     }
    //   }
    // }

    // if (selectedleaveName == 'PL' && availablepls <= 0.0) {
    //   Commonutils.showCustomToastMessageLong('No PLs Available ', context, 1, 6);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    //
    // if (selectedleaveName == 'CL' && availablecls <= 0.0) {
    //   Commonutils.showCustomToastMessageLong('No CLs Available ', context, 1, 6);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (isValid && isChecked) {
    //   // Calculate the difference in days between fromDate and toDate
    //   //int daysDifference = toDate.difference(fromDate).inDays;
    //   // if (daysDifference > 2) {
    //   //   Commonutils.showCustomToastMessageLong(
    //   //       'You cannot select more than 2 days when the checkbox is checked',
    //   //       context,
    //   //       1,
    //   //       7);
    //   //   isValid = false;
    //   //   hasValidationFailed = true;
    //   // }
    // }
    // if (selectedleaveName == 'PL' && availablepls <= 0.0) {
    //   Commonutils.showCustomToastMessageLong('No PLs Available ', context, 1, 6);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (selectedleaveName == 'CL' && availablecls <= 0.0) {
    //   Commonutils.showCustomToastMessageLong('No CLs Available ', context, 1, 6);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }
    // if (widget.buttonName == "PL" || selectedleaveName == "PL") {
    //   int selectedDays = selectedToDate!.difference(selectedDate).inDays + 1;
    //   print('selectedDays:$selectedDays');
    //   if (selectedDays >= DaysToConsiderAsLongLeave!) {
    //     // Show a toast message indicating that only 7 days are allowed
    //     Commonutils.showCustomToastMessageLong('Maximum $DaysToConsiderAsLongLeave days allowed for PLs', context, 1, 6);
    //     // isValid = true;
    //     // hasValidationFailed = false;
    //     isValid = false;
    //     hasValidationFailed = true;
    //   } else if (selectedDays > availablepls) {
    //     // Show a toast message indicating insufficient PLs
    //     Commonutils.showCustomToastMessageLong('Insufficient PLs', context, 1, 6);
    //     isValid = false;
    //     hasValidationFailed = true;
    //   }
    // }
    if (widget.buttonName == "PL" || selectedleaveName == "PL") {
      if (isChecked == false) {
        DateTime? selectedToDatePL;

        if (selectedToDate == null) {
          selectedToDatePL = selectedDate!;
        } else {
          selectedToDatePL = selectedToDate!;
        }

        int selectedDays =
            selectedToDatePL!.difference(selectedDate!).inDays + 1;
        print('selectedDays:$selectedDays');

        if (selectedDays > DaysToConsiderAsLongLeave!) {
          // Show a toast message indicating that only 7 days are allowed
          Commonutils.showCustomToastMessageLong(
              'Maximum $DaysToConsiderAsLongLeave days allowed for PLs',
              context,
              1,
              6);
          fromDateSelected = false;
          _fromdateController.clear();
          _todateController.clear();
          selectedToDate = null;
          selectedDate = null;
          return;
        } else if (selectedDays >= availablepls) {
          // Show a toast message indicating insufficient PLs
          Commonutils.showCustomToastMessageLong(
              'Insufficient PLs', context, 1, 6);
          fromDateSelected = false;
          _fromdateController.clear();
          _todateController.clear();
          selectedToDate = null;
          selectedDate = null;
          isValid = false;
          hasValidationFailed = true;
        } else {
          // Handle other cases where neither of the conditions is met
          isValid = true;
          hasValidationFailed = false;
        }
      }
    }

    if (selectedleaveName == "LL") {
      int selectedDays = selectedToDate!.difference(selectedDate!).inDays + 1;
      print('selectedlongleavedays:$selectedDays');
      print('DaysToConsiderAsLongLeave:$DaysToConsiderAsLongLeave');
      // if (selectedDays > DaysToConsiderAsLongLeave!) {
      //   // Show a toast message indicating the date range exceeds the available days
      //   Commonutils.showCustomToastMessageLong('Long Leave Should be Selected More Than $DaysToConsiderAsLongLeave Days', context, 1, 6);
      //   isValid = false;
      //   hasValidationFailed = true;
      // }

      if (selectedDays >= DaysToConsiderAsLongLeave!) {
        // Show a toast message indicating the date range meets or exceeds the required days
        //Commonutils.showCustomToastMessageLong('Long Leave Should be Selected More Than or Equal to $DaysToConsiderAsLongLeave Days', context, 1, 6);

        isValid = true;
        hasValidationFailed = false;
      } else {
        // Show a toast message indicating the date range is insufficient
        Commonutils.showCustomToastMessageLong(
            'Long Leave Should be Selected More Than $DaysToConsiderAsLongLeave Days',
            context,
            1,
            6);
        fromDateSelected = false;
        _fromdateController.clear();
        _todateController.clear();
        selectedToDate = null;
        selectedDate = null;
        isValid = false;
        hasValidationFailed = true;
      }
    }
    if (widget.buttonName == "CL" || selectedleaveName == "CL") {
      DateTime? previousClDate;
      DateTime? selectedToDateLeaves;
      DateTime? clFromDate;
      if (selectedToDate == null) {
        selectedToDateLeaves = selectedDate!;
      } else {
        selectedToDateLeaves = selectedToDate!;
      }

      // Find if there is any pending CL on another date within the same month
      bool isMatchFound = false;

      for (var ClEntry in CLLeavesList) {
        String? clFromDateStr = ClEntry['fromDate'];
        String? clStatus = ClEntry['status'];
        print('clFromDateStr$clFromDateStr');
        if (clFromDateStr != null && clStatus == "Pending") {
          clFromDate = DateTime.parse(clFromDateStr);

          // Check if it is in the same month and year and a different date
          if (clFromDate.year == selectedToDateLeaves.year &&
              clFromDate.month == selectedToDateLeaves.month &&
              clFromDate.day != selectedToDateLeaves.day) {
            isMatchFound = true;
            previousClDate = clFromDate;
            break;
          }
        }
      }

      if (isMatchFound && previousClDate != null) {
        String formattedMonth = DateFormat("MMMM").format(previousClDate);
        String formattedDate = DateFormat("d MMM yyyy").format(previousClDate!);

        ShowforCLdialog(context, formattedMonth, formattedDate, clFromDate!,
            (bool confirmation) {
          if (confirmation) {
            // Navigator.of(context).pop();
            applyclleaveapi(clFromDate!, selectedDate!);
          } else {
            fromDateSelected = false;
            _fromdateController.clear();
            _todateController.clear();
            selectedToDate = null;
            selectedDate = null;
          }
        });
        return;
        // Show a popup with the previous CL date
        // showDialog(
        //   context: context,
        //
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       backgroundColor: Colors.white,
        //       title:  Text(
        //         "Confirmation",
        //         style: TextStyle(
        //           fontSize: 18,
        //           fontFamily: 'Calibri',
        //           color: Color(0xFFf15f22),
        //         ),
        //       ),
        //       content: Text(
        //         "Kindly confirm whether you wish to retract the previously submitted leave for the month of ${formattedMonth} on this '${formattedDate}', which has not yet approved. Please click 'Confirm' to proceed with the reversion or 'Cancel' to maintain the current application status.",
        //      style: TextStyle(
        //          fontSize: 15,
        //        fontFamily: 'Calibri',
        //        color: Colors.black,
        //      ), ),
        //       actions: [
        //         ElevatedButton(
        //           onPressed: () {
        //             //    Navigator.of(context, rootNavigator: true).pop(context);
        //        applyclleaveapi(clFromDate!,selectedDate!);
        //          },
        //           child: Text(
        //             'Confirm',
        //             style: TextStyle(color: Colors.white, fontFamily: 'Calibri'), // Set text color to white
        //           ),
        //           style: ElevatedButton.styleFrom(
        //             primary: Color(0xFFf15f22), // Change to your desired background color
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(5), // Set border radius
        //             ),
        //           ),
        //         ),
        //         SizedBox(
        //           width: 5.0,
        //         ),
        //         ElevatedButton(
        //           onPressed: () {
        //             Navigator.of(context).pop();
        //
        //           },
        //           child: Text(
        //             'Cancel',
        //             style: TextStyle(color: Colors.white, fontFamily: 'Calibri'), // Set text color to white
        //           ),
        //           style: ElevatedButton.styleFrom(
        //             primary: Color(0xFFf15f22), // Change to your desired background color
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(5), // Set border radius
        //             ),
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // );
        // return;
      }
    }
    print('clleavelist${CLLeavesList.length}');
    if (widget.buttonName == "PL" ||
        selectedleaveName == "PL" ||
        widget.buttonName == "CL" ||
        selectedleaveName == "CL" ||
        selectedleaveName == "LL" ||
        selectedleaveName == "LWP") {
      DateTime? selectedToDateLeaves;

      if (selectedToDate == null) {
        selectedToDateLeaves = selectedDate!;
      } else {
        selectedToDateLeaves = selectedToDate!;
      }

      // Check if the selected dates fall between any "WFH" dates and match
      bool isMatchFound = wfhLeavesList.any((wfhEntry) {
        String? wfhFromDateStr = wfhEntry['fromDate'];
        String? wfhToDateStr = wfhEntry['toDate'];

        // Ensure both fromDate and toDate are not null
        if (wfhFromDateStr != null && wfhToDateStr != null) {
          DateTime? wfhFromDate = DateTime.tryParse(wfhFromDateStr);
          DateTime? wfhToDate = DateTime.tryParse(wfhToDateStr);

          // Check if DateTime parsing was successful
          if (wfhFromDate != null && wfhToDate != null) {
            // bool isSameDateMatch = selectedDate!.isAtSameMomentAs(wfhFromDate) || selectedToDateLeaves!.isAtSameMomentAs(wfhToDate);
            // // Compare the selected from date and to date directly with the "WFH" dates
            // bool isBetweenDates = selectedDate!.isAfter(wfhFromDate) && selectedToDateLeaves!.isBefore(wfhToDate);
            // // Compare the selected from date and to date directly with the "WFH" dates
            // return isSameDateMatch || isBetweenDates;
            bool isMatch = (selectedDate!.isBefore(wfhFromDate) &&
                    selectedToDateLeaves!
                        .isAfter(wfhFromDate)) || // Overlap at the beginning
                (selectedDate!.isBefore(wfhToDate) &&
                    selectedToDateLeaves!
                        .isAfter(wfhToDate)) || // Overlap at the end
                (selectedDate!.isAtSameMomentAs(wfhFromDate) ||
                    selectedToDateLeaves!
                        .isAtSameMomentAs(wfhToDate)) || // Exact match
                (selectedDate!.isAfter(wfhFromDate) &&
                    selectedToDateLeaves!.isBefore(
                        wfhToDate)) || // Other leave completely inside selected dates
                (wfhFromDate.isAfter(selectedDate!) &&
                    wfhToDate.isBefore(
                        selectedToDateLeaves!)); // Other leave in between selected dates

            // Compare the selected from date and to date directly with the "WFH" dates
            return isMatch;
          }
        }

        return false; // Return false if any parsing or comparison failed
      });

      if (todate!.compareTo(fromdate) >= 0) {
        if (isMatchFound) {
          if (isValid) {
            Showdialog(context, (confirmed) {
              if (confirmed) {
                print('confirmed $confirmed');
                // Send API request with confirmedToSplitWFH as true
                confirmedToSplitWFH = true;
                _sendLeaveRequest(confirmedToSplitWFH, fromdate, todate!);
                print('Sending API request with confirmedToSplitWFH as true');
              } else {
                // Handle cancel button click if needed
                print('Cancel button clicked');
                fromDateSelected = false;
                _fromdateController.clear();
                _todateController.clear();
                selectedToDate = null;
                selectedDate = null;
              }
            });

            isValid = false;
            hasValidationFailed = true;
            print('Selected dates fall between "WFH" dates.');
          }
        } else {
          DateTime? overlappingFromDate;
          DateTime? overlappingToDate;
          // Check for other leave types'
          print('otherLeavesList Size is $otherLeavesList');
          bool isOtherLeaveFound = otherLeavesList.any((otherLeave) {
            print('otherLeavesListInside loop Size is $otherLeavesList');
            String? otherFromDateStr = otherLeave['fromDate'];
            String? otherToDateStr = otherLeave['toDate'];

            print('otherFromDateStrrr $otherFromDateStr');
            print('otherToDateStrrrr $otherToDateStr');

            if (otherFromDateStr != null && otherToDateStr != null) {
              // Parsing otherLeave dates
              DateTime? otherFromDate = DateTime.tryParse(
                  otherFromDateStr.substring(0, 10)); // Extracting date part
              DateTime? otherToDate = DateTime.tryParse(
                  otherToDateStr.substring(0, 10)); // Extracting date part

              print('otherFromDateStrrr $otherFromDateStr');
              print('otherToDateStrrrr $otherToDateStr');

              print('otherFromDate $otherFromDate');
              print('otherToDate $otherToDate');

              if (otherFromDate != null && otherToDate != null) {
                // Parsing selected dates
                DateTime selectedFromDate = DateTime(
                    selectedDate!.year, selectedDate!.month, selectedDate!.day);
                DateTime selectedToDatee = DateTime(selectedToDateLeaves!.year,
                    selectedToDateLeaves!.month, selectedToDateLeaves!.day);

                print('selectedDate $selectedDate');
                print('selectedToDateLeaves $selectedToDateLeaves');

                print('selectedFromDate $selectedFromDate');
                print('selectedToDatee $selectedToDatee');

                bool isOverlap = (selectedDate!.isBefore(otherFromDate) &&
                        selectedToDateLeaves!.isAfter(
                            otherFromDate)) || // Overlap at the beginning
                    (selectedDate!.isBefore(otherToDate) &&
                        selectedToDateLeaves!
                            .isAfter(otherToDate)) || // Overlap at the end
                    (selectedDate!.isAtSameMomentAs(otherFromDate) ||
                        selectedToDateLeaves!
                            .isAtSameMomentAs(otherToDate)) || // Exact match
                    (selectedDate!.isAfter(otherFromDate) &&
                        selectedToDateLeaves!.isBefore(
                            otherToDate)) || // Other leave completely inside selected dates
                    (otherFromDate.isAfter(selectedDate!) &&
                        otherToDate.isBefore(
                            selectedToDateLeaves!)); // Other leave in between selected dates

                bool isNoOverlap = !isOverlap;

                // bool isEqualToFromDate = selectedToDatee.isAtSameMomentAs(
                //     otherFromDate);
                // bool isInRange = (selectedFromDate.isAtSameMomentAs(
                //     otherFromDate) ||
                //     selectedToDatee.isAtSameMomentAs(otherToDate) ||
                //     (selectedFromDate.isAfter(otherFromDate) &&
                //         selectedFromDate.isBefore(otherToDate)) ||
                //     (selectedToDatee.isAfter(otherFromDate) &&
                //         selectedToDatee.isBefore(otherToDate)));

                // print('isEqualToFromDate $isEqualToFromDate');
                // print('isInRange $isInRange');

                if (isOverlap) {
                  overlappingFromDate = otherFromDate;
                  overlappingToDate = otherToDate;
                  print('overlappingFromDate $overlappingFromDate');
                  print('overlappingToDate $overlappingToDate');
                  return true; // Overlapping dates found
                }
              }
            }

            return false; // No overlapping dates found
          });

          print('isOtherLeaveFound $isOtherLeaveFound');
          if (isOtherLeaveFound) {
            print('isOtherLeaveFoundInside $isOtherLeaveFound');
            print('isValid $isValid');
            if (isValid) {
              print('isValidInside $isValid');
              // String formattedFromDate = overlappingFromDate != null
              //     ? "${overlappingFromDate!.year}-${overlappingFromDate!.month.toString().padLeft(2, '0')}-${overlappingFromDate!.day.toString().padLeft(2, '0')}"
              //     : "";
              // String formattedToDate = overlappingToDate != null
              //     ? "${overlappingToDate!.year}-${overlappingToDate!.month.toString().padLeft(2, '0')}-${overlappingToDate!.day.toString().padLeft(2, '0')}"
              //     : "";
              String formattedFromDate = DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(overlappingFromDate.toString()));
              String formattedToDate = DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(overlappingToDate.toString()));

              Commonutils.showCustomToastMessageLong(
                  "Ooops !!! Duplicate leave is existing from $formattedFromDate to $formattedToDate dates",
                  context,
                  1,
                  5);
              isValid = false;
              hasValidationFailed = true;
              fromDateSelected = false;
              _fromdateController.clear();
              _todateController.clear();
              selectedToDate = null;
              selectedDate = null;

              print('Selected dates fall between other leave types.');
            }
          } else {
            // No conflicting leave found, proceed with the leave request
          }

          // print('otherLeavesList Size is $otherLeavesList');
          // bool isOtherLeaveFound = otherLeavesList.any((otherLeave) {
          //
          //   print('otherLeavesList Size Inside loop is $otherLeavesList');
          //   String? otherFromDateStr = otherLeave['fromDate'];
          //   String? otherToDateStr = otherLeave['toDate'];
          //
          //   // Ensure both fromDate and toDate are not null
          //   if (otherFromDateStr != null && otherToDateStr != null) {
          //     DateTime? otherFromDate = DateTime.tryParse(otherFromDateStr);
          //     DateTime? otherToDate = DateTime.tryParse(otherToDateStr);
          //
          //     // Check if DateTime parsing was successful
          //     if (otherFromDate != null && otherToDate != null) {
          //       bool isSameDateMatch = selectedDate.isAtSameMomentAs(otherFromDate) || selectedToDate!.isAtSameMomentAs(otherToDate);
          //       // Compare the selected from date and to date directly with the "WFH" dates
          //       bool isBetweenDates = selectedDate.isAfter(otherFromDate) && selectedToDate!.isBefore(otherToDate);
          //       // Compare the selected from date and to date directly with the "WFH" dates
          //       return isSameDateMatch || isBetweenDates;
          //     }
          //   }
          //
          //   return false; // Return false if any parsing or comparison failed
          // });
          //
          // if (isOtherLeaveFound) {
          //   Commonutils.showCustomToastMessageLong("You already have a leave on this date", context, 1, 5);
          //   isValid = false;
          //   hasValidationFailed = true;
          //   print('Selected dates fall between other leave types.');
          // } else {
          //   // No conflicting leave found, proceed with the leave request
          // }
        }
      } else {
        Commonutils.showCustomToastMessageLong(
            "To Date is less than From Date", context, 1, 5);
        isValid = false;
        hasValidationFailed = true;
      }
    }

    // if (widget.buttonName == "PL" ||
    //     selectedleaveName == "PL" ||
    //     widget.buttonName == "CL" ||
    //     selectedleaveName == "CL" ||
    //     selectedleaveName == "LL" ||
    //     selectedleaveName == "LWP") {
    //   // Check if the selected dates fall between any "WFH" dates and match
    //   bool isMatchFound = wfhLeavesList.any((wfhEntry) {
    //     String? wfhFromDateStr = wfhEntry['fromDate'];
    //     String? wfhToDateStr = wfhEntry['toDate'];
    //
    //     // Ensure both fromDate and toDate are not null
    //     if (wfhFromDateStr != null && wfhToDateStr != null) {
    //       DateTime? wfhFromDate = DateTime.tryParse(wfhFromDateStr);
    //       DateTime? wfhToDate = DateTime.tryParse(wfhToDateStr);
    //
    //       // Check if DateTime parsing was successful
    //       if (wfhFromDate != null && wfhToDate != null) {
    //
    //         bool isSameDateMatch = selectedDate.isAtSameMomentAs(wfhFromDate) || selectedToDate!.isAtSameMomentAs(wfhToDate);
    //         // Compare the selected from date and to date directly with the "WFH" dates
    //         bool isBetweenDates = selectedDate.isAfter(wfhFromDate) && selectedToDate!.isBefore(wfhToDate);
    //         // Compare the selected from date and to date directly with the "WFH" dates
    //         return isSameDateMatch || isBetweenDates;
    //       }
    //     }
    //
    //     return false; // Return false if any parsing or comparison failed
    //   });
    //
    //   if (todate!.compareTo(fromdate) >= 0) {
    //     if (isMatchFound) {
    //       Showdialog(context, (confirmed) {
    //         if (confirmed) {
    //           print('confirmed $confirmed');
    //           // Send API request with confirmedToSplitWFH as true
    //           confirmedToSplitWFH = true;
    //           _sendLeaveRequest(confirmedToSplitWFH, fromdate, todate!);
    //           print('Sending API request with confirmedToSplitWFH as true');
    //         } else {
    //           // Handle cancel button click if needed
    //           print('Cancel button clicked');
    //         }
    //       });
    //
    //       isValid = false;
    //       hasValidationFailed = true;
    //       print('Selected dates fall between "WFH" dates.');
    //     } else {
    //       // Check for other leave types'
    //
    //
    //       print('otherLeavesList Size is $otherLeavesList');
    //       bool isOtherLeaveFound = otherLeavesList.any((otherLeave) {
    //
    //         print('otherLeavesList Size Inside loop is $otherLeavesList');
    //         String? otherFromDateStr = otherLeave['fromDate'];
    //         String? otherToDateStr = otherLeave['toDate'];
    //
    //         // Ensure both fromDate and toDate are not null
    //         if (otherFromDateStr != null && otherToDateStr != null) {
    //           DateTime? otherFromDate = DateTime.tryParse(otherFromDateStr);
    //           DateTime? otherToDate = DateTime.tryParse(otherToDateStr);
    //
    //           // Check if DateTime parsing was successful
    //           if (otherFromDate != null && otherToDate != null) {
    //             bool isSameDateMatch = selectedDate.isAtSameMomentAs(otherFromDate) || selectedToDate!.isAtSameMomentAs(otherToDate);
    //             // Compare the selected from date and to date directly with the "WFH" dates
    //             bool isBetweenDates = selectedDate.isAfter(otherFromDate) && selectedToDate!.isBefore(otherToDate);
    //             // Compare the selected from date and to date directly with the "WFH" dates
    //             return isSameDateMatch || isBetweenDates;
    //           }
    //         }
    //
    //         return false; // Return false if any parsing or comparison failed
    //       });
    //
    //       if (isOtherLeaveFound) {
    //         Commonutils.showCustomToastMessageLong("You already have a leave on this date", context, 1, 5);
    //         isValid = false;
    //         hasValidationFailed = true;
    //         print('Selected dates fall between other leave types.');
    //       } else {
    //         // No conflicting leave found, proceed with the leave request
    //         _sendLeaveRequest(confirmedToSplitWFH, fromdate, todate!);
    //       }
    //     }
    //   } else {
    //     Commonutils.showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
    //     isValid = false;
    //     hasValidationFailed = true;
    //   }
    // }

    //Working condition commented to check for otherleavetypes as well
    // if (widget.buttonName == "PL" ||
    //     selectedleaveName == "PL" ||
    //     widget.buttonName == "CL" ||
    //     selectedleaveName == "CL" ||
    //     selectedleaveName == "LL" ||
    //     selectedleaveName == "LWP") {
    //   // Check if the selected dates fall between any "WFH" dates and match
    //   bool isMatchFound = wfhLeavesList.any((wfhEntry) {
    //     String? wfhFromDateStr = wfhEntry['fromDate'];
    //     String? wfhToDateStr = wfhEntry['toDate'];
    //
    //     // Ensure both fromDate and toDate are not null
    //     if (wfhFromDateStr != null && wfhToDateStr != null) {
    //       DateTime? wfhFromDate = DateTime.tryParse(wfhFromDateStr);
    //       DateTime? wfhToDate = DateTime.tryParse(wfhToDateStr);
    //
    //       print('selectedDate:$selectedDate');
    //       print('wfhFromDate:$wfhFromDate');
    //       print('selectedToDate:$selectedToDate');
    //       print('wfhToDate:$wfhToDate');
    //
    //       // Check if DateTime parsing was successful
    //       if (wfhFromDate != null && wfhToDate != null) {
    //         bool isSameDateMatch = selectedDate.isAtSameMomentAs(wfhFromDate) || selectedToDate!.isAtSameMomentAs(wfhToDate);
    //         // Compare the selected from date and to date directly with the "WFH" dates
    //         bool isBetweenDates = selectedDate.isAfter(wfhFromDate) && selectedToDate!.isBefore(wfhToDate);
    //         // Compare the selected from date and to date directly with the "WFH" dates
    //         return isSameDateMatch || isBetweenDates;
    //       }
    //     }
    //
    //     return false; // Return false if any parsing or comparison failed
    //   });
    //
    //   if (todate!.compareTo(fromdate) >= 0) {
    //     print('this is dialog todate');
    //     if (isMatchFound) {
    //       // if (todate!.compareTo(fromdate) < 0) {
    //       //   Commonutils.showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
    //       //   isValid = false;
    //       //   hasValidationFailed = true;
    //       // } else {
    //       Showdialog(context, (confirmed) {
    //         if (confirmed) {
    //           print('confirmed$confirmed');
    //           // Send API request with confirmedToSplitWFH as true
    //           confirmedToSplitWFH = true;
    //           _sendLeaveRequest(confirmedToSplitWFH, fromdate, todate!);
    //           print('Sending API request with confirmedToSplitWFH as true');
    //         } else {
    //           //  confirmedToSplitWFH = false;
    //           // _sendLeaveRequest(confirmedToSplitWFH, fromdate, todate!);
    //           // Handle cancel button click if needed
    //           print('Cancel button clicked');
    //         }
    //       });
    //       // }
    //       // Show your toast message or perform other actions here
    //
    //       isValid = false;
    //       hasValidationFailed = true;
    //       print('Selected dates fall between "WFH" dates and match.');
    //     } else {
    //       print('Selected dates do not fall between "WFH" dates or do not match.');
    //     }
    //   } else {
    //     Commonutils.showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
    //     isValid = false;
    //     hasValidationFailed = true;
    //   }
    // }
    // if (fromdate == null || todate == null) {
    //   Commonutils.showCustomToastMessageLong(
    //       "Please select both FromDate and ToDate", context, 1, 5);
    // } else
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
    } else {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }
    print('====>$selectedleaveName');
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime!);
    // Replace this with your actual login time
    DateTime loginTime = formattedlogintime /* Replace with your login time */;

    // Calculate the time difference
    Duration timeDifference = currentTime.difference(loginTime);

    // Check if the time difference is less than or equal to 1 hour (3600 seconds)
    if (timeDifference.inSeconds <= 3600) {
      // Login is within the allowed window

      print("Login is within 1 hour of current time.");
    } else {
      // Login is outside the allowed window
      // _showtimeoutdialog(context);
      print("Login is more than 1 hour from current time.");
    }
    if (isValid) {
      isLoading = true;
      try {
        final url = Uri.parse(baseUrl + applyleaveapi);
        print('ApplyLeaveUrl: $url');
        final request = {
          "EmployeeId": empolyeid,
          "FromDate": fromdate,
          // if (widget.buttonName == 'CL' || selectedleaveName == 'CL') ...{
          //   "ToDate": fromdate,
          // } else ...{
          //   "ToDate": todate,
          // },
          if (todate == null) ...{
            "ToDate": fromdate,
          } else ...{
            "ToDate": todate,
          },
          "LeaveTypeId": '${widget.lookupDetailId}',
          "Note": _leavetext.text,
          "AcceptedBy": null,
          "AcceptedAt": null,
          "ApprovedBy": null,
          "ApprovedAt": null,
          "Rejected": null,
          "Comments": null,
          "IsApprovalEscalated": null,
          "URL":
              "http://182.18.157.215:/", // In development stage change url to this http://182.18.157.215:///http://hrms.calibrage.in:/
          // "URL": "http://hrms.calibrage.in:/", // In development stage change url to this http://182.18.157.215:///http://hrms.calibrage.in:/
          // "URL": "https://hrms.calibrage.in:/", // Live
          // In development stage change url to this http://182.18.157.215:///http://hrms.calibrage.in:/
          "EmployeeName": "${widget.employename}",
          // "getLeaveType": null,
          if (widget.buttonName == "test") ...{
            "GetLeaveType": "$selectedleaveName",
          } else ...{
            "GetLeaveType": "${widget.buttonName}",
          },
          "IsHalfDayLeave": isChecked,
          "LeaveReasonId": selectedValue,
          "IsFromAttendance": false,
          if (widget.buttonName == "test") ...{
            "LeaveTypeId": selectedleaveValue,
            "LeaveReasonId": selectedleaveValue,
            //   if (selectedleaveName == "WFH")
            //     "leaveReasonId": selectedValue
          }
          // },
        };

        // final headers = {
        //   'Authorization': '$accessToken',
        // };
        // Map<String, String> _header = {
        //   'Authorization': '$accessToken',
        // };
        // String at = accessToken;
        // print('Request Headers: $_header');
        print('Request Body: ${json.encode(request)}');

        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$accessToken',
          },
        );
        //  print('access: $at');
        // if (response.body == "Server errorNullable object must have a value.") {
        //   Commonutils.showCustomToastMessageLong(
        //       'Leave Applied', context, 0, 3);
        // }
        print('Applyresponse: ${response.body}');
        // ProgressDialog progressDialog = ProgressDialog(context);

        // Show the progress dialog
        //  progressDialog.show();
        // Parse the JSON response

        // // Access the value of isSuccess
        // bool isSuccess = responseMap['isSuccess'];
        // dynamic message = responseMap['message'];
        // String messageresponse = message != null ? message.toString() : "No message provided";

        // Access the value of isSuccess

        if (response.statusCode == 200) {
          Map<String, dynamic> responseMap = json.decode(response.body);

          if (responseMap.containsKey('isSuccess')) {
            bool isSuccess = responseMap['isSuccess'];
            if (isSuccess == true) {
              isLoading = false;
              fromDateSelected = false;
              print('response is success');

              disableButton();
              //  progressDialog.dismiss();
              if (selectedleaveName == "WFH") {
                Commonutils.showCustomToastMessageLong(
                    'Successfully WFH has Applied', context, 0, 3);
                setState(() {
                  fromDateSelected = false;
                  _fromdateController.clear();
                  _todateController.clear();
                  selectedToDate = null;
                  selectedDate = null;
                });

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => home_screen()),
                );
              } else {
                Commonutils.showCustomToastMessageLong(
                    'Successfully Leave has Applied', context, 0, 3);
                setState(() {
                  fromDateSelected = false;
                  _fromdateController.clear();
                  _todateController.clear();
                  selectedToDate = null;
                  selectedDate = null;
                });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => home_screen()),
                );
              }
            } else {
              Commonutils.showCustomToastMessageLong(
                  '${responseMap['message']}', context, 1, 4);
              print('Apply Leave Failed: ${response.body}');
            }
          } else {
            if (response.body.toLowerCase().contains('invalid token')) {
              // Invalid token scenario
              Commonutils.showCustomToastMessageLong(
                  'Invalid Token. Please Login Again.', context, 1, 4);
            } else {
              // Other scenarios with success status code
              // Handle as needed, for example, showing the response message
              String message = responseMap['message'] ?? 'No message provided';
              Commonutils.showCustomToastMessageLong(
                  '${response.body}', context, 0, 3);
            }
          }
        } else if (response.statusCode == 520) {
          // Scenario with status code 520
          // Show the response body as a toast
          Commonutils.showCustomToastMessageLong(
              '${response.body}', context, 0, 3);
        } else {
          // Handle other status codes if needed
          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }

        // if (isSuccess == true) {
        //   isLoading = false;
        //   print('response is success');
        //
        //   disableButton();
        //   if (selectedleaveName == "WFH") {
        //     Commonutils.showCustomToastMessageLong('Successfully WFH has Applied', context, 0, 3);
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (context) => home_screen()),
        //     );
        //   } else {
        //     Commonutils.showCustomToastMessageLong('Successfully Leave has Applied', context, 0, 3);
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (context) => home_screen()),
        //     );
        //   }
        // } else {
        //   // Commonutils.showCustomToastMessageLong(' ${messageresponse}', context, 1, 5);
        //
        //   print('response is not success');
        //   Commonutils.showCustomToastMessageLong('${response.body}', context, 0, 3);
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => home_screen()),
        //   );
        //   print('Failed to send the request. Status code: ${response.statusCode}');
        // }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> applyclleaveapi(
      DateTime dateTime, DateTime selecteddateforcl) async {
    String formattedMonth = DateFormat("MMMM").format(dateTime);
    String previouslyClDate = DateFormat("EEEE, d MMMM yyyy").format(dateTime);
    String selectedclDate =
        DateFormat("EEEE, d MMMM yyyy").format(selecteddateforcl);
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String? todate = null;
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
      print('dateTimepreviouslyapplied:${dateTime}');
      print('selecteddateforcl:${selecteddateforcl}');
    } else {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }
    print('====>$selectedleaveName');
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime!);
    // Replace this with your actual login time
    DateTime loginTime = formattedlogintime /* Replace with your login time */;

    // Calculate the time difference
    Duration timeDifference = currentTime.difference(loginTime);

    // Check if the time difference is less than or equal to 1 hour (3600 seconds)
    if (timeDifference.inSeconds <= 3600) {
      // Login is within the allowed window

      print("Login is within 1 hour of current time.");
    } else {
      // Login is outside the allowed window
      // _showtimeoutdialog(context);
      print("Login is more than 1 hour from current time.");
    }
    isLoading = true;
    try {
      final url = Uri.parse(baseUrl + applyleaveapi);
      print('ApplyLeaveUrl: $url');
      final request = {
        "EmployeeId": empolyeid,
        "FromDate": fromdate,
        // if (widget.buttonName == 'CL' || selectedleaveName == 'CL') ...{
        //   "ToDate": fromdate,
        // } else ...{
        //   "ToDate": todate,
        // },
        if (todate == null) ...{
          "ToDate": fromdate,
        } else ...{
          "ToDate": todate,
        },
        "LeaveTypeId": '${widget.lookupDetailId}',
        "Note": _leavetext.text,
        "AcceptedBy": null,
        "AcceptedAt": null,
        "ApprovedBy": null,
        "ApprovedAt": null,
        "Rejected": null,
        "Comments": null,
        "IsApprovalEscalated": null,
        "URL":
            "http://182.18.157.215:/", // In development stage change url to this http://182.18.157.215:///http://hrms.calibrage.in:/
        //"URL": "http://hrms.calibrage.in:/", // In development stage change url to this http://182.18.157.215:///http://hrms.calibrage.in:/
        // "URL": "https://hrms.calibrage.in:/", // Live
        "EmployeeName": "${widget.employename}",
        // "getLeaveType": null,
        if (widget.buttonName == "test") ...{
          "GetLeaveType": "$selectedleaveName",
        } else ...{
          "GetLeaveType": "${widget.buttonName}",
        },
        "IsHalfDayLeave": isChecked,
        "LeaveReasonId": selectedValue,
        "IsFromAttendance": false,
        if (widget.buttonName == "test") ...{
          "LeaveTypeId": selectedleaveValue,
          "LeaveReasonId": selectedleaveValue,
          //   if (selectedleaveName == "WFH")
          //     "leaveReasonId": selectedValue
        }
        // },
      };

      print('Request Body: ${json.encode(request)}');

      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );

      print('Applyresponse: ${response.body}');
      // ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      //   progressDialog.show();
      // Parse the JSON response

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = json.decode(response.body);

        if (responseMap.containsKey('isSuccess')) {
          bool isSuccess = responseMap['isSuccess'];
          if (isSuccess == true) {
            isLoading = false;
            fromDateSelected = false;
            print('response is success');
            // Navigator.of(context).pop();

            disableButton();

            Commonutils.showCustomToastMessageLong(
                'Your request for CL is Submitted for ${selectedclDate}, However the requested CL on ${previouslyClDate} has been declined',
                context,
                0,
                6);
            setState(() {
              fromDateSelected = false;

              _fromdateController.clear();
              _todateController.clear();
              selectedToDate = null;
              selectedDate = null;
            });
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => home_screen()),
            );
            //  progressDialog.dismiss();
          } else {
            Commonutils.showCustomToastMessageLong(
                '${responseMap['message']}', context, 1, 4);
            print('Apply Leave Failed: ${response.body}');
            // progressDialog.dismiss();
          }
        } else {
          //  progressDialog.dismiss();
          if (response.body.toLowerCase().contains('invalid token')) {
            //    progressDialog.dismiss();
            // Invalid token scenario
            Commonutils.showCustomToastMessageLong(
                'Invalid Token. Please Login Again.', context, 1, 4);
          } else {
            //   progressDialog.dismiss();
            // Other scenarios with success status code
            // Handle as needed, for example, showing the response message
            String message = responseMap['message'] ?? 'No message provided';
            Commonutils.showCustomToastMessageLong(
                '${response.body}', context, 0, 3);
          }
        }
      } else if (response.statusCode == 520) {
        //  progressDialog.dismiss();
        // Scenario with status code 520
        // Show the response body as a toast
        Commonutils.showCustomToastMessageLong(
            '${response.body}', context, 0, 3);
      } else {
        /// progressDialog.dismiss();
        // Handle other status codes if needed
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sendLeaveRequest(
      bool confirmedToSplitWFH, String fromdate, String todate) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
    } else {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }
    print('====>$selectedleaveName');
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime!);
    // Replace this with your actual login time
    DateTime loginTime = formattedlogintime /* Replace with your login time */;

    // Calculate the time difference
    Duration timeDifference = currentTime.difference(loginTime);

    // Check if the time difference is less than or equal to 1 hour (3600 seconds)
    if (timeDifference.inSeconds <= 3600) {
      // Login is within the allowed window

      print("Login is within 1 hour of current time.");
    } else {
      // Login is outside the allowed window
      // _showtimeoutdialog(context);
      print("Login is more than 1 hour from current time.");
    }
    //if (isValid) {
    isLoading = true;
    try {
      final url = Uri.parse(baseUrl + applyleaveapi);
      print('ApplyLeaveUrl: $url');
      final request = {
        "EmployeeId": empolyeid,
        "FromDate": fromdate,
        "ToDate": todate,
        "LeaveTypeId": '${widget.lookupDetailId}',
        "Note": _leavetext.text,
        "AcceptedBy": null,
        "AcceptedAt": null,
        "ApprovedBy": null,
        "ApprovedAt": null,
        "Rejected": null,
        "Comments": null,
        "IsApprovalEscalated": null,
        //"URL": "http://hrms.calibrage.in:/", // In development stage change url to this http://182.18.157.215:/
        // "URL": "https://hrms.calibrage.in:/", // Live
        "URL":
            "http://182.18.157.215:/", // In development stage change url to this http://182.18.157.215:/
        "EmployeeName": "${widget.employename}",
        // "getLeaveType": null,
        if (widget.buttonName == "test") ...{
          "GetLeaveType": "$selectedleaveName",
        } else ...{
          "GetLeaveType": "${widget.buttonName}",
        },
        "IsHalfDayLeave": isChecked,
        "LeaveReasonId": selectedValue,
        "IsFromAttendance": false,
        "confirmedToSplitWFH": confirmedToSplitWFH,
        if (widget.buttonName == "test") ...{
          "LeaveTypeId": selectedleaveValue,
          "LeaveReasonId": selectedleaveValue,
          //   if (selectedleaveName == "WFH")
          //     "leaveReasonId": selectedValue
        }
        // },
      };

      // final headers = {
      //   'Authorization': '$accessToken',
      // };
      // Map<String, String> _header = {
      //   'Authorization': '$accessToken',
      // };
      // String at = accessToken;
      // print('Request Headers: $_header');
      print('Request Body: ${json.encode(request)}');

      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );
      //  print('access: $at');
      // if (response.body == "Server errorNullable object must have a value.") {
      //   Commonutils.showCustomToastMessageLong(
      //       'Leave Applied', context, 0, 3);
      // }
      print('Applyresponse: ${response.body}');
      //  ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      //  progressDialog.show();
      // Parse the JSON response

      // // Access the value of isSuccess
      // bool isSuccess = responseMap['isSuccess'];
      // dynamic message = responseMap['message'];
      // String messageresponse = message != null ? message.toString() : "No message provided";

      // Access the value of isSuccess

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = json.decode(response.body);

        if (responseMap.containsKey('isSuccess')) {
          bool isSuccess = responseMap['isSuccess'];
          if (isSuccess == true) {
            isLoading = false;
            print('response is success');
            //   progressDialog.dismiss();
            disableButton();
            if (selectedleaveName == "WFH") {
              Commonutils.showCustomToastMessageLong(
                  'Successfully WFH has Applied', context, 0, 3);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => home_screen()),
              );
            } else {
              Commonutils.showCustomToastMessageLong(
                  'Successfully Leave has Applied', context, 0, 3);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => home_screen()),
              );
            }
          } else {
            Commonutils.showCustomToastMessageLong(
                '${responseMap['message']}', context, 1, 4);
            print('Apply Leave Failed: ${response.body}');
          }
        } else {
          if (response.body.toLowerCase().contains('invalid token')) {
            // Invalid token scenario
            Commonutils.showCustomToastMessageLong(
                'Invalid Token. Please Login Again.', context, 1, 4);
          } else {
            // Other scenarios with success status code
            // Handle as needed, for example, showing the response message
            String message = responseMap['message'] ?? 'No message provided';
            Commonutils.showCustomToastMessageLong(
                '${response.body}', context, 0, 3);
          }
        }
      } else if (response.statusCode == 520) {
        // Scenario with status code 520
        // Show the response body as a toast
        Commonutils.showCustomToastMessageLong(
            '${response.body}', context, 0, 3);
      } else {
        // Handle other status codes if needed
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }

      // if (isSuccess == true) {
      //   isLoading = false;
      //   print('response is success');
      //
      //   disableButton();
      //   if (selectedleaveName == "WFH") {
      //     Commonutils.showCustomToastMessageLong('Successfully WFH has Applied', context, 0, 3);
      //     Navigator.of(context).pushReplacement(
      //       MaterialPageRoute(builder: (context) => home_screen()),
      //     );
      //   } else {
      //     Commonutils.showCustomToastMessageLong('Successfully Leave has Applied', context, 0, 3);
      //     Navigator.of(context).pushReplacement(
      //       MaterialPageRoute(builder: (context) => home_screen()),
      //     );
      //   }
      // } else {
      //   // Commonutils.showCustomToastMessageLong(' ${messageresponse}', context, 1, 5);
      //
      //   print('response is not success');
      //   Commonutils.showCustomToastMessageLong('${response.body}', context, 0, 3);
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => home_screen()),
      //   );
      //   print('Failed to send the request. Status code: ${response.statusCode}');
      // }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    //  }
  }

//MARK: Pending cl status
  void ShowforCLdialog(BuildContext context, String formattedMonth,
      String formattedDate, DateTime clFromDate, Function(bool) _callback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Confirmation",
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Calibri',
              color: Color(0xFFf15f22),
            ),
          ),
          content: Text(
            "Kindly confirm whether you wish to retract the previously submitted leave for the month of ${formattedMonth} on this '${formattedDate}', which has not yet approved. Please click 'Confirm' to proceed with the reversion or 'Cancel' to maintain the current application status.",
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Calibri',
              color: Colors.black,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                //    Navigator.of(context, rootNavigator: true).pop(context);
                // applyclleaveapi(clFromDate!,selectedDate!);
                _callback(true);
                Navigator.of(context).pop();
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Calibri'), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                    0xFFf15f22), // Change to your desired background color
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
                Navigator.of(context).pop();
                _callback(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Calibri'), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                    0xFFf15f22), // Change to your desired background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Set border radius
                ),
              ),
            ),
          ],
        );
      },
    );
    return;
  }

  bool Validations() {
    if (widget.buttonName == "test") if (selectedleaveValue == -1) {
      Commonutils.showCustomToastMessageLong(
          'Please Select Leave Type', context, 1, 4);
      isLoading = false;
      return false;
    }

    if (widget.buttonName == "CL" || selectedleaveName == "CL") {
      if (selectedValue == 0) {
        Commonutils.showCustomToastMessageLong(
            'Please Select Leave Reason', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_fromdateController.text.isEmpty && selectedDate == null) {
        Commonutils.showCustomToastMessageLong(
            'Please Select From Date', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_leavetext.text.trim().isEmpty) {
        Commonutils.showCustomToastMessageLong(
            'Please Enter the Leave Reason Description', context, 1, 4);
        isLoading = false;
        return false;
      }
      if (availablecls <= 0.0) {
        Commonutils.showCustomToastMessageLong(
            'No CLs Available ', context, 1, 6);
        isLoading = false;
        fromDateSelected = false;
        _fromdateController.clear();
        _todateController.clear();
        selectedToDate = null;
        selectedDate = null;
        return false;
      }
    }

    if (widget.buttonName == "PL" || selectedleaveName == "PL") {
      if (selectedValue == 0) {
        Commonutils.showCustomToastMessageLong(
            'Please Select Leave Reason', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_fromdateController.text.isEmpty && selectedDate == null) {
        Commonutils.showCustomToastMessageLong(
            'Please Select From Date', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_leavetext.text.trim().isEmpty) {
        Commonutils.showCustomToastMessageLong(
            'Please Enter the Leave Reason Description', context, 1, 4);
        isLoading = false;
        return false;
      }

      String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String? todate = null;

      if (selectedToDate != null) {
        if (isChecked)
          todate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        else if (selectedToDate != null)
          todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
      } else {
        setState(() {
          selectedToDate = selectedDate!;
          todate = fromdate;
        });
      }

      if (!isChecked) {
        if (todate != null) {
          if (todate!.compareTo(fromdate) < 0) {
            Commonutils.showCustomToastMessageLong(
                "To Date is less than From Date", context, 1, 5);
            isLoading = false;
            return false;
          }
        }
      }

      if (availablepls <= 0.0) {
        Commonutils.showCustomToastMessageLong(
            'No PLs Available ', context, 1, 6);
        fromDateSelected = false;
        _fromdateController.clear();
        _todateController.clear();
        selectedToDate = null;
        selectedDate = null;
        isLoading = false;
        return false;
      }
    }

    if (selectedleaveName == "LWP") {
      if (_fromdateController.text.isEmpty && selectedDate == null) {
        Commonutils.showCustomToastMessageLong(
            'Please Select From Date', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_leavetext.text.trim().isEmpty) {
        Commonutils.showCustomToastMessageLong(
            'Please Enter the Leave Reason Description', context, 1, 4);
        isLoading = false;
        return false;
      }

      String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String? todate = null;

      if (selectedToDate != null) {
        if (isChecked)
          todate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        else if (selectedToDate != null)
          todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
      } else {
        setState(() {
          selectedToDate = selectedDate!;
          todate = fromdate;
        });
      }

      if (todate != null) {
        if (todate!.compareTo(fromdate) < 0) {
          Commonutils.showCustomToastMessageLong(
              "To Date is less than From Date", context, 1, 5);
          isLoading = false;
          return false;
        }
      }
    }

    if (selectedleaveName == "WFH") {
      if (_fromdateController.text.isEmpty && selectedDate == null) {
        Commonutils.showCustomToastMessageLong(
            'Please Select From Date', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_leavetext.text.trim().isEmpty) {
        Commonutils.showCustomToastMessageLong(
            'Please Enter the Leave Reason Description', context, 1, 4);
        isLoading = false;
        return false;
      }

      String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String? todate = null;

      if (selectedToDate != null) {
        if (isChecked)
          todate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        else if (selectedToDate != null)
          todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
      } else {
        setState(() {
          selectedToDate = selectedDate!;
          todate = fromdate;
        });
      }

      if (todate != null) {
        if (todate!.compareTo(fromdate) < 0) {
          Commonutils.showCustomToastMessageLong(
              "To Date is less than From Date", context, 1, 5);
          isLoading = false;
          return false;
        }
      }
    }

    if (selectedleaveName == "LL") {
      // if (_fromdateController.text.isEmpty && selectedDate == null) {
      //   Commonutils.showCustomToastMessageLong('Please Select From Date', context, 1, 4);
      //   isLoading = false;
      //   return false;
      // }
      if (_fromdateController.text.isEmpty && selectedDate == null) {
        if (fromDateSelected == false) {
          Commonutils.showCustomToastMessageLong(
              'Please Select From Date', context, 1, 4);
          isLoading = false;
          return false;
        }
      }
      if (_todateController.text.isEmpty && selectedToDate == null) {
        Commonutils.showCustomToastMessageLong(
            'Please Select To Date', context, 1, 4);
        isLoading = false;
        return false;
      }

      if (_leavetext.text.trim().isEmpty) {
        Commonutils.showCustomToastMessageLong(
            'Please Enter the Leave Reason Description', context, 1, 4);
        isLoading = false;
        return false;
      }

      String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      String? todate = null;

      if (selectedToDate != null) {
        if (isChecked)
          todate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        else if (selectedToDate != null)
          todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);
      } else {
        setState(() {
          selectedToDate = selectedDate!;
          todate = fromdate;
        });
      }

      if (todate != null) {
        if (todate!.compareTo(fromdate) < 0) {
          Commonutils.showCustomToastMessageLong(
              "To Date is less than From Date", context, 1, 5);
          isLoading = false;
          return false;
        }
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (ismatchedlogin) {
      Future.microtask(() => _showtimeoutdialog(context));
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => home_screen()),
        ); // Navigate to the previous screen
        setState(() {
          fromDateSelected = false;
        });
        return false; // Prevent default back navigation behavior
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFf15f22),
            title: Text(
              'HRMS',
              style: TextStyle(color: Colors.white, fontFamily: 'Calibri'),
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
                setState(() {
                  fromDateSelected = false;
                });
              },
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background_layer_2.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Content inside a SingleChildScrollView
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Leave Request',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFFf15f22),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Calibri',
                          ),
                        ),
                      ),
                      if (widget.buttonName == "CL" ||
                          widget.buttonName == "PL")
                        Padding(
                          padding:
                              EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: Color(0xFFf15f22),
                                width: 1.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Text(
                              "${widget.buttonName}",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Calibri',
                              ),
                            ),
                          ),
                        ),
                      if (widget.buttonName == "test")
                        Padding(
                          padding:
                              EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFf15f22), width: 1.5),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white, // Add white background color
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: lookupDetails.length == 0
                                    ? LoadingAnimationWidget.fourRotatingDots(
                                        color: Colors.blue,
                                        size: 40.0,
                                      )
                                    : DropdownButton<int>(
                                        value: selectedleaveValue,
                                        iconSize: 30,
                                        icon: null,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Calibri',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            fromDateSelected = false;
                                            _fromdateController.clear();
                                            _todateController.clear();
                                            selectedToDate = null;
                                            selectedDate = null;
                                            selectedValue = 0;
                                            print(
                                                '_onchangedfromdateController==$_fromdateController');
                                            print(
                                                '_onchangedtodateController==$_todateController');
                                            print(
                                                'onchangedselectedToDate==$selectedToDate');

                                            if (value == -1) {
                                              // Reset the selected value to -1 to show hint text again
                                              setState(() {
                                                fromDateSelected = false;
                                                _fromdateController.clear();
                                                _todateController.clear();
                                                selectedToDate = null;
                                                selectedDate = null;
                                                selectedleaveTypeId = -1;
                                                selectedleaveValue = -1;
                                              });
                                              print(
                                                  'selectedleave==$selectedleaveValue');
                                              // Clear any related variables or text controllers here if needed
                                            } else {
                                              setState(() {
                                                fromDateSelected = false;
                                                _fromdateController.clear();
                                                _todateController.clear();
                                                selectedToDate = null;
                                                selectedDate = null;

                                                print(
                                                    '_onselectedfromdateController==$_fromdateController');
                                                print(
                                                    '_onselectedtodateController==$_todateController');
                                                print(
                                                    'onselectedselectedToDate==$selectedToDate');
                                              });

                                              selectedleaveTypeId = value!;
                                              print(
                                                  'selectedleaveTypeId==$selectedleaveTypeId');
                                              if (selectedleaveTypeId != -1) {
                                                isChecked = false;
                                                LookupDetail selectedDetail =
                                                    lookupDetails.firstWhere(
                                                        (item) =>
                                                            item.lookupDetailId ==
                                                            selectedleaveTypeId);
                                                print(
                                                    "selectedDetail$selectedDetail");
                                                selectedleaveValue =
                                                    selectedDetail
                                                        .lookupDetailId;
                                                selectedleaveName =
                                                    selectedDetail.name;
                                                selectedTypeCdId = -1;
                                                _fromdateController.clear();
                                                _todateController.clear();

                                                _leavetext.clear();
                                                print(
                                                    "selectedleaveValue==========>$selectedleaveValue");
                                                print(
                                                    "selectedleaveName: $selectedleaveName");
                                                getleavereasontype(
                                                    Leavereasonlookupid,
                                                    selectedleaveValue);
                                              }
                                            }
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem<int>(
                                            value: -1,
                                            child: Text(defaultButtonName),
                                          ),
                                          for (LookupDetail item
                                              in lookupDetails)
                                            if (['WFH', 'LWP', 'LL']
                                                    .contains(item.name) ||
                                                (item.name == 'CL' &&
                                                    availablecls != 0.0) ||
                                                (item.name == 'PL' &&
                                                    availablepls != 0.0))
                                              leaveTypeDropdown(item),
                                          /*  DropdownMenuItem<int>(
                                                value: item.lookupDetailId,
                                                child: Text(item.name),
                                              ), */
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.buttonName == "CL" ||
                          widget.buttonName == "PL" ||
                          selectedleaveName == "CL" ||
                          selectedleaveName == "PL")
                        Padding(
                          padding:
                              EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFf15f22), width: 1.5),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: dropdownItems.length == 0
                                    ? LoadingAnimationWidget.fourRotatingDots(
                                        color: Colors.blue,
                                        size: 40.0,
                                      )
                                    : DropdownButton<int>(
                                        value: selectedTypeCdId,
                                        iconSize: 30,
                                        icon: null,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Calibri',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedTypeCdId = value!;
                                            print(
                                                'selectedTypeCdId==$selectedTypeCdId');
                                            if (selectedTypeCdId != -1) {
                                              selectedValue = dropdownItems[
                                                      selectedTypeCdId]
                                                  ['lookupDetailId'];
                                              selectedName = dropdownItems[
                                                  selectedTypeCdId]['name'];

                                              print(
                                                  "selectedValue$selectedValue");
                                              print(selectedName);
                                            } else {
                                              print("==========");
                                              print(selectedValue);
                                              print(selectedName);
                                            }
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem<int>(
                                            value: -1,
                                            child: Text('Select Leave Reason'),
                                          ),
                                          ...dropdownItems
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final item = entry.value;
                                            return DropdownMenuItem<int>(
                                              value: index,
                                              child: Text(
                                                item['name'],
                                                style: TextStyle(
                                                    fontFamily: 'Calibri'),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.buttonName == "CL" ||
                          widget.buttonName == "PL" ||
                          selectedleaveName == "CL" ||
                          selectedleaveName == "PL")
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, top: 10.0, right: 0),
                          child: Row(
                            children: [
                              Text(
                                'Is Halfday Leave?',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFf15f22),
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(width: 6),
                              Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value ??
                                        false; // Use the null-aware operator to handle null values
                                    print('isChecked=== ${isChecked}');
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      //MARK: From Date
                      Padding(
                        padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                        child: GestureDetector(
                          onTap: () async {
                            // setState(() {
                            //   fromDateSelected = true;
                            // });
                            _selectDate(isTodayHoliday);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFf15f22), width: 1.5),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white, // Add white background color
                            ),
                            child: AbsorbPointer(
                              child: SizedBox(
                                child: TextFormField(
                                  controller: _fromdateController,
                                  style: TextStyle(
                                    fontFamily: 'Calibri',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'From Date',
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri',
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 15.0),
                                    // Adjust padding as needed
                                    suffixIcon: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.calendar_today,
                                        // Replace with your desired icon
                                        color: Colors.black54,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                        child: Visibility(
                          visible: !isChecked &&
                              (widget.buttonName != "CL" &&
                                  selectedleaveName != "CL"),
                          child: GestureDetector(
                            onTap: () async {
                              // if (widget.buttonName == "LL" || selectedleaveName == "LL") {
                              //   _selectToCLDate();
                              // } else {
                              //   _selectToDate();
                              // }

                              if (fromDateSelected) {
                                if (widget.buttonName == "CL" ||
                                    selectedleaveName == "CL") {
                                  _selectToCLDate();
                                } else {
                                  _selectToDate();
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color:
                                    Colors.white, // Add white background color
                              ),
                              child: AbsorbPointer(
                                child: SizedBox(
                                  child: TextFormField(
                                    controller: _todateController,
                                    enabled: !isChecked && fromDateSelected,
                                    style: const TextStyle(
                                      fontFamily: 'Calibri',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'To Date',
                                      hintStyle: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                      // contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 15.0),
                                      // Adjust padding as needed
                                      suffixIcon: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.calendar_today,
                                          // Replace with your desired icon
                                          color: Colors.black54,
                                        ),
                                      ),
                                      /*  border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ), */
                                      filled: true,
                                      fillColor: !isChecked && fromDateSelected
                                          ? Colors.white
                                          : Colors.grey[
                                              300], // Add this line to change background color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            /* 
                             Container(
                              width: MediaQuery.of(context).size.width,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color:
                                    Colors.white, // Add white background color
                              ),
                              child: AbsorbPointer(
                                child: SizedBox(
                                  child: TextFormField(
                                    controller: _todateController,
                                    enabled: !isChecked && fromDateSelected,
                                    style: TextStyle(
                                      fontFamily: 'Calibri',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintText: 'To Date',
                                      hintStyle: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                      // contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 15.0),
                                      // Adjust padding as needed
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.calendar_today,
                                          // Replace with your desired icon
                                          color: Colors.black54,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: !isChecked && fromDateSelected
                                          ? Colors.white
                                          : Colors.grey[
                                              300], // Add this line to change background color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                       */
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                        child: GestureDetector(
                          onTap: () async {
                            if (!_focusNode.hasFocus) {
                              _focusNode.requestFocus();
                            }
                          },
                          child: Container(
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFf15f22), width: 1.5),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: [
                                TextFormField(
                                  focusNode: _focusNode,
                                  controller: _leavetext,
                                  style: TextStyle(
                                    fontFamily: 'Calibri',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  maxLines: null,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.startsWith(' ')) {
                                        _leavetext.value = TextEditingValue(
                                          text: value.trimLeft(),
                                          selection: TextSelection.collapsed(
                                              offset: value.trimLeft().length),
                                        );
                                      }
                                      if (value.length > 256) {
                                        // Trim the text if it exceeds 256 characters
                                        _leavetext.value = TextEditingValue(
                                          text: value.substring(0, 256),
                                          selection: TextSelection.collapsed(
                                              offset: 256),
                                        );
                                      }
                                    }); // Update the UI when text changes
                                  },
                                  decoration: InputDecoration(
                                    hintText: hintText,
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri',
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8.0,
                                  right: 8.0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    // decoration: BoxDecoration(
                                    //   color: Colors.black.withOpacity(0.6),
                                    //   borderRadius: BorderRadius.circular(4.0),
                                    // ),
                                    child: Text(
                                      '${_leavetext.text.length}/${_leavetext.text.length > 256 ? 256 : 256}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFf15f22),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    print('clickedonaddleave');
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (Validations()) {
                                      checkLeavesAllocation(
                                              _fromdateController.text.trim(),
                                              selectedleaveValue)
                                          .then((int value) {
                                        /*  if (value) {
                                          applyleave();
                                        } else {
                                          Commonutils
                                              .showCustomToastMessageLong(
                                                  Constants.plErrorMessage,
                                                  context,
                                                  1,
                                                  3);
                                        } */
                                        print('statusCode: $value');

                                        switch (value) {
                                          case 102:
                                            Commonutils.showCustomToastMessageLong(
                                                'Please ensure the start and end dates fall within the same year',
                                                // 'Years must be same while applying a leave',
                                                context,
                                                1,
                                                3);
                                            break;
                                          case 200:
                                            applyleave();
                                            break;
                                          case 400:
                                            Commonutils
                                                .showCustomToastMessageLong(
                                                    Constants
                                                        .plErrorMessage, // Constants.plErrorMessage
                                                    context,
                                                    1,
                                                    3);
                                            break;
                                          case 500:
                                            Commonutils.showCustomToastMessageLong(
                                                'Something went wrong, please try again', // Constants.plErrorMessage
                                                context,
                                                1,
                                                3);
                                            break;
                                        }
                                      });
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            child: const Text(
                              'Add Leave',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Calibri'),
                            ),
                          ),
                        ),
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

  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //       onWillPop: () async {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => home_screen()),
  //         ); // Navigate to the previous screen
  //         return true; // Prevent default back navigation behavior
  //       },
  //       child: MaterialApp(
  //         debugShowCheckedModeBanner: false,
  //         home: Scaffold(
  //           appBar: AppBar(
  //             elevation: 0,
  //             backgroundColor: Color(0xFFf15f22),
  //             title: Text(
  //               'HRMS',
  //               style: TextStyle(color: Colors.white, fontFamily: 'Calibri'),
  //             ),
  //             centerTitle: true,
  //             leading: IconButton(
  //               icon: Icon(
  //                 Icons.arrow_back,
  //                 color: Colors.white,
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pushReplacement(
  //                   MaterialPageRoute(builder: (context) => home_screen()),
  //                 );
  //               },
  //             ),
  //           ),
  //           body: Stack(
  //             children: [
  //               // Background Image
  //               Container(
  //                 decoration: BoxDecoration(
  //                   image: DecorationImage(
  //                     image: AssetImage("assets/background_layer_2.png"),
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //               ),
  //               // Content inside a SingleChildScrollView
  //               SingleChildScrollView(
  //                 child: Container(
  //                   padding: EdgeInsets.all(16.0),
  //                   child: Column(
  //                     children: [
  //                       Container(
  //                         padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                         width: MediaQuery.of(context).size.width,
  //                         // height: MediaQuery.of(context).size.height,
  //                         child: Text(
  //                           'Leave Request',
  //                           style: TextStyle(
  //                             fontSize: 24,
  //                             color: Color(0xFFf15f22),
  //                             fontWeight: FontWeight.w500,
  //                             fontFamily: 'Calibri',
  //                           ),
  //                         ),
  //                       ),
  //                       if (widget.buttonName == "CL" || widget.buttonName == "PL")
  //                         Padding(
  //                           padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                           child: Container(
  //                             padding: EdgeInsets.all(15.0),
  //                             width: MediaQuery.of(context).size.width,
  //                             decoration: BoxDecoration(
  //                               borderRadius: BorderRadius.circular(5.0),
  //                               border: Border.all(
  //                                 color: Color(0xFFf15f22),
  //                                 width: 1.5,
  //                               ),
  //                               color: Colors.white,
  //                             ),
  //                             child: Text(
  //                               "${widget.buttonName}",
  //                               style: TextStyle(
  //                                 color: Colors.black54,
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontFamily: 'Calibri',
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       if (widget.buttonName == "test")
  //                         Padding(
  //                           padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                           child: Container(
  //                             width: MediaQuery.of(context).size.width,
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: Color(0xFFf15f22), width: 1.5),
  //                               borderRadius: BorderRadius.circular(5.0),
  //                               color: Colors.white, // Add white background color
  //                             ),
  //                             child: DropdownButtonHideUnderline(
  //                               child: ButtonTheme(
  //                                 alignedDropdown: true,
  //                                 child: lookupDetails.length == 0
  //                                     ? LoadingAnimationWidget.fourRotatingDots(
  //                                         color: Colors.blue,
  //                                         size: 40.0,
  //                                       )
  //                                     : DropdownButton<int>(
  //                                         value: selectedleaveValue,
  //                                         iconSize: 30,
  //                                         icon: null,
  //                                         style: TextStyle(
  //                                           color: Colors.black54,
  //                                           fontWeight: FontWeight.bold,
  //                                           fontFamily: 'Calibri',
  //                                         ),
  //                                         onChanged: (value) {
  //                                           setState(() {
  //                                             if (value == -1) {
  //                                               // Reset the selected value to -1 to show hint text again
  //
  //                                               setState(() {
  //                                                 selectedleaveTypeId = -1;
  //                                                 selectedleaveValue = -1;
  //                                               });
  //                                               print('selectedleave==$selectedleaveValue');
  //                                               // Clear any related variables or text controllers here if needed
  //                                             } else {
  //                                               selectedleaveTypeId = value!;
  //                                               print('selectedleaveTypeId==$selectedleaveTypeId');
  //                                               if (selectedleaveTypeId != -1) {
  //                                                 isChecked = false;
  //                                                 LookupDetail selectedDetail =
  //                                                     lookupDetails.firstWhere((item) => item.lookupDetailId == selectedleaveTypeId);
  //                                                 print("selectedDetail$selectedDetail");
  //                                                 selectedleaveValue = selectedDetail.lookupDetailId;
  //                                                 selectedleaveName = selectedDetail.name;
  //                                                 selectedTypeCdId = -1;
  //                                                 _fromdateController.clear();
  //                                                 _todateController.clear();
  //
  //                                                 _leavetext.clear();
  //                                                 print("selectedleaveValue==========>$selectedleaveValue");
  //                                                 print("selectedleaveName: $selectedleaveName");
  //                                                 getleavereasontype(Leavereasonlookupid, selectedleaveValue);
  //                                               }
  //                                             }
  //                                           });
  //                                         },
  //                                         items: [
  //                                           DropdownMenuItem<int>(
  //                                             value: -1,
  //                                             child: Text(defaultButtonName),
  //                                           ),
  //                                           for (LookupDetail item in lookupDetails)
  //                                             if (['CL', 'PL', 'WFH', 'LWP', 'LL'].contains(item.name))
  //                                               DropdownMenuItem<int>(
  //                                                 value: item.lookupDetailId,
  //                                                 child: Text(item.name),
  //                                               ),
  //                                         ],
  //                                       ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL")
  //                         Padding(
  //                           padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                           child: Container(
  //                             width: MediaQuery.of(context).size.width,
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: Color(0xFFf15f22), width: 1.5),
  //                               borderRadius: BorderRadius.circular(5.0),
  //                               color: Colors.white,
  //                             ),
  //                             child: DropdownButtonHideUnderline(
  //                               child: ButtonTheme(
  //                                 alignedDropdown: true,
  //                                 child: dropdownItems.length == 0
  //                                     ? LoadingAnimationWidget.fourRotatingDots(
  //                                         color: Colors.blue,
  //                                         size: 40.0,
  //                                       )
  //                                     : DropdownButton<int>(
  //                                         value: selectedTypeCdId,
  //                                         iconSize: 30,
  //                                         icon: null,
  //                                         style: TextStyle(
  //                                           color: Colors.black54,
  //                                           fontWeight: FontWeight.bold,
  //                                           fontFamily: 'Calibri',
  //                                         ),
  //                                         onChanged: (value) {
  //                                           setState(() {
  //                                             selectedTypeCdId = value!;
  //                                             print('selectedTypeCdId==$selectedTypeCdId');
  //                                             if (selectedTypeCdId != -1) {
  //                                               selectedValue = dropdownItems[selectedTypeCdId]['lookupDetailId'];
  //                                               selectedName = dropdownItems[selectedTypeCdId]['name'];
  //
  //                                               print("selectedValue$selectedValue");
  //                                               print(selectedName);
  //                                             } else {
  //                                               print("==========");
  //                                               print(selectedValue);
  //                                               print(selectedName);
  //                                             }
  //                                           });
  //                                         },
  //                                         items: [
  //                                           DropdownMenuItem<int>(
  //                                             value: -1,
  //                                             child: Text('Select Leave Reason'),
  //                                           ),
  //                                           ...dropdownItems.asMap().entries.map((entry) {
  //                                             final index = entry.key;
  //                                             final item = entry.value;
  //                                             return DropdownMenuItem<int>(
  //                                               value: index,
  //                                               child: Text(
  //                                                 item['name'],
  //                                                 style: TextStyle(fontFamily: 'Calibri'),
  //                                               ),
  //                                             );
  //                                           }).toList(),
  //                                         ],
  //                                       ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       // Visibility(
  //                       //   visible: (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL"),
  //                       //   child: Padding(
  //                       //     padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                       //     child: Container(
  //                       //       width: MediaQuery.of(context).size.width,
  //                       //       decoration: BoxDecoration(
  //                       //         border: Border.all(color: Color(0xFFf15f22), width: 1.5),
  //                       //         borderRadius: BorderRadius.circular(5.0),
  //                       //         color: Colors.white,
  //                       //       ),
  //                       //       child: DropdownButtonHideUnderline(
  //                       //         child: ButtonTheme(
  //                       //           alignedDropdown: true,
  //                       //           child: DropdownButton<int>(
  //                       //             value: selectedTypeCdId,
  //                       //             iconSize: 30,
  //                       //             icon: null,
  //                       //             style: TextStyle(
  //                       //               color: Colors.black54,
  //                       //               fontWeight: FontWeight.bold,
  //                       //               fontFamily: 'Calibri',
  //                       //             ),
  //                       //             onChanged: (value) {
  //                       //               setState(() {
  //                       //                 selectedTypeCdId = value!;
  //                       //                 print('selectedTypeCdId==$selectedTypeCdId');
  //                       //                 if (selectedTypeCdId != -1) {
  //                       //                   selectedValue = dropdownItems[selectedTypeCdId]['lookupDetailId'];
  //                       //                   selectedName = dropdownItems[selectedTypeCdId]['name'];
  //                       //
  //                       //                   print("selectedValue$selectedValue");
  //                       //                   print(selectedName);
  //                       //                 } else {
  //                       //                   print("==========");
  //                       //                   print(selectedValue);
  //                       //                   print(selectedName);
  //                       //                 }
  //                       //                 if (selectedleaveName == 'WFH') {
  //                       //                   hintText = 'Reason For WFH';
  //                       //                 } else {
  //                       //                   hintText;
  //                       //                 }
  //                       //               });
  //                       //             },
  //                       //             items: [
  //                       //               DropdownMenuItem<int>(
  //                       //                 value: -1,
  //                       //                 child: Text('Select Leave Reason'),
  //                       //               ),
  //                       //               ...dropdownItems.asMap().entries.map((entry) {
  //                       //                 final index = entry.key;
  //                       //                 final item = entry.value;
  //                       //                 return DropdownMenuItem<int>(
  //                       //                   value: index,
  //                       //                   child: Text(
  //                       //                     item['name'],
  //                       //                     style: TextStyle(fontFamily: 'Calibri'),
  //                       //                   ),
  //                       //                 );
  //                       //               }).toList(),
  //                       //             ],
  //                       //           ),
  //                       //         ),
  //                       //       ),
  //                       //     ),
  //                       //   ),
  //                       // ),
  //
  //                       if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL")
  //                         Padding(
  //                           padding: EdgeInsets.only(left: 10, top: 10.0, right: 0),
  //                           child: Row(
  //                             children: [
  //                               Text(
  //                                 'Is Halfday Leave?',
  //                                 style: TextStyle(fontSize: 14, color: Color(0xFFf15f22), fontFamily: 'Calibri', fontWeight: FontWeight.w500),
  //                               ),
  //                               SizedBox(width: 6),
  //                               Checkbox(
  //                                 value: isChecked,
  //                                 onChanged: (bool? value) {
  //                                   setState(() {
  //                                     isChecked = value ?? false; // Use the null-aware operator to handle null values
  //                                     print('isChecked=== ${isChecked}');
  //                                   });
  //                                 },
  //                                 activeColor: Colors.green,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                         child: GestureDetector(
  //                           onTap: () async {
  //                             _selectDate(isTodayHoliday);
  //                           },
  //                           child: Container(
  //                             width: MediaQuery.of(context).size.width,
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: Color(0xFFf15f22), width: 1.5),
  //                               borderRadius: BorderRadius.circular(5.0),
  //                               color: Colors.white, // Add white background color
  //                             ),
  //                             child: AbsorbPointer(
  //                               child: SizedBox(
  //                                 child: TextFormField(
  //                                   controller: _fromdateController,
  //                                   style: TextStyle(
  //                                     fontFamily: 'Calibri',
  //                                     fontSize: 14,
  //                                     fontWeight: FontWeight.w300,
  //                                   ),
  //                                   decoration: InputDecoration(
  //                                     hintText: 'From Date',
  //                                     hintStyle: TextStyle(
  //                                       color: Colors.black54,
  //                                       fontSize: 14,
  //                                       fontWeight: FontWeight.bold,
  //                                       fontFamily: 'Calibri',
  //                                     ),
  //                                     contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  //                                     // Adjust padding as needed
  //                                     suffixIcon: Padding(
  //                                       padding: EdgeInsets.all(8.0),
  //                                       child: Icon(
  //                                         Icons.calendar_today,
  //                                         // Replace with your desired icon
  //                                         color: Colors.black54,
  //                                       ),
  //                                     ),
  //                                     border: InputBorder.none,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                         child: Visibility(
  //                           visible: !isChecked && (widget.buttonName != "CL" && selectedleaveName != "CL"),
  //                           child: GestureDetector(
  //                             onTap: () async {
  //                               // if (widget.buttonName == "LL" || selectedleaveName == "LL") {
  //                               //   _selectToCLDate();
  //                               // } else {
  //                               //   _selectToDate();
  //                               // }
  //                               if (widget.buttonName == "CL" || selectedleaveName == "CL") {
  //                                 _selectToCLDate();
  //                               } else {
  //                                 _selectToDate();
  //                               }
  //                             },
  //                             child: Container(
  //                               width: MediaQuery.of(context).size.width,
  //                               decoration: BoxDecoration(
  //                                 border: Border.all(color: Color(0xFFf15f22), width: 1.5),
  //                                 borderRadius: BorderRadius.circular(5.0),
  //                                 color: Colors.white, // Add white background color
  //                               ),
  //                               child: AbsorbPointer(
  //                                 child: SizedBox(
  //                                   child: TextFormField(
  //                                     controller: _todateController,
  //                                     enabled: !isChecked,
  //                                     style: TextStyle(
  //                                       fontFamily: 'Calibri',
  //                                       fontSize: 14,
  //                                       fontWeight: FontWeight.w300,
  //                                     ),
  //                                     decoration: InputDecoration(
  //                                       hintText: 'To Date',
  //                                       hintStyle: TextStyle(
  //                                         color: Colors.black54,
  //                                         fontSize: 14,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontFamily: 'Calibri',
  //                                       ),
  //                                       contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  //                                       // Adjust padding as needed
  //                                       suffixIcon: Padding(
  //                                         padding: EdgeInsets.all(8.0),
  //                                         child: Icon(
  //                                           Icons.calendar_today,
  //                                           // Replace with your desired icon
  //                                           color: Colors.black54,
  //                                         ),
  //                                       ),
  //                                       border: InputBorder.none,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
  //                         child: GestureDetector(
  //                           onTap: () async {
  //                             if (!_focusNode.hasFocus) {
  //                               _focusNode.requestFocus();
  //                             }
  //                           },
  //                           child: Container(
  //                             height: 180,
  //                             width: MediaQuery.of(context).size.width,
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: Color(0xFFf15f22), width: 1.5),
  //                               borderRadius: BorderRadius.circular(5.0),
  //                               color: Colors.white,
  //                             ),
  //                             child: Stack(
  //                               children: [
  //                                 TextFormField(
  //                                   focusNode: _focusNode,
  //                                   controller: _leavetext,
  //                                   style: TextStyle(
  //                                     fontFamily: 'Calibri',
  //                                     fontSize: 14,
  //                                     fontWeight: FontWeight.w300,
  //                                   ),
  //                                   maxLines: null,
  //                                   onChanged: (value) {
  //                                     setState(() {
  //                                       if (value.startsWith(' ')) {
  //                                         _leavetext.value = TextEditingValue(
  //                                           text: value.trimLeft(),
  //                                           selection: TextSelection.collapsed(offset: value.trimLeft().length),
  //                                         );
  //                                       }
  //                                       if (value.length > 256) {
  //                                         // Trim the text if it exceeds 256 characters
  //                                         _leavetext.value = TextEditingValue(
  //                                           text: value.substring(0, 256),
  //                                           selection: TextSelection.collapsed(offset: 256),
  //                                         );
  //                                       }
  //                                     }); // Update the UI when text changes
  //                                   },
  //                                   decoration: InputDecoration(
  //                                     hintText: hintText,
  //                                     hintStyle: TextStyle(
  //                                       color: Colors.black54,
  //                                       fontSize: 14,
  //                                       fontWeight: FontWeight.bold,
  //                                       fontFamily: 'Calibri',
  //                                     ),
  //                                     contentPadding: EdgeInsets.symmetric(
  //                                       horizontal: 16.0,
  //                                       vertical: 12.0,
  //                                     ),
  //                                     border: InputBorder.none,
  //                                   ),
  //                                 ),
  //                                 Positioned(
  //                                   bottom: 8.0,
  //                                   right: 8.0,
  //                                   child: Container(
  //                                     padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  //                                     // decoration: BoxDecoration(
  //                                     //   color: Colors.black.withOpacity(0.6),
  //                                     //   borderRadius: BorderRadius.circular(4.0),
  //                                     // ),
  //                                     child: Text(
  //                                       '${_leavetext.text.length}/${_leavetext.text.length > 256 ? 256 : 256}',
  //                                       style: TextStyle(
  //                                         color: Colors.black,
  //                                         fontSize: 12,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontFamily: 'Calibri',
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       Padding(
  //                         padding: EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
  //                         child: Container(
  //                           width: double.infinity,
  //                           decoration: BoxDecoration(
  //                             color: Color(0xFFf15f22),
  //                             borderRadius: BorderRadius.circular(6.0),
  //                           ),
  //                           child: ElevatedButton(
  //                             onPressed: isLoading
  //                                 ? null
  //                                 : () async {
  //                                     print('clickedonaddleave');
  //                                     setState(() {
  //                                       isLoading = true;
  //                                     });
  //                                     await applyleave();
  //                                     setState(() {
  //                                       isLoading = false;
  //                                     });
  //                                   },
  //                             child: Text(
  //                               'Add Leave',
  //                               style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Calibri'),
  //                             ),
  //                             style: ElevatedButton.styleFrom(
  //                               primary: Colors.transparent,
  //                               elevation: 0,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(4.0),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ));
  // }

  // Future<void> fetchHolidayList(String accessToken) async {
  //   int currentYear = DateTime.now().year;
  //   print('Currentyearinapplyleave: $currentYear');
  //
  //   final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //   print('urlholidaylistapi: $url');
  //   print('API headers:1 $accessToken');
  //   try {
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //     print('API headers:2 $accessToken');
  //
  //     final response = await http.get(url, headers: headers);
  //     print('response body : ${response.body}');
  //     //  final response = await http.get(Uri.parse(url), headers: headers);
  //     print("responsecode ${response.statusCode}");
  //     // Check if the request was successful (status code 200)
  //     if (response.statusCode == 200) {
  //       // Parse the JSON response
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         holidayList = data.map((json) => HolidayResponse.fromJson(json)).toList();
  //       });
  //
  //       print('Today is a holiday: $holidayList');
  //       DateTime now = DateTime.now();
  //       DateTime currentDate = DateTime(now.year, now.month, now.day);
  //       String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentDate);
  //
  //       for (final holiday in holidayList) {
  //         DateTime holidayDate = holiday.fromDate;
  //         String holidaydate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(holidayDate);
  //
  //         if (formattedDate == holidaydate) {
  //           isTodayHoliday = true;
  //           print('Today is a holiday: $formattedDate');
  //           break; // If a match is found, exit the loop
  //         }
  //       }
  //     } else {
  //       // Handle error if the request was not successful
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     // Handle any exceptions that occurred during the request
  //     print('Error: $error');
  //   }
  // }

  // Future<List<Holiday_Model>> fetchHolidayList(String accessToken) async {
  //   try {
  //     int currentYear = DateTime.now().year;
  //
  //     final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //     print('fetchHoliday: $url');
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonData = jsonDecode(response.body);
  //
  //       setState(() {
  //         holidayList = jsonData.map((json) => HolidayResponse.fromJson(json)).toList();
  //       });
  //       print('holidays${holidayList.length}');
  //       DateTime now = DateTime.now();
  //       DateTime currentDate = DateTime(now.year, now.month, now.day);
  //       String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentDate);
  //
  //       for (final holiday in holidayList) {
  //         DateTime holidayFromDate = holiday.fromDate;
  //         DateTime holidayToDate = holiday.toDate ?? holiday.fromDate; // If toDate is null, assume it's the same as fromDate
  //
  //         // for (DateTime date = holidayFromDate;
  //         //     date.isBefore(holidayToDate) || date.isAtSameMomentAs(holidayToDate);
  //         //     date = date.add(Duration(days: 1))) {
  //         //   String holidayDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
  //         //   if (formattedDate == holidayDate) {
  //         //     isTodayHoliday = true;
  //         //     print('Todayisaholiday: $formattedDate');
  //         //     break; // If a match is found, exit the loop
  //         //   }
  //         // }
  //         // for (DateTime date = holidayFromDate;
  //         //     date.isBefore(holidayToDate) || date.isAtSameMomentAs(holidayToDate) || date.isAtSameMomentAs(holidayToDate.add(Duration(days: 1)));
  //         //     date = date.add(Duration(days: 1))) {
  //         //   // Check if today's date falls within the holiday's date range
  //         //   String holidayDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
  //         //   if (formattedDate == holidayDate) {
  //         //     isTodayHoliday = true;
  //         //     print('Today is a holiday: $formattedDate');
  //         //     break; // If a match is found, exit the loop
  //         //   }
  //         // }
  //
  //         for (DateTime date = holidayFromDate; date.isBefore(holidayToDate.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
  //           // Check if today's date falls within the holiday's date range
  //           String holidayDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
  //           if (formattedDate == holidayDate) {
  //             isTodayHoliday = true;
  //             print('Today is a holiday: $formattedDate');
  //             break; // If a match is found, exit the loop
  //           }
  //         }
  //       }
  //       return [];
  //     } else {
  //       throw Exception('Failed to load holidays: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error in holiday list: $error');
  //     return []; // Return empty list in case of an error
  //   }
  // }
  Future<List<Holiday_Model>> fetchHolidayList(String accessToken) async {
    try {
      int currentYear = DateTime.now().year;

      final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      final response = await http.get(url, headers: headers);

      print('fetchHolidayList: $url');
      print('fetchHolidayList: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        print('jsonData: $jsonData');

        List<Holiday_Model> _holidayList = jsonData
            .where((json) =>
                json['isActive'] == true) // Filter for active holidays
            .map((json) => Holiday_Model.fromJson(json))
            .toList();

        print('holidays: ${_holidayList.length}');
        for (final holiday in _holidayList) {
          // Print the fromDate and toDate for each holiday
          print('Holiday: ${holiday.title}');
          print('From Date: ${holiday.fromDate}');
          print('To Date: ${holiday.toDate ?? holiday.fromDate}');
        }
        setState(() {
          holidayList = _holidayList;
        });

        DateTime now = DateTime.now();
        DateTime currentDate = DateTime(now.year, now.month, now.day);
        for (final holiday in _holidayList) {
          DateTime holidayFromDate = holiday.fromDate;
          DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
          print('holidayToDate: $holidayToDate');
          if (currentDate
                  .isAfter(holidayFromDate.subtract(Duration(days: 1))) &&
              currentDate.isBefore(holidayToDate.add(Duration(days: 1)))) {
            setState(() {
              isTodayHoliday = true;
              print('isTodayHoliday:$isTodayHoliday');
            });
            break;
          }
        }
        return _holidayList; // Return the list of holidays
      } else {
        throw Exception('Failed to load holidays: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in holiday list: $error');
      return []; // Return empty list in case of an error
    }
  }

  // Future<List<Holiday_Model>> fetchHolidayList(String accessToken) async {
  //   try {
  //     int currentYear = DateTime.now().year;
  //
  //     final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //     print('fetchHoliday: $url');
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonData = jsonDecode(response.body);
  //       print('jsonData${jsonData}');
  //       List<Holiday_Model> holidayList = jsonData
  //           .where((json) => json['isActive'] == true) // Filter for active holidays
  //           .map((json) => Holiday_Model.fromJson(json))
  //           .toList();
  //       for (final holiday in holidayList) {
  //         // Print the fromDate and toDate for each holiday
  //         print('Holiday: ${holiday.title}');
  //         print('From Date: ${holiday.fromDate}');
  //         print('To Date: ${holiday.toDate ?? holiday.fromDate}');
  //       }
  //       print('holidays${holidayList.length}');
  //       // DateTime now = DateTime.now();
  //       // DateTime currentDate = DateTime(now.year, now.month, now.day);
  //       // String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentDate);
  //       //
  //       // for (final holiday in holidayList) {
  //       //   DateTime holidayFromDate = holiday.fromDate;
  //       //   DateTime holidayToDate = holiday.toDate ?? holiday.fromDate; // If toDate is null, assume it's the same as fromDate
  //       //
  //       //   for (DateTime date = holidayFromDate; date.isBefore(holidayToDate.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
  //       //     // Check if today's date falls within the holiday's date range
  //       //     String holidayDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(date);
  //       //     print('holidayDate:$holidayDate');
  //       //     if (formattedDate == holidayDate) {
  //       //       isTodayHoliday = true;
  //       //       print('Today is a holiday: $formattedDate');
  //       //       break; // If a match is found, exit the loop
  //       //     }
  //       //   }
  //       // }
  //       DateTime now = DateTime.now();
  //       DateTime currentDate = DateTime(now.year, now.month, now.day);
  //       for (final holiday in holidayList) {
  //         DateTime holidayFromDate = holiday.fromDate;
  //         DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
  //         print('holidayToDate:$holidayToDate');
  //         if (currentDate.isAfter(holidayFromDate.subtract(Duration(days: 1))) &&
  //             currentDate.isBefore(holidayToDate.add(Duration(days: 1)))) {
  //           setState(() {
  //             isTodayHoliday = true;
  //           });
  //           break;
  //         }
  //       }
  //       return holidayList; // Return the list of holidays
  //     } else {
  //       throw Exception('Failed to load holidays: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error in holiday list: $error');
  //     return []; // Return empty list in case of an error
  //   }
  // }

  //working for fromdates hiden by manohar to add todates as well
  // Future<List<Holiday_Model>> fetchHolidayList(String accessToken) async {
  //   try {
  //     int currentYear = DateTime.now().year;
  //
  //     final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear');
  //     print('fetchHoliday: $url');
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': '$accessToken',
  //     };
  //     final response = await http.get(url, headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> jsonData = jsonDecode(response.body);
  //
  //       /// List<Holiday_Model> holidayList = jsonData.map((holidayJson) => Holiday_Model.fromJson(holidayJson)).toList();
  //       setState(() {
  //         holidayList = jsonData.map((json) => HolidayResponse.fromJson(json)).toList();
  //       });
  //       print('holidays${holidayList.length}');
  //       DateTime now = DateTime.now();
  //       DateTime currentDate = DateTime(now.year, now.month, now.day);
  //       String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentDate);
  //
  //       for (final holiday in holidayList) {
  //         DateTime holidayDate = holiday.fromDate;
  //         String holidaydate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(holidayDate);
  //
  //         if (formattedDate == holidaydate) {
  //           isTodayHoliday = true;
  //           print('Todayisaholiday: $formattedDate');
  //           break; // If a match is found, exit the loop
  //         }
  //       }
  //       return [];
  //     } else {
  //       throw Exception('Failed to load holidays: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error in holiday list: $error');
  //     return []; // Return empty list in case of an error
  //   }
  // }

  // Future<void> _selectToCLDate() async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //
  //   DateTime today = selectedDate;
  //
  //   // Calculate the initial date as today + 9 days
  //   DateTime initialDate = today.add(const Duration(days: 7));
  //
  //   // Check if there's a holiday within the initialDate and initialDate + 6 days
  //   bool hasHolidayInRange = false;
  //   for (int i = 0; i < 7; i++) {
  //     if (_isHolidayOrWeekend(initialDate.add(Duration(days: i)))) {
  //       hasHolidayInRange = true;
  //       break;
  //     }
  //   }
  //
  //   // If there's a holiday, add one more day to the initialDate
  //   if (hasHolidayInRange) {
  //     initialDate = initialDate.add(const Duration(days: 1));
  //   }
  //
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: initialDate,
  //     lastDate: today.add(Duration(days: 365)), // Adjust this range as needed
  //     selectableDayPredicate: (DateTime date) {
  //       final isPastDate = date.isBefore(today.subtract(Duration(days: 1)));
  //
  //       final saturday = date.weekday == DateTime.saturday;
  //       final sunday = date.weekday == DateTime.sunday;
  //
  //       final isHoliday = holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);
  //
  //       if (_isTodayHoliday && isHoliday && isPastDate) {
  //         return true;
  //       }
  //
  //       final isPreviousYear = date.year < today.year;
  //
  //       // Return false if any of the conditions are met
  //       return !isPastDate && !saturday && !sunday && !isHoliday && !isPreviousYear && date.year >= today.year;
  //     },
  //   );
  //
  //   if (pickedDate != null) {
  //     setState(() {
  //       selectedToDate = pickedDate;
  //       _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
  //       //  onDateSelected(pickedDate);
  //     });
  //   }
  // }

  Future<void> _selectToCLDate() async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    DateTime today = DateTime.now();
    DateTime initialDate = today.add(const Duration(days: 9));

    while (_isHolidayOrWeekend(initialDate) ||
        !selectableDayPredicate(initialDate)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: selectedDate!,
      lastDate: today.add(const Duration(days: 365)),
      selectableDayPredicate: selectableDayPredicate,
    );

    if (pickedDate != null) {
      final DateTime selectedToDatePlus7Days =
          pickedDate.add(const Duration(days: 7));
      setState(() {
        selectedToDate = selectedToDatePlus7Days;
        _todateController.text =
            DateFormat('dd-MM-yyyy').format(selectedToDate!);
      });
    }
  }

  // Future<void> _selectToCLDate() async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //
  //   DateTime today = DateTime.now();
  //
  //   // Calculate the initial date as today + 9 days
  //   DateTime initialDate = today.add(const Duration(days: 9));
  //
  //   // Check if the initialDate is a holiday, if yes, increment it until a non-holiday date is found
  //   while (_isHolidayOrWeekend(initialDate)) {
  //     initialDate = initialDate.add(const Duration(days: 1));
  //   }
  //
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: today,
  //     lastDate: today.add(const Duration(days: 365)), // Adjust this range as needed
  //     selectableDayPredicate: (DateTime date) {
  //       final isPastDate = date.isBefore(today.subtract(Duration(days: 1)));
  //
  //       final saturday = date.weekday == DateTime.saturday;
  //       final sunday = date.weekday == DateTime.sunday;
  //
  //       final isHoliday = holidayList
  //           .any((holiday) =>
  //       date.year == holiday.fromDate.year &&
  //           date.month == holiday.fromDate.month &&
  //           date.day == holiday.fromDate.day);
  //
  //       if (_isTodayHoliday && isHoliday && isPastDate) {
  //         return true;
  //       }
  //
  //       final isPreviousYear = date.year < today.year;
  //
  //       // Return false if any of the conditions are met
  //       return !isPastDate && !saturday && !sunday && !isHoliday &&
  //           !isPreviousYear && date.year >= today.year;
  //       //   final saturday = date.weekday == DateTime.saturday;
  //       //   final sunday = date.weekday == DateTime.sunday;
  //       //
  //       //   final isHoliday = holidayList.any((holiday) {
  //       //     DateTime holidayFromDate = holiday.fromDate;
  //       //     DateTime holidayToDate = holiday.toDate ?? holiday.fromDate;
  //       //
  //       //     return date.isAfter(holidayFromDate.subtract(Duration(days: 1))) && date.isBefore(holidayToDate.add(Duration(days: 1)));
  //       //   });
  //       //
  //       //   // Return true if it's not Saturday, not Sunday, not a holiday, and not before today
  //       //   return !saturday && !sunday && !isHoliday && date.isAfter(DateTime.now().subtract(Duration(days: 1)));
  //       // },
  //     }
  //   );
  //
  //   if (pickedDate != null) {
  //     // Calculate the date 7 days ahead of the pickedDate
  //     final DateTime selectedToDatePlus7Days = pickedDate.add(const Duration(days: 7));
  //
  //     setState(() {
  //       selectedToDate = selectedToDatePlus7Days;
  //       _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
  //       //  onDateSelected(pickedDate);
  //     });
  //   }
  // }

  // Future<void> getleavereasontype(int leavereasonlookupid, int lookupDetailId) async {
  //   final url = Uri.parse(baseUrl + getdropdown + '$leavereasonlookupid' + '/$lookupDetailId');
  //   print('leave reson $url');
  //   final response = await http.get((url));
  //   // final url =  Uri.parse(baseUrl+GetHolidayListByBranchId+'$branchId');
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     setState(() {
  //       dropdownItems = data;
  //     });
  //   } else {
  //     print('Failed to fetch data');
  //   }
  // }
  Future<void> getleavereasontype(
      int leaveReasonLookupId, int lookupDetailId) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse(
        baseUrl + getdropdown + '$leaveReasonLookupId' + '/$lookupDetailId');
    print('leave reason $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );
    // final response = await http.get(url); // Removed extra parentheses
    // final url =  Uri.parse(baseUrl+GetHolidayListByBranchId+'$branchId');
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body); // Parse response
      if (responseData is List<dynamic>) {
        // Check if response is a list
        setState(() {
          dropdownItems = responseData; // Assign parsed data to dropdownItems
        });
      } else {
        print('Response is not in expected format');
      }
    } else {
      print('Failed to fetch data');
    }
  }

  Future<void> getleavereasonlookupid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Leavereasonlookupid = prefs.getInt('leavereasons') ?? 0;
      getleavereasontype(Leavereasonlookupid, widget.lookupDetailId);
    });
    print("Leavereasonlookupid:$Leavereasonlookupid");
    // Provide a default value if not found
  }

  bool _isHolidayOrWeekend(DateTime date) {
    final isSaturday = date.weekday == DateTime.saturday;
    final isSunday = date.weekday == DateTime.sunday;

    final isHoliday = holidayList.any((holiday) =>
        date.year == holiday.fromDate.year &&
        date.month == holiday.fromDate.month &&
        date.day == holiday.fromDate.day);

    return isSaturday || isSunday || isHoliday;
  }

  Future<void> getDayWorkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      DayWorkStatus = prefs.getInt('dayWorkStatus') ?? 0;
    });
    print("DayWorkStatus:$DayWorkStatus");
    fetchDataleavetype(DayWorkStatus);
    // Provide a default value if not found
  }

  Future<void> fetchDataleavetype(int dayWorkStatus) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    final url = Uri.parse(baseUrl + getdropdown + '$dayWorkStatus');
    print('leave reason 2:${url}');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);

      if (jsonData is List<dynamic>) {
        setState(() {
          lookupDetails =
              jsonData.map((data) => LookupDetail.fromJson(data)).toList();
        });
      } else {
        print('Unexpected response format: $jsonData');
        throw Exception('Failed to load data. Unexpected response format.');
      }
    } else {
      print('HTTP error: ${response.statusCode}');
      throw Exception(
          'Failed to load data. Status Code: ${response.statusCode}');
    }
  }

  void Showdialog(BuildContext context, Function(bool) callback) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Confirmation",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Calibri',
                  color: Color(0xFFf15f22),
                ),
              ),
              // IconButton(
              //   icon: Icon(Icons.close),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Leave Request is within the WFH Span. will you want to split this, Please confirm this by "Clicking" Confirm else "Cancel"',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Calibri',
                  color: Colors.black,
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                //    Navigator.of(context, rootNavigator: true).pop(context);
                Navigator.of(context).pop();
                callback(true);
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Calibri'), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                    0xFFf15f22), // Change to your desired background color
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
                Navigator.of(context).pop();
                callback(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Calibri'), // Set text color to white
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                    0xFFf15f22), // Change to your desired background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Set border radius
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<int> checkLeavesAllocation(String fromDate, int leaveTypeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final empId = prefs.getString("employeeId") ?? "";

    final apiUrl =
        '$baseUrl$getleaveStatistics${fromDate.split('-')[2]}/$empId';
    // 'http://182.18.157.215/HRMS/API/hrmsapi/Attendance/GetLeaveStatistics/2025/176';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': accessToken,
    };

    final jsonResponse = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    print('checkLeaves: $apiUrl');
    print('checkLeaves: $jsonResponse');

    if (selectedDate != null && selectedToDate != null) {
      if (selectedDate!.year != selectedToDate!.year) {
        return 102; // years different
      }
      /* else {
        return 200; // years same
      } */
    }

    if (jsonResponse.statusCode == 200) {
      final Map<String, dynamic> response = jsonDecode(jsonResponse.body);

      if (checkForLeavesAvailability(leaveTypeId, response) > 0) {
        // return true;
        return 200;
      }
      // return false;
      return 400; // no leaves
    }
    // return false;
    return 500; // api failed
  }

  double checkForLeavesAvailability(
      int leaveTypeId, Map<String, dynamic> response) {
    late double allocatedLeaves;
    late double usedLeaves;
    switch (leaveTypeId) {
      case 102: // CL
        allocatedLeaves = response['allottedCasualLeaves'] ?? 0.0;
        usedLeaves = response['usedCasualLeavesInYear'] ?? 0.0;
        break;
      case 103: // PL
        allocatedLeaves = response['allottedPrivilegeLeaves'] ?? 0.0;
        usedLeaves = response['usedPrivilegeLeavesInYear'] ?? 0.0;
        break;
      case 104: // LWP
        return 1;
      case 160: // WFH
        return 1;
      case 179: // LL
        return 1;
    }
    return allocatedLeaves.toDouble() - usedLeaves.toDouble();
  }

  DropdownMenuItem<int> leaveTypeDropdown(LookupDetail item) {
    // final bool isDisabled = (item.name == 'PL' || item.name == 'CL');
    return DropdownMenuItem<int>(
      value: item.lookupDetailId,
      // enabled: !isDisabled,
      child: Text(
        item.name,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Calibri',
          // color: isDisabled ? Colors.grey : null,
        ),
      ),
    );
  }
}
