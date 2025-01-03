class EmployeeLeave {
  // final int employeeId;
  // final String employeeName;
  // final String? code;
  // final int employeeLeaveId;
  final String leaveType;
  final String fromDate;
  final String? toDate;
  final int employeeLeaveId;
  bool isMarkedForDeletion;

  // final int leaveTypeId;
  // final int usedCLsInMonth;
  // final int usedPLsInMonth;
  final bool? isHalfDayLeave;
  late final bool? isDeleted;
  final bool isLeaveUsed;

  // final String? acceptedAt;
  // final String? acceptedBy;
  // final String? approvedAt;
  // final String? approvedBy;
  final String note;
  final String status;
  // final bool? isApprovalEscalated;
  // final Null comments;
  // final String createdAt;
  // final String createdBy;

  EmployeeLeave({
    // required this.employeeId,
    // required this.employeeName,
    // required this.code,
    // required this.employeeLeaveId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.isHalfDayLeave,
    required this.isDeleted,
    required this.employeeLeaveId,
    this.isMarkedForDeletion = false,
    required this.isLeaveUsed,
    // required this.leaveTypeId,
    // required this.usedCLsInMonth,
    // required this.usedPLsInMonth,
    // required this.rejected,
    // required this.acceptedAt,
    // required this.acceptedBy,
    // required this.approvedAt,
    // required this.approvedBy,
    required this.note,
    required this.status,
    // required this.isApprovalEscalated,
    // required this.comments,
    // required this.createdAt,
    // required this.createdBy,
  });

  factory EmployeeLeave.fromJson(Map<String, dynamic> json) {
    return EmployeeLeave(
      // employeeId: json['employeeId'],
      // employeeName: json['employeeName'],
      // code: json['code'],
      // employeeLeaveId: json['employeeLeaveId'],
      employeeLeaveId: json['employeeLeaveId'],
      leaveType: json['leaveType'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      isHalfDayLeave: json['isHalfDayLeave'],
      isDeleted: json['isDeleted'],
      isLeaveUsed: json['isLeaveUsed'],
      // leaveTypeId: json['leaveTypeId'],
      // usedCLsInMonth: json['usedCLsInMonth'],
      // usedPLsInMonth: json['usedPLsInMonth'],
      // rejected: json['rejected'],
      // acceptedAt: json['acceptedAt'],
      // acceptedBy: json['acceptedBy'],
      // approvedAt: json['approvedAt'],
      // approvedBy: json['approvedBy'],
      note: json['note'],
      status: json['status'],
      // isApprovalEscalated: json['isApprovalEscalated'],
      // comments: json['comments'],
      // createdAt: json['createdAt'],
      // createdBy: json['createdBy'],
    );
  }
}
