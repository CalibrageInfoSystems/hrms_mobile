// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Database/HRMSDatabaseHelper.dart';
import 'package:hrms/ui_screens/view_leads_info.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/DataAccessHandler.dart';
import '../Model Class/LeadsModel.dart';
import '../common_widgets/common_styles.dart';
import '../common_widgets/custom_lead_template.dart';
import '../common_widgets/custom_textfield.dart';



class ViewLeads extends StatefulWidget {
  const ViewLeads({super.key});

  @override
  State<ViewLeads> createState() => _ViewLeadsState();
}

class _ViewLeadsState extends State<ViewLeads> {
  HRMSDatabaseHelper? palm3FoilDatabase;

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? displayFromDate;
  String? displayToDate;

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  late Future<List<LeadsModel>> futureLeads;
  late List<LeadsModel> copyLeads;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    futureLeads = loadLeads();
    futureLeads.then((data) {
      setState(() {
        copyLeads = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    fromDateController.dispose();
    toDateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: CommonStyles.listOddColor,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          scrolledUnderElevation: 0,
          title: const Text(
            'View Client Visits',
            //  style: CommonStyles.txStyF14CbFF5,
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.more_vert_rounded),
          //   ),
          // ],
        ),
        body: Column(
          children: [
            filterAndSearch(),
            Expanded(
              child: FutureBuilder(
                future: futureLeads,
                  builder: (context, snapshot) {
                    // Check if there's an error
                    if (snapshot.hasError) {
                      return Text(
                        snapshot.error.toString().replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5,
                      );
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      // When the future is completed
                      final leads = snapshot.data as List<LeadsModel>;

                      // Check if the leads list is empty
                      if (leads.isEmpty) {
                        return const Center(
                          child: Text(
                            'No Client Visits Found',
                            style: CommonStyles.txStyF16CpFF5,
                          ),
                        );
                      } else {
                        return ListView.separated(
                          itemCount: leads.length,
                          itemBuilder: (context, index) {
                            final lead = leads[index];

                            return CustomLeadTemplate(
                              index: index,
                              lead: lead,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewLeadsInfo(code: lead.code!),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 0),
                        );
                      }
                    }

                    // If the connection state is still waiting, return an empty container or any other widget you prefer
                    return Container(); // or return SizedBox.shrink();
                  }

                //   builder: (context, snapshot) {
                //   if (snapshot.connectionState == ConnectionState.waiting) {
                //     return loading;
                //   } else if (snapshot.hasError) {
                //     return Text(
                //         snapshot.error
                //             .toString()
                //             .replaceFirst('Exception: ', ''),
                //         style: CommonStyles.txStyF16CpFF5);
                //   } else {
                //     final leads = snapshot.data as List<LeadsModel>;
                //
                //     if (leads.isEmpty) {
                //       return const Center(
                //         child: Text('No Client Visits Found',
                //             style: CommonStyles.txStyF16CpFF5),
                //       );
                //     } else {
                //       return ListView.separated(
                //         itemCount: leads.length,
                //         itemBuilder: (context, index) {
                //           final lead = leads[index];
                //
                //           return CustomLeadTemplate(
                //               index: index,
                //               lead: lead,
                //               onTap: () {
                //                 Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                     builder: (context) =>
                //                         ViewLeadsInfo(code: lead.code!),
                //                   ),
                //                 );
                //               });
                //         },
                //         separatorBuilder: (context, index) =>
                //             const SizedBox(height: 0),
                //       );
                //     }
                //   }
                // },
              ),
            ),
          ],
        ));
  }

  Future<List<LeadsModel>> loadLeads() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final createdByUserId = prefs.getInt('userID');
      print('createdByUserId: $createdByUserId');
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads =
          await dataAccessHandler.getleads(createdByUserId: createdByUserId!);
      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<List<LeadsModel>> getTodayLeads(String today) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads = await dataAccessHandler.getTodayLeads(today);
      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<List<LeadsModel>> filterTheLeads(String query) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> leads = await dataAccessHandler.getFilterData(query);

      return leads.map((item) => LeadsModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Container filterAndSearch() {
    return Container(
      color: CommonStyles.listOddColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 45,
            child: Row(
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: CommonStyles.whiteColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10)),
                    onPressed: () => openFilter(context),
                    child: const SizedBox(
                      height: 45,
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt,
                            color: CommonStyles.dataTextColor,
                          ),
                          Text(
                            'Filter',
                            style: TextStyle(color: CommonStyles.dataTextColor),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 45, // Set the height of the container
                    decoration: BoxDecoration(
                      color: CommonStyles.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      // Optional: Add a shadow for elevation effect
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterLeadsBasedOnCompanyNameAndEmail(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search with Mobile number or Name',
                        hintStyle: TextStyle(color: CommonStyles.dataTextColor),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 25,
                          color: CommonStyles.dataTextColor,
                        ),
                        border: InputBorder.none, // Remove the underline
                        focusedBorder:
                            InputBorder.none, // Remove underline when focused
                        enabledBorder:
                            InputBorder.none, // Remove underline when enabled
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      style: const TextStyle(color: CommonStyles.dataTextColor),
                    ),
                  ),
                )

                /* Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: CommonStyles.whiteColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: CommonStyles.dataTextColor,
                        ),
                        Text(
                          'Search',
                          style: TextStyle(color: CommonStyles.dataTextColor),
                        ),
                      ],
                    ),
                  ),
                ), */
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

 // Timer? _debounce;
  // @override
  // void dispose() {
  //   _debounce?.cancel();
  //   super.dispose();
  // }

  void onSearchTextChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 2), () {
      filterLeadsBasedOnCompanyNameAndEmail(input);
    });
  }
  void filterLeadsBasedOnCompanyNameAndEmail(String input) {

    setState(() {
      futureLeads = Future.value(copyLeads
          .where((item) =>
              item.phoneNumber!.toLowerCase().contains(input.toLowerCase()) ||
              item.name!.toLowerCase().contains(input.toLowerCase()))
          .toList());
    });
  }

