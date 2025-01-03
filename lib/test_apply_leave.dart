// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Model%20Class/LookupDetail.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/styles.dart';
import 'package:http/http.dart' as http;
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
  // String? selectedValue;
  String selectedValue = '';
  String selectedName = '';

  bool dropDownValidator = false;

  bool? isHalfDay = false;

  TextStyle txStyFS15FFc = const TextStyle(fontFamily: 'Calibri');

  late String accessToken;
  late Future<List<LookupDetail>> futreLeaveTypes;

  @override
  void initState() {
    super.initState();

    futreLeaveTypes = getLeaveTypes();
  }

  final testdropdownItems = [
    {'item': 'Select Leave Type', 'value': '', 'leaveTypeId': -1},
    {'item': 'Casual Leave', 'value': 'CL', 'leaveTypeId': 1},
    {'item': 'Sick Leave', 'value': 'SL', 'leaveTypeId': 2},
    {'item': 'Personal Leave', 'value': 'PL', 'leaveTypeId': 3},
    {'item': 'Work From Home', 'value': 'WFH', 'leaveTypeId': 4},
    {'item': 'Long Leave', 'value': 'LL', 'leaveTypeId': 5},
  ];

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

      List<LookupDetail> lookupDetails = response
          .map((data) => LookupDetail.fromJson(data as Map<String, dynamic>))
          .toList();
      return lookupDetails;
      /*  if (jsonResponse is List<dynamic>) {
        setState(() {
          lookupDetails =
              jsonResponse.map((data) => LookupDetail.fromJson(data)).toList();
        });
      } else {
        print('Unexpected response format: $jsonResponse');
        throw Exception('Failed to load data. Unexpected response format.');
      } */
    } else {
      throw Exception('Failed to load data: ${jsonResponse.statusCode}');
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ?? '';
  }

  /* 
  Future<void> getLeaveTypes(
      // int leaveReasonLookupId, int lookupDetailId,
      ) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }

    final url =
        Uri.parse('$baseUrl$getdropdown$leaveReasonLookupId/$lookupDetailId');
    print('leave reason $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );
    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      if (responseData is List<dynamic>) {
        /*  setState(() {
          dropdownItems = responseData; // Assign parsed data to dropdownItems
        }); */
      } else {
        print('Response is not in expected format');
      }
    } else {
      print('Failed to fetch data');
    }
  }
 */

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
                      buildDropdown(),
                      if (dropDownValidator)
                        Container(
                          padding: const EdgeInsets.only(left: 15, top: 8),
                          child: const Text(
                            'Please select Leave Type',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 10),
                      halfDayCheckBox(),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'From Date',
                        controller: _fromDateController,
                        onTap: () {
                          Commonutils.launchDatePicker(context);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please select From Date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        hintText: 'To Date',
                        controller: _toDateController,
                        onTap: () {
                          Commonutils.launchDatePicker(context);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please select To Date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                          hintText: 'Leave Reason Description',
                          controller: _leaveReasonController,
                          readOnly: false,
                          maxLines: 6,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Leave Reason';
                            }
                            return null;
                          }),
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

//MARK: Add Leave Btn
  SizedBox addLeaveBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // _fromDateController.text = '2022-01-01';
          if (_formKey.currentState!.validate()) {
            print('_formKey selectedTypeCdId: $selectedDropdownId');
            print('_formKey selectedValue: $selectedValue');
            print('_formKey selectedName: $selectedName');
            print('_formKey isHalfDay: $isHalfDay');
            print('_formKey From Date: ${_fromDateController.text}');
            print('_formKey To Date: ${_toDateController.text}');
            print('_formKey Leave Reason: ${_leaveReasonController.text}');
          }

          setState(() {
            if (selectedDropdownId == null || selectedDropdownId == -1) {
              dropDownValidator = true;
            } else {
              dropDownValidator = false;
            }
          });
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
            value: isHalfDay,
            onChanged: (bool? value) {
              setState(() {
                isHalfDay = value;
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

//MARK: Dropdown
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
                    setState(() {
                      selectedDropdownId = value!;
                      final selectedItem = leaveTypes.firstWhere((item) =>
                          item.lookupDetailId ==
                          leaveTypes[selectedDropdownId!].lookupDetailId);
                      selectedDropdownLookupDetailId = selectedItem.lookupDetailId;
                      print('xxx lookupId: $selectedDropdownLookupDetailId');
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
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.readOnly = true,
    this.maxLines = 1,
    this.onTap,
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
        fillColor: Colors.white,
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ), // Replace with your custom hint style
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
        border: InputBorder.none,
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
