// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hrms/Model%20Class/DailyPunch.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';




import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model Class/FileRepositoryModel.dart';
import '../Model Class/GeoBoundariesModel.dart';
import '../Model Class/LeadsModel.dart';
import '../api config.dart';
import '../common_widgets/common_styles.dart';
import 'package:hrms/database/DataAccessHandler.dart';
import 'DatabaseHelper.dart';
import 'HRMSDatabaseHelper.dart';
// other imports as necessary

class SyncService {
 static  String apiUrl = '$baseUrl$SyncTransactions';
 // static const String apiUrl = "http://182.18.157.215/SmartGeoTrack/API/SyncTransactions/SyncTransactions";
 //var apiUrl = Uri.parse('$baseUrl$SyncTransactions');
  static const String geoBoundariesTable = 'geoBoundaries';
  static const String leadsTable = 'leads';
  static const String fileRepositoryTable = 'FileRepository';
 static const String dailyPunchTable = 'DailyPunchInAndOut';
 final dbHelper = HRMSDatabaseHelper();

 final DataAccessHandler dataAccessHandler;
  Map<String, List<Map<String, dynamic>>> refreshTransactionsDataMap = {};
  List<String> refreshTableNamesList = [
    geoBoundariesTable,
    leadsTable,
    fileRepositoryTable,
    dailyPunchTable
  ];
  int transactionsCheck = 0;

  SyncService(
      this.dataAccessHandler); // Constructor to inject DataAccessHandler

  Future<List<T>> _fetchData<T>(
      Future<List<T>> Function() fetchFunction, String modelName) async {
    List<T> dataList = await fetchFunction();
    if (dataList.isEmpty) {
      print('$modelName list is empty.');
    } else {
      print('$modelName fetched: $dataList');
    }
    return dataList;
  }

 Future<void> getRefreshSyncTransDataMap() async {
   // Fetching geoBoundaries
   List<GeoBoundariesModel> geoBoundariesList =
   await _fetchData(dbHelper.getGeoBoundariesDetails, 'GeoBoundaries');

   if (geoBoundariesList.isNotEmpty) {
     List<GeoBoundariesModel> updatedGeoBoundariesList = [];

     for (var boundary in geoBoundariesList) {
       if (boundary.latitude != null && boundary.longitude != null) {
         boundary.Address =
         await getAddressFromLatLong(boundary.latitude!, boundary.longitude!);
       }
       updatedGeoBoundariesList.add(boundary);
     }

     refreshTransactionsDataMap[geoBoundariesTable] =
         updatedGeoBoundariesList.map((model) => model.toMap()).toList();
   }

   // Fetching leads
   List<LeadsModel> leadsList =
   await _fetchData(dbHelper.getLeadsDetails, 'Leads');

   if (leadsList.isNotEmpty) {
     List<LeadsModel> updatedLeadsList = [];

     for (var lead in leadsList) {
       if (lead.latitude != null && lead.longitude != null) {
         lead.Address =
         await getAddressFromLatLong(lead.latitude!, lead.longitude!);
       }
       updatedLeadsList.add(lead);
     }

     refreshTransactionsDataMap[leadsTable] =
         updatedLeadsList.map((model) => model.toMap()).toList();
   }

   // Fetching Daily Punch
   List<DailyPunch> dailyPunchList =
   await _fetchData(dbHelper.getDailyPunchDetails, 'DailyPunchInAndOut');

   if (dailyPunchList.isNotEmpty) {
     List<DailyPunch> updatedDailyPunchList = [];

     for (var punch in dailyPunchList) {
       if (punch.punchInLatitude != null && punch.punchInLongitude != null) {
         punch.punchInAddress =
         await getAddressFromLatLong(punch.punchInLatitude, punch.punchInLongitude);
       }
       if (punch.punchOutLatitude != null && punch.punchOutLongitude != null) {
         punch.punchOutAddress =
         await getAddressFromLatLong(punch.punchOutLatitude!, punch.punchOutLongitude!);
       }
       updatedDailyPunchList.add(punch);
     }

     refreshTransactionsDataMap[dailyPunchTable] =
         updatedDailyPunchList.map((model) => model.toMap()).toList();
   }

   // Fetching fileRepoList - Make sure this happens regardless of other data
   List<FileRepositoryModel> fileRepoList = await _fetchData(dbHelper.getFileRepositoryDetails, 'FileRepository');

   if (fileRepoList.isNotEmpty) {
     List<FileRepositoryModel> updatedFileRepoList = [];

     for (var model in fileRepoList) {
       if (model.fileLocation != null) {
       await prepareAndSendFile(model.fileLocation!, model);
         updatedFileRepoList.add(model);
       }
     }

     refreshTransactionsDataMap[fileRepositoryTable] = updatedFileRepoList.map((model) => model.toJson()).toList();
   }

   if (refreshTransactionsDataMap.isEmpty) {
     print('No data was fetched from any table.');
   } else {
     print('Fetched Data: $refreshTransactionsDataMap');
   }
 }



