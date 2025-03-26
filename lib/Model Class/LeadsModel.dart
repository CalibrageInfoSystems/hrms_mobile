
class LeadsModel {
  final bool isCompany;
  final String? code;
  final String? name;
  final String? companyName;
  final String? phoneNumber;
  final String? email;
  final String? comments;
  final double? latitude;
  final double? longitude;
  String? Address;
  final int? createdByUserId;
  final DateTime? createdDate;
  final int? updatedByUserId;
  final DateTime? updatedDate;
  bool? serverUpdatedStatus;

  LeadsModel({
    required this.isCompany,
    required this.code,
    required this.name,
    this.companyName,
    required this.phoneNumber,
    required this.email,
    required this.comments,
    required this.latitude,
    required this.longitude,
    required this.Address,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.serverUpdatedStatus,
  });

  // Factory method to create a Lead instance from a map
  factory LeadsModel.fromMap(Map<String, dynamic> map) {
    return LeadsModel(
      isCompany: map['IsCompany'] == 1 || map['IsCompany'] == true,
      code: map['code'],
      name: map['Name'],
      companyName: map['CompanyName'],
      phoneNumber: map['PhoneNumber'],
      email: map['Email'],
      comments: map['Comments'],
      latitude: map['Latitude'],
      longitude: map['Longitude'],
      Address:map['Address'],
      createdByUserId: map['CreatedByUserId'],
      createdDate: DateTime.parse(map['CreatedDate']),
      updatedByUserId: map['UpdatedByUserId'],
      updatedDate: DateTime.parse(map['UpdatedDate']),
      serverUpdatedStatus: map['ServerUpdatedStatus'] is bool
          ? map['ServerUpdatedStatus']
          : map['ServerUpdatedStatus'] == 1,
    );
  }

  // Method to convert a Lead instance to a map
  Map<String, dynamic> toMap() {
    return {
      'IsCompany': isCompany, // Sending as a boolean (true/false)
      'code': code,
      'Name': name,
      'CompanyName': companyName,
      'PhoneNumber': phoneNumber,
      'Email': email,
      'Comments': comments,
      'Latitude': latitude,
      'Longitude': longitude,
      'Address':Address,
      'CreatedByUserId': createdByUserId,
      'CreatedDate': createdDate?.toIso8601String(),
      'UpdatedByUserId': updatedByUserId,
      'UpdatedDate': updatedDate?.toIso8601String(),
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }
}

