class UpComingbirthdays {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final DateTime originalDOB;

  UpComingbirthdays({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.originalDOB,
  });

  factory UpComingbirthdays.fromJson(Map<String, dynamic> json) {
    return UpComingbirthdays(
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      employeeCode: json['employeeCode'],
      originalDOB: DateTime.parse(json['originalDOB']),
    );
  }
}
