import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hrms/screens/home/HomeScreen.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../Model Class/FileRepositoryModel.dart';
import '../Model Class/GeoBoundariesModel.dart';
import '../Model Class/LeadsModel.dart';

class HRMSDatabaseHelper {
  static const String _databaseName = "hrmsgeotrack.sqlite";
  static const int _databaseVersion = 1;
  // static final Lock _lock = Lock();
  static final HRMSDatabaseHelper _instance = HRMSDatabaseHelper._internal();

  factory HRMSDatabaseHelper() => _instance;

  HRMSDatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      print("Database already initialized.");
      return _database!;
    }
    print("Initializing database...");
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> get _dbPath async {
    String path = join(await getDatabasesPath(), _databaseName);
    print("Database path: $path");
    return path;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await _dbPath;
    bool dbExists = await databaseExists(dbPath);

    if (!dbExists) {
      print("Database does not exist. Copying from assets...");
      try {
        await _copyDatabaseFromAssets(dbPath);
        print("Database copied successfully.");
      } catch (e) {
        print("Error copying database: $e");
        throw Exception("Error copying database: $e");
      }
    } else {
      print("Database already exists.");
    }

    print("Opening database...");
    return await openDatabase(dbPath, version: _databaseVersion);
  }

  /// Create Database (if it doesn't exist)
  Future<void> createDatabase() async {
    String dbPath = await _dbPath;
    bool dbExists = await databaseExists(dbPath);

    if (!dbExists) {
      print("Database does not exist. Copying from assets...");
      try {
        await _copyDatabaseFromAssets(dbPath);
        print('Database copied successfully.');
      } catch (e) {
        print('Error copying database: $e');
        throw Exception('Error copying database');
      }
    } else {
      print("Database already exists, skipping copy.");
    }

    // Open the database after creation or if it already exists
    print("Opening database after creation...");
    await printTables();
  }

  Future<void> _copyDatabaseFromAssets(String dbPath) async {
    print("Loading database from assets...");
    ByteData data = await rootBundle.load("assets/$_databaseName");
    List<int> bytes = data.buffer.asUint8List();

    print("Writing database to: $dbPath");
    await File(dbPath).writeAsBytes(bytes, flush: true);
    print("Database written successfully.");
  }

  Future<void> insertData(
      String tableName, List<Map<String, dynamic>> dataList) async {
    final db = await database;
    print("Inserting data into table: $tableName");

    try {
      for (var data in dataList) {
        print("Inserting row: $data");
        await db.insert(tableName, data);
      }
      print("Data inserted successfully.");
    } catch (e) {
      print("Data insertion failed: $e");
      throw Exception("Data insertion failed: $e");
    }
  }

  Future<void> updateData(String tableName, Map<String, dynamic> updatedValues,
      String whereClause) async {
    final db = await database;
    print("Updating table: $tableName");
    print("Values to update: $updatedValues");
    print("Condition: $whereClause");

    try {
      await db.update(tableName, updatedValues, where: whereClause);
      print("Data updated successfully.");
    } catch (e) {
      print("Data update failed: $e");
      throw Exception("Data update failed: $e");
    }
  }

  Future<void> deleteRow(
      String tableName, String columnName, String value) async {
    final db = await database;
    print("Deleting from table: $tableName");
    print("Condition: $columnName = $value");

    try {
      await db.delete(tableName, where: "$columnName = ?", whereArgs: [value]);
      print("Row deleted successfully.");
    } catch (e) {
      print("Error deleting row: $e");
      throw Exception("Error deleting row: $e");
    }
  }

  Future<void> printTables() async {
    final db = await database;
    print("Fetching list of tables...");

    try {
      List<Map<String, dynamic>> tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      print("Tables in database:");
      for (var table in tables) {
        print(" - ${table['name']}");
      }
    } catch (e) {
      print("Error fetching tables: $e");
    }
  }

  /// Get location by latitude and longitude
  Future<List<Map<String, dynamic>>> getLocationByLatLong(
      double latitude, double longitude) async {
    final db = await database;
    final result = await db.query(
      'GeoBoundaries',
      where: 'Latitude = ? AND Longitude = ?',
      whereArgs: [latitude, longitude],
    );
    return result;
  }

  Future<void> insertLocationValues({
    required double latitude,
    required double longitude,
    required int? createdByUserId,
    required bool serverUpdatedStatus,
    required String? from,
  }) async {
    try {
      final db = await database;
      final geoBoundaryValues = {
        'Latitude': latitude,
        'Longitude': longitude,
        'Address': from,
        'CreatedByUserId': createdByUserId,
        'CreatedDate': DateTime.now().toIso8601String(),
        'ServerUpdatedStatus': false, // SQLite stores boolean as 0 or 1
      };

      await db.insert('GeoBoundaries', geoBoundaryValues);
      print('Location values inserted');
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error inserting GeoBoundaries:",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      print('Failed to insert location values: $e');
      appendLog('Failed to insert location values: ${e.toString()}');
    }
  }

  Future<void> insertOrUpdateData(
      String tableName, List<Map<String, dynamic>> data, String idField) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in data) {
        print('Processing item: ${item.toString()}');
        print(
            'Processing item serverUpdatedStatus: ${item['serverUpdatedStatus']}');
        // Check if serverUpdatedStatus is 0, then update it to 1
        if (item.containsKey('serverUpdatedStatus') &&
            item['serverUpdatedStatus'] == 0 &&
            item['serverUpdatedStatus'] == 'false') {
          item['serverUpdatedStatus'] = 1;
        }

        // Check if a record with the same ID exists
        var existingRecord = await txn.query(
          tableName,
          where: '$idField = ?',
          whereArgs: [item[idField]],
        );
        print(
            'Updated existing record in $tableName with $idField = ${item[idField]}');
        if (existingRecord.isNotEmpty) {
          // If the record exists, update it
          await txn.update(
            tableName,
            item,
            where: '$idField = ?',
            whereArgs: [item[idField]],
          );
          print(
              'Updated existing record in $tableName with $idField = ${item[idField]}');
        } else {
          // If the record does not exist, insert it
          await txn.insert(tableName, item);
          print(
              'Inserted new record into $tableName with $idField = ${item[idField]}');
        }
      }
    });
  }

  Future<void> insertOrUpdateweekxrefData(
      String tableName, List<Map<String, dynamic>> data, String idField) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var item in data) {
        print('Processing item: ${item.toString()}');
        print('Processing item: ${item['code']}');

        // Check if a record with the same ID and Code exists
        var existingRecord = await txn.query(
          tableName,
          where: '$idField = ? AND code = ?',
          whereArgs: [item[idField], item['code']], // Fixed argument passing
        );

        print('Existing record: ${existingRecord.toString()}');

        if (existingRecord.isNotEmpty) {
          // If the record exists, update it
          await txn.update(
            tableName,
            item,
            where: 'code = ?', // Update by unique "code"
            whereArgs: [item['code']],
          );
          print(
              'Updated existing record in $tableName with $idField = ${item[idField]} and code = ${item['code']}');
        } else {
          // If the record does not exist, insert it
          // Ensure "serverUpdatedStatus" is set to 1 if it's false
          if (item['serverUpdatedStatus'] == false) {
            item['serverUpdatedStatus'] = 1;
          }

          await txn.insert(tableName, item);
          print(
              'Inserted new record into $tableName with $idField = ${item[idField]} and code = ${item['code']}');
        }
      }
    });
  }

  Future<int> insertLead(Map<String, dynamic> leadData) async {
    final db = await database;
    // Validate lead data before insertion
    // if (!isValidLeadData(leadData)) {
    //   throw Exception("Invalid lead data");
    // }

    try {
      return await db.insert(
        'Leads',
        leadData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Log or handle the error as needed
      print("Insert failed: $e");
      return -1; // Return an error code or handle it differently
    }
    // Fallback value in case of unexpected null.
  }

  Future<int> insertFileRepository(Map<String, dynamic> fileData) async {
    final db = await database;
    return await db.insert(
      'FileRepositorys',
      fileData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getOnlyOneIntValueFromDb(
    String query,
  ) async {
    debugPrint("@@@ query $query");
    try {
      List<Map<String, dynamic>> result =
          await (await database).rawQuery(query);
      if (result.isNotEmpty) {
        return result.first.values.first as int;
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  Future<List<int>> getSingleListData(String query) async {
    debugPrint("@@@ query 400 === $query");

    List<int> genericData = [];
    final db = await database;
    try {
      List<Map<String, dynamic>> result = await db.rawQuery(query);

      for (var row in result) {
        var value = row.values.first; // Fetch first column value

        if (value is int) {
          genericData.add(value); // Directly add if int
        } else if (value is String) {
          genericData.add(int.tryParse(value) ?? 0); // Convert if string
        }
      }

      debugPrint("Updated List: $genericData"); // Debugging output
    } catch (e) {
      debugPrint("Database Error: $e");
    }

    return genericData; // Return updated list
  }

  Future<String?> getOnlyOneStringValueFromDb(
      String query, List<dynamic> params) async {
    List<Map<String, dynamic>> result;
    try {
      final db = await database;
      result = await db.rawQuery(query, params);

      if (result.isNotEmpty && result.first.isNotEmpty) {
        return result.first.values.first.toString();
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getleads(
      {required int createdByUserId}) async {
    final db = await database;
    String query = 'SELECT * FROM Leads WHERE CreatedByUserId = ?';
    List<Map<String, dynamic>> results =
        await db.rawQuery(query, [createdByUserId]);
    return results;
  }

  Future<List<Map<String, dynamic>>> getTodayLeadsuser(
      String today, int? userID) async {
    final db = await database;
    String query =
        'SELECT * FROM Leads WHERE DATE(CreatedDate) = ? AND CreatedByUserId = ?';
    print('Executing Query: $query with parameters: $today, $userID');

    List<Map<String, dynamic>> results =
        await db.rawQuery(query, [today, userID]);

    print('Query Results:');
    for (var row in results) {
      print(row);
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> getTodayLeads(String today) async {
    final db = await database;
    String query = 'SELECT * FROM Leads WHERE DATE(CreatedDate) = $today';
    List<Map<String, dynamic>> results = await db.query(query);
/*     print('xxx: $query');
    print('xxx: ${jsonEncode(results)}'); */
    return results;
  }

  Future<List<Map<String, dynamic>>> getFilterData(String query) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery(query);
    return results;
  }

  Future<List<Map<String, dynamic>>> getLeadInfoByCode(String code) async {
    try {
      final db = await database;
      String query = 'SELECT * FROM Leads Where Code = ?';
      List<Map<String, dynamic>> results = await db.rawQuery(
        query,
        [code],
      );

      return results;
    } catch (e) {
      throw Exception('catch: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeadImagesByCode(
      String leadsCode, String fileExtension) async {
    try {
      final db = await database;
      String query =
          'SELECT * FROM FileRepositorys WHERE leadsCode = ? AND FileExtension = ?';
      List<Map<String, dynamic>> results = await db.rawQuery(
        query,
        [leadsCode, fileExtension],
      );
      print('xxx getLeadImagesByCode: ${jsonEncode(results)}');
      return results;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeadDocsByCode(
      String leadsCode, List<String> fileExtensions) async {
    try {
      final db = await database;
      String placeholders = fileExtensions.map((_) => '?').join(', ');
      String query =
          'SELECT * FROM FileRepositorys WHERE leadsCode = ? AND FileExtension IN ($placeholders)';
      print('query: $query');
      List<dynamic> parameters = [leadsCode] + fileExtensions;

      List<Map<String, dynamic>> results = await db.rawQuery(
        query,
        parameters,
      );
      print('getLeadDocsByCode: ${jsonEncode(results)}');
      return results;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<String?> fetchBase64Image(String leadCode) async {
    // Replace with your actual database path and query
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT FileName FROM FileRepositorys WHERE leadsCode = ?',
      [leadCode],
    );

    if (result.isNotEmpty) {
      return result.first['FileName']
          as String; // Assuming FileName contains Base64
    }
    return null; // Return null if no image found
  }

  bool isValidLeadData(Map<String, dynamic> leadData) {
    // Add your validation logic here
    return leadData.containsKey('requiredField') &&
        leadData['requiredField'] != null;
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  Future<List<Map<String, dynamic>>> getDataFromQuery(String query) async {
    final db = await database;
    return await db
        .rawQuery(query); // Execute the raw query and return the result
  }

  Future<List<Map<String, double>>> fetchLatLongsFromDatabase(
      String startDate, String endDate) async {
    print('Fetching lat/longs from database...');
    print('Start Date: $startDate, End Date: $endDate');

    // Get database instance
    final db = await database;
    print('Database instance retrieved.');

    // Retrieve userID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    print('Retrieved userID: $userID');

    if (userID == null) {
      print('Error: userID is null. Returning empty list.');
      return [];
    }

    // Construct SQL query manually for logging
    String query = '''
    SELECT Latitude, Longitude 
    FROM GeoBoundaries 
    WHERE DATE(CreatedDate) BETWEEN ? AND ? 
      AND CreatedByUserId = ?
  ''';
    List<dynamic> whereArgs = [startDate, endDate, userID];

    print('Executing query: $query');
    print('Query Parameters: $whereArgs');

    // Execute query
    List<Map<String, dynamic>> queryResult = await db.query(
      'GeoBoundaries',
      columns: ['Latitude', 'Longitude'],
      where: 'DATE(CreatedDate) BETWEEN ? AND ? AND CreatedByUserId = ?',
      whereArgs: whereArgs,
    );

    print('Query executed successfully.');
    print('Query Result: $queryResult');

    // Convert result to List<Map<String, double>>
    List<Map<String, double>> latLongList = queryResult.map((row) {
      double lat = row['Latitude'] is double
          ? row['Latitude']
          : (row['Latitude'] as num).toDouble();
      double lng = row['Longitude'] is double
          ? row['Longitude']
          : (row['Longitude'] as num).toDouble();

      print('Processed lat/lng: $lat, $lng');
      return {'lat': lat, 'lng': lng};
    }).toList();

    print('Final lat/long list: $latLongList');
    return latLongList;
  }

// Method to check if GeoBoundary has a point for the current date
  Future<bool> hasPointForToday() async {
    // Get a reference to the database
    final db = await database;
    String currentDate = getCurrentDate();
    // SQL query to be executed
    String query = "SELECT * FROM GeoBoundaries WHERE DATE(CreatedDate) = ?";

    // Print the query and the parameter (formattedDate)
    print("Executing query: $query with parameter: $currentDate");
    appendLog(
        "Executing query hasPointForToday: $query with parameter: $currentDate ");

    // Query the GeoBoundary table for points on the current date
    final List<Map<String, dynamic>> result =
        await db.rawQuery(query, [currentDate]);

    // If the result is not empty, a point exists for today
    return result.isNotEmpty;
  }

  Future<bool> checkIfExcludedDate() async {
    // Get a reference to the database
    final db = await database;
    // Get the current date in 'YYYY-MM-DD' format
    String currentDate = getCurrentDate();

    // SQL query to check if the current date is a holiday and is active
    String query =
        'SELECT * FROM HolidayConfiguration WHERE DATE(Date) = ? AND IsActive = 1';

    // Print the query and the parameter (currentDate)
    print("Executing query: $query with parameter: $currentDate");
    appendLog(
        "Executing query _checkIfExcludedDate: $query with parameter: $currentDate");

    // Query the HolidayConfiguration table for the current date
    final List<Map<String, dynamic>> result =
        await db.rawQuery(query, [currentDate]);

    // If the result is not empty, the current date is a holiday (excluded)
    return result.isNotEmpty;
  }

// Fetch the ShiftFromTime from the UserInfos table
  Future<String> getShiftFromTime() async {
    final db = await database;
    // Assuming userID is retrieved from SharedPreferences or passed as an argument
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    final List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT TrackFromTime FROM UserInfos WHERE id = ?', [userID]);
    return result.isNotEmpty
        ? result.first['TrackFromTime']
        : '09:00'; // Default to '09:00' if no result
  }

// Fetch the ShiftToTime from the UserInfos table
  Future<String> getShiftToTime() async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    final List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT TrackToTime FROM UserInfos WHERE id = ?', [userID]);
    return result.isNotEmpty
        ? result.first['TrackToTime']
        : '19:00'; // Default to '19:00' if no result
  }

  Future<String> getweekoffs() async {
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    final List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT weekOffs FROM UserInfos WHERE id = ?', [userID]);
    return result.isNotEmpty
        ? result.first['weekOffs']
        : 'sunday'; // Default to 'sunday' if no result
  }

  Future<bool> hasleaveday(String weekOffDate) async {
    // Get a reference to the database
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    // SQL query with additional conditions for IsActive and UserId
    String query =
        "SELECT * FROM UserWeekOffXref WHERE DATE(Date) = ? AND IsActive = 1 AND UserId = ?";

    // Print the query and parameters
    print("Executing query: $query with parameters: $weekOffDate, $userID");
    appendLog(
        "Executing query hasleaveday: $query with parameters: $weekOffDate, $userID");

    // Query the UserWeekOffXref table for the given weekOffDate, IsActive, and UserId
    final List<Map<String, dynamic>> result =
        await db.rawQuery(query, [weekOffDate, userID]);

    // If the result is not empty, a leave exists for that date
    return result.isNotEmpty;
  }

  Future<bool> hasleaveForToday() async {
    // Get a reference to the database
    final db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    String currentDate = getCurrentDate();
    // SQL query with additional conditions for IsActive and UserId
    String query =
        "SELECT * FROM UserWeekOffXref WHERE DATE(Date) = ? AND IsActive = 1 AND UserId = ?";

    // Print the query and parameters
    print("Executing query: $query with parameters: $currentDate, $userID");
    appendLog(
        "Executing query hasleaveForToday: $query with parameters: $currentDate, $userID");

    // Query the GeoBoundaries table for points on the current date, IsActive, and UserId
    final List<Map<String, dynamic>> result =
        await db.rawQuery(query, [currentDate, userID]);

    // If the result is not empty, a point exists for today
    return result.isNotEmpty;
  }

  Future<List<GeoBoundariesModel>> getGeoBoundariesDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'geoBoundaries',
      where: 'ServerUpdatedStatus = ?',
      whereArgs: [0],
    );

    return result.map((row) => GeoBoundariesModel.fromMap(row)).toList();
  }

  Future<List<LeadsModel>> getLeadsDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Leads',
      where: 'ServerUpdatedStatus = ?',
      whereArgs: [0],
    );
    print('Leads fetched: $result');

    return result.map((row) => LeadsModel.fromMap(row)).toList();
  }

  Future<List<FileRepositoryModel>> getFileRepositoryDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'FileRepositorys',
      where: 'ServerUpdatedStatus = ?',
      whereArgs: [0],
    );
    print('fileRepository fetched: $result');

    return result.map((row) => FileRepositoryModel.fromJson(row)).toList();
  }
}
