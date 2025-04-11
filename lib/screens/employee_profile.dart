// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Constants.dart';
import 'package:hrms/Model%20Class/LookupDetail.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/common_widgets/common_styles.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:convert';

import '../api config.dart';

class EmployeeProfile extends StatefulWidget {
  const EmployeeProfile({super.key});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  String accessToken = '';

  int? bloodGroupId;
  int? employeeId;
  String? bloodGroup;
  String? mobileNumber;
  String? certificateDob;
  String? code;
  String? emailId;
  String? firstName;
  String? gender;
  String? originalDob;
  String? photo;
  String? signDate;

  late Future<Map<String, dynamic>> futureEmployeeInfo;
  late Future<Uint8List> futureEmployeeImage;

  final sampleData = {
    'employeeName': 'data',
    'designation': 'data',
    'code': 'data',
    'gender': 'data',
    'emailId': 'data',
    'officeEmailId': 'data',
    'originalDOB': 'data',
    'mobileNumber': 'data',
    'reportingTo': 'data',
    'experienceInCompany': 'data',
    'bloodGroup': 'data',
    'dateofJoin': 'data',
    'nationality': 'data',
  };

  @override
  void initState() {
    super.initState();
    employeedata();
    fetchBloodGroups();
    futureEmployeeInfo = loadEmployeeInfo();
    futureEmployeeImage = fetchEmployeeImage();
  }

