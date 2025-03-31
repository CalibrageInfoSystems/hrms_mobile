class DailyPunch {
  final String userId;
  final DateTime punchInTime;
  final double punchInLatitude;
  final double punchInLongitude;
    String? punchInAddress;
  final DateTime? punchOutTime;
  final double? punchOutLatitude;
  final double? punchOutLongitude;
 String? punchOutAddress;
  final String createdByUserId;
  final DateTime createdDate;
  final String updatedByUserId;
  final DateTime updatedDate;
  final bool serverUpdatedStatus;

  DailyPunch({
    required this.userId,
    required this.punchInTime,
    required this.punchInLatitude,
    required this.punchInLongitude,
    this.punchInAddress,
    this.punchOutTime,
    this.punchOutLatitude,
    this.punchOutLongitude,
    this.punchOutAddress,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.serverUpdatedStatus,
  });

  // Convert a DailyPunch object into a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'PunchInTime': punchInTime.toIso8601String(),
      'PunchInLatitude': punchInLatitude,
      'PunchInLongitude': punchInLongitude,
      'PunchInAddress': punchInAddress,
      'PunchOutTime': punchOutTime?.toIso8601String(),
      'PunchOutLatitude': punchOutLatitude,
      'PunchOutLongitude': punchOutLongitude,
      'PunchOutAddress': punchOutAddress,
      'CreatedByUserId': createdByUserId,
      'CreatedDate': createdDate.toIso8601String(),
      'UpdatedByUserId': updatedByUserId,
      'UpdatedDate': updatedDate.toIso8601String(),
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }

  // Create a DailyPunch object from a database Map
  factory DailyPunch.fromMap(Map<String, dynamic> map) {
    return DailyPunch(
      userId: map['UserId'],
      punchInTime: DateTime.parse(map['PunchInTime']),
      punchInLatitude: map['PunchInLatitude'],
      punchInLongitude: map['PunchInLongitude'],
      punchInAddress: map['PunchInAddress'],
      punchOutTime:
      map['PunchOutTime'] != null ? DateTime.parse(map['PunchOutTime']) : null,
      punchOutLatitude: map['PunchOutLatitude'],
      punchOutLongitude: map['PunchOutLongitude'],
      punchOutAddress: map['PunchOutAddress'],
      createdByUserId: map['CreatedByUserId'],
      createdDate: DateTime.parse(map['CreatedDate']),
      updatedByUserId: map['UpdatedByUserId'],
      updatedDate: DateTime.parse(map['UpdatedDate']),
      serverUpdatedStatus: map['ServerUpdatedStatus'] is bool
          ? map['ServerUpdatedStatus']
          : map['ServerUpdatedStatus'] == 1,
    );
  }
}
