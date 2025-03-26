import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrms/Database/HRMSDatabaseHelper.dart';
import 'package:hrms/database/HRMSDatabaseHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Database/DataAccessHandler.dart';
import '../Database/SyncService.dart';
import '../HomeScreen.dart';
import '../common_widgets/common_styles.dart';



class AddLeads extends StatefulWidget {
  const AddLeads({super.key});

  @override
  _AddLeadScreenState createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeads>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  // TextEditingController _usernameController = TextEditingController();
  bool _isCompany = false;

  Position? _currentPosition;
  final List<Uint8List> _images = [];
  final List<XFile> _imagepath = [];
  bool isImageList = false;
  final ImagePicker _picker = ImagePicker();
  final List<PlatformFile> _files = [];
  int? userID;
  String? _errorMessage;
  String? Username;
  String? empCode;


  void _pickFile() async {
    if (_images.length + _files.length < 3) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'csv', 'pptx'],
      );

      if (result != null) {
        int availableSlots = 3 - (_images.length + _files.length);
        List<PlatformFile> selectedFiles = result.files.take(availableSlots).toList();

        for (PlatformFile file in selectedFiles) {
          String? fileExtension = file.extension?.toLowerCase();
          if (fileExtension != null &&
              !['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
            // Move the file to a custom directory
            await _moveFileToCustomDirectory(file);

            setState(() {
              _files.add(file);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Please select a non-image file.')));
            return;
          }
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You can upload a maximum of 3 files and images combined.')));
    }
  }


  void _deleteFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if GPS is enabled (Internet is not needed, only GPS)
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CommonStyles.showCustomToastMessageLong(
        'Location Services (GPS) are Disabled. Please Turn On Your Location Services.',
        context, 1, 2,
      );

      // Do not return error, continue with null location
      _currentPosition = null;
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CommonStyles.showCustomToastMessageLong(
          'Location permission is required to get current location.',
          context, 1, 2,
        );
        _currentPosition = null;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CommonStyles.showCustomToastMessageLong(
        'Location permission is permanently denied. Enable it from app settings.',
        context, 1, 2,
      );
      _currentPosition = null;
      return;
    }

    // Get current position using GPS
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting location: $e");
      _currentPosition = null;
    }
  }

  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Check if GPS is enabled (Internet is not needed, only GPS)
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     CommonStyles.showCustomToastMessageLong('Location Services (GPS) are Disabled.Please Turn On Your Loaction Services.', context, 1, 2);
  //
  //    return Future.error('Location services (GPS) are disabled.');
  //
  //   }
  //
  //   // Check location permission
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied.');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   // Get current position using GPS (this works offline)
  //   _currentPosition = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high, // Uses GPS
  //   );
  // }

  @override
  void initState() {
    super.initState();

    getuserdata();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50], // Background color
        elevation: 0, // Remove the shadow under the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate to the previous screen
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Text(
              'Add Client Visits', // Add Leads beside the back arrow
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name *",
                        hintText: "Enter Name",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLength: 30,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Name';
                        }
                        return null;
                      },
                    ),
                    Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _isCompany,
                            onChanged: (bool? value) {
                              setState(() {
                                _isCompany = value!;
                                if (!_isCompany) {
                                  // Clear the text when switching to false
                                  _companyNameController.clear();
                                }
                              });
                            },
                          ),
                          const Text("Is Company"),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _isCompany,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _companyNameController,
                            decoration: InputDecoration(
                              labelText: "Company Name *",
                              hintText: "Enter Company Name",
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLength: 50,
                            validator: (value) {
                              if (_isCompany &&
                                  (value == null || value.isEmpty)) {
                                return 'Please Enter Company Name';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: "Phone Number *",
                        hintText: "Enter Phone Number",
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[6-9][0-9]*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Phone Number';
                        } else if (value.length != 10) {
                          return 'Phone Number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,

                      decoration: InputDecoration(
                        labelText: "Email *",
                        hintText: "Enter Email",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLength: 30,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Email';
                        } else if (!RegExp(
                            r"^[a-zA-Z][a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]*@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },

                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _commentsController,
                      decoration: InputDecoration(
                        labelText: "Comments",
                        hintText: "Enter Comments",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 4,
                      maxLength: 250,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    mobileImagePicker(context);
                                  },
                                  child: DottedBorder(
                                    color: CommonStyles.dotColor,
                                    strokeWidth: 2,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    child: Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/add_a_photo.svg",
                                            width: 50,
                                            height: 50,
                                            color: CommonStyles.dotColor,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Upload Image',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickFile,
                                  child: DottedBorder(
                                    color: CommonStyles.dotColor,
                                    strokeWidth: 2,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    child: Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/fileuploadicon.svg",
                                            width: 50,
                                            height: 50,
                                            color: CommonStyles.dotColor,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Upload Doc',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_images.isNotEmpty) ...[
                            const Text('Uploaded Images:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: _images.map((image) {
                                final int index = _images.indexOf(image);
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: MemoryImage(image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _deleteImage(index),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close,
                                              color: Colors.red, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                          if (_files.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text('Uploaded Files:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _files.map((file) {
                                final int index = _files.indexOf(file);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Colors.blue),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          color: Colors.grey[100],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.file_present,
                                                size: 30, color: Colors.blue),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                file.name,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    overflow:
                                                    TextOverflow.ellipsis),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () => _deleteFile(index),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close,
                                                color: Colors.red, size: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ]
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: CommonStyles
                              .buttonbg, // You can customize the color here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Add Client Visit",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
  //  await _getCurrentLocation(); // Fetch location
      showLoadingDialog(context);
      _validateTotalItems();

      final dataAccessHandler = Provider.of<DataAccessHandler>(context, listen: false);

      if (empCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee code not found.')),
        );
        return;
      }

      String formattedDate = getCurrentDateInDDMMYYHHMMSS();
      String currentDate = getCurrentDate();
      String maxNumQuery = '''
    SELECT MAX(CAST(SUBSTR(code, INSTR(code, '-') + 1) AS INTEGER)) AS MaxNumber 
    FROM Leads WHERE DATE(CreatedDate) = '$currentDate'
    ''';

      int? maxSerialNumber = await dataAccessHandler.getOnlyOneIntValueFromDb(maxNumQuery);
      int serialNumber = (maxSerialNumber != null) ? maxSerialNumber + 1 : 1;
      String formattedSerialNumber = serialNumber.toString().padLeft(3, '0');
      String leadCode = 'L$empCode$formattedDate-$formattedSerialNumber';

      // Prepare lead data, handling null location
      final leadData = {
        'IsCompany': _isCompany ? 1 : 0,
        'Code': leadCode,
        'Name': _nameController.text,
        'CompanyName': _isCompany ? _companyNameController.text : null,
        'PhoneNumber': _phoneNumberController.text,
        'Email': _emailController.text,
        'Comments': _commentsController.text,
        'Latitude': _currentPosition?.latitude, // Allow null values
        'Longitude': _currentPosition?.longitude,
        'Address': "Test",
        'CreatedByUserId': userID,
        'CreatedDate': DateTime.now().toIso8601String(),
        'UpdatedByUserId': userID,
        'UpdatedDate': DateTime.now().toIso8601String(),
        'ServerUpdatedStatus': false,
      };

      try {
        int leadId = await dataAccessHandler.insertLead(leadData) ?? -1;

        if (leadId == -1) {
          stopLoadingDialog(context);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Failed to insert lead data.')),
          // );
          CommonStyles.showCustomToastMessageLong('Failed to Add Client Visit Data.', context, 1, 2);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          return;
        }

        // Handle images & files
        for (var image in _imagepath) {
          String fileLocation = image.path;
          String fileExtension = '.jpg';

          final fileData = {
            'leadsCode': leadCode,
            'FileName': fileLocation,
            'FileLocation': fileLocation,
            'FileExtension': fileExtension,
            'IsActive': 1,
            'CreatedByUserId': userID,
            'CreatedDate': DateTime.now().toIso8601String(),
            'UpdatedByUserId': userID,
            'UpdatedDate': DateTime.now().toIso8601String(),
            'ServerUpdatedStatus': false,
          };

          await dataAccessHandler.insertFileRepository(fileData);
        }

        // Handle file uploads
        for (var file in _files) {
          String fileExtension = path.extension(file.name);
          String newFilePath = await _moveFileToCustomDirectory(file);

          File fileObj = File(newFilePath);
          List<int> fileBytes = await fileObj.readAsBytes();
          String base64String = base64Encode(fileBytes);

          final fileData = {
            'leadsCode': leadCode,
            'FileName': path.basename(newFilePath),
            'FileLocation': newFilePath,
            'FileExtension': fileExtension,
            'IsActive': 1,
            'CreatedByUserId': userID,
            'CreatedDate': DateTime.now().toIso8601String(),
            'UpdatedByUserId': userID,
            'UpdatedDate': DateTime.now().toIso8601String(),
            'ServerUpdatedStatus': false,
          };

          await dataAccessHandler.insertFileRepository(fileData);
        }

        bool isConnected = await CommonStyles.checkInternetConnectivity();
        if (isConnected) {
          final syncService = SyncService(dataAccessHandler);
          syncService.performRefreshTransactionsSync(context, 3)
              .whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          });
        } else {
          CommonStyles.showCustomToastMessageLong('Client Visit added successfully.', context, 0, 2);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }

        _nameController.clear();
        _companyNameController.clear();
        _phoneNumberController.clear();
        _emailController.clear();
        _commentsController.clear();
        _imagepath.clear();
      } catch (e) {
        print('Error inserting lead data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to insert lead data.')),
        );
      }
    }
  }

  Future<void> mobileImagePicker(BuildContext context) async {
    // Ensure the combined count of images and files is less than 3 before showing the picker
    if (_images.length + _files.length < 3) {
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
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show an error or handle the case when the limit is reached
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'You can upload a maximum of 3 files and images combined.')));
    }
  }

  // Method to pick image from specified source
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final Uint8List imageData = await pickedFile.readAsBytes();

        // Specify folder path with 'documents' inside 'SmartGeoTrack'
        const String folderName = 'SmartGeoTrack/documents';
        // Directory appDocDir =  Directory(Constants.originPath);;
        Directory appDocDir =  await getApplicationDocumentsDirectory();
        // Check if the directory exists, if not, create it
        if (!await appDocDir.exists()) {
          await appDocDir.create(recursive: true);
        }

        final String appDocPath = appDocDir.path;

        // Create a file in the documents directory with a unique name
        final String fileName = pickedFile.name;
        final File savedImage = File('$appDocPath/$fileName');

        // Save the image to the documents directory
        await savedImage.writeAsBytes(imageData);

        setState(() {
          _images.add(imageData); // Add image data to the list
          _imagepath.add(XFile(savedImage.path)); // Update image path to persistent location
        });

        print('Image saved to: $appDocPath/$fileName');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final pickedFile = await _picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       final Uint8List imageData = await pickedFile.readAsBytes();
  //       setState(() {
  //         _images.add(imageData);
  //         _imagepath.add(pickedFile);
  //         //  _imagepath.ad
  //       });
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //   }
  // }

  // Method to delete image from the list
  void _deleteImage(int index) {
    setState(() {
      _imagepath.removeAt(index);
      _images.removeAt(index);
    });
  }

  void _validateTotalItems() {
    // Combined count of images and files
    if (_images.length + _files.length > 3) {
      setState(() {
        _errorMessage =
        'You can upload a maximum of 3 images and files combined.';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getInt('userID');
    Username = prefs.getString('username') ?? '';
    empCode = prefs.getString('empCode') ?? '';
    // String firstName = prefs.getString('empCode') ?? '';
    String email = prefs.getString('email') ?? '';
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    String roleName = prefs.getString('roleName') ?? '';
  }

  String getCurrentDateInDDMMYY() {
    final DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = (now.year % 100).toString().padLeft(2, '0');
    return '$day$month$year';
  }
  String getCurrentDateInDDMMYYHHMMSS() {
    final DateTime now = DateTime.now();

    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String year = (now.year % 100).toString().padLeft(2, '0');

    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    final String second = now.second.toString().padLeft(2, '0');

    return '$day$month$year$hour$minute$second';
  }

  Future<String?> fetchEmpCode(String username, BuildContext context) async {
    final dataAccessHandler =
    Provider.of<DataAccessHandler>(context, listen: false);

    // Use parameterized query to avoid SQL injection
    String empCodeQuery = 'SELECT EmpCode FROM UserInfos WHERE UserName = ?';

    // Fetch EmpCode using the query
    String? empCode = await dataAccessHandler
        .getOnlyOneStringValueFromDb(empCodeQuery, [username]);

    // Print the result
    if (empCode != null) {
      print('EmpCode: $empCode'); // Print the fetched EmpCode
    } else {
      print('EmpCode not found for UserName: $username');
    }

    return empCode; // Optionally return the EmpCode
  }


  Future<String> _moveFileToCustomDirectory(PlatformFile file) async {
    try {
      const String folderName = 'SmartGeoTrack/documents'; // Add 'documents' folder
      // Directory appDocDir =  Directory(Constants.originPath);;
      Directory appDocDir =   await getApplicationDocumentsDirectory();
      print('appDocDir: $appDocDir');
      // Check if the directory exists, if not, create it
      if (!await appDocDir.exists()) {
        await appDocDir.create(recursive: true);
      }

      // Construct the new file path
      String newFilePath = path.join(appDocDir.path, file.name);

      // Move the file from its current location to the new directory
      File tempFile = File(file.path!);
      await tempFile.copy(newFilePath);

      print('File moved to: $newFilePath');
      return newFilePath; // Return the new file path as a String
    } catch (e) {
      print('Error moving file: $e');
      return file.path!; // Fallback to the original path if something fails
    }
  }

  void stopLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
