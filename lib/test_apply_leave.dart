// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Model%20Class/LookupDetail.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/holiday_model.dart';
import 'package:hrms/styles.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestApplyLeave extends StatefulWidget {
  final String? leaveType;
  final int? lookupDetailId;
  final String? employeName;
  const TestApplyLeave(
      {super.key, this.leaveType, this.lookupDetailId, this.employeName});

  @override
  State<TestApplyLeave> createState() => _TestApplyLeaveState();
}

class _TestApplyLeaveState extends State<TestApplyLeave> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _leaveReasonController = TextEditingController();
  int? selectedDropdownId;
  int? selectedDropdownLookupDetailId;
  int? selectedLeaveDescriptionId;
  // String? selectedValue;

  int? selectedDescriptionId;
  String selectedValue = '';
  String selectedName = '';

  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  bool dropDownValidator = false;

  bool? isHalfDayLeave = false;

  TextStyle txStyFS15FFc = const TextStyle(fontFamily: 'Calibri');

  late String accessToken;
  late Future<List<LookupDetail>> futreLeaveTypes;
  late Future<List<LeaveDescriptionModel>> futreLeaveDescription;
  late List<Holiday_Model> holidayList;
  late LeaveValidationsModel leaveValidationsModel;
  // late Future<List<EmployeeSelfLeaves>> empSelfLeaves;
  late List<EmployeeSelfLeaves> empSelfLeaves;

  @override
  void initState() {
    super.initState();
    futreLeaveTypes = getLeaveTypes();
    // empSelfLeaves = getEmpLeaves();

    initializeData();
  }

  Future<void> initializeData() async {
    holidayList = await getLeaves();
    empSelfLeaves = await getEmpLeaves();
  }

//MARK: Dropdown API
  Future<List<LookupDetail>> getLeaveTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final dayWorkStatus = prefs.getInt('dayWorkStatus') ?? 0;
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      throw Exception(''); // 'Please Check the Internet Connection'
    }

    final url = Uri.parse('$baseUrl$getdropdown$dayWorkStatus');
    print('getLeaveTypes: $url');
    final jsonResponse = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );

    if (jsonResponse.statusCode == 200) {
      List<dynamic> response = json.decode(jsonResponse.body);
      List<dynamic> filteredResponse = response
          .where((element) =>
              element['lookupDetailId'] != 100 &&
              element['lookupDetailId'] != 101)
          .toList();
      List<LookupDetail> lookupDetails = filteredResponse
          .map((data) => LookupDetail.fromJson(data as Map<String, dynamic>))
          .toList();
      return lookupDetails;
    } else {
      throw Exception('No leaves found!');
    }
  }

//MARK: Leaves Description
  Future<List<LeaveDescriptionModel>> getLeaveDescription(
      {int? lookupDetailsId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final leaveReasons = prefs.getInt('leavereasons') ?? 0;
      final apiUrl =
          Uri.parse('$baseUrl$getdropdown$leaveReasons/$lookupDetailsId');
      final jsonResponse = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      print('dcsdc: $apiUrl');
      if (jsonResponse.statusCode == 200) {
        return leaveDescriptionModelFromJson(jsonResponse.body);
      } else {
        throw Exception('No leave description found!');
      }
    } catch (e) {
      print('catch: $e');
      rethrow;
    }
  }

