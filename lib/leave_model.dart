class leave_model {
  final String leaveType;
  final int leaveTypeId;
  final double usedCLsInMonth;
  final double usedPLsInMonth;

  leave_model(
      {required this.leaveType,
      required this.leaveTypeId,
      required this.usedCLsInMonth,
      required this.usedPLsInMonth});

  factory leave_model.fromJson(Map<String, dynamic> json) {
    return leave_model(
        leaveType: json['leaveType'],
        leaveTypeId: json['leaveTypeId'],
        usedCLsInMonth: json['usedCLsInMonth'],
        usedPLsInMonth: json['usedPLsInMonth']);
  }
}
