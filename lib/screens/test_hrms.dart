// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hrms/common_widgets/common_styles.dart';
import 'package:hrms/personal_details.dart';
import 'package:hrms/screens/AddLeads.dart';
import 'package:hrms/screens/ViewLeads.dart';
import 'package:intl/intl.dart';

class TestHrms extends StatefulWidget {
  const TestHrms({super.key});

  @override
  State<TestHrms> createState() => _TestHrmsState();
}

class _TestHrmsState extends State<TestHrms> {
  bool isButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    /*  if (ismatchedlogin) {
      Future.microtask(() => _showtimeoutdialog(context));
    } */
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFf15f22),
          title: const Text(
            'HRMS',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            backgroundGredient(context),
            Positioned.fill(
              child: Column(
                children: [
                  headerSection(context),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      customBox(title: 'Custom Box 1', data: 1),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child:
                                      customBox(title: 'Custom Box 2', data: 2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            statisticsSection(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      customBox(title: 'Custom Box 3', data: 3),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child:
                                      customBox(title: 'Custom Box 4', data: 4),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: customBtn(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AddLeads()),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 18,
                                          color: CommonStyles.whiteColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Add Client Visit',
                                          style: CommonStyles.txStyF14CwFF5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: customBtn(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ViewLeads(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.view_list_rounded,
                                          size: 18,
                                          color: CommonStyles.whiteColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'View Client Visits',
                                          style: CommonStyles.txStyF14CwFF5,
                                        ),
                                      ],
                                    ),
                                    backgroundColor:
                                        CommonStyles.btnBlueBgColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: customBtn(
                                onPressed: () {},
                                backgroundColor: isButtonEnabled
                                    ? CommonStyles.btnRedBgColor
                                    : CommonStyles.hintTextColor,
                                // Set background color based on enabled/disabled state
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      size: 18,
                                      color: isButtonEnabled
                                          ? CommonStyles.whiteColor
                                          : CommonStyles
                                              .disabledTextColor, // Adjust icon color when disabled
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sync Data',
                                      style: isButtonEnabled
                                          ? CommonStyles.txStyF14CwFF5
                                          : CommonStyles.txStyF14CwFF5.copyWith(
                                              color: CommonStyles
                                                  .disabledTextColor), // Adjust text color when disabled
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Work hours",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "09:00 to 18:00",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon:
                                        const Icon(Icons.play_arrow, size: 18),
                                    label: const Text("Punch In"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container customBox({
    required String title,
    int? data,
    // String bgImg = 'assets/bg_image1.jpg',
    String bgImg = 'assets/card_bg_image.jpg',
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(bgImg),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: CommonStyles.primaryColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: CommonStyles.txStyF20CbluFF5.copyWith(
                fontSize: 16,
                color: CommonStyles.primaryColor,
              )),
          Text(
            '$data',
            style: CommonStyles.txStyF20CbFcF5.copyWith(
              // color: CommonStyles.primaryColor,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton customBtn(
      {Color? backgroundColor = CommonStyles.btnRedBgColor,
      required Widget child,
      void Function()? onPressed}) {
    return ElevatedButton(
      onPressed: () {
        onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }

  Widget statisticsSection() {
    return Row(
      children: [
        const Text(
          'Statistics',
          style: CommonStyles.txStyF16CbFF5,
        ),
        const Spacer(),
        datePopupMenu(
          onSelected: (String selectedDay) {
            print(selectedDay);
          },
        ),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: GestureDetector(
            onTap: () {
              final DateTime currentDate = DateTime.now();
              final DateTime firstDate = DateTime(currentDate.year - 2);

              launchDatePicker(
                context,
                firstDate: firstDate,
                lastDate: DateTime.now(),
                initialDate: DateTime.now(),
              );
            },
            child: const Row(
              children: [
                Text(
                  'dd/MM/yyyy',
                  style: CommonStyles.txStyF14CbFcF5,
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget datePopupMenu({
    required Function(String) onSelected,
    List<String> days = const [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ],
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return days.map((String day) {
          return PopupMenuItem<String>(
            value: day,
            child: Text(day),
          );
        }).toList();
      },
      child: const Icon(Icons.calendar_today), // You can customize this button
    );
  }

  void launchDatePicker(
    BuildContext context, {
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime initialDate,
  }) {
    DateTime parsedInitialDate;

    try {
      parsedInitialDate = DateTime.now();

      // Ensure parsedInitialDate is within the allowed range
      if (parsedInitialDate.isBefore(firstDate) ||
          parsedInitialDate.isAfter(lastDate)) {
        parsedInitialDate = initialDate; // Reset to initialDate if out of range
      }
    } catch (e) {
      parsedInitialDate = initialDate; // Fallback in case of parsing error
    }

    showDatePicker(
      context: context,
      initialDate: parsedInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: CommonStyles.primaryColor,
              ),
              dialogBackgroundColor: Colors.white,
              bannerTheme: const MaterialBannerThemeData(
                backgroundColor: CommonStyles.primaryColor,
                contentTextStyle: TextStyle(color: Colors.white),
              ),
              bottomAppBarTheme: const BottomAppBarTheme(
                color: CommonStyles.primaryColor,
              )),
          child: child!,
        );
        /*  return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.orange, // AppBar background color
            hintColor: Colors.orange, // Accent color
            colorScheme: ColorScheme.light(
              primary: Colors.orange, // Selected date circle color
              onPrimary: Colors.white, // Text color inside selected date
              onSurface: Colors.black, // Default text color
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.orange, // Header background color
              iconTheme: IconThemeData(color: Colors.white), // Back icon color
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Button text color
              ),
            ),
          ),
          child: child!,
        ); */
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {});
      }
    });
  }

  SizedBox employeeInfoBox(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(
                  color: Color(0xFFf15f22),
                  width: 1.5,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 5, 0, 0),
                                child: Text(
                                  "Employee Id",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                                child: Text(
                                  "cisid",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "Gender",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "Gender",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "Office Email Id ",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "OfficeEmailid",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "DOJ",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "formatteddateofjoining",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "Mobile Number ",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "Mobilenum",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "DOB",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontFamily: 'Calibri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "dob",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                child: Text(
                                  "Reporting To",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  ":",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(
                                  "ReportingTo",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox headerSection(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 4.0, // Decreased height
      child: ClipPath(
        clipper: CurvedBottomClipper2(),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFf15f22),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 4.0, // Decreased height
          child: Padding(
            padding: const EdgeInsets.only(left: 0, top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 4.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /* Container(
                                width: MediaQuery.of(context).size.width / 4.0,
                                height:
                                    MediaQuery.of(context).size.height / 8.0,
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      image: AssetImage('assets/bg_image2.jpg'),
                                      fit: BoxFit.fill,
                                    ),
                                    border: Border.all(
                                        color: Colors.white, width: 2.0)),
                              ), */
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 4.0,
                                    height: MediaQuery.of(context).size.height /
                                        8.0,
                                    padding: const EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: const DecorationImage(
                                        image:
                                            AssetImage('assets/bg_image2.jpg'),
                                        fit: BoxFit.fill,
                                      ),
                                      border: Border.all(
                                          color: Colors.white, width: 2.0),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 12,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: InkWell(
                                        onTap: () async {
                                          //  await showBottomSheetForImageSelection(
                                          //                           context);
                                        },
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 15.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          const SizedBox(
                            child: Text(
                              "EmployeName",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'Calibri'),
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          const Text(
                            "Software Developer",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: 'Calibri'),
                          ),
                          const Text(
                            "10 AUG 1999",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: 'Calibri'),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
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
}

class CurvedBottomClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final roundingHeight =
        size.height * 4 / 5; // Reduced height for smaller curve

    final filledRectangle =
        Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    final roundingRectangle = Rect.fromLTRB(
        -5, size.height - roundingHeight * 2, size.width + 5, size.height);

    final path = Path();
    path.addRect(filledRectangle);

    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
