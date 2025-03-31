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
  static const String fileRepositoryTable = 'FileRepositorys';
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
   List<GeoBoundariesModel> geoBoundariesList = await _fetchData(dbHelper.getGeoBoundariesDetails, 'GeoBoundaries');

   // Check if geoBoundariesList is not empty before adding to the map
   if (geoBoundariesList.isNotEmpty) {
     List<GeoBoundariesModel> updatedGeoBoundariesList = [];

     // For each geo boundary, get the address using latitude and longitude
     for (var boundary in geoBoundariesList) {
       if (boundary.latitude != null && boundary.longitude != null) {
         String address = await getAddressFromLatLong(
             boundary.latitude!, boundary.longitude!);
         boundary.Address = address;
       }
       // Add the updated boundary to the new list
       updatedGeoBoundariesList.add(boundary);
     }

     // Now store the updated list with addresses in the map
     refreshTransactionsDataMap[geoBoundariesTable] =
         updatedGeoBoundariesList.map((model) => model.toMap()).toList();
     print(
         'Updated geoBoundariesTable map: ${refreshTransactionsDataMap[geoBoundariesTable]}');
   } else {
     print('GeoBoundaries list is empty, skipping to next.');
   }

   // Fetching leads
   List<LeadsModel> leadsList = await _fetchData(dbHelper.getLeadsDetails, 'Leads');
   print('leadsList: ${leadsList.length}');

   // Check if leadsList is not empty before adding to the map
   if (leadsList.isNotEmpty) {List<LeadsModel> updatedleadsList = [];

     // For each lead, get the address using latitude and longitude
     for (var leaddata in leadsList) { // Should use leadsList, not updatedleadsList
       if (leaddata.latitude != null && leaddata.longitude != null) {
         String address = await getAddressFromLatLong(
             leaddata.latitude!, leaddata.longitude!);
         leaddata.Address = address;
       }
       // Add the updated lead to the new list
       updatedleadsList.add(leaddata);
     }

     // Now store the updated list with addresses in the map
     refreshTransactionsDataMap[leadsTable] = updatedleadsList.map((model) => model.toMap()).toList();
     print('Updated leadsTable map: ${refreshTransactionsDataMap[leadsTable]}');
   } else {
     print('Leads list is empty, skipping to next.');
   }

   // Fetching fileRepoList
   // List<FileRepositoryModel> fileRepoList = await _fetchData(
   //     dbHelper.getFileRepositoryDetails, 'FileRepositorys');
   //
   // if (fileRepoList.isNotEmpty) {
   //   print('File Repository list: $fileRepoList');
   //
   //   List<FileRepositoryModel> updatedFileRepoList = [];
   //
   //   // For each file repository, call prepareAndSendFile
   //   for (var model in fileRepoList) {
   //     if (model.fileLocation != null) {
   //       // Call prepareAndSendFile and update the model
   //       await prepareAndSendFile(model.fileLocation!, model);
   //
   //       // Add the updated model to the new list
   //       updatedFileRepoList.add(model);
   //     }
   //   }
   //
   //   // Now store the updated list in the map
   //   refreshTransactionsDataMap[fileRepositoryTable] =
   //       updatedFileRepoList.map((model) => model.toJson()).toList();
   //
   //   print(
   //       'Updated File Repository map: ${refreshTransactionsDataMap[fileRepositoryTable]}');
   // } else {
   //   print('File Repository list is empty.');
   // }

   // Fetching Daily Punch-In/Out data
  // List<DailyPunch> dailyPunchList = await dbHelper.getDailyPunchDetails();

   List<DailyPunch> dailyPunchList = await _fetchData(dbHelper.getDailyPunchDetails, 'DailyPunchInAndOut');
   print("DailyPunchlist before adding: ${dailyPunchList.length}");
   if (dailyPunchList.isNotEmpty) {
     List<DailyPunch> updatedDailyPunchList = [];

     for (var punchData in dailyPunchList) {
       if (punchData.punchInLatitude != null &&
           punchData.punchInLongitude != null) {
         punchData.punchInAddress = await getAddressFromLatLong(
             punchData.punchInLatitude, punchData.punchInLongitude);
       }
       if (punchData.punchOutLatitude != null &&
           punchData.punchOutLongitude != null) {
         punchData.punchOutAddress = await getAddressFromLatLong(
             punchData.punchOutLatitude!, punchData.punchOutLongitude!);
       }
       updatedDailyPunchList.add(punchData);
     }

     refreshTransactionsDataMap[dailyPunchTable] =
         updatedDailyPunchList.map((model) => model.toMap()).toList();

     print(
         'Updated DailyPunchInAndOut map: ${refreshTransactionsDataMap[dailyPunchTable]}');
   } else {
     print('DailyPunch list is empty.');
   }

   // If no data was fetched, print a message
   if (refreshTransactionsDataMap.isEmpty) {
     print('No data was fetched from any table.');
   } else {
     print('Fetched Data: $refreshTransactionsDataMap');
   }
 }



  Future<void> performRefreshTransactionsSync(BuildContext context, int toastIndex,
      {void Function()? showSuccessBottomSheet,
      void Function()? onComplete}) async {
    await getRefreshSyncTransDataMap();

    if (refreshTransactionsDataMap.isNotEmpty) {
      await _syncTransactionsDataToCloud(
          context, refreshTableNamesList[transactionsCheck],toastIndex);
    }
    else {
      // _showSnackBar(context, "No transactions data to sync.");
      String tableName = "No transactions data to sync.";
      List tableData = refreshTransactionsDataMap[tableName] ?? [];
      print('Syncing table: $tableName, Data: ${jsonEncode({tableName: tableData})}');
      print('toastIndex=>193 $toastIndex');
      if (tableData.isNotEmpty) {
        try {
          String data = jsonEncode({tableName: tableData});
          var response = await http.post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},
            body: data,
          );
          if (response.statusCode == 200) {
            // Parse response to check isSuccess
            var responseBody = jsonDecode(response.body);

            if (responseBody['isSuccess'] == true) {
              await _updateServerUpdatedStatus(tableName);
              transactionsCheck++;

              for (int transactionsCheck = 0;
              transactionsCheck < refreshTableNamesList.length;
              transactionsCheck++) {
                await _syncTransactionsDataToCloud(
                    context, refreshTableNamesList[transactionsCheck],toastIndex);
              }
              print('toastIndex=>193 $toastIndex');

              // Call onComplete after the loop ends
              if (onComplete != null) {
                onComplete(); // Ensure the callback is invoked
              }
            }
            else {
              // If isSuccess is false, handle the error
              String errorMessage = responseBody['endUserMessage'] ?? "Sync failed with no error message";
              print("Sync failed for $tableName: $errorMessage");
              _showSnackBar(context, "Sync failed for $tableName: $errorMessage");
            }


          } else {
            print("Sync failed for $tableName: ${response.body}");
            _showSnackBar(
                context, "Sync failed for $tableName: ${response.body}");
          }
        } catch (e) {
          _showSnackBar(context, "Error syncing data for $tableName: $e");
        }
      } else {
        transactionsCheck++;
        if (transactionsCheck < refreshTableNamesList.length) {
          await _syncTransactionsDataToCloud(
              context, refreshTableNamesList[transactionsCheck],toastIndex);
        } else {
          // Call showSuccessBottomSheet when loop ends
          if (showSuccessBottomSheet != null) {
            showSuccessBottomSheet(); // Ensure the callback is invoked
          }
        }
      }
    }
  }

  Future<void> _syncTransactionsDataToCloud(
      BuildContext context, String tableName, int toastIndex) async {
    List tableData = refreshTransactionsDataMap[tableName] ?? [];
    print('tableData for ${jsonEncode({tableName: tableData})}');
    print('SyncTransactions===213$apiUrl');
    if (tableData.isNotEmpty) {
      try {
        String data = jsonEncode({tableName: tableData});
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: data,
        );

        if (response.statusCode == 200) {

          var responseBody = jsonDecode(response.body);

          if (responseBody['isSuccess'] == true) {
          // Execute the SQL update query after successful sync
          await _updateServerUpdatedStatus(tableName); // Ensure this is awaited

          transactionsCheck++;
          if (transactionsCheck < refreshTableNamesList.length) {
            await _syncTransactionsDataToCloud(
                context, refreshTableNamesList[transactionsCheck],toastIndex);
          } else {
            if(toastIndex == 0){
              CommonStyles.showCustomToastMessageLong('Work from Office Added Successfully!', context, 0, 2);

            }else if (toastIndex == 1){
              CommonStyles.showCustomToastMessageLong('Leave Added Successfully!', context, 0, 2);

            }else if (toastIndex == 2){
              CommonStyles.showCustomToastMessageLong('Leave Deleted Successfully!', context, 0, 2);

            }else if (toastIndex == 3){
              CommonStyles.showCustomToastMessageLong('Lead Added Successfully!', context, 0, 2);

            }
            else if (toastIndex ==5){
              CommonStyles.showCustomToastMessageLong(' Work from Office Deleted Successfully!', context, 0, 2);

            }else
            {

              CommonStyles.showCustomToastMessageLong('Sync is successful!', context, 0, 2);
            }

          }
        }
          else {
            // If isSuccess is false, handle the error
            String errorMessage = responseBody['endUserMessage'] ?? "Sync failed with no error message";
            print("Sync failed for $tableName: $errorMessage");
            _showSnackBar(context, "Sync failed for $tableName: $errorMessage");
          }
        }


        else {
         // Error response:
          print('Error response: ${response.body}');
          _showSnackBar(
              context, "Sync failed for $tableName: ${response.body}");
        }
      } catch (e) {
        print( "Error syncing data for $tableName: $e");
        _showSnackBar(context, "Error syncing data for $tableName: $e");
      }
    } else {
      transactionsCheck++;
      if (transactionsCheck < refreshTableNamesList.length) {
        await _syncTransactionsDataToCloud(
            context, refreshTableNamesList[transactionsCheck],toastIndex);
      } else {
        if(toastIndex == 0){
          CommonStyles.showCustomToastMessageLong('Work from Office Added Successfully!', context, 0, 2);

        }else if (toastIndex == 1){
          CommonStyles.showCustomToastMessageLong('Leave Added Successfully!', context, 0, 2);

        }else if (toastIndex == 2){
          CommonStyles.showCustomToastMessageLong('Leave Deleted Successfully!', context, 0, 2);

        }else if (toastIndex == 3){
          CommonStyles.showCustomToastMessageLong('Lead Added Successfully!', context, 0, 2);

        }
        else if (toastIndex ==5){
          CommonStyles.showCustomToastMessageLong(' Work from Office Deleted Successfully!', context, 0, 2);

        }else
        {

          CommonStyles.showCustomToastMessageLong('Sync is successful!', context, 0, 2);
        }

      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateServerUpdatedStatus(String tableName) async {
    print(
        "Attempting to update ServerUpdatedStatus for table: $tableName"); // Debug statement
    final db = await dbHelper.database; // Accessing database from DataAccessHandler
    String query =
        "UPDATE $tableName SET ServerUpdatedStatus = '1' WHERE ServerUpdatedStatus = '0'";

    try {
      await db.rawUpdate(query);
      print("Updated ServerUpdatedStatus for $tableName successfully.");
    } catch (e) {
      print("Error updating ServerUpdatedStatus for $tableName: $e");
    }
  }

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
}
