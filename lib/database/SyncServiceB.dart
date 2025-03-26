
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:hrms/database/DataAccessHandler.dart';

import 'package:http/http.dart' as http;
import '../HomeScreen.dart';
import '../Model Class/GeoBoundariesModel.dart';
import '../api config.dart';

import 'DatabaseHelper.dart';
import 'HRMSDatabaseHelper.dart';

class SyncServiceB {
  static String apiUrl = '$baseUrl$SyncTransactions';
  static const String geoBoundariesTable = 'geoBoundaries';

  final DataAccessHandler dataAccessHandler;
  final dbHelper = HRMSDatabaseHelper();
  Map<String, List<Map<String, dynamic>>> refreshTransactionsDataMap = {};

  SyncServiceB(this.dataAccessHandler);

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
    // Fetch geoBoundaries data
    List<GeoBoundariesModel> geoBoundariesList = await _fetchData(
        dbHelper.getGeoBoundariesDetails, 'GeoBoundaries');

    // If data is available, process and update the map
    if (geoBoundariesList.isNotEmpty) {
      List<GeoBoundariesModel> updatedGeoBoundariesList = [];
      for (var boundary in geoBoundariesList) {
        if (boundary.latitude != null && boundary.longitude != null) {
          String address = await getAddressFromLatLong(
              boundary.latitude!, boundary.longitude!);
          boundary.Address = address;
        }
        updatedGeoBoundariesList.add(boundary);
      }
      refreshTransactionsDataMap[geoBoundariesTable] =
          updatedGeoBoundariesList.map((model) => model.toMap()).toList();
      print(
          'Updated geoBoundariesTable map: ${refreshTransactionsDataMap[geoBoundariesTable]}');
      appendLog('Updated geoBoundariesTable map: ${refreshTransactionsDataMap[geoBoundariesTable]}');
    }

    // Check if the map is still empty
    if (refreshTransactionsDataMap.isEmpty) {
      print('No data was fetched from the geoBoundaries table.');
      appendLog('No data was fetched from the geoBoundaries table.');
    } else {
      print('Fetched Data: $refreshTransactionsDataMap');
      appendLog('Fetched Data: $refreshTransactionsDataMap');
    }
  }

  Future<void> performRefreshTransactionsSync() async {
    // Fetch the data for sync
    await getRefreshSyncTransDataMap();

    // If there's data to sync, send it to the server
    if (refreshTransactionsDataMap.isNotEmpty) {
      print('Fetched Data: ${refreshTransactionsDataMap}');
      appendLog('Fetched Data: ${refreshTransactionsDataMap}');
      await _syncTransactionsDataToCloud(geoBoundariesTable);
    } else {
      print('No transactions data to sync.');
      appendLog('No transactions data to sync.');
    }
  }

  Future<void> _syncTransactionsDataToCloud(String tableName) async {
    // Get the data for the specified table
    List tableData = refreshTransactionsDataMap[tableName] ?? [];

    // Sync only if there is data to sync
    if (tableData.isNotEmpty) {
      try {
        String data = jsonEncode({tableName: tableData});
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: data,
        );
        print('Syncing table data for $tableName: ${jsonEncode({tableName: tableData})}');
        print('statusCode: ${response.statusCode}');
        appendLog('Syncing table data for $tableName: ${jsonEncode({tableName: tableData})}');
        appendLog('statusCode: ${response.statusCode}');
        // If sync is successful, update the sync status in the local database
        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);

          if (responseBody['isSuccess'] == true) {
            await _updateServerUpdatedStatus(tableName);
            print("Sync is successful!");
            appendLog('Sync is successful!');
          }
          else {
            // If isSuccess is false, handle the error
            String errorMessage = responseBody['endUserMessage'] ?? "Sync failed with no error message";
            print("Sync failed for $tableName: $errorMessage");
            appendLog('Sync failed for $tableName: $errorMessage');
            //_showSnackBar(context, "Sync failed for $tableName: $errorMessage");
          }
        } else {
          print("Sync failed for $tableName: ${response.body}");
          appendLog('Sync failed for $tableName: ${response.body}');
        }
      } catch (e) {
        appendLog('Error syncing data for $tableName: $e');
        print("Error syncing data for $tableName: $e");
      }
    } else {
      appendLog('No data to sync for $tableName.');
      print('No data to sync for $tableName.');
    }
  }

  Future<void> _updateServerUpdatedStatus(String tableName) async {
    final db = await dbHelper.database;
    String query =
        "UPDATE $tableName SET ServerUpdatedStatus = '1' WHERE ServerUpdatedStatus = '0'";
    appendLog('UPDATE query: $query');
    print("UPDATE query: $query");
    await db.rawUpdate(query);
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