// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/Model%20Class/LookupDetail.dart';
import 'package:hrms/Model%20Class/employee_self_leaves.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/common_widgets/custom_textfield.dart';
import 'package:hrms/holiday_model.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:hrms/styles.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestApplyLeave extends StatefulWidget {
  final String? leaveType;
  final int? leaveTypeId;
  final String? employeName;

  const TestApplyLeave(
      {super.key, this.leaveType, this.leaveTypeId, this.employeName});

  @override
  State<TestApplyLeave> createState() => _TestApplyLeaveState();
}

class _TestApplyLeaveState extends State<TestApplyLeave> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _leaveReasonController = TextEditingController();
  int? selectedleaveTypeDropdownId;
  int? selectedDropdownLookupDetailId;
  String? selectedDropdownLeaveName;
  int? selectedLeaveDescriptionId;
  bool confirmedToSplitWFH = false;
  String? wfhId;
  String? leaveIdsToDelete;
  // String? selectedValue;

  int? selectedDescriptionId;
  String selectedValue = '';
  String selectedName = '';

  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  bool leaveTypeValidator = false;
  bool leaveDescriptionValidator = false;

  bool? isHalfDayLeave = false;
  bool isRequestProcessing = false;

  TextStyle txStyFS15FFc = const TextStyle(fontFamily: 'Calibri');

  late String accessToken;
  late Future<List<LookupDetail>> futreLeaveTypes;
  late Future<List<LeaveDescriptionModel>> futreLeaveDescription;
  late List<Holiday_Model> holidayList;
  late LeaveValidationsModel leaveValidationsModel;
  // late Future<List<EmployeeSelfLeaves>> empSelfLeaves;
  late List<EmployeeSelfLeaves> empSelfLeaves;
  String? logintime;
  bool ismatchedlogin = false;
  @override
  void initState() {
    super.initState();
    prepopulateIfDataExists();
    futreLeaveTypes = getLeaveTypes();
    getLoginTime();
    print(
        'TestApplyLeave: ${widget.employeName} | ${widget.leaveType} | ${widget.leaveTypeId}');
    initializeData();
  }

  void prepopulateIfDataExists() {
    if (widget.leaveType != null) {
      selectedleaveTypeDropdownId = widget.leaveType == 'CL' ? 0 : 1;
      selectedDropdownLookupDetailId = widget.leaveTypeId;
      selectedDropdownLeaveName = widget.leaveType;
      futreLeaveDescription =
          getLeaveDescription(lookupDetailsId: widget.leaveTypeId);
    }
  }

  Future<void> initializeData() async {
    holidayList = await getLeaves();
    empSelfLeaves = await getEmpLeaves();
    leaveValidationsModel = await getLeaveValidations();
  }