//MARK: Leave Validations
  Future<LeaveValidationsModel> getLeaveValidations(
      {int? lookupDetailsId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final apiUrl = Uri.parse(baseUrl + getadminsettings);
      final jsonResponse = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      print('dcsdc: $apiUrl');
      if (jsonResponse.statusCode == 200) {
        return leaveValidationsModelFromJson(jsonResponse.body);
      } else {
        throw Exception('No leave description found!');
      }
    } catch (e) {
      print('catch: $e');
      rethrow;
    }
  }

  //MARK: Get Leaves
  Future<List<Holiday_Model>> getLeaves() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    int currentYear = DateTime.now().year;
    final apiUrl = Uri.parse('$baseUrl$GetHolidayList$currentYear');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': accessToken,
    };

    final jsonResponse = await http.get(apiUrl, headers: headers);
    print('getLeaves: ${jsonResponse.body}');
    if (jsonResponse.statusCode == 200) {
      List<dynamic> response = json.decode(jsonResponse.body);
      List<Holiday_Model> holidayList = response
          .map((data) => Holiday_Model.fromJson(data as Map<String, dynamic>))
          .toList();
      return holidayList;
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

//MARK: Emp Leaves
  Future<List<EmployeeSelfLeaves>> getEmpLeaves() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final employeeId = prefs.getString("employeeId") ?? "";
    int currentYear = DateTime.now().year;
    final apiUrl = Uri.parse('$baseUrl$getleavesapi$employeeId/$currentYear');
    final jsonResponse = await http.get(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );
    print('getEmpLeaves: ${jsonResponse.body}');
    if (jsonResponse.statusCode == 200) {
      return employeeSelfLeavesFromJson(jsonResponse.body);
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

//MARK: Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(),
        body: Stack(
          children: [
            backgroundImage(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      leaveRequestText(),
                      const SizedBox(height: 10),
                      leaveTypeDropdown(),
                      if (dropDownValidator) leaveTypeValidation(),
                      const SizedBox(height: 10),
                      if (selectedDropdownLookupDetailId == 102 ||
                          selectedDropdownLookupDetailId == 103)
                        Column(
                          children: [
                            leaveDescriptionDropdown(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      if (selectedDropdownLookupDetailId == 102 ||
                          selectedDropdownLookupDetailId == 103)
                        Column(
                          children: [
                            halfDayCheckBox(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      const SizedBox(height: 10),
                      fromDateField(),
                      const SizedBox(height: 10),
                      if (selectedDropdownLookupDetailId != 102)
                        Column(
                          children: [
                            toDateField(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      leaveDescription(),
                      const SizedBox(height: 20),
                      addLeaveBtn()
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

//MARK: Descrption Box
  CustomTextField leaveDescription() {
    return CustomTextField(
        hintText: 'Leave Reason Description',
        controller: _leaveReasonController,
        readOnly: false,
        maxLines: 6,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter Leave Reason';
          }
          return null;
        });
  }

  CustomTextField toDateField() {
    return CustomTextField(
      hintText: 'To Date',
      controller: _toDateController,
      fillColor: selectedFromDate == null ? Colors.grey[300] : Colors.white,
      onTap: selectedFromDate == null ? null : launchToDate,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please select To Date';
        }
        return null;
      },
    );
  }

  Future<void> launchToDate() async {
    DateTime? initialDate = calculateCLInitialDate(holidayList);
    // DateTime? initialDate = calculateInitialDate(holidayList);
    print('checkLeaveTypeAndLaunchDatePicker cl: $initialDate');
    Commonutils.launchDatePicker(
      context,
      initialDate: selectedFromDate,
      firstDate: selectedFromDate ?? DateTime.now(),
      selectableDayPredicate: (DateTime date) => selectableDayPredicate(
        date,
        leaves: holidayList,
      ),
      onDateSelected: (pickedDay) {
        if (pickedDay != null) {
          setState(() {
            selectedToDate = pickedDay;
            _toDateController.text = Commonutils.formatDisplayDate(pickedDay);
          });
        }
      },
    );
  }

  CustomTextField fromDateField() {
    return CustomTextField(
      hintText: 'From Date',
      controller: _fromDateController,
      onTap: () {
        // Commonutils.launchDatePicker(context);
        checkLeaveTypeAndLaunchDatePicker(selectedDropdownLookupDetailId);
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please select From Date';
        }
        return null;
      },
    );
  }

/*  PT | 100 // PRESENT
    AT | 101 // ABSENT
    CL | 102 // CASUAL LEAVE
    PL | 103 // PRIVILEGE LEAVE
    LWP | 104 // LEAVE WITHOUT PAY
    WFH | 160 // WORK FROM HOME
    LL | 179 // LONG LEAVE */

  Future<void> checkLeaveTypeAndLaunchDatePicker(
      int? selectedDropdownLookupDetailId) async {
    DateTime today = DateTime.now();
    print('checkLeaveTypeAndLaunchDatePicker: $selectedDropdownLookupDetailId');
    switch (selectedDropdownLookupDetailId) {
      case 102: // CL | 102 // CASUAL LEAVE
        {
          DateTime? initialDate = calculateCLInitialDate(holidayList);
          // DateTime? initialDate = calculateInitialDate(holidayList);
          print('checkLeaveTypeAndLaunchDatePicker cl: $initialDate');
          Commonutils.launchDatePicker(
            context,
            // initialDate: selectedFromDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) => selectableDayPredicate(
                date,
                leaves: holidayList,
                initialDate: initialDate),
            onDateSelected: onDateSelectedForFromDate,
            /*  onDateSelected: (pickedDay) {
              if (pickedDay != null) {
                setState(() {
                  selectedFromDate = pickedDay;
                  _fromDateController.text =
                      Commonutils.formatDisplayDate(pickedDay);
                  selectedToDate = null;
                  _toDateController.clear();
                });
              }
            }, */
          );
        }
        break;
      case 103: // PL | 103 // PRIVILEGE LEAVE
        {
          DateTime? initialDate = calculatePLInitialDate(holidayList);
          // DateTime? initialDate = calculatePLInitialDate(holidayList);
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) => selectableDayPredicate(
                date,
                leaves: holidayList,
                initialDate: initialDate),
            onDateSelected: onDateSelectedForFromDate,

            /* (pickedDay) {
              if (pickedDay != null) {
                setState(() {
                  selectedFromDate = pickedDay;
                  _fromDateController.text =
                      Commonutils.formatDisplayDate(pickedDay);
                });
              }
            }, */
          );
        }
        break;
      case 104: // LWP | 104 // LEAVE WITHOUT PAY
        {
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForOthers(date, holidayList),
            onDateSelected: onDateSelectedForFromDate,
            /* onDateSelected: (pickedDay) {
              if (pickedDay != null) {
                setState(() {
                  selectedFromDate = pickedDay;
                  _fromDateController.text =
                      Commonutils.formatDisplayDate(pickedDay);
                });
              }
            }, */
          );
        }
        break;
      case 160: // WFH | 160 // WORK FROM HOME
        {
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForOthers(date, holidayList),
            onDateSelected: onDateSelectedForFromDate,
            /*  onDateSelected: (pickedDay) {
              if (pickedDay != null) {
                setState(() {
                  selectedFromDate = pickedDay;
                  _fromDateController.text =
                      Commonutils.formatDisplayDate(pickedDay);
                });
              }
            }, */
          );
        }
        break;
      case 179: // LL | 179 // LONG LEAVE
        {
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForOthers(date, holidayList),
            onDateSelected: onDateSelectedForFromDate,
            /* nDateSelected: (pickedDay) {
              if (pickedDay != null) {
                setState(() {
                  selectedFromDate = pickedDay;
                  _fromDateController.text =
                      Commonutils.formatDisplayDate(pickedDay);
                });
              }
            }, */
          );
        }
        break;

/*       
     
      case 160: // WFH | 160 // WORK FROM HOME
        {
          DateTime? initialDate = calculatePLInitialDate(holidayList);
          Commonutils.launchDatePicker(
            context,
            initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForFromDate(date, initialDate),
          );
        }
        break;
      case 179: // LL | 179 // LONG LEAVE
        {
          DateTime? initialDate = calculatePLInitialDate(holidayList);
          Commonutils.launchDatePicker(
            context,
            initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForFromDate(date, initialDate),
          );
        }
        break;
      default:
        {
          DateTime? initialDate = calculatePLInitialDate(holidayList);
          Commonutils.launchDatePicker(
            context,
            initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForFromDate(date, initialDate),
          );
        } */
    }
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
      if (leave.isActive) {
        for (var date = fromDate;
            date.isBefore(toDate.add(const Duration(days: 1)));
            date = date.add(const Duration(days: 1))) {
          leaveDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }

    // Step 3: Add three working days.
    int workingDaysAdded = 0;

    while (workingDaysAdded < 3) {
      // while (workingDaysAdded < 4) {
      initialDate = initialDate.add(const Duration(days: 1));
      if (initialDate.weekday != DateTime.saturday &&
          initialDate.weekday != DateTime.sunday &&
          !leaveDates.contains(
              DateTime(initialDate.year, initialDate.month, initialDate.day))) {
        workingDaysAdded++;
      }
    }

    return initialDate;
  }

  DateTime calculatePLInitialDate(List<Holiday_Model> leaves) {
    // Step 1: Initialize the initialDate to the current date.
    DateTime now = DateTime.now();
    DateTime initialDate = now;

    // Step 2: Create a set of all leave dates from the Holiday_Model list.
    Set<DateTime> leaveDates = {};
    for (var leave in leaves) {
      DateTime fromDate = leave.fromDate;
      DateTime toDate = leave.toDate ??
          leave.fromDate; // Handle null `toDate` as single-day leave.
      if (leave.isActive) {
        for (var date = fromDate;
            date.isBefore(toDate.add(const Duration(days: 1)));
            date = date.add(const Duration(days: 1))) {
          leaveDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }

    // Step 3: Add three working days.
    int workingDaysAdded = 0;

    while (workingDaysAdded < 1) {
      // while (workingDaysAdded < 2) {
      initialDate = initialDate.add(const Duration(days: 1));
      if (initialDate.weekday != DateTime.saturday &&
          initialDate.weekday != DateTime.sunday &&
          !leaveDates.contains(
              DateTime(initialDate.year, initialDate.month, initialDate.day))) {
        workingDaysAdded++;
      }
    }

    return initialDate;
  }

  bool selectableDayPredicate(DateTime date,
      {required List<Holiday_Model> leaves, DateTime? initialDate}) {
    // Disable weekends (Saturdays and Sundays)
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }

    // Disable holidays
    for (var holiday in leaves) {
      if (holiday.isActive) {
        DateTime endDate = holiday.toDate ?? holiday.fromDate;
        // Ensuring to consider dates equal to the holiday as disabled
        if (date.isAfter(holiday.fromDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1)))) {
          return false;
        }
      }
    }
    if (initialDate != null) {
      // Disable all dates before initialDate
      if (date.isBefore(initialDate.subtract(const Duration(days: 1)))) {
        return false;
      }
    }
    // Disable all dates before initialDate

    return true;
  }

  bool selectableDayPredicateForOthers(
      DateTime date, List<Holiday_Model> leaves) {
    // Disable weekends (Saturdays and Sundays)
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }

    // Disable holidays
    for (var holiday in leaves) {
      if (holiday.isActive) {
        DateTime endDate = holiday.toDate ?? holiday.fromDate;
        // Ensuring to consider dates equal to the holiday as disabled
        if (date.isAfter(holiday.fromDate.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate.add(const Duration(days: 1)))) {
          return false;
        }
      }
    }

    // Disable the current day
    if (date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day) {
      return false;
    }

    return true;
  }

  DateTime calculateInitialDate(List<Holiday_Model> leaves) {
    DateTime today = DateTime.now();
    DateTime initialDate =
        today.add(const Duration(days: 1)); // Start from tomorrow

    bool isHoliday(DateTime date) {
      for (var holiday in leaves) {
        if (holiday.isActive) {
          DateTime endDate = holiday.toDate ?? holiday.fromDate;
          if (date.isAfter(
                  holiday.fromDate.subtract(const Duration(days: 1))) &&
              date.isBefore(endDate.add(const Duration(days: 1)))) {
            return true;
          }
        }
      }
      return false;
    }

    // Find the next available date not on a holiday
    while (isHoliday(initialDate)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    return initialDate;
  }

  DateTime calculateInitialDateWith3WorkingDays(List<Holiday_Model> leaves) {
    // Step 1: Get the current date and initialize variables
    DateTime now = DateTime.now();
    DateTime initialDate =
        now.add(const Duration(days: 1)); // Start from tomorrow
    int workingDaysCount = 0;

    // Step 2: Create a set of all leave dates from the Holiday_Model list
    Set<DateTime> leaveDates = {};
    for (var leave in leaves) {
      if (leave.isActive) {
        DateTime fromDate = leave.fromDate;
        DateTime toDate = leave.toDate ?? leave.fromDate;
        for (var date = fromDate;
            date.isBefore(toDate.add(const Duration(days: 1)));
            date = date.add(const Duration(days: 1))) {
          leaveDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }

    // Step 3: Calculate the initial date after 3 working days
    while (workingDaysCount < 3) {
      // Skip weekends (Saturday and Sunday) and holidays
      if (initialDate.weekday != DateTime.saturday &&
          initialDate.weekday != DateTime.sunday &&
          !leaveDates.contains(
              DateTime(initialDate.year, initialDate.month, initialDate.day))) {
        workingDaysCount++;
      }
      // Move to the next day
      if (workingDaysCount < 3) {
        initialDate = initialDate.add(const Duration(days: 1));
      }
    }

    return initialDate;
  }

/*   DateTime calculateInitialDateWith3WorkingDays(List<Holiday_Model> leaves) {
    DateTime today = DateTime.now();
    DateTime initialDate = today.add(Duration(days: 1)); // Start from tomorrow

    bool isHolidayOrWeekend(DateTime date) {
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        return true;
      }
      for (var holiday in leaves) {
        if (holiday.isActive) {
          DateTime endDate = holiday.toDate ?? holiday.fromDate;
          if (date.isAfter(holiday.fromDate.subtract(Duration(days: 1))) &&
              date.isBefore(endDate.add(Duration(days: 1)))) {
            return true;
          }
        }
      }
      return false;
    }

    int workingDaysAdded = 0;

    // Add 3 working days, skipping holidays and weekends
    while (workingDaysAdded < 3) {
      if (!isHolidayOrWeekend(initialDate)) {
        workingDaysAdded++;
      }
      initialDate = initialDate.add(Duration(days: 1));
    }

    return initialDate;
  } */

  Container leaveTypeValidation() {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 8),
      child: const Text(
        'Please select Leave Type',
        style: TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }

//MARK: Add Leave Btn
  SizedBox addLeaveBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // _fromDateController.text = '2022-01-01';
          print(
              'selectedDropdownLookupDetailId: $selectedDropdownLookupDetailId');

          if (_formKey.currentState!.validate()) {
            print('_formKey selectedTypeCdId: $selectedDropdownId');
            print('_formKey selectedValue: $selectedValue');
            print('_formKey selectedName: $selectedName');
            print('_formKey isHalfDay: $isHalfDayLeave');
            print('_formKey From Date: ${_fromDateController.text}');
            print('_formKey To Date: ${_toDateController.text}');
            print('_formKey Leave Reason: ${_leaveReasonController.text}');
            validationForLL();
          }

          setState(() {
            if (selectedDropdownId == null || selectedDropdownId == -1) {
              dropDownValidator = true;
            } else {
              dropDownValidator = false;
            }
          });

          leaveValidation(selectedDropdownLookupDetailId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Styles.primaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: const Text(
          'Add Leave',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontFamily: 'Calibri'),
        ),
      ),
    );
  }

  void validationForLL() {
    if (selectedDropdownLookupDetailId == 179) {
      // LL Validation
      if (selectedFromDate != null && selectedToDate != null) {
        final difference = selectedToDate?.difference(selectedFromDate!).inDays;
        if (difference! < 7) {
          Commonutils.showCustomToastMessageLong(
              'Long Leave must be apply minimum 7 days', context, 1, 4);
          return;
        }
      }
    }
  }

  //MARK: Cl Validation
  void checkCLLeave(DateTime fromDateObj) {
    final hasAppliedCLLeaveInMonth =
        getAppliedCLLeaveDateInMonth(empSelfLeaves, fromDateObj);
    final hasApprovedCLLeaveInMonth =
        checkApprovedCLLeaveDateInMonth(empSelfLeaves, fromDateObj);

    if (hasAppliedCLLeaveInMonth != null) {
      final message =
          "Kindly confirm whether you wish to retract the previously submitted leave for the month of ${getMonthName(selectedFromDate!)} on this '${formatStringDate(selectedFromDate!)}', which has not yet approved. Please click 'Confirm' to proceed with the reversion or 'Cancel' to maintain the current application status.";
      showCustomDialog(context, hasAppliedCLLeaveInMonth,
          title: 'Confirmation', message: message);
      print(
          "checkCLLeave: Employee has already applied for a leave in this month'CL'  with status 'Approved' or 'Pending'. Multiple CL leaves are not allowed in the same month.");
    } else if (hasApprovedCLLeaveInMonth != null) {
      const message =
          '''Employee has already applied for a leave in this month. 'CL' with status 'Approved'. Multiple CL leaves are not allowed in the same month.''';
      showCustomDialog(context, hasAppliedCLLeaveInMonth,
          isActions: false, title: 'Warning', message: message);
      /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
          ),
        ),
      ); */
    } else {
      print("checkCLLeave: Employee can apply for 'CL' leave in this month.");
      applyLeave();
    }
  }

  DateTime? checkApprovedCLLeaveDateInMonth(
      List<EmployeeSelfLeaves> empSelfLeaves, DateTime fromDateObj) {
    for (var leave in empSelfLeaves) {
      if (leave.leaveType == 'CL' && leave.status == 'Approved') {
        // Check if the month and year match
        if (leave.fromDate != null &&
            leave.fromDate!.year == fromDateObj.year &&
            leave.fromDate!.month == fromDateObj.month) {
          return leave.fromDate;
        }
      }
    }
    return null;
  }

  void leaveValidation(int? leaveTypeId) {
    switch (leaveTypeId) {
      case 102:
        // CL Validation
        checkCLLeave(selectedFromDate!);
        break;
      case 103:
        // PL Validation
        break;
      case 104:
        // LWP Validation
        break;
      case 160:
      // WFH Validation
      case 179:
        // LL Validation
        break;
    }
  }

  // leave.status == 'Approved'
  DateTime? getAppliedCLLeaveDateInMonth(
      List<EmployeeSelfLeaves> empSelfLeaves, DateTime fromDateObj) {
    for (var leave in empSelfLeaves) {
      if (leave.leaveType == 'CL' &&
          (leave.status == 'Pending' || leave.status == 'Accepted')) {
        // Check if the month and year match
        if (leave.fromDate != null &&
            leave.fromDate!.year == fromDateObj.year &&
            leave.fromDate!.month == fromDateObj.month) {
          return leave.fromDate;
        }
      }
    }
    return null;
  }

  String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  String formatStringDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  void showCustomDialog(
    BuildContext context,
    DateTime? selectedFromDate, {
    required String title,
    required String message,
    bool isActions = true,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            // 'Confirmation',
            title,
            style: TextStyle(
              color: Styles.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // "Kindly confirm whether you wish to retract the previously submitted leave for the month of ${getMonthName(selectedFromDate!)} on this '${formatStringDate(selectedFromDate!)}', which has not yet approved. Please click 'Confirm' to proceed with the reversion or 'Cancel' to maintain the current application status.",
                message,
              ),
            ],
          ),
          actions: isActions ? actions(context) : null,
        );
      },
    );
  }

  List<Widget> actions(BuildContext context) {
    return [
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                applyLeave().whenComplete(() {
                  Navigator.of(context).pop();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child:
                  const Text('Confirm', style: TextStyle(color: Colors.white)),
              /* style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                  ), */
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Add your submit logic here
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
              /* style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                  ), */
            ),
          ),
        ],
      )
    ];
  }

  Future<void> getLeaveStatistics({int? leaveStatasticsYear}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final employeeId = prefs.getString("employeeId");
    leaveStatasticsYear ??= DateTime.now().year;

    final apiUrl = Uri.parse(
        '$baseUrl$getleaveStatistics$leaveStatasticsYear/$employeeId');
    // final apiUrl = 'http://182.18.157.215/HRMS/API/hrmsapi/Attendance/GetLeaveStatistics/2025/131';
    final jsonResponse = await http.get(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );
  }

  Future<void> applyLeave() async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 3);
      FocusScope.of(context).unfocus();
      return;
    }

    // check token validation

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString("employeeId");
    final accessToken = prefs.getString("accessToken") ?? '';
    final apiUrl = Uri.parse(baseUrl + applyleaveapi);
    final loadedData = await SharedPreferencesHelper.getCategories();
    final employeeName = loadedData?['employeeName'];

    final requestBody = jsonEncode({
      "employeeId": employeeId,
      "fromDate": Commonutils.formatApiDate(selectedFromDate),
      "toDate": Commonutils.formatApiDate(selectedToDate) ??
          Commonutils.formatApiDate(selectedFromDate),
      "leaveTypeId": selectedDropdownLookupDetailId,
      "note": _leaveReasonController.text,
      "acceptedBy": null,
      "acceptedAt": null,
      "approvedBy": null,
      "approvedAt": null,
      "rejected": null,
      "comments": null,
      "isApprovalEscalated": null,
      "url": leaveApplyURL,
      "employeeName": employeeName,
      "getLeaveType": getLeaveType(selectedDropdownLookupDetailId!),
      "isHalfDayLeave": isHalfDayLeave,
      "leaveReasonId": selectedDropdownLookupDetailId,
      "isFromAttendance": false,
    });

    final jsonResponse = await http.post(
      apiUrl,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );

    if (jsonResponse.statusCode == 200) {
      print('lol: Leave applied successfully');
      Map<String, dynamic> response = jsonDecode(jsonResponse.body);
      if (response['isSuccess'] == true) {
        Commonutils.showCustomToastMessageLong(
            'Leave Applied Successfully', context, 0, 3);
        Navigator.of(context).pop();
      }
    } else {
      print('lol: Failed to apply leave');

      Commonutils.showCustomToastMessageLong(
          'Something went wrong, please try again later', context, 1, 3);
    }
  }

  String getLeaveType(int leaveCode) {
    switch (leaveCode) {
      case 100:
        return 'PT';
      case 101:
        return 'AT';
      case 102:
        return 'CL';
      case 103:
        return 'PL';
      case 104:
        return 'LWP';
      case 160:
        return 'WFH';
      case 179:
        return 'LL';
      default:
        return 'Unknown Leave Type';
    }
  }

  Row halfDayCheckBox() {
    return Row(
      children: [
        const Text(
          'Is Halfday Leave?',
          style: TextStyle(
              fontSize: 14,
              color: Styles.primaryColor,
              fontFamily: 'Calibri',
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 20,
          child: Checkbox(
            value: isHalfDayLeave,
            onChanged: (bool? value) {
              setState(() {
                isHalfDayLeave = value;
              });
            },
            activeColor: Styles.primaryColor,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder? customBorder(
      {required Color borderColor, double width = 1.5}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: borderColor,
        width: width,
      ),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Text leaveRequestText() {
    return const Text(
      'Leave Request',
      style: TextStyle(
        fontSize: 24,
        color: Color(0xFFf15f22),
        fontWeight: FontWeight.w500,
        fontFamily: 'Calibri',
      ),
    );
  }

//MARK: Leaves Dropdown
  Widget leaveTypeDropdown() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Styles.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
      ),
      child: FutureBuilder(
        future: futreLeaveTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Text('Loading Leaves..'),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', '')),
            );
          } else {
            final List<LookupDetail> leaveTypes = snapshot.data ?? [];

            if (leaveTypes.isNotEmpty) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<int>(
                  hint: Text(
                    'Select Leave Type',
                    style: txStyFS15FFc,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                  ),
                  isExpanded: true,
                  value: selectedDropdownId,
                  items: leaveTypes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        item.name,
                        style: txStyFS15FFc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      selectedDropdownId = value!;
                      final selectedItem = leaveTypes.firstWhere((item) =>
                          item.lookupDetailId ==
                          leaveTypes[selectedDropdownId!].lookupDetailId);
                      selectedDropdownLookupDetailId =
                          selectedItem.lookupDetailId;
                      print(
                          'selectedDropdownLookupDetailId: ${leaveTypes[selectedDropdownId!].name} | $selectedDropdownLookupDetailId');

                      if (selectedDropdownLookupDetailId == 102 ||
                          selectedDropdownLookupDetailId == 103) {
                        futreLeaveDescription = getLeaveDescription(
                            lookupDetailsId: selectedDropdownLookupDetailId);
                      }

                      clearForm();
                    });
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      color: Colors.white,
                    ),
                    offset: const Offset(0, 0),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all<double>(6),
                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 20),
                  ),
                ),
              );
            } else {
              return const Text('No data found');
            }
          }
        },
      ),
    );
  }

  Widget leaveDescriptionDropdown() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Styles.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
      ),
      child: FutureBuilder(
          future: futreLeaveDescription,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text('Loading Leave Descriptions..'),
              );
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', '')),
              );
            } else {
              final List<LeaveDescriptionModel> leaveDescriptionsList =
                  snapshot.data ?? [];
              if (leaveDescriptionsList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Text('No leaves description found!'),
                );
              }
              return DropdownButtonHideUnderline(
                child: DropdownButton2<int>(
                  hint: Text(
                    'Select Leave Description',
                    style: txStyFS15FFc,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                  ),
                  isExpanded: true,
                  value: selectedLeaveDescriptionId,
                  items: leaveDescriptionsList.map((item) {
                    return DropdownMenuItem<int>(
                      value: item.lookupDetailId,
                      child: Text(
                        '${item.name}',
                        style: txStyFS15FFc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  /* items: leaveDescriptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        item['description']!,
                        style: txStyFS15FFc,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(), */
                  onChanged: (int? value) {
                    print('Selected description: $value');
                    setState(() {
                      selectedLeaveDescriptionId = value!;
                    });
                    /*  setState(() {
                      selectedDescriptionId = value!;
                      final selectedItem =
                          leaveDescriptions[selectedDescriptionId!];
                      print(
                          'Selected description: ${selectedItem['description']}');
                    }); */
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      color: Colors.white,
                    ),
                    offset: const Offset(0, 0),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all<double>(6),
                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 20),
                  ),
                ),
              );
            }
          }),
    );
  }

  /* 
  Widget buildDropdown() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Styles.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
      ),
      child: FutureBuilder(
          future: futreLeaveTypes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text('Loading Leaves..'),
              );
            } else if (snapshot.hasError) {
              return const Text('Error fetching data');
            } else {
              final List<LookupDetail> leaveTypes = snapshot.data ?? [];

              if (leaveTypes.isNotEmpty) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton2<int>(
                    hint: Text(
                      'Select Leave Type',
                      style: txStyFS15FFc,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black54,
                      ),
                    ),
                    isExpanded: true,
                    value: selectedDropdownId,
                    items: leaveTypes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(
                          item.name,
                          style: txStyFS15FFc,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      print('xxx: $value');
                      setState(() {
                        selectedDropdownId = value!;
                      });
                    },
                    dropdownStyleData: DropdownStyleData(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all<double>(6),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 20),
                    ),
                  ),
                );
              } else {
                return const Text('No data found');
              }
            }
/* 
        return DropdownButtonHideUnderline(
          child: DropdownButton2<int>(
            hint: Text(
              'Select Leave Type',
              style: txStyFS15FFc,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black54,
              ),
            ),
            isExpanded: true,
            items: testdropdownItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  item['item'] as String,
                  style: txStyFS15FFc,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            value: selectedDropdownId,
            onChanged: (int? value) {
              setState(() {
                selectedDropdownId = value!;
                print('selectedTypeCdId==$selectedDropdownId');
                if (selectedDropdownId != -1) {
                  selectedValue = selectedDropdownId != null
                      ? testdropdownItems[selectedDropdownId!]['value'] as String
                      : '';
                  selectedName =
                      testdropdownItems[selectedDropdownId!]['item'] as String;
                  print("selectedValue: $selectedValue");
                  print("selectedName: $selectedName");
                } else {
                  print("==========");
                  print(selectedValue);
                  print(selectedName);
                }
              });
            },
            dropdownStyleData: DropdownStyleData(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: Colors.white,
              ),
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.only(left: 14, right: 20),
            ),
          ),
        );
      */
          }),
    );
  }
 */

  Container backgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background_layer_2.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Styles.primaryColor,
      title: const Text(
        'HRMS',
        style: TextStyle(color: Colors.white, fontFamily: 'Calibri'),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void clearForm() {
    selectedLeaveDescriptionId = null;
    selectedFromDate = null;
    selectedToDate = null;
    _fromDateController.clear();
    _toDateController.clear();
    _leaveReasonController.clear();
  }

  onDateSelectedForFromDate(DateTime? pickedDay) {
    if (pickedDay != null) {
      setState(() {
        selectedFromDate = pickedDay;
        _fromDateController.text = Commonutils.formatDisplayDate(pickedDay);
        selectedToDate = null;
        _toDateController.clear();
      });
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool readOnly;
  final int maxLines;
  final Color? fillColor;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.readOnly = true,
    this.maxLines = 1,
    this.onTap,
    this.fillColor = Colors.white,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
      ), // Replace with your custom style
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ), // Replace with your custom hint style
        border: customBorder(
          borderColor: Styles.primaryColor,
        ),
        focusedErrorBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        disabledBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        enabledBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        focusedBorder: customBorder(
          borderColor: Styles.primaryColor,
        ),
        errorBorder: customBorder(
          borderColor: Colors.red,
        ),
        contentPadding: maxLines != 1
            ? const EdgeInsets.symmetric(horizontal: 15, vertical: 6)
            : const EdgeInsets.only(left: 15, top: 6),
        suffixIcon: maxLines != 1
            ? null
            : const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.black54,
                ),
              ),
        // border: InputBorder.none,
      ),
      onTap: onTap,
    );
  }

  InputBorder customBorder({required Color borderColor, double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: borderColor, width: width),
    );
  }
}