 Future<void> performRefreshTransactionsSync(BuildContext context, int toastIndex,
     {void Function()? showSuccessBottomSheet, void Function()? onComplete}) async {
   await getRefreshSyncTransDataMap();

   if (refreshTransactionsDataMap.isNotEmpty) {
     for (String tableName in refreshTransactionsDataMap.keys) {
       await _syncTransactionsDataToCloud(context, tableName, toastIndex);
     }
   } else {
     print('No transactions data to sync.');
     showSuccessBottomSheet?.call();
   }

   // Ensure File Repository data is synced after all other data is processed
   if (refreshTransactionsDataMap.containsKey(fileRepositoryTable)) {
     await _syncTransactionsDataToCloud(context, fileRepositoryTable, toastIndex);
   }
 }

 Future<void> _syncTransactionsDataToCloud(
     BuildContext context, String tableName, int toastIndex) async {
   List tableData = refreshTransactionsDataMap[tableName] ?? [];
   if (tableData.isNotEmpty) {
     try {
       String data = jsonEncode({tableName: tableData});
       var response = await http.post(
         Uri.parse(apiUrl),
         headers: {"Content-Type": "application/json"},
         body: data,
       );
       print('data: ${jsonEncode({tableName: tableData})}');
       if (response.statusCode == 200) {
         var responseBody = jsonDecode(response.body);
         print("responseBody $tableName: ${responseBody}");
         if (responseBody['isSuccess'] == true) {
           await _updateServerUpdatedStatus(tableName);
           transactionsCheck++;

           if (transactionsCheck >= refreshTableNamesList.length) {
             _showSuccessMessage(context, toastIndex);
           }
         } else {
           print("Sync failed for $tableName: ${responseBody['endUserMessage']}");
           _showSnackBar(context, "Sync failed for $tableName: ${responseBody['endUserMessage']}");
         }
       } else {
         print('Error syncing $tableName: ${response.body}');
         _showSnackBar(context, "Sync failed for $tableName: ${response.body}");
       }
     } catch (e) {
       print("Error syncing $tableName: $e");
       _showSnackBar(context, "Error syncing $tableName: $e");
     }
   }
 }

 Future<void> _updateServerUpdatedStatus(String tableName) async {
   print("Updating ServerUpdatedStatus for table: $tableName");
   final db = await dbHelper.database;
   try {
     await db.rawUpdate("UPDATE $tableName SET ServerUpdatedStatus = '1' WHERE ServerUpdatedStatus = '0'");
     print("Updated ServerUpdatedStatus for $tableName successfully.");
   } catch (e) {
     print("Error updating ServerUpdatedStatus for $tableName: $e");
   }
 }

 void _showSuccessMessage(BuildContext context, int toastIndex) {
   switch (toastIndex) {
     case 0:
       CommonStyles.showCustomToastMessageLong('Work from Office Added Successfully!', context, 0, 2);
       break;
     case 1:
       CommonStyles.showCustomToastMessageLong('Leave Added Successfully!', context, 0, 2);
       break;
     case 2:
       CommonStyles.showCustomToastMessageLong('Leave Deleted Successfully!', context, 0, 2);
       break;
     case 3:
       CommonStyles.showCustomToastMessageLong('Lead Added Successfully!', context, 0, 2);
       break;
     case 5:
       CommonStyles.showCustomToastMessageLong('Work from Office Deleted Successfully!', context, 0, 2);
       break;
     default:
       CommonStyles.showCustomToastMessageLong('Sync is successful!', context, 0, 2);
       break;
   }
 }