//MARK: Dropdown API
  Future<List<LookupDetail>> getLeaveTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';
    final dayWorkStatus = prefs.getInt('dayWorkStatus') ?? 0;
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 5);
      FocusScope.of(context).unfocus();
      throw Exception(''); // 'Please Check the Internet Connection'
    }

    final APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    final url = Uri.parse('$baseUrl$getdropdown$dayWorkStatus');
    print('getLeaveTypes: $url');
    final jsonResponse = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'APIKey': APIKey,
      },
    );

    if (jsonResponse.statusCode == 200) {
      List<dynamic> response = json.decode(jsonResponse.body);
      List<dynamic> filteredResponse = response
          .where(
              (element) => element['name'] != 'PT' && element['name'] != 'AT')
          // element['lookupDetailId'] != 100 &&
          // element['lookupDetailId'] != 101)
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
    print('getLeaveDescription: $lookupDetailsId');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final leaveReasons = prefs.getInt('leavereasons') ?? 0;
      final APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      final apiUrl =
          Uri.parse('$baseUrl$getdropdown$leaveReasons/$lookupDetailsId');
      final jsonResponse = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'APIKey': APIKey,
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
   final APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    int currentYear = DateTime.now().year;
    // final apiUrl = Uri.parse(
    // 'http://182.18.157.215/HRMS/API/hrmsapi/Admin/GetHolidays/2025/1');
    final apiUrl = Uri.parse('$baseUrl$GetHolidayList$currentYear/1');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'APIKey': APIKey,
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

  void login(String logintime) {
    DateTime currentTime = DateTime.now();
    DateTime formattedlogintime = DateTime.parse(logintime);
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
    /*  if (timeDifference.inSeconds <= 3600) {
      print("Login is within 1 hour of current time.");
      setState(() {
        ismatchedlogin = false;
      });
    } else {
      print("Login is more than 1 hour from current time.");
      setState(() {
        ismatchedlogin = true;
        throw SessionTimeOut('Session Time Out');
      });
    } */
  }

//MARK: Build Method
  @override
  Widget build(BuildContext context) {
  //  if (ismatchedlogin) Future.microtask(() => showtimeoutdialog(context));
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
                      if (leaveTypeValidator)
                        Column(
                          children: [
                            leaveTypeValidation(),
                            // const SizedBox(height: 10),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (selectedDropdownLeaveName == 'CL' ||
                          selectedDropdownLeaveName == 'PL' ||
                          widget.leaveTypeId != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leaveDescriptionDropdown(),
                            if (leaveDescriptionValidator)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  leaveDescriptionValidation(),
                                  // const SizedBox(height: 10),
                                ],
                              ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      if (selectedDropdownLeaveName == 'CL' ||
                          selectedDropdownLeaveName == 'PL' ||
                          widget.leaveTypeId != null)
                        Column(
                          children: [
                            halfDayCheckBox(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      fromDateField(),
                      const SizedBox(height: 10),
                      if (selectedDropdownLeaveName != 'CL' &&
                          isHalfDayLeave == false)
                        Column(
                          children: [
                            toDateField(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      leaveDescription(),
                      const SizedBox(height: 20),
                      addLeaveBtn(),
                      /* const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () {}, child: const Text('test')), */
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

  Future<void> launchToDate() async {
    DateTime? initialDate = calculateCLInitialDate(holidayList);
    // DateTime? initialDate = calculateInitialDate(holidayList);
    print('launchToDate: $initialDate');
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
        checkLeaveTypeAndLaunchDatePicker(selectedDropdownLeaveName);
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please select From Date';
        }
        return null;
      },
      suffixIcon: const Icon(
        Icons.calendar_today,
        color: Colors.black54,
      ),
    );
  }

  CustomTextField toDateField() {
    return CustomTextField(
      hintText: 'To Date',
      controller: _toDateController,
      fillColor: selectedFromDate == null ? Colors.grey[300] : Colors.white,
      onTap: selectedFromDate == null ? null : launchToDate,
/*       validator: (value) {
        if (value!.isEmpty) {
          return 'Please select To Date';
        }
        return null;
      }, */
      suffixIcon: const Icon(
        Icons.calendar_today,
        color: Colors.black54,
      ),
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
      String? selectedDropDownLeaveName
      // int? selectedDropdownLookupDetailId
      ) async {
    DateTime today = DateTime.now();
    print('checkLeaveTypeAndLaunchDatePicker: $selectedDropDownLeaveName');
    switch (selectedDropDownLeaveName) {
      case 'CL': // CL | 102 // CASUAL LEAVE
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
      case 'PL': // PL | 103 // PRIVILEGE LEAVE
        {
          // DateTime? initialDate = calculatePLInitialDate(holidayList);
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) => selectableDayPredicate(
              date,
              leaves: holidayList,
              // initialDate: initialDate,
            ),
            onDateSelected: onDateSelectedForFromDate,
          );
        }
        break;
      case 'LWP': // LWP | 104 // LEAVE WITHOUT PAY
        {
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForOthers(date, holidayList),
            onDateSelected: onDateSelectedForFromDate,
          );
        }
        break;
      case 'WFH': // WFH | 160 // WORK FROM HOME
        {
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForOthers(date, holidayList),
            onDateSelected: onDateSelectedForFromDate,
          );
        }
        break;
      case 'LL': // LL | 179 // LONG LEAVE
        {
          Commonutils.launchDatePicker(
            context,
            // initialDate: initialDate,
            firstDate: today,
            selectableDayPredicate: (DateTime date) =>
                selectableDayPredicateForOthers(date, holidayList),
            onDateSelected: onDateSelectedForFromDate,
          );
        }
        break;
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

  Container leaveTypeValidation() {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 8),
      child: const Text(
        'Please select Leave Type',
        style: TextStyle(fontSize: 12, color: Color(0xff98423a)),
      ),
    );
  }

  Container leaveDescriptionValidation() {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 8),
      child: const Text(
        'Please select Leave Description',
        style: TextStyle(fontSize: 12, color: Color(0xff98423a)),
      ),
    );
  }

//MARK: Add Leave Btn
  SizedBox addLeaveBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isRequestProcessing
            ? null
            : () async {
                FocusScope.of(context).unfocus();
                setState(() {
                  isRequestProcessing = true;
                });
                if (validateFields()) {
                  confirmedToSplitWFH = false;
                  wfhId = null;
                  getLeavesAllocationAndApplyLeave();
                } else {
                  setState(() {
                    isRequestProcessing = false;
                  });
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isRequestProcessing ? Colors.grey.shade400 : Styles.primaryColor,
          elevation: isRequestProcessing ? 0 : 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: isRequestProcessing
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Styles.primaryColor,
                ))
            : const Text(
                'Apply Leave',
                style: TextStyle(
                    color: Colors.white, fontSize: 15, fontFamily: 'Calibri'),
              ),
      ),
    );
  }

  bool validateFields() {
    print('_formKey selectedleaveTypeDropdownId: $selectedleaveTypeDropdownId');
    print('_formKey selectedTypeName: $selectedDropdownLeaveName');
    print('_formKey selectedTypId: $selectedDropdownLookupDetailId');
    print('_formKey selectedLeaveDescription: $selectedLeaveDescriptionId');
    print('_formKey isHalfDay: $isHalfDayLeave');
    print('_formKey From Date: ${_fromDateController.text}');
    print('_formKey To Date: ${_toDateController.text}');
    print('_formKey Leave Reason: ${_leaveReasonController.text}');
    /*  if (!_formKey.currentState!.validate()) {
      print('_formKey selectedLeaveDescriptionId: $selectedLeaveDescriptionId');
      return false;
    } */
    // validationForLL();

    if (selectedleaveTypeDropdownId == null ||
        selectedleaveTypeDropdownId == -1) {
      leaveTypeValidator = true;
    } else {
      leaveTypeValidator = false;
    }
    if (selectedDropdownLeaveName == 'CL' &&
        selectedDropdownLeaveName == 'PL') {
      if (selectedLeaveDescriptionId == null ||
          selectedLeaveDescriptionId == -1) {
        leaveDescriptionValidator = true;
      } else {
        leaveDescriptionValidator = false;
      }
    }

    if (_formKey.currentState!.validate() &&
        !leaveTypeValidator &&
        !leaveDescriptionValidator) {
      print('Form Validated succussfully');
      // leaveValidation(selectedDropdownLookupDetailId);
      return true;
    }
    setState(() {});
    return false;
  }

  void validationForLL() {
    // if (selectedDropdownLookupDetailId == 179) {
    if (selectedDropdownLeaveName == 'LL') {
      // LL Validation
      if (selectedFromDate != null && selectedToDate != null) {
        final difference = selectedToDate?.difference(selectedFromDate!).inDays;
        if (difference! < 7) {
          Commonutils.showCustomToastMessageLong(
              'Long Leave must be apply minimum 7 days', context, 1, 5);
          return;
        }
      }
    }
  }

  bool ensureLeaveAvailability({
    required List<EmployeeSelfLeaves> empSelfLeaves,
    DateTime? formFromDate,
    DateTime? formToDate,
    required List<String> statusesToCheck,
    String? leaveTypeName,
    bool isWFHOverlapping = false,
  }) {
    print(
        'ensureLeaveAvailability: argues: $formFromDate | $formToDate | $statusesToCheck | $leaveTypeName | $isWFHOverlapping');
    if (isWFHOverlapping) return false;
    for (var leave in empSelfLeaves) {
      if (leave.isDeleted != true && !statusesToCheck.contains(leave.status)) {
        DateTime? leaveFromDate = leave.fromDate;
        DateTime? leaveToDate = leave.toDate;

        if (leaveFromDate != null && leaveToDate != null) {
          // Check for overlap
          bool isWithinRange = formFromDate!
                  .isBefore(leaveToDate.add(const Duration(days: 1))) &&
              (formToDate == null ||
                  formToDate.isAfter(
                      leaveFromDate.subtract(const Duration(days: 1))));

          if (isWithinRange && leaveTypeName != 'CL') {
            final message =
                '''The current leave request from '${Commonutils.ddMMyyyyFormat(formFromDate)}' ${selectedToDate != null ? 'to ${Commonutils.ddMMyyyyFormat(formToDate)}' : ''} is overlapping with applied leaves. Please check and try again.''';
            Commonutils.showCustomToastMessageLong(message, context, 1, 5);
            return true;
          }
/*           print('ensureLeaveAvailability: ${JsonEncoder().convert(leave)}');
          print(
              'ensureLeaveAvailability: ${leaveTypeId == 102} | ${leave.leaveType} ${leave.leaveType == 'CL'} | ${leaveFromDate.month == formFromDate.month} | ${leaveFromDate.year == formFromDate.year} | ${leaveFromDate.day == formFromDate.day} | ${![
            'Rejected'
          ].contains(leave.status)}'); */

          if (leaveFromDate.month == formFromDate.month &&
              leaveFromDate.year == formFromDate.year &&
              leaveFromDate.day == formFromDate.day &&
              !['Rejected'].contains(leave.status)) {
            final message =
                '''The current leave request on '${Commonutils.ddMMyyyyFormat(formFromDate)}' is overlapping with applied leaves. Please check and try again.''';

            Commonutils.showCustomToastMessageLong(message, context, 1, 5);

            // throw Exception(message);
            return true;
          }

          if (leaveTypeName == 'CL' &&
              leave.leaveType == 'CL' &&
              leaveFromDate.month == formFromDate.month &&
              leaveFromDate.year == formFromDate.year &&
              leaveFromDate.day == formFromDate.day &&
              !['Rejected'].contains(leave.status)) {
            final message =
                '''The current leave request on '${Commonutils.ddMMyyyyFormat(formFromDate)}' is overlapping with applied leaves. Please check and try again.''';

            Commonutils.showCustomToastMessageLong(message, context, 1, 5);

            // throw Exception(message);
            return true;
          }
          if (leaveTypeName == 'CL' &&
              leave.leaveType == 'CL' &&
              leaveFromDate.month == formFromDate.month &&
              leaveFromDate.year == formFromDate.year &&
              !['Rejected', 'Approved'].contains(leave.status)) {
            final message =
                '''Kindly confirm whether you wish to retract the previously submitted a leave on '${Commonutils.ddMMyyyyFormat(leave.fromDate)}' which has not yet been approved. Please click 'Confirm' to proceed with revoking the previously applied leave request or 'Cancel' to stop the creation of the current leave.''';
            // '''You have already a '${leave.leaveType}' range of ${Commonutils.ddMMyyyyFormat(leave.fromDate)} ${selectedToDate != null ? 'to ${Commonutils.ddMMyyyyFormat(formToDate)}' : ''} with the status of '${leave.status}'.''';

            showCustomDialog(context, title: 'Confirmation', message: message,
                onConfirm: () {
              leaveIdsToDelete = leave.employeeLeaveId.toString();
              createLeave();
            });
            return true;
          }
          if (!isWFHOverlapping &&
              leaveTypeName == 'CL' &&
              leave.leaveType == 'CL' &&
              leaveFromDate.month == formFromDate.month &&
              leaveFromDate.year == formFromDate.year &&
              ['Approved'].contains(leave.status) &&
              !leave.fromDate!.isAtSameMomentAs(DateTime.now()) &&
              leave.fromDate!.isAfter(DateTime.now())) {
            final message =
                '''Kindly confirm whether you wish to retract the previously submitted a leave on '${Commonutils.ddMMyyyyFormat(leave.fromDate)}' which has already been approved. Please click 'Confirm' to proceed with revoking the previously applied leave request or 'Cancel' to stop the creation of the current leave.''';
            // '''${leave.employeeName} has a approved CL on this date '${Commonutils.ddMMyyyyFormat(leave.fromDate)}', so the leave request is not valid.''';

            showCustomDialog(context, title: 'Confirmation', message: message,
                onConfirm: () {
              leaveIdsToDelete = leave.employeeLeaveId.toString();
              createLeave();
            });
            return true;
          }

          if (!isWFHOverlapping &&
              leaveTypeName == 'CL' &&
              leave.leaveType == 'CL' &&
              leaveFromDate.month == formFromDate.month &&
              leaveFromDate.year == formFromDate.year &&
              ['Approved'].contains(leave.status)) {
            final message =
                '''An approved leave for the month of January on '${Commonutils.ddMMyyyyFormat(leave.fromDate)}' which has already been approved and utilized. The leave cannot be created.''';
            // '''${leave.employeeName} has a approved CL on this date '${Commonutils.ddMMyyyyFormat(leave.fromDate)}', so the leave request is not valid.''';

            Commonutils.showCustomToastMessageLong(message, context, 1, 5);
            return true;
          }
        }
      }
    }

    print(
        'checkLeaveStatus22: Success: Selected dates do not overlap with any existing leave ranges.');
    return false;
  }

  Future<bool> checkingWfhDatesClashOrNot({
    required List<EmployeeSelfLeaves> empSelfLeaves,
    DateTime? selectedFromDate,
    DateTime? selectedToDate,
    required List<String> statusesToCheck,
    String? leaveTypeName,
  }) async {
    print(
        'checkingWfhDatesClashOrNot: argues $selectedFromDate | $selectedToDate | $statusesToCheck | $leaveTypeName');
    for (var leave in empSelfLeaves) {
      // Checking only leaves which are not deleted & status is not rejected & leave type is 160(WFH)
      if (leave.isDeleted != true &&
          !statusesToCheck.contains(leave.status) &&
          leave.leaveType == 'WFH') {
        DateTime? leaveFromDate = leave.fromDate;
        DateTime? leaveToDate = leave.toDate;

        if (leaveFromDate != null && leaveToDate != null) {
          // Check for overlap
          bool isWithinRange = selectedFromDate!
                  .isBefore(leaveToDate.add(const Duration(days: 1))) &&
              (selectedToDate == null ||
                  selectedToDate.isAfter(
                      leaveFromDate.subtract(const Duration(days: 1))));

          print(
              'checkLeaveStatus33 leaveTypeId: $leaveTypeName |  ${leave.leaveTypeId} | ${leave.fromDate} |  ${leave.toDate} | ${leave.status}');

          if (isWithinRange) {
            showCustomDialog(
              context,
              title: 'Confirmation',
              // title: 'WFH Overlap Dialog',
              message: Constants.wfhDialogMessage,
              onConfirm: () {
                confirmedToSplitWFH = true;
                wfhId = leave.employeeLeaveId.toString();
                createLeave();
              },
            );
            return true;
          }
        }
      }
    }
    // No WFH overlap
    return false;
  }

  DateTime? checkApprovedCLLeaveDateInMonth(
      List<EmployeeSelfLeaves> empSelfLeaves, DateTime fromDateObj) {
    for (var leave in empSelfLeaves) {
      if (leave.leaveType == 'CL' &&
          leave.status != 'Rejected' &&
          leave.isDeleted != true) {
        if (leave.fromDate != null &&
            leave.fromDate!.year == fromDateObj.year &&
            leave.fromDate!.month == fromDateObj.month) {
          return leave.fromDate;
        }
      }
    }
    return null;
  }

  bool leaveValidation(String? leaveTypeName, double countOfLeaves) {
    late bool isLeaveValid;
    print(
        'leaveValidation: $leaveTypeName | $countOfLeaves | ${countOfLeaves <= 0}');

    if (countOfLeaves <= 0 && selectedFromDate!.year > DateTime.now().year) {
      // selected year is future then display
      Commonutils.showCustomToastMessageLong(
          Constants.futureDatesErrMsg, context, 1, 3);
      return false;
    }

    switch (leaveTypeName) {
      case 'CL':
        // CL Validation
        isLeaveValid = clLeaveCondition(countOfLeaves);
        break;
      case 'PL':
        // PL Validation
        isLeaveValid = plLeaveCondition(countOfLeaves);
        break;
      case 'LWP':
        // LWP Validation
        isLeaveValid = true;
        break;
      case 'WFH':
        // WFH Validation
        isLeaveValid = wfhLeaveCondition(countOfLeaves);
      case 'LL':
        // LL Validation
        isLeaveValid = llLeaveCondition();
        break;
      default:
        isLeaveValid = true;
    }
    return isLeaveValid;
  }

  // leave.status == 'Approved'
  DateTime? getAppliedCLLeaveDateInMonth(
      List<EmployeeSelfLeaves> empSelfLeaves, DateTime fromDateObj) {
    for (var leave in empSelfLeaves) {
      if (leave.leaveType == 'CL' &&
          ((leave.status == 'Pending' || leave.status == 'Accepted') &&
              leave.isDeleted != true)) {
        // Check if the month and year match
        if (leave.fromDate != null &&
            leave.fromDate!.year == fromDateObj.year &&
            leave.fromDate!.month == fromDateObj.month) {
          print('test22: ${leave.isDeleted}');
          print('test22: ${leave.fromDate}');
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
    BuildContext context, {
    required String title,
    required String message,
    bool isActions = true,
    void Function()? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            // 'Confirmation',
            title,
            style: const TextStyle(
              color: Styles.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white)),
                    /* style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                  ), */
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      confirmedToSplitWFH = false;
                      wfhId = null;
                      // Add your submit logic here
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> createLeave() async {
    try {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (!isConnected) {
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection', context, 1, 5);
        return;
      }
      // checking session time out
      await getLoginTime();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString("employeeId");
      final accessToken = prefs.getString("accessToken") ?? '';
      final apiUrl = Uri.parse(baseUrl + applyleaveapi);
      final loadedData = await SharedPreferencesHelper.getCategories();
      final employeeName = loadedData?['employeeName'];

      final requestBody =

/*     jsonEncode({
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
    }); */
          jsonEncode({
        "employeeId": employeeId,
        "sFromDate": Commonutils.formatApiDate(selectedFromDate),
        "sToDate": isHalfDayLeave == true
            ? null
            : Commonutils.formatApiDate(selectedToDate),
        "fromDate": Commonutils.getDateWithOneDaySubtracted(selectedFromDate),
        "toDate": isHalfDayLeave == true
            ? null
            : Commonutils.getDateWithOneDaySubtracted(selectedToDate),
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
        // "employeeName": employeeName,
        // "getLeaveType": getLeaveType(selectedDropdownLookupDetailId!),
        "isHalfDayLeave": isHalfDayLeave,
        "leaveReasonId": selectedDropdownLookupDetailId,
        "isFromAttendance": false,
// change
        "isDeleted": false,
        "employeeLeaveId": null,
        "leaveIdsToDelete": leaveIdsToDelete,
        "confirmedToSplitWFH": confirmedToSplitWFH,
        "wfhId": wfhId,
      });

      print('createLeave: $requestBody');

      final jsonResponse = await http.post(
        apiUrl,
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      setState(() {
        isRequestProcessing = false;
      });
      if (jsonResponse.statusCode == 200) {
        Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        print('lol: Leave applied successfully');
        if (response['isSuccess']) {
          Commonutils.showCustomToastMessageLong(
              '${selectedDropdownLeaveName == 'WFH' ? selectedDropdownLeaveName : 'Leave'} Applied Successfully',
              context,
              0,
              3);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );
        } else {
          Commonutils.showCustomToastMessageLong(
              response['message'] as String, context, 1, 5);
        }
      } else if (jsonResponse.statusCode == 520) {
        Commonutils.showCustomToastMessageLong(
            jsonResponse.body, context, 1, 5);
      } else {
        Commonutils.showCustomToastMessageLong(
            'Something went wrong, please check your leaves and apply again.',
            context,
            1,
            5);
      }
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      Commonutils.showCustomToastMessageLong(e.toString(), context, 1, 5);
      rethrow;
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
                selectedToDate = null;
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
            if (snapshot.error.toString().contains('SocketException')) {
              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Text('No Leave Types Found'),
              );
            }
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
                  value: selectedleaveTypeDropdownId,
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
                      selectedleaveTypeDropdownId = value!;
                      final selectedItem = leaveTypes.firstWhere((item) =>
                          item.lookupDetailId ==
                          leaveTypes[selectedleaveTypeDropdownId!]
                              .lookupDetailId);
                      selectedDropdownLookupDetailId =
                          selectedItem.lookupDetailId;

                      selectedDropdownLeaveName = selectedItem.name;
                      print(
                          'selectedDropdownLookupDetailId: ${leaveTypes[selectedleaveTypeDropdownId!].name} | $selectedDropdownLookupDetailId || $selectedDropdownLeaveName');

                      if (selectedDropdownLeaveName == 'CL' ||
                          selectedDropdownLeaveName == 'PL') {
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
                      thickness: WidgetStateProperty.all<double>(6),
                      thumbVisibility: WidgetStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 20),
                  ),
                ),
              );
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
                  value: selectedleaveTypeDropdownId,
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
                      selectedleaveTypeDropdownId = value!;
                      final selectedItem = leaveTypes.firstWhere((item) =>
                          item.lookupDetailId ==
                          leaveTypes[selectedleaveTypeDropdownId!]
                              .lookupDetailId);
                      selectedDropdownLookupDetailId =
                          selectedItem.lookupDetailId;
                      print(
                          'selectedDropdownLookupDetailId: ${leaveTypes[selectedleaveTypeDropdownId!].name} | $selectedDropdownLookupDetailId');

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
                      thickness: WidgetStateProperty.all<double>(6),
                      thumbVisibility: WidgetStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 20),
                  ),
                ),
              );
          */
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
                  onChanged: (int? value) {
                    print('Selected description: $value');
                    setState(() {
                      selectedLeaveDescriptionId = value!;
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
                      thickness: WidgetStateProperty.all<double>(6),
                      thumbVisibility: WidgetStateProperty.all<bool>(true),
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
          // Navigator.pop(context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );
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


  Future<void> deleteLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginTime');
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

  Future<int> checkLeavesAllocation(
      String fromDate, String? selectedLeaveName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken") ?? '';
      final empId = prefs.getString("employeeId") ?? "";
      String brnchId = prefs.getString(SharedKeys.brnchId) ?? "";
      print('====$brnchId');
      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      final apiUrl = '$baseUrl$getleaveStatistics${fromDate.split('-')[2]}/$brnchId/$empId';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'APIKey': APIKey,
      };

      final jsonResponse = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      print('checkLeaves: $apiUrl');

      if (selectedFromDate != null && selectedToDate != null) {
        if (selectedFromDate!.year != selectedToDate!.year) {
          return 102; // years different
        }
      }

      if (jsonResponse.statusCode == 200) {
        final Map<String, dynamic> response = jsonDecode(jsonResponse.body);

        final isLeaveValid = leaveValidation(selectedLeaveName,
            checkForLeavesAvailability(selectedLeaveName, response));
        /* if (checkForLeavesAvailability(selectedDropdownLookupDetailId, response) >
          0) {
        return 200;
      } */
        if (isLeaveValid) {
          return 200;
        }
        return 400;
      }
      return 500; // api failed
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      rethrow;
    }
  }

  double checkForLeavesAvailability(
      String? leaveTypeName, Map<String, dynamic> response) {
    late double allocatedLeaves;
    late double usedLeaves;
    double availableLeaves = 0;
    switch (leaveTypeName) {
      case 'CL': // CL
        allocatedLeaves = response['allottedCasualLeaves'] ?? 0.0;
        usedLeaves = response['usedCasualLeavesInYear'] ?? 0.0;
        availableLeaves = allocatedLeaves.toDouble() - usedLeaves.toDouble();
        break;
      case 'PL': // PL
        allocatedLeaves = response['allottedPrivilegeLeaves'] ?? 0.0;
        usedLeaves = response['usedPrivilegeLeavesInYear'] ?? 0.0;
        availableLeaves = allocatedLeaves.toDouble() - usedLeaves.toDouble();
        break;
      case 'LWP': // LWP
        // availableLeaves = response['totalLWPsInYear'] ?? 0.0;
        availableLeaves = 100;
        break;
      case 'WFH': // WFH
        // availableLeaves = response['longLeavesInanYear'] ?? 0.0;
        availableLeaves = 100;
        break;
      case 'LL': // LL
        // availableLeaves = response['longLeavesInanYear'] ?? 0.0;
        availableLeaves = 100;
        break;
      default:
        availableLeaves = 0;
        break;
    }
    return availableLeaves;
  }

  bool plLeaveCondition(double countOfLeaves) {
    print(
        'plLeaveCondition: $countOfLeaves | $selectedFromDate | $selectedToDate | ${selectedFromDate == DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)}');
    if (selectedDropdownLeaveName == 'PL' &&
        (selectedFromDate ==
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day))) {
      print('plLeaveCondition: You cannot apply PL on current date');
      Commonutils.showCustomToastMessageLong(
          Constants.plCurrentDateErrorMessage,
          // 'Years must be same while applying a leave',
          context,
          1,
          5);
      return false;
    }

    /* if ((selectedFromDate != null && selectedToDate != null) &&
        selectedDropdownLeaveName == 'PL') {
      int leaveDuration = selectedToDate!.difference(selectedFromDate!).inDays;

      if (leaveDuration > 6) {
        Commonutils.showCustomToastMessageLong(
            'PL must be less than 6 days.', context, 1, 5);
        return false;
      }

      if (countOfLeaves <= 6) {
        Commonutils.showCustomToastMessageLong(
            'You have only $countOfLeaves PL\'s available', context, 1, 5);
        return false;
      }
    } */
    if ((selectedFromDate != null && selectedToDate != null) &&
        selectedDropdownLeaveName == 'PL') {
      int totalDays = selectedToDate!.difference(selectedFromDate!).inDays + 1;
      int weekendDays = 0;

      for (int i = 0; i < totalDays; i++) {
        DateTime currentDate = selectedFromDate!.add(Duration(days: i));
        if (currentDate.weekday == DateTime.saturday ||
            currentDate.weekday == DateTime.sunday) {
          weekendDays++;
        }
      }

      int leaveDuration = totalDays - weekendDays;

      if (leaveDuration > 6) {
        Commonutils.showCustomToastMessageLong(
            'PL must be less than 6 days.', context, 1, 5);
        return false;
      }

      if (countOfLeaves <= 6) {
        Commonutils.showCustomToastMessageLong(
            'You have only $countOfLeaves PL\'s available', context, 1, 5);
        return false;
      }
    }
    return true;
  }

  bool clLeaveCondition(double countOfLeaves) {
    print(
        'clLeaveCondition: $countOfLeaves | $selectedFromDate | $selectedToDate');

    if (selectedDropdownLeaveName == 'CL' && countOfLeaves <= 0) {
      Commonutils.showCustomToastMessageLong(
          'You have No Casual Leaves available',
          // 'Years must be same while applying a leave',
          context,
          1,
          5);
      return false;
    }

    return true;
  }

  bool wfhLeaveCondition(double countOfLeaves) {
    // print(
    //     'wfhLeaveCondition: $countOfLeaves | $selectedFromDate | $selectedToDate | ${selectedToDate!.difference(selectedFromDate!).inDays}');
    return true;
  }

  void getLeavesAllocationAndApplyLeave() {
    checkLeavesAllocation(
            _fromDateController.text.trim(), selectedDropdownLeaveName)
        .then((int value) {
      print('checkLeavesAllocation: $value');
      switch (value) {
        case 102:
          Commonutils.showCustomToastMessageLong(
              'Please ensure the start and end dates fall within the same year',
              context,
              1,
              3);
          break;
        case 200:
          handleApplyLeave();
          break;
        case 400:
          handle400();
          break;
        case 500:
          handle500();
          break;
      }
    });
  }

  void handle400() {
    setState(() {
      isRequestProcessing = false;
    });
  }

  void handle500() {
    Commonutils.showCustomToastMessageLong(
        'Something went wrong, please try again', context, 1, 5);
    setState(() {
      isRequestProcessing = false;
    });
  }

  bool llLeaveCondition() {
    final maxLongLeavesToApply =
        leaveValidationsModel.mininumDaysToConsiderAsLongLeave;
    if (selectedFromDate == null || selectedToDate == null) {
      Commonutils.showCustomToastMessageLong(
          'Please select From Date and To Date', context, 1, 4);
      return false;
    }
    print(
        'llLeaveCondition: $maxLongLeavesToApply | ${selectedToDate!.difference(selectedFromDate!).inDays + 1}');
    if (maxLongLeavesToApply != null &&
        maxLongLeavesToApply >
            selectedToDate!.difference(selectedFromDate!).inDays + 1) {
      Commonutils.showCustomToastMessageLong(
          'Long Leave must be at least 7 days.', context, 1, 4);
      return false;
    }

    return true;
  }

  Future<void> handleApplyLeave() async {
    final isWFHOverlapping = await checkingWfhDatesClashOrNot(
      empSelfLeaves: empSelfLeaves,
      selectedFromDate: selectedFromDate,
      selectedToDate: selectedToDate ?? selectedFromDate,
      statusesToCheck: ['Rejected'],
      leaveTypeName: selectedDropdownLeaveName,
    );
    final isAlreadyLeaveOnSameDateWithNotRejectedStatus =
        ensureLeaveAvailability(
      empSelfLeaves: empSelfLeaves,
      formFromDate: selectedFromDate,
      formToDate: selectedToDate ?? selectedFromDate,
      statusesToCheck: ['Rejected'],
      // statusesToCheck: ['Pending', 'Accepted'],
      leaveTypeName: selectedDropdownLeaveName,
      isWFHOverlapping: isWFHOverlapping,
    );

    if (isWFHOverlapping) {
      setState(() {
        isRequestProcessing = false;
      });
    } else if (isAlreadyLeaveOnSameDateWithNotRejectedStatus) {
      setState(() {
        isRequestProcessing = false;
      });
    } else {
      createLeave();
    }
  }
}
