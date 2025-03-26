// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../Model Class/FileRepositoryModel.dart';
// import '../Model Class/GeoBoundariesModel.dart';
// import '../Model Class/LeadsModel.dart';
//
// class DatabaseHelper {
//   static const _databaseName = "hrmsgeotrack.sqlite";
//   static const _databaseVersion = 1;
//
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//   Future<Database> _initDatabase() async {
//
//     //Directory customDirectory = Directory('/storage/emulated/0/$folderName');
//     Directory? customDirectory;
//     if (Platform.isAndroid) {
//     //  customDirectory = Directory(Constants.originPath);
//       customDirectory = await getApplicationDocumentsDirectory();
//       print('customDirectory: $customDirectory');
//     } else if (Platform.isIOS) {
//       // directoryPath = await getApplicationSupportDirectory();
//       customDirectory = await getApplicationDocumentsDirectory();
//     } else {
//       print("Unsupported platform");
//
//     }
//   //  Directory documentsDirectory = await getApplicationDocumentsDirectory();
//  //   Directory customDirectory = Directory('${documentsDirectory.path}/$folderName');
//
//     if (!customDirectory!.existsSync()) {
//       customDirectory.createSync(recursive: true);
//     }
//
//     String path = join(customDirectory.path, _databaseName);
//     print('Database path: $path'); // Log the path for debugging
//
//     if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
//       ByteData data = await rootBundle.load(join("assets", _databaseName));
//       List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await File(path).writeAsBytes(bytes);
//     }
//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onOpen: (db) async {
//         await db.execute('PRAGMA read_uncommitted = true;');
//       },
//     );
//     // Open the database in writable mode
//  //   return await openDatabase(path, version: _databaseVersion);
//   }
//
//
//
//   Future<void> executeSQL(String sql) async {
//     final db = await database;
//     await db.execute(sql);
//   }
//
//   Future<void> insertData(
//       String tableName, List<Map<String, dynamic>> data) async {
//     final db = await database;
//     Batch batch = db.batch();
//     for (var row in data) {
//       batch.insert(tableName, row,
//           conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//     await batch.commit(noResult: true);
//   }
//
//   Future<List<GeoBoundariesModel>> getGeoBoundariesDetails() async {
//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.query(
//       'geoBoundaries',
//       where: 'ServerUpdatedStatus = ?',
//       whereArgs: [0],
//     );
//
//     return result.map((row) => GeoBoundariesModel.fromMap(row)).toList();
//   }
//
//   Future<List<LeadsModel>> getLeadsDetails() async {
//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.query(
//       'Leads',
//       where: 'ServerUpdatedStatus = ?',
//       whereArgs: [0],
//     );
//     print('Leads fetched: $result');
//
//     return result.map((row) => LeadsModel.fromMap(row)).toList();
//   }
//
//   Future<List<FileRepositoryModel>> getFileRepositoryDetails() async {
//     final db = await database;
//     final List<Map<String, dynamic>> result = await db.query(
//       'FileRepositorys',
//       where: 'ServerUpdatedStatus = ?',
//       whereArgs: [0],
//     );
//     print('fileRepository fetched: $result');
//
//     return result.map((row) => FileRepositoryModel.fromJson(row)).toList();
//   }
//
//
//
// }