  Future<void> fetchBloodGroups() async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bloodlookupid = prefs.getInt('BloodGroups') ?? 0;
    final accessToken = prefs.getString("accessToken") ?? "";
    String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection',
          context as BuildContext,
          1,
          4);
      FocusScope.of(context as BuildContext).unfocus();
      return;
    }
    final url = Uri.parse('$baseUrl$getdropdown$bloodlookupid');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'APIKey': APIKey,
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData == 'Token invalid !!!') {
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
          Commonutils.showCustomToastMessageLong(
              "Token is Expired", context as BuildContext, 0, 3);

          Navigator.of(context as BuildContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
          return;
        }

        if (jsonData is List<dynamic>) {
          List<LookupDetail> lookupDetails =
              jsonData.map((data) => LookupDetail.fromJson(data)).toList();

          for (var detail in lookupDetails) {
            if (detail.name == bloodGroup) {
              bloodGroupId = detail.lookupDetailId;
              break;
            }
          }
        } else {
          throw Exception('Failed to load data. Unexpected response format.');
        }
      } else {
        throw Exception('Failed to load data.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadEmployeeInfo() async {
    final loadedData = await SharedPreferencesHelper.getCategories();
    if (loadedData != null) {
      // bloodGroupId = loadedData['bloodGroupId'];
      bloodGroup = loadedData['bloodGroup'];
      code = loadedData['code'];
      mobileNumber = loadedData['mobileNumber'];
      certificateDob = loadedData['originalDOB'];
      emailId = loadedData['emailId'];
      employeeId = loadedData['employeeId'];
      firstName = loadedData['employeeName'];
      gender = loadedData['gender'];
      originalDob = loadedData['originalDOB'];
      signDate = loadedData['signDate'];

      // photo = loadedData['photo'];
/*       print('loadEmployeeInfo employeeName: ${loadedData['employeeName']}');
      print('loadEmployeeInfo designation: ${loadedData['designation']}');
      print('loadEmployeeInfo code: ${loadedData['code']}');
      print('loadEmployeeInfo gender: ${loadedData["gender"]}');
      print('loadEmployeeInfo emailId: ${loadedData['emailId']}');
      print('loadEmployeeInfo officeEmailId: ${loadedData['officeEmailId']}');
      print('loadEmployeeInfo originalDOB: ${loadedData['originalDOB']}');
      print('loadEmployeeInfo mobileNumber: ${loadedData['mobileNumber']}');
      print('loadEmployeeInfo reportingTo: ${loadedData['reportingTo']}');
      print(
          'loadEmployeeInfo experienceInCompany: ${loadedData['experienceInCompany']}');
      print('loadEmployeeInfo bloodGroup: ${loadedData['bloodGroup']}');
      print('loadEmployeeInfo dateofJoin: ${loadedData['dateofJoin']}');
      print('loadEmployeeInfo nationality: ${loadedData['nationality']}'); */
      return {
        'employeeName': loadedData['employeeName'],
        'designation': loadedData['designation'],
        'code': loadedData['code'],
        'gender': loadedData["gender"],
        'emailId': loadedData['emailId'],
        'officeEmailId': loadedData['officeEmailId'],
        'originalDOB': DateFormat('dd MMM yyyy')
            .format(DateTime.parse(loadedData['originalDOB'])),
        'mobileNumber': loadedData['mobileNumber'],
        'reportingTo': loadedData['reportingTo'],
        'experienceInCompany': loadedData['experienceInCompany'],
        'bloodGroup': loadedData['bloodGroup'],
        'dateofJoin': DateFormat('dd MMM yyyy')
            .format(DateTime.parse(loadedData['dateofJoin'])),
        'nationality': loadedData['nationality'],
      };
    } else {
      throw Exception('Failed to load employee information');
    }
  }

  Future<Uint8List> fetchEmployeeImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final empolyeid = prefs.getString("employeeId") ?? "";
      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      final url = Uri.parse(baseUrl + GetEmployeePhoto + empolyeid);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',

          'APIKey': APIKey,
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        final imageData = data['ImageData'];
        final List<String> parts = imageData.split(',');
        if (parts.length != 2) {
          throw const FormatException('Invalid base64 string');
        }
        final String dataPart = parts[1];
        return const Base64Codec().decode(dataPart);
      } else {
        throw Exception('Failed to load employee image');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> showBottomSheetForImageSelection(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery, context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => home_screen()),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: CommonStyles.bgColor,
        // appBar: appBar(),
        body: Column(
          children: [
            headerSection(context),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(10),
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
                      child: FutureBuilder(
                          future: futureEmployeeInfo,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Skeletonizer(
                                enabled: true,
                                child: employeeInformation(sampleData, context),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData) {
                              return const Center(
                                  child: Text('No data available'));
                            }
                            final employeeInfo =
                                snapshot.data as Map<String, dynamic>;
                            if (employeeInfo.isEmpty) {
                              return const Center(
                                  child: Text('No data available'));
                            }
                            return employeeInformation(employeeInfo, context);
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column employeeInformation(
      Map<String, dynamic> employeeInfo, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*  Text(
                                'Employee Information',
                                style: CommonStyles.txStyF20CbFcF5.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5), */
        /*  customBox(
                                  context,
                                  employeeInfo['employeeName'],
                                  'Employee Id'),
                              const SizedBox(height: 5),
                              customBox(
                                  context,
                                  employeeInfo['designation'],
                                  'designation'),
                              const SizedBox(height: 5), */
        if (employeeInfo['code'] != null && employeeInfo['code'] != '')
          customBox(context, employeeInfo['code'], 'Employee Id', Icons.code),
        if (employeeInfo['gender'] != null && employeeInfo['gender'] != '')
          customBox(context, employeeInfo['gender'], 'Gender', Icons.male),
        if (employeeInfo['dateofJoin'] != null &&
            employeeInfo['dateofJoin'] != '')
          customBox(context, employeeInfo['dateofJoin'], 'Date of Join',
              Icons.calendar_month_rounded),
        if (employeeInfo['officeEmailId'] != null &&
            employeeInfo['officeEmailId'] != '')
          customBox(context, employeeInfo['officeEmailId'], 'Office Email Id',
              Icons.email),
        if (employeeInfo['originalDOB'] != null &&
            employeeInfo['originalDOB'] != '')
          customBox(context, employeeInfo['originalDOB'], 'Date of Birth',
              Icons.date_range),
        if (employeeInfo['mobileNumber'] != null &&
            employeeInfo['mobileNumber'] != '')
          customBox(context, employeeInfo['mobileNumber'], 'Mobile Number',
              Icons.phone),
        // const SizedBox(height: 5),
        if (employeeInfo['reportingTo'] != null &&
            employeeInfo['reportingTo'].trim() != '')
          customBox(context, employeeInfo['reportingTo'], 'Reporting To',
              Icons.report),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: const Color(0xFFf15f22),
      title: const Text(
        'HRMS',
        style: TextStyle(color: Colors.white),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      // automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  Row customBox(
    BuildContext context,
    String? title,
    String? subTitle,
    IconData? icon,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: CommonStyles.primaryColor.withOpacity(0.4),
          child: Icon(
            icon ?? Icons.home,
            size: 25,
            color: CommonStyles.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ListTile(
            onTap: () {},
            dense: true,
            contentPadding: const EdgeInsets.all(0),
            style: ListTileStyle.drawer,
            title: Text(
              '$title',
              style: CommonStyles.txStyF20CbFcF5,
            ),
            subtitle: Text(
              '$subTitle',
              style: CommonStyles.txStyF20CbFcF5.copyWith(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        /* const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            
          },
          icon: const Icon(
            Icons.arrow_right_rounded,
            size: 26,
          ),
        ), */
      ],
    );
  }

  Widget headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      width: MediaQuery.of(context).size.width,
      color: CommonStyles.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder(
                      future: futureEmployeeImage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Skeletonizer(
                            child: employeeImageTemplate(context, Uint8List(0)),
                          );
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error);
                        }
                        Uint8List employeeImage = snapshot.data as Uint8List;
                        return employeeImageTemplate(context, employeeImage);
                      }),
                  Positioned(
                    bottom: 0,
                    right: 12,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () async {
                          await showBottomSheetForImageSelection(context);
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
          FutureBuilder(
              future: futureEmployeeInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Skeletonizer(
                    enabled: true,
                    child: Column(
                      children: [
                        Text('''employeeInfoempName'''),
                        Text(
                          '''designation''',
                        ),

                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final employeeInfo = snapshot.data as Map<String, dynamic>;
                if (employeeInfo.isEmpty) {
                  return const SizedBox();
                }
                return employeeNameNdDesignation(employeeInfo);
              }),
        ],
      ),
    );
  }

  Column employeeNameNdDesignation(Map<String, dynamic> employeeInfo) {
    return Column(
      children: [
        Text(
          '${employeeInfo['employeeName']}',
          softWrap: true,
          textAlign: TextAlign.center,
          style: CommonStyles.txStyF20CpFF5.copyWith(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${employeeInfo['designation']}',
          style: const TextStyle(
              fontSize: 15, color: Colors.white, fontFamily: 'Calibri'),
        ),

      ],
    );
  }

  Container employeeImageTemplate(
      BuildContext context, Uint8List employeeImage) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      height: MediaQuery.of(context).size.height / 8.0,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: MemoryImage(employeeImage),
          fit: BoxFit.fill,
        ),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
    );
  }

  Future<void> employeedata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString(SharedKeys.APIKey) ?? "";
    final employeeId = prefs.getString("employeeId") ?? "";
    accessToken = prefs.getString("accessToken") ?? "";

    try {
      final url = Uri.parse(baseUrl + getemployedata + employeeId);

      final response = await http.get(
        url,
        headers: {
          'APIKey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        signDate = data['signDate'];
      } else {
        throw Exception('Failed to load employee data');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedImage = await ImagePicker()
          .pickImage(source: source, preferredCameraDevice: CameraDevice.front);
      if (pickedImage == null) {
        throw Exception('No image selected');
      } else {
        final filename = basename(pickedImage.path);
        final fileExtension = extension(pickedImage.path);
        List<int> imageBytes = await pickedImage.readAsBytes();
        Uint8List compressedBytes = Uint8List.fromList(imageBytes);
        final compressWithList = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minHeight: 800,
          minWidth: 800,
          quality: 80,
        );

        final base64Image = base64Encode(compressedBytes);

        bool isConnected = await Commonutils.checkInternetConnectivity();
        if (!isConnected) {
          Commonutils.showCustomToastMessageLong(
              'Please Check the Internet Connection', context, 1, 4);
          FocusScope.of(context).unfocus();
          throw Exception('No internet connection');
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";

        final apiUrl = Uri.parse(baseUrl + uploadimage);
        final request = {
          "alternateMobileNumber": "",
          "bloodGroupId": bloodGroupId,
          "certificateDob": certificateDob,
          "code": code,
          "emailId": emailId,
          "employeeId": employeeId,
          "firstName": firstName,
          "gender": "",
          "isAFresher": false,
          "isActive": true,
          "isFromRecruitment": false,
          "lastName": "",
          "maritalStatus": "",
          "middleName": "",
          "mobileNumber": mobileNumber,
          "nationality": "Indian",
          "originalDob": certificateDob,
          "photo": "data:image/$fileExtension;base64,$base64Image",
          "signDate": signDate
        }
            /* {
          "alternateMobileNumber": "",
          "bloodGroupId": bloodmatchid,
          "certificateDob": "$stringdob",
          "code": "$employecode",
          "emailId": "$EmailId",
          "employeeId": "$loggedInEmployeeId",
          "firstName": "$employeName",
          "gender": Gender,
          "isAFresher": false,
          "isActive": true,
          "isFromRecruitment": false,
          "lastName": "",
          "maritalStatus": "Single",
          "middleName": "",
          "mobileNumber": Mobilenum,
          "nationality": "Indian",
          "originalDob": "$stringdob",
          "photo": "data:image/$fileExtension;base64,$base64Image",
          "signDate": "$stringsigndate"
        } */
            ;

        final response = await http.post(
          apiUrl,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
            'APIKey': APIKey,
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            futureEmployeeInfo = loadEmployeeInfo();
            futureEmployeeImage = fetchEmployeeImage();
          });
        } else if (response.statusCode == 520) {
          Commonutils.showCustomToastMessageLong(response.body, context, 1, 3);
        } else {
          Commonutils.showCustomToastMessageLong(
              'Failed to send the request. Status code: ${response.statusCode}',
              context,
              1,
              4);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
