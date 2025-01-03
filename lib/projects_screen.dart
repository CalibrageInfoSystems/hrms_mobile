import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Model%20Class/projectmodel.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/personal_details.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'main.dart';

class projects_screen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<projects_screen> {
  List<Widget> projectCardWidgets = [];
  String? EmployeName;
  String projectnamedetails = '';
  late Uint8List bytes;
  List<projectmodel> projectlist = [];
  String accesstoken = '';
  int employeid = 0;
  int projectid = 0;
  String? logintime;
  bool _isLoading = false;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    bytes = Uint8List(0);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        loadAccessToken();
        print('The Internet Is Connected');
        _loadProjectDetails();
        getLoginTime();
        // _loadProjectDetails();
      } else {
        print('The Internet Is not Connected');
      }
    });
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accesstoken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninprojectscreen:$accesstoken");
  }

  void _loadProjectDetails() async {
    setState(() {
      _isLoading = true;
    });
    // Specify the API endpoint
    final loadedData = await SharedPreferencesHelper.getCategories();
    String pm = "";

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final emplyeid = loadedData["employeeId"];
      final workingProjects = loadedData['workingProjects'];
      print("workingProjects ===>96 ${workingProjects}");
      print('workingProjects ====>97: $workingProjects');

      setState(() {
        employeid = emplyeid;

        print('employeid: $employeid');
      });
      if (workingProjects != null) {
        List<dynamic> projects = json.decode(workingProjects);
        if (projects != null && projects is List) {
          List<projectmodel> projectList = [];
          for (var project in projects) {
            print("Project ID: ${project["projectId"]}");
            print("Project Name: ${project["projectName"]}");
            print("Project Description: ${project["projectDescription"]}");
            print("Project Logo: ${project["projectLogo"]}");
            print("\n");
            pm = project["projectName"];
            // String base64Image = project["projectLogo"].split(',')[1];
            String? base64Image;

// Check if project["projectLogo"] is not null
            if (project["projectLogo"] != null) {
              String? logoString = project["projectLogo"];

              if (logoString != null) {
                List<String> parts = logoString.split(',');

                if (parts.length > 1) {
                  base64Image = parts[1];
                  bytes = Uint8List.fromList(base64.decode(base64Image));
                }
              }
            }

            print("Project Logo:108===? $base64Image");
            // bytes = Uint8List.fromList(base64.decode(base64Image!));
            print("bytes:108===? $bytes");
            print("Project endAt: ${project["endAt"]}");

            var existingProjectIndex = projectList.indexWhere(
              (existingProject) =>
                  existingProject.projectname == project["projectName"],
            );

            if (existingProjectIndex != -1) {
              // If the project exists, add only the instance
              projectList[existingProjectIndex].instances.add(ProjectInstance(
                    projectfromdate: project["sinceFrom"],
                    projecttodate: project["endAt"] ?? "Progress",
                  ));
            } else {
              // If the project doesn't exist, create a new project and add it to projectList
              List<ProjectInstance> instances = [];
              instances.add(ProjectInstance(
                projectfromdate: project["sinceFrom"],
                projecttodate: project["endAt"] ?? "Progress",
              ));

              projectList.add(projectmodel(
                  projectlogo: bytes,
                  projectname: project["projectName"],
                  instances: instances,
                  projectid: project["projectId"]));
            }
          }
          setState(() {
            // EmployeName = employeeName;
            projectlist = projectList;
            _isLoading = false;
            projectnamedetails = pm;
          });
        }
      } else {
        // Handle the case where workingProjects is null
        // You may want to initialize projects to an empty list or handle the error differently
      }
      setState(() {
        EmployeName = employeeName;
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchProjectList(int employeid, int selectedProjectId) async {
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }
    try {
      final url = Uri.parse(baseUrl + getprojectemployeslist + '$employeid');
      print('API URL: $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accesstoken',
        },
      );
      print('accestoekn:$accesstoken');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        List<dynamic> projects = jsonDecode(response.body);
        print('project$projects');

        // Find the selected project by ID
        var selectedProject = projects.firstWhere(
          (project) => project['projectId'] == selectedProjectId,
          orElse: () => null,
        );

        if (selectedProject != null) {
          print('Selected Project Name: ${selectedProject['projectName']}');
          print(
              'Selected Project Description: ${selectedProject['description']}');

          // Check if teamMembers is not null
          if (selectedProject['teamMembers'] != null) {
            List<dynamic> teamMembers =
                jsonDecode(selectedProject['teamMembers']);
            showpopup(teamMembers);
            for (var member in teamMembers) {
              print('Employee Code: ${member['employeeCode']}');
              print('Employee Name: ${member['employeeName']}');
              print('Designation Name: ${member['designationName']}');
              print('Reporting to${member['reportingTo']}');
            }
          } else {
            print('No team members found for this project.');
            Commonutils.showCustomToastMessageLong(
                'You are Currently Not In This Project', context, 1, 4);
          }
        } else {
          print('Project not found.');
        }
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Rethrow the caught exception if needed
    }
  }

  // Future<void> fetchProjectList(int employeid) async {
  //   try {
  //     final url = Uri.parse(baseUrl + getprojectemployeslist + '$employeid');
  //     print('API URL: $url');
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': '$accesstoken',
  //       },
  //     );
  //     print('accestoekn:$accesstoken');
  //     print('Response Headers: ${response.headers}');
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> projects = jsonDecode(response.body);
  //       print('project$projects');
  //       // Iterate through each project
  //       for (var project in projects) {
  //         print('Project Name: ${project['projectName']}');
  //         print('Project Description: ${project['description']}');
  //
  //         // Check if teamMembers is not null
  //         if (project['teamMembers'] != null) {
  //           List<dynamic> teamMembers = jsonDecode(project['teamMembers']);
  //           showpopup(teamMembers);
  //           for (var member in teamMembers) {
  //             print('Employee Code: ${member['employeeCode']}');
  //             print('Employee Name: ${member['employeeName']}');
  //             print('Designation Name: ${member['designationName']}');
  //           }
  //         }
  //       }
  //     } else {
  //       throw Exception('Failed to load projects: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     // Rethrow the caught exception
  //   }
  // }

  Future<String?> getLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logintime = prefs.getString('loginTime') ?? 'Unknown';
    print('Login Time: $logintime');
    return logintime;
  }

  List<Widget> buildRows(List instances) {
    List<Widget> rows = [];

    for (var instance in instances) {
      // Convert date strings to DateTime objects
      DateTime fromDate = DateTime.parse(instance.projectfromdate);
      String? formattedToDate;
      if (instance.projecttodate != null && instance.projecttodate.isNotEmpty) {
        try {
          DateTime toDate = DateTime.parse(instance.projecttodate);
          formattedToDate = DateFormat('dd MMM yyyy').format(toDate);
        } catch (e) {
          formattedToDate = 'Progress';
        }
      } else {
        formattedToDate = 'Progress';
      }
      rows.add(Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Expanded(
            //   flex: 5,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.fromLTRB(4, 7, 4, 0),
            //         child: Text(
            //           DateFormat('dd MMM yyyy').format(fromDate), // Format date here
            //           style: TextStyle(
            //             color: Colors.black54,
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             fontFamily: 'Calibri',
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: Text(
                DateFormat('dd MMM yyyy').format(fromDate), // Format date here
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
            // Expanded(
            //   flex: 0,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
            //         child: Text(
            //           "-",
            //           style: TextStyle(
            //             color: Colors.black54,
            //             fontSize: 16,
            //             fontFamily: 'Calibri',
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: Text(
                "-",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontFamily: 'Calibri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Expanded(
            //   flex: 5,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.fromLTRB(4, 7, 5, 0),
            //         child: Text(
            //           formattedToDate!, // Format date here
            //           style: TextStyle(
            //             color: Colors.black54,
            //             fontSize: 14,
            //             fontWeight: FontWeight.bold,
            //             fontFamily: 'Calibri',
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // )
            Padding(
              // padding: EdgeInsets.fromLTRB(4, 7, 5, 0),
              padding: EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: Text(
                formattedToDate, // Format date here
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Stack(
              children: [
                // Background Image
                Image.asset(
                  'assets/background_layer_2.png', // Replace with your image path
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),

                // SingleChildScrollView for scrollable content
                SingleChildScrollView(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Hello!",
                          //   style: TextStyle(fontSize: 26, color: Colors.black, fontFamily: 'Calibri'),
                          // ),
                          // SizedBox(
                          //   height: 8.0,
                          // ),
                          // Text(
                          //   "$EmployeName",
                          //   style: TextStyle(fontSize: 26, color: Color(0xFFf15f22), fontFamily: 'Calibri'),
                          // ),
                          Text(
                            'Assigned Projects',
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                                fontFamily: 'Calibri'),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          projectlist.isNotEmpty
                              ? _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator
                                          .adaptive()) // Show loading indicator
                                  : GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              mainAxisExtent: 160,
                                              childAspectRatio: 8 / 2),
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: projectlist.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        projectmodel project =
                                            projectlist[index];

                                        return GestureDetector(
                                            onTap: () {
                                              //  fetchProjectList(employeid);
                                              print(
                                                  'project_id${project.projectid}');
                                              DateTime currentTime =
                                                  DateTime.now();
                                              DateTime formattedlogintime =
                                                  DateTime.parse(logintime!);
                                              DateTime loginTime =
                                                  formattedlogintime /* Replace with your login time */;

                                              // Calculate the time difference
                                              Duration timeDifference =
                                                  currentTime
                                                      .difference(loginTime);

                                              if (timeDifference.inSeconds <=
                                                  3600) {
                                                fetchProjectList(employeid,
                                                    project.projectid);

                                                print(
                                                    "Login is within 1 hour of current time.");
                                              } else {
                                                // Login is outside the allowed window
                                                _showtimeoutdialog(context);
                                                print(
                                                    "Login is more than 1 hour from current time.");
                                              }
                                            },
                                            child: Scrollbar(
                                                child: Container(
                                              // height: 300,
                                              //   padding: EdgeInsets.only(top: 10.0, left: 5, right: 5),
                                              padding: EdgeInsets.only(top: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: SingleChildScrollView(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  //SizedBox(height: 5.0),
                                                  // Display project name and logo only once
                                                  CircleAvatar(
                                                    radius: 40.0,
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        MemoryImage(project
                                                            .projectlogo),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    "${project.projectname}",
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  //  SizedBox(height: 5.0),
                                                  // Display from date and to date multiple times

                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: buildRows(
                                                        project.instances),
                                                  ),
                                                  // SizedBox(
                                                  //   height: 50,
                                                  //   child: ListView.builder(
                                                  //     scrollDirection: Axis.vertical,
                                                  //     itemCount: project.instances.length,
                                                  //     itemBuilder: (BuildContext context, int instanceIndex) {
                                                  //       var instance = project.instances[instanceIndex];
                                                  //       return Column(
                                                  //         children: [
                                                  //           Row(
                                                  //             children: [
                                                  //               Padding(
                                                  //                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  //                 child: Text(
                                                  //                   "${instance.projectfromdate}",
                                                  //                   style: TextStyle(
                                                  //                     color: Colors.black54,
                                                  //                     fontSize: 14,
                                                  //                     fontWeight: FontWeight.bold,
                                                  //                     fontFamily: 'Calibri',
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               Padding(
                                                  //                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  //                 child: Text(
                                                  //                   "-",
                                                  //                   style: TextStyle(
                                                  //                     color: Colors.black54,
                                                  //                     fontSize: 16,
                                                  //                     fontFamily: 'Calibri',
                                                  //                     fontWeight: FontWeight.bold,
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //               Padding(
                                                  //                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  //                 child: Text(
                                                  //                   "${instance.projecttodate}",
                                                  //                   style: TextStyle(
                                                  //                     color: Colors.black54,
                                                  //                     fontSize: 14,
                                                  //                     fontWeight: FontWeight.bold,
                                                  //                     fontFamily: 'Calibri',
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ],
                                                  //           ),
                                                  //         ],
                                                  //       );
                                                  //     },
                                                  //   ),
                                                  // ),
                                                ],
                                              )),
                                            )));
                                      },
                                    )
                              : Center(
                                  child: Text(
                                    "There is no Assigned Projects for this Employee",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily: 'Calibri'),
                                  ),
                                ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ));
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
              surfaceTintColor: Colors.transparent,
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
                  // SizedBox(
                  //   height: 3.0,
                  // ),
                  // Text(
                  //   "Invalid Token",
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontFamily: 'Calibri',
                  //     color: Colors.black,
                  //   ),
                  // ),

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
                    onConfirmLogout();
                    Navigator.of(context).pop();
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

  Future<void> deleteLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginTime');
  }

  void onConfirmLogout() {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong("Logout Successful", context, 0, 3);
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => LoginPage()));

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void showpopup(List<dynamic> teamMembers) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Colors.white,
            // title: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       "Team Members",
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontFamily: 'Calibri',
            //         color: Color(0xFFf15f22),
            //       ),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.close),
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //       },
            //     ),
            //   ],
            // ),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.3,
                padding:
                    EdgeInsets.only(left: 15.0, right: 10, top: 6, bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Team Members",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Calibri',
                            color: Color(0xFFf15f22),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height /
                            3.0, // Adjust the height as needed
                        child: ListView.builder(
                          itemCount: teamMembers.length,
                          itemBuilder: (BuildContext context, int index) {
                            var member = teamMembers[index];
                            return Card(
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    // height: MediaQuery.of(context).size.height / 3.0,
                                    // height: MediaQuery.of(context).size.height, // Adjust the height as needed
                                    padding: EdgeInsets.only(
                                        left: 10.0,
                                        right: 10,
                                        bottom: 10,
                                        top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            //  Text('Employee Name: '),
                                            Expanded(
                                                flex: 3,
                                                child: Text(
                                                  '${member['employeeName']}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Calibri',
                                                    color: Color(0xFFf15f22),
                                                  ),
                                                )),
                                          ],
                                        ),
                                        // Row(
                                        //   children: [
                                        //     Text('Employee Id  : '),
                                        //     Expanded(
                                        //         flex: 3,
                                        //         child: Text(
                                        //           ' ${member['employeeCode']}',
                                        //           style: TextStyle(fontSize: 14),
                                        //         )),
                                        //   ],
                                        // ),

                                        RichText(
                                          text: TextSpan(
                                            children: <InlineSpan>[
                                              WidgetSpan(
                                                child: Container(
                                                  width:
                                                      90, // Adjust the width as needed to align the colons
                                                  child: Text('Employee Id',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  // Adjust the width as needed to align the colons
                                                  child: Text(':',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  // Adjust the width as needed to align the colons
                                                  child: Text(
                                                      ' ${member['employeeCode']}',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Row(
                                        //   children: [
                                        //     Text('Designation  : '),
                                        //     Expanded(
                                        //         flex: 3,
                                        //         child: Text(
                                        //           ' ${member['designationName']}',
                                        //           style: TextStyle(fontSize: 14),
                                        //         )),
                                        //   ],
                                        // ),
                                        RichText(
                                          text: TextSpan(
                                            children: <InlineSpan>[
                                              WidgetSpan(
                                                child: Container(
                                                  width:
                                                      90, // Adjust the width as needed to align the colons
                                                  child: Text('Designation',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  // Adjust the width as needed to align the colons
                                                  child: Text(':',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  // Adjust the width as needed to align the colons
                                                  child: Text(
                                                      ' ${member['designationName']}',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (member.containsKey('reportingTo') &&
                                            member['reportingTo'] != null)
                                          // Row(  n
                                          //   children: [
                                          //     Text('Reporting To:'),
                                          //     Expanded(
                                          //       flex: 1,
                                          //       child: Text(
                                          //         '${member['reportingTo']}',
                                          //         maxLines: 5,
                                          //         style: TextStyle(fontSize: 14),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          RichText(
                                            text: TextSpan(
                                              children: <InlineSpan>[
                                                WidgetSpan(
                                                  child: Container(
                                                    width:
                                                        90, // Adjust the width as needed to align the colons
                                                    child: Text('Reporting To',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: Container(
                                                    // Adjust the width as needed to align the colons
                                                    child: Text(':',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: Container(
                                                    // Adjust the width as needed to align the colons
                                                    child: Text(
                                                        ' ${member['reportingTo']}',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // SizedBox(height: 10), // Adjust spacing between entries
                                      ],
                                    )));
                          },
                        )),
                  ],
                )));
      },
    );
  }
}
