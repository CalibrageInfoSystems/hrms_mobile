import 'dart:convert';

class EmployeeInfo {
  final int employeeId;
  final int contractorId;
  final List<ShiftDetail> shiftDetails;
  final List<TrackingInfo> trackingInfo;
  final bool isLeaveToday;
  final List<Holiday> holidays;

  EmployeeInfo({
    required this.employeeId,
    required this.contractorId,
    required this.shiftDetails,
    required this.trackingInfo,
    required this.isLeaveToday,
    required this.holidays,
  });

  factory EmployeeInfo.fromJson(Map<String, dynamic> json) {
    return EmployeeInfo(
      employeeId: json['employeeId'],
      contractorId: json['contractorId'],
      shiftDetails: (jsonDecode(json['shiftDetails']) as List)
          .map((e) => ShiftDetail.fromJson(e))
          .toList(),
      trackingInfo: (jsonDecode(json['trackingInfo']) as List)
          .map((e) => TrackingInfo.fromJson(e))
          .toList(),
      isLeaveToday: json['isLeaveToday'],
      holidays: (jsonDecode(json['holidays']) as List)
          .map((e) => Holiday.fromJson(e))
          .toList(),
    );
  }
}

class ShiftDetail {
  final int shiftId;
  final String shiftIn;
  final String shiftOut;
  final String minimumWorkingHours;
  final String graceTime;
  final String recreationTime;
  final String shiftName;
  final String shiftTypeName;
  final String workingDays;

  ShiftDetail({
    required this.shiftId,
    required this.shiftIn,
    required this.shiftOut,
    required this.minimumWorkingHours,
    required this.graceTime,
    required this.recreationTime,
    required this.shiftName,
    required this.shiftTypeName,
    required this.workingDays,
  });

  factory ShiftDetail.fromJson(Map<String, dynamic> json) {
    return ShiftDetail(
      shiftId: json['ShiftId'],
      shiftIn: json['ShiftIn'],
      shiftOut: json['ShiftOut'],
      minimumWorkingHours: json['MinimumWorkingHours'],
      graceTime: json['GraceTime'],
      recreationTime: json['RecreationTime'],
      shiftName: json['ShiftName'],
      shiftTypeName: json['ShiftTypeName'],
      workingDays: json['WorkingDays'],
    );
  }
}

class TrackingInfo {
  final bool canTrackEmployee;
  final int trackTypeId;
  final String trackType;
  final String? trackInTime;
  final String? trackOutTime;

  TrackingInfo({
    required this.canTrackEmployee,
    required this.trackTypeId,
    required this.trackType,
    this.trackInTime,
    this.trackOutTime,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      canTrackEmployee: json['CanTrackEmployee'],
      trackTypeId: json['TrackTypeId'],
      trackType: json['TrackType'],
      trackInTime: json['TrackInTime'],
      trackOutTime: json['TrackOutTime'],
    );
  }
}

class Holiday {
  final int id;
  final String name;
  final String fromDate;
  final String toDate;

  Holiday({
    required this.id,
    required this.name,
    required this.fromDate,
    required this.toDate,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['Id'],
      name: json['Name'],
      fromDate: json['FromDate'],
      toDate: json['ToDate'],
    );
  }
}
