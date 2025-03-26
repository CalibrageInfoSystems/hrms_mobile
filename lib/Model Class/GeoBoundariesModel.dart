class GeoBoundariesModel {
  double? latitude;
  double? longitude;
  String? Address;
  int? createdByUserId;
  String? createdDate;
  bool? serverUpdatedStatus;

  GeoBoundariesModel({
    required this.latitude,
    required this.longitude,
    required this.Address,
    required this.createdByUserId,
    required this.createdDate,

    required this.serverUpdatedStatus,
  });
  //
  // factory GeoBoundariesModel.fromMap(Map<String, dynamic> json) {
  //   return GeoBoundariesModel(
  //     latitude: json['Latitude'],
  //     longitude: json['Longitude'],
  //     createdByUserId: json['CreatedByUserId'],
  //     createdDate: json['CreatedDate'],
  //     updatedByUserId: json['UpdatedByUserId'],
  //     updatedDate: json['UpdatedDate'],
  //     serverUpdatedStatus: json['ServerUpdatedStatus'],
  //   );
  // }

  factory GeoBoundariesModel.fromMap(Map<String, dynamic> json) {
    return GeoBoundariesModel(
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      Address:json['Address'],
      createdByUserId: json['CreatedByUserId'],
      createdDate: json['CreatedDate'],
      // Convert int (0 or 1) to bool
      serverUpdatedStatus: json['ServerUpdatedStatus'] is bool
          ? json['ServerUpdatedStatus']
          : json['ServerUpdatedStatus'] == 1,
    );
  }

  // Convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
      'Address':Address,
      'CreatedByUserId': createdByUserId,
      'CreatedDate': createdDate,
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }
}
