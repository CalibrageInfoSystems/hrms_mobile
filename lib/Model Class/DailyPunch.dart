class DailyPunch {

  final String userId;
  final DateTime punchDate;
  final int isPunchIn;
  final double latitude;
  final double longitude;
   String? address;
  final String remarks;
  final String punchMode;
  final int serverUpdateStatus;
  final String createdByUserId;
  final DateTime createdDate;

  DailyPunch({

    required this.userId,
    required this.punchDate,
    required this.isPunchIn,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.remarks,
    required this.punchMode,
    required this.serverUpdateStatus,
    required this.createdByUserId,
    required this.createdDate,
  });

  factory DailyPunch.fromJson(Map<String, dynamic> json) {
    return DailyPunch(
      userId: json['UserId'],
      punchDate: DateTime.parse(json['PunchDate']),
      isPunchIn: json['IsPunchIn'],
      latitude: (json['Latitude'] as num).toDouble(),
      longitude: (json['Longitude'] as num).toDouble(),
      address: json['Address'],
      remarks: json['Remarks'] ?? '',
      punchMode: json['PunchMode'],
      serverUpdateStatus: json['ServerUpdateStatus'],
      createdByUserId: json['CreatedByUserId'],
      createdDate: DateTime.parse(json['CreatedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'PunchDate': punchDate.toIso8601String(),
      'IsPunchIn': isPunchIn,
      'Latitude': latitude,
      'Longitude': longitude,
      'Address': address,
      'Remarks': remarks,
      'PunchMode': punchMode,
      'ServerUpdateStatus': serverUpdateStatus,
      'CreatedByUserId': createdByUserId,
      'CreatedDate': createdDate.toIso8601String(),
    };
  }
}