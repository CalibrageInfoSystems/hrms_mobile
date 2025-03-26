import 'dart:convert';
import 'dart:io';

class FileRepositoryModel {
  final String leadsCode;
  String? fileName; // File name will now store the Base64 string
  final String? fileLocation; // Nullable
  final String? fileExtension; // Nullable
  final bool isActive;
  final int createdByUserId;
  final String createdDate; // This should not be nullable
  final int updatedByUserId;
  final String updatedDate; // This should not be nullable
  final bool serverUpdatedStatus;

  FileRepositoryModel({
    required this.leadsCode,
    this.fileName, // Base64 content (optional, will be updated later)
    this.fileLocation, // Nullable
    this.fileExtension, // Nullable
    required this.isActive,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.serverUpdatedStatus,
  });

  // Factory method to create an instance from a JSON map
  factory FileRepositoryModel.fromJson(Map<String, dynamic> json) {
    return FileRepositoryModel(
      leadsCode: json['leadsCode'] ?? '', // Ensure it has a default value
      fileName: json['FileName'], // The base64 encoded file
      fileLocation: json['FileLocation'], // Check the key here
      fileExtension: json['FileExtension'], // Check the key here
      isActive: json['IsActive'] == 1, // Handle conversion from int to bool
      createdByUserId: json['CreatedByUserId'] ?? 0, // Default to 0 if null
      createdDate: json['CreatedDate'] ?? '', // Ensure it has a default value
      updatedByUserId: json['UpdatedByUserId'] ?? 0, // Default to 0 if null
      updatedDate: json['UpdatedDate'] ?? '', // Ensure it has a default value
      serverUpdatedStatus: json['ServerUpdatedStatus'] == 1, // Handle conversion from int to bool
    );
  }

  // Method to convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'leadsCode': leadsCode,
      'FileName': fileName, // Now holding the Base64 string
      'FileLocation': fileLocation,
      'FileExtension': fileExtension,
      'isActive': isActive,
      'createdByUserId': createdByUserId,
      'CreatedDate': createdDate,
      'UpdatedByUserId': updatedByUserId,
      'UpdatedDate': updatedDate,
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }
}


Future<String> convertFileToBase64(String filePath) async {
  final File file = File(filePath);
  if (await file.exists()) {
    List<int> fileBytes = await file.readAsBytes();
    String base64String = base64Encode(fileBytes);
    print("Base64 encoded string: $base64String");  // Debugging
    return base64String;
  } else {
    throw Exception("File not found");
  }
}

Future<void> prepareAndSendFile(String filePath, FileRepositoryModel model) async {
  try {
    // Log the file path to ensure it's being passed correctly
    print("File path: $filePath");

    // Convert the file to a Base64 string
    String base64File = await convertFileToBase64(filePath);

    // Check if the Base64 string is not null or empty
    if (base64File.isEmpty) {
      print("Base64 string is empty");
    } else {
      print("Base64 string generated successfully");
    }

    // Directly update the model with the Base64 string in the fileName field
    model.fileName = base64File;

    // Log updated model to ensure it contains the Base64 content
    print("Updated model with Base64 in fileName: ${model.toJson()}");

  } catch (e) {
    print("Error: $e");
  }
}
