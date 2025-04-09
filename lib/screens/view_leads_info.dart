import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model Class/lead_info_model.dart';
import '../common_widgets/common_styles.dart';
import '../database/DataAccessHandler.dart';

class ViewLeadsInfo extends StatefulWidget {
  final String code;
  const ViewLeadsInfo({super.key, required this.code});

  @override
  State<ViewLeadsInfo> createState() => _ViewLeadsInfoState();
}

class _ViewLeadsInfoState extends State<ViewLeadsInfo> {
  late Future<List<LeadInfoModel>> futureLeadInfo;
  late Future<List<Map<String, dynamic>>> futureLeadImages;
  late Future<List<Map<String, dynamic>>> futureLeadDocs;
  String? username;
  @override
  void initState() {
    super.initState();
    getusername();
    futureLeadInfo = getLeadInfoByCode(widget.code);

    futureLeadImages = getLeadImagesByCode(widget.code);
    futureLeadDocs = getLeadDocsByCode(widget.code);
  }

  Future<List<LeadInfoModel>> getLeadInfoByCode(String code) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> result = await dataAccessHandler.getLeadInfoByCode(code);
      List<LeadInfoModel> leads =
          result.map((item) => LeadInfoModel.fromJson(item)).toList();
      print('xxx Info: ${jsonEncode(leads)}');
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getLeadImagesByCode(String code) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> result =
          await dataAccessHandler.getLeadImagesByCode(code, '.jpg');
      List<Map<String, dynamic>> leads =
          result.map((item) => Map<String, dynamic>.from(item)).toList();
      print('xxx Images: ${jsonEncode(leads)}');
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getLeadDocsByCode(String code) async {
    try {
      final dataAccessHandler =
          Provider.of<DataAccessHandler>(context, listen: false);
      List<dynamic> result = await dataAccessHandler.getLeadDocsByCode(
        code,
        ['.xlsx', '.pdf'],
      );
      List<Map<String, dynamic>> leads =
          result.map((item) => Map<String, dynamic>.from(item)).toList();
      print('xxx Docs: ${jsonEncode(leads)}');
      return leads;
    } catch (e) {
      throw Exception('catch: ${e.toString()}');
    }
  }