  List<String> dates = ['Today', 'This Week', 'Month'];
  List<String> types = ['Company', 'Individual'];
  int dateChipValue = -1;
  int typeChipValue = -1;

//MARK: openFilter
  void openFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Filter(
                dateChipValue: dateChipValue,
                typeChipValue: typeChipValue,
                dates: dates,
                types: types,
                fromDateController: fromDateController,
                toDateController: toDateController,
                onSelectedDateChip: (int selectedIndex) {
                  setModalState(() {
                    if (selectedIndex != -1) {
                      dateChipValue = selectedIndex;
                    }
                  });
                },
                onSelectedTypeChip: (int selectedIndex) {
                  setModalState(() {
                    typeChipValue = selectedIndex;
                  });
                },
                onFromDate: () {
                  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 2);
                  launchFromDatePicker(
                    context,
                    firstDate: firstDate,
                    lastDate: currentDate,
                  );
                },
                onToDate: () {
                  final DateTime currentDate = DateTime.now();
                  final DateTime firstDate = DateTime(currentDate.year - 100);
                  launchToDatePicker(context,
                      firstDate: selectedFromDate ?? firstDate,
                      lastDate: currentDate,
                      initialDate: selectedFromDate);
                },
                onSubmit: (date, category) {
                  /* final result = FilterModel(
                    date: getDate(date),
                    category: getCategory(category),
                    fromDate: validateDate(fromDateController.text),
                    toDate: validateDate(toDateController.text),
                  );
                  print(
                      'Result: ${result.date} ${result.category} ${result.fromDate} ${result.toDate}');

                  final query = buildLeadsQuery(result.date, result.category,
                      result.fromDate, result.toDate);
                  Navigator.pop(context);
                  setState(() {
                    futureLeads = filterTheLeads(query);
                  }); */

                  if (fromDateController.text.isNotEmpty &&
                      toDateController.text.isEmpty) {
                    Navigator.pop(context);

                    showSnackBar('Please select To Date');
                  } else if (fromDateController.text.isEmpty &&
                      toDateController.text.isNotEmpty) {
                    Navigator.pop(context);

                    showSnackBar('Please select From Date');
                  } else if (selectedFromDate != null &&
                      selectedToDate != null) {
                    if (isFromDateGreaterThanToDate(selectedFromDate.toString(),
                        selectedToDate.toString())) {
                      Navigator.pop(context);

                      showSnackBar('From Date cannot be greater than To Date');
                    } else {
                      makeQueryAndFilter(date, category, context);
                    }
                  } else {
                    makeQueryAndFilter(date, category, context);
                  }
                },
                onClear: () {
                  setState(() {
                    dateChipValue = -1;
                    typeChipValue = -1;
                    fromDateController.clear();
                    toDateController.clear();
                    futureLeads = loadLeads();
                    Navigator.pop(context);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  void makeQueryAndFilter(int? date, int? category, BuildContext context) {
    final result = FilterModel(
      date: date,
      category: getCategory(category),
      fromDate: validateDate(fromDateController.text),
      toDate: validateDate(toDateController.text),
    );
    print(
        'Result: ${result.date} ${result.category} ${result.fromDate} ${result.toDate}');

    final query = buildLeadsQuery(
        result.date, result.category, result.fromDate, result.toDate);
    print('Result: $query');
    Navigator.pop(context);
    setState(() {
      futureLeads = filterTheLeads(query);
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool isFromDateGreaterThanToDate(String fromDate, String toDate) {
    DateTime fromDateTime = DateTime.parse(fromDate);
    DateTime toDateTime = DateTime.parse(toDate);

    return fromDateTime.isAfter(toDateTime);
  }

  String? validateDate(String? date) {
    if (date == null || date.isEmpty) {
      return null;
    }
    return convertDate(date);
  }

  String convertDate(String dateStr) {
    DateFormat inputFormat = DateFormat('dd/MM/yyyy');

    DateTime dateTime = inputFormat.parse(dateStr);

    DateFormat outputFormat = DateFormat('yyyy-MM-dd');

    return outputFormat.format(dateTime);
  }
/* 
  String buildLeadsQuery(
      String? date, int? category, String? fromDate, String? toDate) {
    String query = 'SELECT * FROM Leads';

    List<String> conditions = [];

    if (date != null) {
      conditions.add('DATE(CreatedDate) = "$date"');
    }

    if (category != null) {
      conditions.add('IsCompany = $category');
    }

    if (date == null) {
      if (fromDate != null && toDate != null) {
        conditions.add('DATE(CreatedDate) BETWEEN "$fromDate" AND "$toDate"');
      }
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    return query;
  }
 */

  String buildLeadsQuery(
      int? date, int? category, String? fromDate, String? toDate) {
    print('buildLeadsQuery: $date $category $fromDate $toDate');
    String query = 'SELECT * FROM Leads';
    List<String> conditions = [];
    print('Result dates: $fromDate $toDate');
    print('Result date: $date');
    DateTime currentDate = DateTime.now();
    String formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);

    DateTime weekFirstDay =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    String formattedWeekFirstDay =
        DateFormat('yyyy-MM-dd').format(weekFirstDay);

    DateTime monthFirstDay = DateTime(currentDate.year, currentDate.month, 1);
    String formattedMonthFirstDay =
        DateFormat('yyyy-MM-dd').format(monthFirstDay);

    if (date != null) {
      if (date == 0) {
        conditions.add('DATE(CreatedDate) = "$formattedCurrentDate"');
      } else if (date == 1) {
        conditions.add(
            'DATE(CreatedDate) BETWEEN "$formattedWeekFirstDay" AND "$formattedCurrentDate"');
      } else if (date == 2) {
        conditions.add(
            'DATE(CreatedDate) BETWEEN "$formattedMonthFirstDay" AND "$formattedCurrentDate"');
      }
    }

    if (date != 0 &&
        date != 1 &&
        date != 2 &&
        fromDate != null &&
        toDate != null) {
      conditions.add('DATE(CreatedDate) BETWEEN "$fromDate" AND "$toDate"');
    }

    // Category filter
    if (category != null) {
      conditions.add('IsCompany = $category');
    }

    // Construct the query
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    return query;
  }

  String? getDate(int? date) {
    if (date == null) {
      return null;
    }
    final now = DateTime.now();
// SELECT * FROM Leads WHERE DATE(CreatedDate) BETWEEN "2024-09-03" AND "2024-09-24"
    switch (date) {
      case 0: // Today
        return _formatDate(now);

      case 1: // This Week (Get Monday of the current week)
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final week = 'BETWEEN ${_formatDate(monday)} AND ${_formatDate(now)}';
        return week;

      case 2: // Month (Get the first day of the current month)
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final month =
            'BETWEEN ${_formatDate(firstDayOfMonth)} AND ${_formatDate(now)}';
        return month;

      default:
        return null;
    }
  }

  String _formatDate(DateTime date) {
    // Format the date as YYYY-MM-DD
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int? getCategory(int? category) {
    switch (category) {
      case 0:
        return 1;
      case 1:
        return 0;
      default:
        return null;
    }
  }

  Future<void> launchFromDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      setState(() {
        selectedFromDate = pickedDay;
        fromDateController.text =
            DateFormat('dd/MM/yyyy').format(selectedFromDate!);
      });
    }
  }

  Future<void> launchToDatePicker(BuildContext context,
      {required DateTime firstDate,
      required DateTime lastDate,
      DateTime? initialDate}) async {
    // final DateTime lastDate = DateTime.now();
    // final DateTime firstDate = DateTime(lastDate.year - 100);
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      // initialDate: DateTime.now(),
      initialDate: initialDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      setState(() {
        selectedToDate = pickedDay;
        toDateController.text =
            DateFormat('dd/MM/yyyy').format(selectedToDate!);
      });
    }
  }
}

//MARK: Filter
class Filter extends StatefulWidget {
  final int dateChipValue;
  final int typeChipValue;
  final void Function(int)? onSelectedDateChip;
  final void Function(int)? onSelectedTypeChip;
  final List<String> dates;
  final List<String> types;
  final void Function()? onToDate;
  final void Function()? onFromDate;
  final void Function(int?, int?) onSubmit;
  final void Function()? onClear;
  final TextEditingController? fromDateController;
  final TextEditingController? toDateController;

  const Filter({
    super.key,
    required this.dateChipValue,
    required this.typeChipValue,
    required this.dates,
    required this.types,
    this.onToDate,
    this.onFromDate,
    this.fromDateController,
    this.toDateController,
    this.onSelectedDateChip,
    this.onSelectedTypeChip,
    required this.onSubmit,
    this.onClear,
  });

  @override
  State<Filter> createState() => _FilterState();
}

/* 
class _FilterState extends State<Filter> {
  int? selectedDateIndex;
  int? selectedTypeIndex;

  @override
  void initState() {
    super.initState();
    selectedDateIndex = widget.dateChipValue;
    selectedTypeIndex = widget.typeChipValue;
    print('selectedDateIndex: $selectedDateIndex');
    print('selectedTypeIndex: $selectedTypeIndex');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text('Filter', style: CommonStyles.txStyF20CbFF5),
              IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12.0,
                      children: List<Widget>.generate(
                        widget.dates.length,
                        (int index) {
                          return ChoiceChip(
                            label: Text(
                              widget.dates[index],
                            ),
                            selectedColor: CommonStyles.btnBlueBgColor,
                            backgroundColor: CommonStyles.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: CommonStyles.btnBlueBgColor)),
                            selected: widget.dateChipValue == index,
                            onSelected: (bool selected) {
                              if (widget.onSelectedDateChip != null) {
                                widget
                                    .onSelectedDateChip!(selected ? index : -1);
                                selectedDateIndex = index;
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12.0,
                      children: List<Widget>.generate(
                        widget.types.length,
                        (int index) {
                          return ChoiceChip(
                            label: Text(
                              widget.types[index],
                            ),
                            selectedColor: CommonStyles.btnBlueBgColor,
                            backgroundColor: CommonStyles.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: CommonStyles.btnBlueBgColor)),
                            // No chip selected initially if widget.typeChipValue == -1
                            selected: widget.typeChipValue == index,
                            onSelected: (bool selected) {
                              if (widget.onSelectedTypeChip != null) {
                                widget
                                    .onSelectedTypeChip!(selected ? index : -1);
                                selectedTypeIndex = index;
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                CustomTextField(
                  label: 'From Date',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onTap: widget.onFromDate,
                  controller: widget.fromDateController,
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  label: 'To Date',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onTap: widget.onToDate,
                  controller: widget.toDateController,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: customBtn(
                        onPressed: () {
                          widget.onSubmit(selectedDateIndex, selectedTypeIndex);
                        },
                        child: const Text(
                          'Submit',
                          style: CommonStyles.txStyF14CwFF5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: customBtn(
                          onPressed: widget.onClear,
                          child: const Text(
                            'Clear',
                            style: CommonStyles.txStyF14CwFF5,
                          ),
                          backgroundColor: CommonStyles.btnBlueBgColor),
                    ),
                  ],
                ),
              ],
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
}
 */
class _FilterState extends State<Filter> {
  int? selectedDateIndex;
  int? selectedTypeIndex;

  @override
  void initState() {
    super.initState();
    selectedDateIndex = widget.dateChipValue;
    selectedTypeIndex = widget.typeChipValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Text('Filter', style: CommonStyles.txStyF20CbFF5),
              IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12.0,
                      children: List<Widget>.generate(
                        widget.dates.length,
                        (int index) {
                          return ChoiceChip(
                            label: Text(
                              widget.dates[index],
                            ),
                            selectedColor: CommonStyles.btnBlueBgColor,
                            backgroundColor: CommonStyles.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: CommonStyles.btnBlueBgColor)),
                            selected: selectedDateIndex == index,
                            onSelected: (bool selected) {
                              if (widget.onSelectedDateChip != null) {
                                widget
                                    .onSelectedDateChip!(selected ? index : -1);
                                setState(() {
                                  selectedDateIndex = selected ? index : null;
                                });
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12.0,
                      children: List<Widget>.generate(
                        widget.types.length,
                        (int index) {
                          return ChoiceChip(
                            label: Text(
                              widget.types[index],
                            ),
                            selectedColor: CommonStyles.btnBlueBgColor,
                            backgroundColor: CommonStyles.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: CommonStyles.btnBlueBgColor)),
                            selected: selectedTypeIndex == index,
                            onSelected: (bool selected) {
                              if (widget.onSelectedTypeChip != null) {
                                widget
                                    .onSelectedTypeChip!(selected ? index : -1);
                                setState(() {
                                  selectedTypeIndex = selected ? index : null;
                                });
                              }
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                CustomTextField(
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onTap: widget.onFromDate,
                  controller: widget.fromDateController!,
                  hintText: '',
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  // label: 'To Date',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onTap: widget.onToDate,
                  controller: widget.toDateController!, hintText: '',
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: customBtn(
                        onPressed: () {
                          widget.onSubmit(selectedDateIndex, selectedTypeIndex);
                        },
                        child: const Text(
                          'Submit',
                          style: CommonStyles.txStyF14CwFF5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: customBtn(
                        onPressed: () {
                          // Clear the chip selection
                          setState(() {
                            selectedDateIndex = null;
                            selectedTypeIndex = null;
                          });
                          // Call the onClear function to reset the parent state
                          if (widget.onClear != null) {
                            widget.onClear!();
                          }
                        },
                        child: const Text(
                          'Clear',
                          style: CommonStyles.txStyF14CwFF5,
                        ),
                        backgroundColor: CommonStyles.btnBlueBgColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton customBtn({
    Color? backgroundColor = CommonStyles.btnRedBgColor,
    required Widget child,
    void Function()? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }
}

class FilterModel {
  int? date;
  int? category;
  String? fromDate;
  String? toDate;
  FilterModel({
    this.date,
    this.category,
    this.fromDate,
    this.toDate,
  });
}