  // Future<void> _syncTransactionsDataToCloud(
  //     BuildContext context, String tableName, int toastIndex) async {
  //   List tableData = refreshTransactionsDataMap[tableName] ?? [];
  //   print('tableData for ${jsonEncode({tableName: tableData})}');
  //   print('SyncTransactions===213$apiUrl');
  //   if (tableData.isNotEmpty) {
  //     try {
  //       String data = jsonEncode({tableName: tableData});
  //       var response = await http.post(
  //         Uri.parse(apiUrl),
  //         headers: {"Content-Type": "application/json"},
  //         body: data,
  //       );
  //
  //       if (response.statusCode == 200) {
  //
  //         var responseBody = jsonDecode(response.body);
  //
  //         if (responseBody['isSuccess'] == true) {
  //         // Execute the SQL update query after successful sync
  //         await _updateServerUpdatedStatus(tableName); // Ensure this is awaited
  //
  //         transactionsCheck++;
  //         if (transactionsCheck < refreshTableNamesList.length) {
  //           await _syncTransactionsDataToCloud(
  //               context, refreshTableNamesList[transactionsCheck],toastIndex);
  //         } else {
  //           if(toastIndex == 0){
  //             CommonStyles.showCustomToastMessageLong('Work from Office Added Successfully!', context, 0, 2);
  //
  //           }else if (toastIndex == 1){
  //             CommonStyles.showCustomToastMessageLong('Leave Added Successfully!', context, 0, 2);
  //
  //           }else if (toastIndex == 2){
  //             CommonStyles.showCustomToastMessageLong('Leave Deleted Successfully!', context, 0, 2);
  //
  //           }else if (toastIndex == 3){
  //             CommonStyles.showCustomToastMessageLong('Lead Added Successfully!', context, 0, 2);
  //
  //           }
  //           else if (toastIndex ==5){
  //             CommonStyles.showCustomToastMessageLong(' Work from Office Deleted Successfully!', context, 0, 2);
  //
  //           }else
  //           {
  //
  //             CommonStyles.showCustomToastMessageLong('Sync is successful!', context, 0, 2);
  //           }
  //
  //         }
  //       }
  //         else {
  //           // If isSuccess is false, handle the error
  //           String errorMessage = responseBody['endUserMessage'] ?? "Sync failed with no error message";
  //           print("Sync failed for $tableName: $errorMessage");
  //           _showSnackBar(context, "Sync failed for $tableName: $errorMessage");
  //         }
  //       }
  //
  //
  //       else {
  //        // Error response:
  //         print('Error response: ${response.body}');
  //         _showSnackBar(
  //             context, "Sync failed for $tableName: ${response.body}");
  //       }
  //     } catch (e) {
  //       print( "Error syncing data for $tableName: $e");
  //       _showSnackBar(context, "Error syncing data for $tableName: $e");
  //     }
  //   } else {
  //     transactionsCheck++;
  //     if (transactionsCheck < refreshTableNamesList.length) {
  //       await _syncTransactionsDataToCloud(
  //           context, refreshTableNamesList[transactionsCheck],toastIndex);
  //     } else {
  //       if(toastIndex == 0){
  //         CommonStyles.showCustomToastMessageLong('Work from Office Added Successfully!', context, 0, 2);
  //
  //       }else if (toastIndex == 1){
  //         CommonStyles.showCustomToastMessageLong('Leave Added Successfully!', context, 0, 2);
  //
  //       }else if (toastIndex == 2){
  //         CommonStyles.showCustomToastMessageLong('Leave Deleted Successfully!', context, 0, 2);
  //
  //       }else if (toastIndex == 3){
  //         CommonStyles.showCustomToastMessageLong('Lead Added Successfully!', context, 0, 2);
  //
  //       }
  //       else if (toastIndex ==5){
  //         CommonStyles.showCustomToastMessageLong(' Work from Office Deleted Successfully!', context, 0, 2);
  //
  //       }else
  //       {
  //
  //         CommonStyles.showCustomToastMessageLong('Sync is successful!', context, 0, 2);
  //       }
  //
  //     }
  //   }
  // }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Future<void> _updateServerUpdatedStatus(String tableName) async {
  //   print(
  //       "Attempting to update ServerUpdatedStatus for table: $tableName"); // Debug statement
  //   final db = await dbHelper.database; // Accessing database from DataAccessHandler
  //   String query =
  //       "UPDATE $tableName SET ServerUpdatedStatus = '1' WHERE ServerUpdatedStatus = '0'";
  //
  //   try {
  //     await db.rawUpdate(query);
  //     print("Updated ServerUpdatedStatus for $tableName successfully.");
  //   } catch (e) {
  //     print("Error updating ServerUpdatedStatus for $tableName: $e");
  //   }
  // }

  Future<String> getAddressFromLatLong(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print(e);
    }
    return "Unknown Location";
  }


 Future<void> prepareAndSendFile(String filePath, FileRepositoryModel model) async {
   try {
     // Log the file path
     print("📂 File path: $filePath");

     // Convert file to Base64
     String base64File = await convertFileToBase64(filePath);

     if (base64File.isEmpty) {
       print("❌ Error: Base64 conversion failed.");
       return;
     } else {
       print("✅ Base64 string generated successfully.");
     }

     // Update model (use a proper field for Base64)
   //  model.fileName = base64File; // Ensure `fileContent` exists in `FileRepositoryModel` //TODO
     model.fileName = filePath;
     // Ensure correct JSON structure before sending
     Map<String, dynamic> requestData = model.toJson();
     print("📤 Sending data: $requestData");
    //  print("File Repository Data to Sync: ${refreshTransactionsDataMap[fileRepositoryTable]}");
    //
    //  // Send data to the server
    // bool isSent = await syncDataToServer(requestData);

     // if (isSent) {
     //   print("✅ File successfully sent to the server.");
     // } else {
     //   print("❌ Failed to send file to the server.");
     // }
   } catch (e) {
     print("❌ Error in prepareAndSendFile: $e");
   }
 }



 Future<bool> syncDataToServer(Map<String, dynamic> dataMap) async {

   try {
     final response = await http.post(
       Uri.parse(apiUrl),
       headers: {
         'Content-Type': 'application/json',
       },
       body: jsonEncode(dataMap),
     );

     if (response.statusCode == 200) {
       print("Data synced successfully.");
       return true;
     } else {
       print("Server Error: ${response.statusCode} - ${response.body}");
       return false;
     }
   } catch (e) {
     print("Error sending data: $e");
     return false;
   }
 }

 sendFileDataToServer(Map<String, dynamic> requestData) {}


}