  Future<void> openLocalFileByPath(
      BuildContext context, String? filePath) async {
    print('openLocalFileByPath: $filePath');
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        try {
          final result = await OpenFile.open(filePath);
          print('OpenFile result: ${result.message}');
        } catch (e) {
          print('Error opening file: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to open the file'),
            ),
          );
        }
      } else {
        print('File does not exist: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File does not exist'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid file path'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.appBgColor,
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: futureLeadInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        //  CommonStyles.customShimmer(child: leadInfoShimmer()),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data as List<LeadInfoModel>;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          leadInfo(leads[0]),
                        ],
                      );
                    }
                  }
                },
              ),
              FutureBuilder(
                future: futureLeadImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        // CommonStyles.customShimmer(
                        //     child: leadInfoShimmer(height: 100)),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data!;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          uploadmages(leads),
                        ],
                      );
                    }
                  }
                },
              ),
              FutureBuilder(
                future: futureLeadDocs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        // CommonStyles.customShimmer(
                        //     child: leadInfoShimmer(height: 100)),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        snapshot.error
                            .toString()
                            .replaceFirst('Exception: ', ''),
                        style: CommonStyles.txStyF16CpFF5);
                  } else {
                    final leads = snapshot.data!;

                    if (leads.isEmpty) {
                      return const SizedBox();
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          uploadDocs(leads),
                        ],
                      );
                    }
                  }
                },
              ),

              // FutureBuilder(
              //   future: futureLeadInfo,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Column(
              //         children: [
              //           const SizedBox(height: 12),
              //           CommonStyles.customShimmer(child: leadInfoShimmer()),
              //         ],
              //       );
              //     } else if (snapshot.hasError) {
              //       return Text(
              //           snapshot.error
              //               .toString()
              //               .replaceFirst('Exception: ', ''),
              //           style: CommonStyles.txStyF16CpFF5);
              //     } else {
              //       final leads = snapshot.data as List<LeadInfoModel>;

              //       if (leads.isEmpty) {
              //         return const SizedBox();
              //       } else {
              //         return Column(
              //           children: [
              //             const SizedBox(height: 12),
              //             updatedDetails(leads[0]),
              //           ],
              //         );
              //       }
              //     }
              //   },
              // ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Row updatedDetailItem({required String label, String? data}) {
    return Row(
      children: [
        Text('$label : ', style: CommonStyles.txStyF14CpFF),
        Text('$data',
            style: CommonStyles.txStyF14CbFcF5
                .copyWith(color: CommonStyles.dataTextColor)),
      ],
    );
  }

  Widget userItem(
      {required String label, String? data, bool isSpaceNeeded = true}) {
    if (data == null || data.isEmpty) {
      return const SizedBox();
    }
    return Container(
      padding: EdgeInsets.only(bottom: isSpaceNeeded ? 5 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label : ', style: CommonStyles.txStyF14CpFF),
          Flexible(
            child: Text(data,
                style: CommonStyles.txStyF14CbFcF5
                    .copyWith(color: CommonStyles.dataTextColor)),
          ),
        ],
      ),
    );
  }

  Container uploadDocs(List<Map<String, dynamic>> leads) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.whiteColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Uploaded Documents:',
              style: CommonStyles.txStyF16CbFF5,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              children: [
                ...leads.map(
                  (lead) => customDoc(lead, leads.indexOf(lead)),
                ),
              ],
            )
          ]),
    );
  }

  Column customDoc(Map<String, dynamic> lead, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final filePath = lead['FileLocation'] as String?;
            if (filePath != null && filePath.isNotEmpty) {
              if (await File(filePath).exists()) {
                await openDocument(context, filePath);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File does not exist')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid file path')),
              );
            }
          },
          child: SvgPicture.asset(
            'assets/fileDownloadIcon.svg',
            color: CommonStyles.btnBlueBgColor,
            width: 70,
            height: 70,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Doc${lead['FileExtension']}',
          style: CommonStyles.txStyF14CbFcF5,
        ),
      ],
    );
  }

  // Column customDoc(Map<String, dynamic> lead, int index) {
  //   return Column(
  //     children: [
  //       GestureDetector(
  //         onTap: () =>   if (await File(filePath).exists()) {
  //   await openDocument(context, filePath);
  //   } else {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //   const SnackBar(content: Text('File does not exist')),
  //   );
  //   },
  //           onTap: () => openLocalFileByPath(context,lead['FileLocation']),
  //           child: SvgPicture.asset('assets/fileDownloadIcon.svg',
  //               color: CommonStyles.btnBlueBgColor, width: 70, height: 70)),
  //       const SizedBox(height: 5),
  //       Text(
  //         'Doc${lead['FileExtension']}',
  //         style: CommonStyles.txStyF14CbFF5,
  //       )
  //     ],
  //   );
  // }

  Container uploadmages(List<Map<String, dynamic>> lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.whiteColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Uploaded Images:',
            style: CommonStyles.txStyF16CbFF5,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            children: [
              ...lead.map(
                (lead) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => showZoomedAttachment(lead['FileLocation']),
                        child: Image.file(
                          File(lead['FileLocation']),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset(
                            'assets/fileuploadicon.svg',
                            width: 70,
                            height: 70,
                            color: CommonStyles.btnBlueBgColor,
                          ),
                        ),
                      ),
                      // Text(
                      //   lead['FileLocation'],
                      //   style: CommonStyles.txStyF16CbFF5,
                      // ),
                    ],
                  );
                },
              ).toList(),
            ],
          )
        ],
      ),
    );
  }

  void showZoomedAttachment(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider:
                            FileImage(File(imagePath)), // Use FileImage
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container leadInfo(LeadInfoModel lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.whiteColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                userItem(label: 'Name', data: lead.name),
                userItem(label: 'Company Name', data: lead.companyName),
                userItem(label: 'Email', data: lead.email),
                userItem(label: 'Mobile Number', data: lead.phoneNumber),
                userItem(
                    label: 'Visited On',
                    data: formatDateString(lead.createdDate)),
                userItem(
                    label: 'Comment',
                    isSpaceNeeded: false,
                    data: '${lead.comments}'),

                /* updatedDetailItem(label: 'Name', data: lead.name),
                if (lead.companyName != null)
                  // listCustomText(
                  //   '${lead.companyName}',
                  // ),
                  updatedDetailItem(
                      label: 'Company Name', data: lead.companyName),
                const SizedBox(height: 5),
                if (lead.email != null)
                  // listCustomText(
                  //   '${lead.email}',
                  // ),
                  updatedDetailItem(
                      label: 'Email', data: lead.email), // lead.email
                const SizedBox(height: 5),
                if (lead.phoneNumber != null)
                  // listCustomText(
                  //   '${lead.phoneNumber}',
                  // ),
                  updatedDetailItem(
                      label: 'Mobile Number', data: lead.phoneNumber),
                const SizedBox(height: 5),
                updatedDetailItem(
                    label: 'Visited On',
                    data: formatDateString(lead.createdDate)),
                const SizedBox(height: 5),
                if (lead.comments != null && lead.comments!.isNotEmpty) ...[
                  const Text('Comment:',
                      style: TextStyle(
                          fontSize: 16, color: CommonStyles.primaryTextColor)),
                  const SizedBox(height: 3),
                  Flexible(
                      child: Text('${lead.comments}',
                          style: CommonStyles.txStyF14CbFF5
                              .copyWith(color: CommonStyles.dataTextColor))),
                ], */
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openMap(lead.latitude!, lead.longitude!),
            child: const Icon(Icons.location_on,
                color: CommonStyles.formFieldErrorBorderColor),
          ),
        ],
      ),
    );
  }

  String? formatDateString(String? date) {
    print('date: $date');
    if (date != null && date.isNotEmpty) {
      try {
        // Parse the date string
        DateTime parsedDate = DateTime.parse(date);
        // Format the date and time
        return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);
      } catch (e) {
        print('Error parsing date: $e');
        return date; // Return the original date string in case of error
      }
    }
    return date;
  }

  Container leadInfoShimmer({double? height = 130}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CommonStyles.listOddColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: CommonStyles.primaryColor,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
      scrolledUnderElevation: 0,
      title: const Text(
        'View Client Visit',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Text listCustomText(String text, {bool isSpace = true}) {
    return Text(
      text,
      style: CommonStyles.txStyF16CbFF5,
    );
  }

  void _openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> getusername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    username = prefs.getString('username') ?? '';
  }

  Future<void> openDocument(BuildContext context, String filePath) async {
    final fileExtension = filePath.split('.').last.toLowerCase();

    if (fileExtension == 'pdf') {
      // Open the PDF in PDFViewScreen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PDFViewScreen(path: filePath),
      //   ),
      //   );
    } else if (fileExtension == 'xls' || fileExtension == 'xlsx') {
      // Open Excel file externally
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => ExcelViewer(
      //         filePath: filePath,
      //       )),
      // );
      // try {
      //   final result = await OpenFile.open(filePath);
      //   print('OpenFile result: ${result.message}');
      // } catch (e) {
      //   print('Error opening Excel file: $e');
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Failed to open Excel file')),
      //   );
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsupported file type')),
      );
    }
  }
}
