import 'dart:convert';

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/personal_details.dart';
import 'package:hrms/shared_keys.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'Commonutils.dart';
import 'Constants.dart';
import 'Model Class/EmployeeLeave.dart';
import 'SharedPreferencesHelper.dart';
import 'holiday_model.dart';
import 'main.dart';

class HolidaysScreen extends StatefulWidget {
  @override
  HolidaysScreen_screenState createState() => HolidaysScreen_screenState();
}

class HolidaysScreen_screenState extends State<HolidaysScreen> {
  String accessToken = '';
  String empolyeid = '';
  String logintime = '';
  List<Holiday_Model> holidaylist = [];
  bool ismatchedlogin = false;
  late Future<List<EmployeeLeave>> EmployeeLeaveData;
  DateTime _selectedDate = DateTime.now();
  DateTime _displayDate = DateTime.now();
  late CalendarController _calendarController;
  String _agendaText = 'No events';

  //PageController _pageController = PageController(initialPage: DateTime.now().month - 1);
  //CalendarController _calendarController = CalendarController();
  // final GlobalKey<SfCalendar> _calendarKey = GlobalKey<SfCalendarState>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        loadAccessToken();
        getLoginTime();
        _calendarController = CalendarController();
        //   _calendarController.displayDate = _displayDate;
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  void _changeView(CalendarView view) {
    setState(() {
      _calendarController.view = view;
    });
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

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      fetchHolidayList(accessToken);
    });
    print("accestokeninapplyleave:$accessToken");
  }

  Future<List<Holiday_Model>> fetchHolidayList(String accessToken) async {
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
      int currentYear = DateTime.now().year;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      String brnchId = prefs.getString(SharedKeys.brnchId) ?? "";

      final url = Uri.parse(baseUrl + GetHolidayList + '$currentYear' + '/' + brnchId);
      print('fetchHoliday: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'APIKey': '$APIKey',
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        List<Holiday_Model> holidayList = jsonData
            .map((holidayJson) => Holiday_Model.fromJson(holidayJson))
            .toList();
        setState(() {
          holidaylist = holidayList;
        });
        print('holidays${holidaylist.length}');
        return holidayList;
      } else {
        throw Exception('Failed to load holidays: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in holiday list: $error');
      return []; // Return empty list in case of an error
    }
  }

  void _updateAgendaText(ViewChangedDetails details) {
    // Assuming you have a method to fetch the agenda for the new month
    final DateTime visibleDate = details.visibleDates.first;
    setState(() {
      _agendaText = 'Agenda for ${visibleDate.month}/${visibleDate.year}';
      // You can customize this part to show actual agenda text based on the month
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (ismatchedlogin) {
    //   Future.microtask(() => _showtimeoutdialog(context));
    // }
    //  final events = Provider.of<EventProvider>(context).events;
    ///  final CalendarController _calendarControler = CalendarController();
    return WillPopScope(
        onWillPop: () async {
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (context) => home_screen()),
          // ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color(0xFFf15f22),
              title: Text(
                'Holidays',
                style: TextStyle(color: Colors.white),
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
                  // Implement your logic to navigate back
                },
              ),
            ),
            body: Container(
              // padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 0.2,
              child: SfCalendar(
                view: CalendarView.month,
                //  showDatePickerButton: true,
                showNavigationArrow: true,
                todayHighlightColor: Color(0xFFf15f22),
                // controller: _calendarController,

                initialSelectedDate: _selectedDate,
                //      onViewChanged: _updateAgendaText,
                todayTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                initialDisplayDate: _displayDate,
                minDate: DateTime(DateTime.now().year, 1, 1),
                maxDate: DateTime(DateTime.now().year, 12, 31),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                ),

                onTap: (CalendarTapDetails details) {
                  if (details.targetElement == CalendarElement.calendarCell &&
                      details.date != null) {
                    setState(() {
                      _selectedDate = details.date!;
                      _displayDate = details.date!;

                      print('_selectedDate ${_selectedDate}');
                      print('_displayDate ${_displayDate}');
                    });
                  }
                },

                dataSource: HolidayDataSource(_getAppointments()),
                monthCellBuilder: _monthCellBuilder,
                monthViewSettings: MonthViewSettings(
                  dayFormat: 'EEE',
                  showTrailingAndLeadingDates: false,
                  showAgenda: true,
                  agendaItemHeight: 50,
                  agendaStyle: AgendaStyle(
                    dateTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf15f22),
                    ),
                    dayTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf15f22),
                    ),
                  ),
                ),
              ),
            )));
  }

  // List<Appointment> _getAppointments() {
  //   return holidaylist.map((holiday) {
  //     return Appointment(
  //       startTime: holiday.fromDate,
  //       endTime: holiday.toDate!.add(Duration(days: 1)), // Ensure the end time is inclusive
  //       subject: holiday.title,
  //       //notes: holiday.description,
  //       color: Color(0xFFf15f22), // Highlight color
  //       isAllDay: true,
  //     );
  //   }).toList();
  // }

  List<Appointment> _getAppointments() {
    List<Appointment> appointments = [];
    for (var holiday in holidaylist) {
      DateTime? current = holiday.fromDate;
      DateTime? endDate = holiday.toDate;
      if (current != null && endDate != null) {
        while (
            current!.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
          appointments.add(
            Appointment(
              startTime: current,
              endTime: endDate,
              subject: holiday.title,
              notes: holiday.description,
              color: Color(0xFFf15f22),
              // color: Colors.deepOrange.shade700,
              // Highlight color
              isAllDay: true,
            ),
          );
          current = current.add(Duration(days: 1));
        }
      }
    }
    return appointments;
  }

  Widget _monthCellBuilder(BuildContext context, MonthCellDetails details) {
    bool isWeekend = details.date.weekday == 6 || details.date.weekday == 7;

    bool isHoliday = holidaylist.any((holiday) =>
        holiday.fromDate != null &&
        holiday.toDate != null &&
        details.date.isAfter(holiday.fromDate!.subtract(Duration(days: 1))) &&
        details.date.isBefore(holiday.toDate!.add(Duration(days: 1))));

    bool isToday = details.date.year == DateTime.now().year &&
        details.date.month == DateTime.now().month &&
        details.date.day == DateTime.now().day;

    String description = '';
    if (isHoliday) {
      Holiday_Model holiday = holidaylist.firstWhere((holiday) =>
          holiday.fromDate != null &&
          holiday.toDate != null &&
          details.date.isAfter(holiday.fromDate!.subtract(Duration(days: 1))) &&
          details.date.isBefore(holiday.toDate!.add(Duration(days: 1))));
      description = holiday.description;
    }
    bool isClickable = !isWeekend; // Disable clicking for weekends

    return Container(
        decoration: BoxDecoration(
          // color: isHoliday ? Color(0xFFf15f22) : Colors.transparent,
          //  color: isToday ? Colors.transparent : (isHoliday ? Color(0xFFf15f22) : Colors.transparent),
          color: isToday
              ? Colors.transparent
              : (isHoliday
                  ? Color(0xFFf15f22)
                  : (isWeekend ? Colors.transparent : Colors.transparent)),

          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: InkWell(
          onTap: isClickable
              ? () {
                  // Handle tap event here
                  print('Clicked on ${details.date}');
                }
              : null,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  details.date.day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    //    fontWeight: FontWeight.bold,
                    // color: isHoliday ? Colors.white : Colors.black87,
                    color: isHoliday
                        ? Colors.white
                        : (isWeekend ? Colors.black12 : Colors.black87),
                  ),
                ),
                // if (isHoliday)
                //   Text(
                //     description,
                //     style: TextStyle(
                //       fontSize: 12,
                //       color: Colors.white,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
              ],
            ),
          ),
        ));
  }
}

class HolidayDataSource extends CalendarDataSource {
  HolidayDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }
}
