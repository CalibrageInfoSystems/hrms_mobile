import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Model%20Class/projectmodel.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/login_screen.dart';
import 'package:hrms/shared_keys.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'database/ApiKeyManager.dart';

class TestProjectsScreen extends StatefulWidget {
  const TestProjectsScreen({super.key});

  @override
  State<TestProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<TestProjectsScreen> {
  late Future<List<projectmodel>> futureProjects;

  @override
  void initState() {
    super.initState();
    futureProjects = getProjectDetails();
  }

  Future<List<projectmodel>> getProjectDetails() async {
    try {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (!isConnected) {
        Commonutils.showCustomToastMessageLong(
            'Please Check the Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        throw NetworkException('Please Check the Internet Connection');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString(SharedKeys.accessToken) ?? "";
      String? employeid = prefs.getString(SharedKeys.employeeId) ?? "";
      String? loginTime = prefs.getString('loginTime') ?? 'Unknown';

      DateTime currentTime = DateTime.now();
      DateTime formattedlogintime = DateTime.parse(loginTime);

      Duration timeDifference = currentTime.difference(formattedlogintime);

      // if (timeDifference.inSeconds > 3600) {
      //   _showtimeoutdialog(context);
      //   throw SessionTimeOut('Session Time Out');
      // }

      /*  if (timeDifference.inSeconds <= 3600) {
    } else {
      _showtimeoutdialog(context);
      throw SessionTimeOut('Session Time Out');
    } */

      final apiUrl = Uri.parse('$baseUrl$getselfempolyee$employeid');

      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      // String? apiKey = await ApiKeyManager.getApiKey();
      // print('Stored API Key: $apiKey');
//  final apiUrl = Uri.parse(baseUrl + getselfempolyee + empolyeid);
      final jsonResponse = await http.get(
        apiUrl,
        headers: {
          'APIKey': APIKey,
        },
      );

      print('jsonResponse.body: ${jsonResponse.body}');

      if (jsonResponse.statusCode == 200) {
        final Map<String, dynamic> response = jsonDecode(jsonResponse.body);

        if (response['workingProjects'] != null &&
            response['workingProjects'].isNotEmpty) {
          final List<dynamic> workingProjects =
              jsonDecode(response['workingProjects']);
          /* workingProjects.map((project) {
          print('getProjectDetails: ${project['projectName']}');
        }).toList(); */
          List<projectmodel> projectList = workingProjects.map((project) {
            return projectmodel(
              projectlogo:
                  convertBase64StringToUint8List(project['projectLogo'])!,
              projectname: project['projectName'],
              instances: [
                ProjectInstance(
                    projectfromdate: project["sinceFrom"],
                    projecttodate: project["endAt"] ?? "Progress")
              ],
              projectid: project['projectId'],
            );
          }).toList();

          return projectList;
        } else {
          throw Exception('There is no Assigned Projects for this Employee');
        }
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      print('catch: $e');
      rethrow;
    }
  }

  // Future<bool> checkSessionTimeOut(String? loginTime) async {
  //   if (loginTime == null) {
  //     return false;
  //   }
  //   DateTime currentTime = DateTime.now();
  //   DateTime formattedlogintime = DateTime.parse(loginTime);
  //
  //   Duration timeDifference = currentTime.difference(formattedlogintime);
  //
  //   if (timeDifference.inSeconds > 3600) {
  //     _showtimeoutdialog(context);
  //     return false;
  //   }
  //   return true;
  // }

  Uint8List convertBase64StringToUint8List(String? base64String) {
    if (base64String == null) {
      return Uint8List(0);
    }

    List<String> parts = base64String.split(',');

    if (parts.length > 1) {
      String base64Image = parts[1];
      return Uint8List.fromList(base64.decode(base64Image));
    }

    return Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        /*  Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          ); */
        return true;
      },
      child: Scaffold(
        /*  
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                'Projects',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Calibri',
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            */

        body: Stack(
          children: [
            Image.asset(
              'assets/background_layer_2.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                //  vertical: 40.0
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Text(
                      'Assigned Projects',
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontFamily: 'Calibri'),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Expanded(
                        child: FutureBuilder(
                            future: futureProjects,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                if (snapshot.error is NetworkException) {
                                  return Center(
                                    child: Text(
                                        (snapshot.error as NetworkException)
                                            .message),
                                  );
                                }
                                return Center(
                                  child: Text(
                                    snapshot.error
                                        .toString()
                                        .replaceFirst('Exception: ', ''),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily: 'Calibri'),
                                  ),
                                );
                              }
                              final projectList =
                                  snapshot.data as List<projectmodel>;
                              return projectsGrid(projectList);
                              /*  return ListView.builder(
                                    itemCount: projectList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Text(
                                            projectList[index].projectname),
                                      );
                                    },
                                  ); */
                            }))
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget projectsGrid(List<projectmodel> projectlist) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          mainAxisExtent: 160,
          childAspectRatio: 8 / 2),
      /*  physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true, */
      itemCount: projectlist.length,
      itemBuilder: (BuildContext context, int index) {
        projectmodel project = projectlist[index];

        return GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? loginTime = prefs.getString('loginTime') ?? 'Unknown';
              fetchProjectList(project.projectid);
              // if (await checkSessionTimeOut(loginTime)) {
              //   fetchProjectList(project.projectid);
              // }
              /*  print(
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
                                              } */
            },
            child: Scrollbar(
                child: Container(
              // height: 300,
              //   padding: EdgeInsets.only(top: 10.0, left: 5, right: 5),
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //SizedBox(height: 5.0),
                  // Display project name and logo only once
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.white,
                    backgroundImage: MemoryImage(project.projectlogo),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    project.projectname,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  //  SizedBox(height: 5.0),
                  // Display from date and to date multiple times

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildRows(project.instances),
                  ),
                ],
              )),
            )));
      },
    );
  }

  Future<void> fetchProjectList(int selectedProjectId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? accessToken = prefs.getString(SharedKeys.accessToken) ?? "";
      String APIKey = prefs.getString(SharedKeys.APIKey) ?? "";
      final loadedData = await SharedPreferencesHelper.getCategories();
      if (loadedData != null) {
        int employeid = loadedData["employeeId"];

        bool isConnected = await Commonutils.checkInternetConnectivity();
        if (!isConnected) {
          Commonutils.showCustomToastMessageLong(
              'Please Check the Internet Connection', context, 1, 4);
          FocusScope.of(context).unfocus();
          return;
        }
        final url = Uri.parse('$baseUrl$getprojectemployeslist$employeid');
        print('API URL: $url');
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'APIKey': APIKey,
          },
        );
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
        }
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      print('Error: $e');
      // Rethrow the caught exception if needed
    }
  }

  List<Widget> buildRows(List instances) {
    List<Widget> rows = [];

    for (var instance in instances) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: Text(
                DateFormat('dd MMM yyyy').format(fromDate),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
            const Padding(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 5, 2, 0),
              child: Text(
                formattedToDate,
                style: const TextStyle(
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
                  SizedBox(
                    height: 50.0,
                    width: 60.0,
                    child: SvgPicture.asset(
                      'assets/cislogo-new.svg',
                      height: 120.0,
                      width: 55.0,
                    ),
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  const Text(
                    "Session Time Out",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 3.0,
                  ),
                  const Text(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf15f22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Calibri'),
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
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
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.3,
                padding: const EdgeInsets.only(
                    left: 15.0, right: 10, top: 6, bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Team Members",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Calibri',
                            color: Color(0xFFf15f22),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 3.0,
                        child: ListView.builder(
                          itemCount: teamMembers.length,
                          itemBuilder: (BuildContext context, int index) {
                            var member = teamMembers[index];
                            return Card(
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.only(
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
                                            Expanded(
                                                flex: 3,
                                                child: Text(
                                                  '${member['employeeName']}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Calibri',
                                                    color: Color(0xFFf15f22),
                                                  ),
                                                )),
                                          ],
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: <InlineSpan>[
                                              const WidgetSpan(
                                                child: SizedBox(
                                                  width: 90,
                                                  child: Text('Employee Id',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  child: const Text(':',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  child: Text(
                                                      ' ${member['employeeCode']}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: <InlineSpan>[
                                              const WidgetSpan(
                                                child: SizedBox(
                                                  width: 90,
                                                  child: Text('Designation',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  child: const Text(':',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: Container(
                                                  child: Text(
                                                      ' ${member['designationName']}',
                                                      style: const TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (member.containsKey('reportingTo') &&
                                            member['reportingTo'] != null)
                                          RichText(
                                            text: TextSpan(
                                              children: <InlineSpan>[
                                                const WidgetSpan(
                                                  child: SizedBox(
                                                    width: 90,
                                                    child: Text('Reporting To',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: Container(
                                                    child: const Text(':',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                                WidgetSpan(
                                                  child: Container(
                                                    child: Text(
                                                        ' ${member['reportingTo']}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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

class NetworkException implements Exception {
  final String message;
  final int? code;

  NetworkException(this.message, {this.code});

  @override
  String toString() => message.toString();
}

// class SessionTimeOut implements Exception {
//   final String message;
//   final int? code;
//
//   SessionTimeOut(this.message, {this.code});
//
//   @override
//   String toString() => message.toString();
// }
