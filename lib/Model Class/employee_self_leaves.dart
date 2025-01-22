import 'dart:convert';

List<EmployeeSelfLeaves> employeeSelfLeavesFromJson(String str) =>
    List<EmployeeSelfLeaves>.from(
        json.decode(str).map((x) => EmployeeSelfLeaves.fromJson(x)));

String employeeSelfLeavesToJson(List<EmployeeSelfLeaves> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EmployeeSelfLeaves {
  final int? employeeId;
  final String? employeeName;
  final String? code;
  final int? employeeLeaveId;
  final double? usedCLsInMonth;
  final double? usedPLsInMonth;
  final String? leaveType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? leaveTypeId;
  final bool? rejected;
  final DateTime? acceptedAt;
  final String? acceptedBy;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? note;
  final String? status;
  final bool? isApprovalEscalated;
  final bool? isHalfDayLeave;
  final String? comments;
  final DateTime? createdAt;
  final String? createdBy;
  final bool? isLeaveUsed;
  final bool? isDeleted;
  final DateTime? rejectedAt;
  final String? rejectedBy;

  EmployeeSelfLeaves({
    this.employeeId,
    this.employeeName,
    this.code,
    this.employeeLeaveId,
    this.usedCLsInMonth,
    this.usedPLsInMonth,
    this.leaveType,
    this.fromDate,
    this.toDate,
    this.leaveTypeId,
    this.rejected,
    this.acceptedAt,
    this.acceptedBy,
    this.approvedAt,
    this.approvedBy,
    this.note,
    this.status,
    this.isApprovalEscalated,
    this.isHalfDayLeave,
    this.comments,
    this.createdAt,
    this.createdBy,
    this.isLeaveUsed,
    this.isDeleted,
    this.rejectedAt,
    this.rejectedBy,
  });

  factory EmployeeSelfLeaves.fromJson(Map<String, dynamic> json) =>
      EmployeeSelfLeaves(
        employeeId: json["employeeId"],
        employeeName: json["employeeName"],
        code: json["code"],
        employeeLeaveId: json["employeeLeaveId"],
        usedCLsInMonth: json["usedCLsInMonth"]?.toDouble(),
        usedPLsInMonth: json["usedPLsInMonth"]?.toDouble(),
        leaveType: json["leaveType"],
        fromDate:
            json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
        toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
        leaveTypeId: json["leaveTypeId"],
        rejected: json["rejected"],
        acceptedAt: json["acceptedAt"] == null
            ? null
            : DateTime.parse(json["acceptedAt"]),
        acceptedBy: json["acceptedBy"],
        approvedAt: json["approvedAt"] == null
            ? null
            : DateTime.parse(json["approvedAt"]),
        approvedBy: json["approvedBy"],
        note: json["note"],
        status: json["status"],
        isApprovalEscalated: json["isApprovalEscalated"],
        isHalfDayLeave: json["isHalfDayLeave"],
        comments: json["comments"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        createdBy: json["createdBy"],
        isLeaveUsed: json["isLeaveUsed"],
        isDeleted: json["isDeleted"],
        rejectedAt: json["rejectedAt"] == null
            ? null
            : DateTime.parse(json["rejectedAt"]),
        rejectedBy: json["rejectedBy"],
      );

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "employeeName": employeeName,
        "code": code,
        "employeeLeaveId": employeeLeaveId,
        "usedCLsInMonth": usedCLsInMonth,
        "usedPLsInMonth": usedPLsInMonth,
        "leaveType": leaveType,
        "fromDate": fromDate?.toIso8601String(),
        "toDate": toDate?.toIso8601String(),
        "leaveTypeId": leaveTypeId,
        "rejected": rejected,
        "acceptedAt": acceptedAt?.toIso8601String(),
        "acceptedBy": acceptedBy,
        "approvedAt": approvedAt?.toIso8601String(),
        "approvedBy": approvedBy,
        "note": note,
        "status": status,
        "isApprovalEscalated": isApprovalEscalated,
        "isHalfDayLeave": isHalfDayLeave,
        "comments": comments,
        "createdAt": createdAt?.toIso8601String(),
        "createdBy": createdBy,
        "isLeaveUsed": isLeaveUsed,
        "isDeleted": isDeleted,
        "rejectedAt": rejectedAt?.toIso8601String(),
        "rejectedBy": rejectedBy,
      };
}

/* 
  List<EmployeeSelfLeaves> testData() {
    List<Map<String, dynamic>> testList = [
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "PL",
        "fromDate": "2025-01-31T00:00:00",
        "toDate": "2025-02-03T00:00:00",
        "leaveTypeId": 103,
        "rejected": false,
        "note": "ok",
        "status": "Accepted",
        "isHalfDayLeave": false,
        "comments": "nngjjfgjfj",
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "PL",
        "fromDate": "2025-02-12T00:00:00",
        "toDate": "2025-02-13T00:00:00",
        "leaveTypeId": 103,
        "rejected": null,
        "note": "test",
        "status": "Pending",
        "isHalfDayLeave": false,
        "comments": null,
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "CL",
        "fromDate": "2025-02-05T00:00:00",
        "toDate": "2025-02-05T00:00:00",
        "leaveTypeId": 102,
        "rejected": false,
        "note": "dec 1st",
        "status": "Pending",
        "isHalfDayLeave": false,
        "comments": "thrtrthrt",
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "CL",
        "fromDate": "2025-12-01T00:00:00",
        "toDate": "2025-12-01T00:00:00",
        "leaveTypeId": 102,
        "rejected": false,
        "note": "dec 1st",
        "status": "Approved",
        "isHalfDayLeave": false,
        "comments": "thrtrthrt",
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "LL",
        "fromDate": "2025-04-08T00:00:00",
        "toDate": "2025-04-15T00:00:00",
        "leaveTypeId": 179,
        "rejected": null,
        "note": "test",
        "status": "Pending",
        "isHalfDayLeave": false,
        "comments": null,
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "LWP",
        "fromDate": "2025-02-03T00:00:00",
        "toDate": "2025-02-04T00:00:00",
        "leaveTypeId": 104,
        "rejected": null,
        "note": "test",
        "status": "Pending",
        "isHalfDayLeave": false,
        "comments": null,
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "PL",
        "fromDate": "2025-01-16T00:00:00",
        "toDate": "2025-01-16T00:00:00",
        "leaveTypeId": 103,
        "rejected": true,
        "note": "test",
        "status": "Rejected",
        "isHalfDayLeave": false,
        "comments": "asdasdasasd",
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "PL",
        "fromDate": "2025-02-16T00:00:00",
        "toDate": "2025-02-16T00:00:00",
        "leaveTypeId": 103,
        "rejected": null,
        "note": "test",
        "status": "Pending",
        "isHalfDayLeave": false,
        "comments": null,
        "isLeaveUsed": false,
        "isDeleted": null
      },
      {
        "employeeId": 85,
        "employeeName": "Suman D",
        "leaveType": "CL",
        "fromDate": "2025-05-12T00:00:00",
        "toDate": "2025-05-12T00:00:00",
        "leaveTypeId": 102,
        "rejected": false,
        "note": "ok",
        "status": "Approved",
        "isHalfDayLeave": false,
        "comments": "hjfohjoisfoisf",
        "isLeaveUsed": false,
        "isDeleted": null
      }
    ];

    return testList.map((item) => EmployeeSelfLeaves.fromJson(item)).toList();
  }
 */

//MARK: Leaves Model
List<LeaveDescriptionModel> leaveDescriptionModelFromJson(String str) =>
    List<LeaveDescriptionModel>.from(
        json.decode(str).map((x) => LeaveDescriptionModel.fromJson(x)));

String leaveDescriptionModelToJson(List<LeaveDescriptionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeaveDescriptionModel {
  final int? lookupDetailId;
  final String? code;
  final String? name;
  final int? lookupId;
  final String? description;
  final bool? isActive;
  final int? fkeySelfId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  LeaveDescriptionModel({
    this.lookupDetailId,
    this.code,
    this.name,
    this.lookupId,
    this.description,
    this.isActive,
    this.fkeySelfId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory LeaveDescriptionModel.fromJson(Map<String, dynamic> json) =>
      LeaveDescriptionModel(
        lookupDetailId: json["lookupDetailId"],
        code: json["code"],
        name: json["name"],
        lookupId: json["lookupId"],
        description: json["description"],
        isActive: json["isActive"],
        fkeySelfId: json["fkeySelfId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
      );

  Map<String, dynamic> toJson() => {
        "lookupDetailId": lookupDetailId,
        "code": code,
        "name": name,
        "lookupId": lookupId,
        "description": description,
        "isActive": isActive,
        "fkeySelfId": fkeySelfId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "createdBy": createdBy,
        "updatedBy": updatedBy,
      };
}

//MARK: Leave Validations
LeaveValidationsModel leaveValidationsModelFromJson(String str) =>
    LeaveValidationsModel.fromJson(json.decode(str));

String leaveValidationsModelToJson(LeaveValidationsModel data) =>
    json.encode(data.toJson());

class LeaveValidationsModel {
  final int? appSettingId;
  final int? minimumJobOpeningProcessTime;
  final int? maximumTimesJobOpeningBeProcessed;
  final int? leaveAccumulationProcessDuration;
  final int? maximumAllowableMaternityLeaves;
  final int? maximumAllowableMiscarriageLeaves;
  final int? maximumAllowableEventLeaves;
  final int? maximumAllowableMarriageLeaves;
  final int? maximumAllowableStudyLeaves;
  final int? maximumAllowableDeathCeremonyLeaves;
  final int? maximumAllowableHouseWarmingLeaves;
  final bool? useHierarchicalMailForLeaveApproval;
  final int? mininumDaysToConsiderAsLongLeave;

  LeaveValidationsModel({
    this.appSettingId,
    this.minimumJobOpeningProcessTime,
    this.maximumTimesJobOpeningBeProcessed,
    this.leaveAccumulationProcessDuration,
    this.maximumAllowableMaternityLeaves,
    this.maximumAllowableMiscarriageLeaves,
    this.maximumAllowableEventLeaves,
    this.maximumAllowableMarriageLeaves,
    this.maximumAllowableStudyLeaves,
    this.maximumAllowableDeathCeremonyLeaves,
    this.maximumAllowableHouseWarmingLeaves,
    this.useHierarchicalMailForLeaveApproval,
    this.mininumDaysToConsiderAsLongLeave,
  });

  factory LeaveValidationsModel.fromJson(Map<String, dynamic> json) =>
      LeaveValidationsModel(
        appSettingId: json["appSettingId"],
        minimumJobOpeningProcessTime: json["minimumJobOpeningProcessTime"],
        maximumTimesJobOpeningBeProcessed:
            json["maximumTimesJobOpeningBeProcessed"],
        leaveAccumulationProcessDuration:
            json["leaveAccumulationProcessDuration"],
        maximumAllowableMaternityLeaves:
            json["maximumAllowableMaternityLeaves"],
        maximumAllowableMiscarriageLeaves:
            json["maximumAllowableMiscarriageLeaves"],
        maximumAllowableEventLeaves: json["maximumAllowableEventLeaves"],
        maximumAllowableMarriageLeaves: json["maximumAllowableMarriageLeaves"],
        maximumAllowableStudyLeaves: json["maximumAllowableStudyLeaves"],
        maximumAllowableDeathCeremonyLeaves:
            json["maximumAllowableDeathCeremonyLeaves"],
        maximumAllowableHouseWarmingLeaves:
            json["maximumAllowableHouseWarmingLeaves"],
        useHierarchicalMailForLeaveApproval:
            json["useHierarchicalMailForLeaveApproval"],
        mininumDaysToConsiderAsLongLeave:
            json["mininumDaysToConsiderAsLongLeave"],
      );

  Map<String, dynamic> toJson() => {
        "appSettingId": appSettingId,
        "minimumJobOpeningProcessTime": minimumJobOpeningProcessTime,
        "maximumTimesJobOpeningBeProcessed": maximumTimesJobOpeningBeProcessed,
        "leaveAccumulationProcessDuration": leaveAccumulationProcessDuration,
        "maximumAllowableMaternityLeaves": maximumAllowableMaternityLeaves,
        "maximumAllowableMiscarriageLeaves": maximumAllowableMiscarriageLeaves,
        "maximumAllowableEventLeaves": maximumAllowableEventLeaves,
        "maximumAllowableMarriageLeaves": maximumAllowableMarriageLeaves,
        "maximumAllowableStudyLeaves": maximumAllowableStudyLeaves,
        "maximumAllowableDeathCeremonyLeaves":
            maximumAllowableDeathCeremonyLeaves,
        "maximumAllowableHouseWarmingLeaves":
            maximumAllowableHouseWarmingLeaves,
        "useHierarchicalMailForLeaveApproval":
            useHierarchicalMailForLeaveApproval,
        "mininumDaysToConsiderAsLongLeave": mininumDaysToConsiderAsLongLeave,
      };
}