//MARK: Leaves Model
List<LeaveDescriptionModel> leaveDescriptionModelFromJson(String str) =>
    List<LeaveDescriptionModel>.from(
        json.decode(str).map((x) => LeaveDescriptionModel.fromJson(x)));

String leaveDescriptionModelToJson(List<LeaveDescriptionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeaveDescriptionModel {
  final int? lookupDetailId;
  final String? code;
  final String? name;
  final int? lookupId;
  final String? description;
  final bool? isActive;
  final int? fkeySelfId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  LeaveDescriptionModel({
    this.lookupDetailId,
    this.code,
    this.name,
    this.lookupId,
    this.description,
    this.isActive,
    this.fkeySelfId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory LeaveDescriptionModel.fromJson(Map<String, dynamic> json) =>
      LeaveDescriptionModel(
        lookupDetailId: json["lookupDetailId"],
        code: json["code"],
        name: json["name"],
        lookupId: json["lookupId"],
        description: json["description"],
        isActive: json["isActive"],
        fkeySelfId: json["fkeySelfId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
      );

  Map<String, dynamic> toJson() => {
        "lookupDetailId": lookupDetailId,
        "code": code,
        "name": name,
        "lookupId": lookupId,
        "description": description,
        "isActive": isActive,
        "fkeySelfId": fkeySelfId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "updatedBy": updatedBy,
      };
}

//MARK: Leave Validations
LeaveValidationsModel leaveValidationsModelFromJson(String str) =>
    LeaveValidationsModel.fromJson(json.decode(str));

String leaveValidationsModelToJson(LeaveValidationsModel data) =>
    json.encode(data.toJson());

class LeaveValidationsModel {
  final int? appSettingId;
  final int? minimumJobOpeningProcessTime;
  final int? maximumTimesJobOpeningBeProcessed;
  final int? leaveAccumulationProcessDuration;
  final int? maximumAllowableMaternityLeaves;
  final int? maximumAllowableMiscarriageLeaves;
  final int? maximumAllowableEventLeaves;
  final int? maximumAllowableMarriageLeaves;
  final int? maximumAllowableStudyLeaves;
  final int? maximumAllowableDeathCeremonyLeaves;
  final int? maximumAllowableHouseWarmingLeaves;
  final bool? useHierarchicalMailForLeaveApproval;
  final int? mininumDaysToConsiderAsLongLeave;

  LeaveValidationsModel({
    this.appSettingId,
    this.minimumJobOpeningProcessTime,
    this.maximumTimesJobOpeningBeProcessed,
    this.leaveAccumulationProcessDuration,
    this.maximumAllowableMaternityLeaves,
    this.maximumAllowableMiscarriageLeaves,
    this.maximumAllowableEventLeaves,
    this.maximumAllowableMarriageLeaves,
    this.maximumAllowableStudyLeaves,
    this.maximumAllowableDeathCeremonyLeaves,
    this.maximumAllowableHouseWarmingLeaves,
    this.useHierarchicalMailForLeaveApproval,
    this.mininumDaysToConsiderAsLongLeave,
  });

  factory LeaveValidationsModel.fromJson(Map<String, dynamic> json) =>
      LeaveValidationsModel(
        appSettingId: json["appSettingId"],
        minimumJobOpeningProcessTime: json["minimumJobOpeningProcessTime"],
        maximumTimesJobOpeningBeProcessed:
            json["maximumTimesJobOpeningBeProcessed"],
        leaveAccumulationProcessDuration:
            json["leaveAccumulationProcessDuration"],
        maximumAllowableMaternityLeaves:
            json["maximumAllowableMaternityLeaves"],
        maximumAllowableMiscarriageLeaves:
            json["maximumAllowableMiscarriageLeaves"],
        maximumAllowableEventLeaves: json["maximumAllowableEventLeaves"],
        maximumAllowableMarriageLeaves: json["maximumAllowableMarriageLeaves"],
        maximumAllowableStudyLeaves: json["maximumAllowableStudyLeaves"],
        maximumAllowableDeathCeremonyLeaves:
            json["maximumAllowableDeathCeremonyLeaves"],
        maximumAllowableHouseWarmingLeaves:
            json["maximumAllowableHouseWarmingLeaves"],
        useHierarchicalMailForLeaveApproval:
            json["useHierarchicalMailForLeaveApproval"],
        mininumDaysToConsiderAsLongLeave:
            json["mininumDaysToConsiderAsLongLeave"],
      );

  Map<String, dynamic> toJson() => {
        "appSettingId": appSettingId,
        "minimumJobOpeningProcessTime": minimumJobOpeningProcessTime,
        "maximumTimesJobOpeningBeProcessed": maximumTimesJobOpeningBeProcessed,
        "leaveAccumulationProcessDuration": leaveAccumulationProcessDuration,
        "maximumAllowableMaternityLeaves": maximumAllowableMaternityLeaves,
        "maximumAllowableMiscarriageLeaves": maximumAllowableMiscarriageLeaves,
        "maximumAllowableEventLeaves": maximumAllowableEventLeaves,
        "maximumAllowableMarriageLeaves": maximumAllowableMarriageLeaves,
        "maximumAllowableStudyLeaves": maximumAllowableStudyLeaves,
        "maximumAllowableDeathCeremonyLeaves":
            maximumAllowableDeathCeremonyLeaves,
        "maximumAllowableHouseWarmingLeaves":
            maximumAllowableHouseWarmingLeaves,
        "useHierarchicalMailForLeaveApproval":
            useHierarchicalMailForLeaveApproval,
        "mininumDaysToConsiderAsLongLeave": mininumDaysToConsiderAsLongLeave,
      };
}

//MARK: Emp Self Leaves
List<EmployeeSelfLeaves> employeeSelfLeavesFromJson(String str) =>
    List<EmployeeSelfLeaves>.from(
        json.decode(str).map((x) => EmployeeSelfLeaves.fromJson(x)));

String employeeSelfLeavesToJson(List<EmployeeSelfLeaves> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EmployeeSelfLeaves {
  final int? employeeId;
  final String? employeeName;
  final String? code;
  final int? employeeLeaveId;
  final double? usedCLsInMonth;
  final double? usedPLsInMonth;
  final String? leaveType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? leaveTypeId;
  final bool? rejected;
  final DateTime? acceptedAt;
  final String? acceptedBy;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? note;
  final String? status;
  final bool? isApprovalEscalated;
  final bool? isHalfDayLeave;
  final String? comments;
  final DateTime? createdAt;
  final String? createdBy;
  final bool? isLeaveUsed;
  final bool? isDeleted;
  final DateTime? rejectedAt;
  final String? rejectedBy;

  EmployeeSelfLeaves({
    this.employeeId,
    this.employeeName,
    this.code,
    this.employeeLeaveId,
    this.usedCLsInMonth,
    this.usedPLsInMonth,
    this.leaveType,
    this.fromDate,
    this.toDate,
    this.leaveTypeId,
    this.rejected,
    this.acceptedAt,
    this.acceptedBy,
    this.approvedAt,
    this.approvedBy,
    this.note,
    this.status,
    this.isApprovalEscalated,
    this.isHalfDayLeave,
    this.comments,
    this.createdAt,
    this.createdBy,
    this.isLeaveUsed,
    this.isDeleted,
    this.rejectedAt,
    this.rejectedBy,
  });

  factory EmployeeSelfLeaves.fromJson(Map<String, dynamic> json) =>
      EmployeeSelfLeaves(
        employeeId: json["employeeId"],
        employeeName: json["employeeName"],
        code: json["code"],
        employeeLeaveId: json["employeeLeaveId"],
        usedCLsInMonth: json["usedCLsInMonth"]?.toDouble(),
        usedPLsInMonth: json["usedPLsInMonth"]?.toDouble(),
        leaveType: json["leaveType"],
        fromDate:
            json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
        toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
        leaveTypeId: json["leaveTypeId"],
        rejected: json["rejected"],
        acceptedAt: json["acceptedAt"] == null
            ? null
            : DateTime.parse(json["acceptedAt"]),
        acceptedBy: json["acceptedBy"],
        approvedAt: json["approvedAt"] == null
            ? null
            : DateTime.parse(json["approvedAt"]),
        approvedBy: json["approvedBy"],
        note: json["note"],
        status: json["status"],
        isApprovalEscalated: json["isApprovalEscalated"],
        isHalfDayLeave: json["isHalfDayLeave"],
        comments: json["comments"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        createdBy: json["createdBy"],
        isLeaveUsed: json["isLeaveUsed"],
        isDeleted: json["isDeleted"],
        rejectedAt: json["rejectedAt"] == null
            ? null
            : DateTime.parse(json["rejectedAt"]),
        rejectedBy: json["rejectedBy"],
      );

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "employeeName": employeeName,
        "code": code,
        "employeeLeaveId": employeeLeaveId,
        "usedCLsInMonth": usedCLsInMonth,
        "usedPLsInMonth": usedPLsInMonth,
        "leaveType": leaveType,
        "fromDate": fromDate?.toIso8601String(),
        "toDate": toDate?.toIso8601String(),
        "leaveTypeId": leaveTypeId,
        "rejected": rejected,
        "acceptedAt": acceptedAt?.toIso8601String(),
        "acceptedBy": acceptedBy,
        "approvedAt": approvedAt?.toIso8601String(),
        "approvedBy": approvedBy,
        "note": note,
        "status": status,
        "isApprovalEscalated": isApprovalEscalated,
        "isHalfDayLeave": isHalfDayLeave,
        "comments": comments,
        "createdAt": createdAt?.toIso8601String(),
        "createdBy": createdBy,
        "isLeaveUsed": isLeaveUsed,
        "isDeleted": isDeleted,
        "rejectedAt": rejectedAt?.toIso8601String(),
        "rejectedBy": rejectedBy,
      };
}
