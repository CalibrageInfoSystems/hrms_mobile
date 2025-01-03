class HolidayResponse {
  int holidayId;
  String title;
  // String description;
  DateTime fromDate;
  DateTime? toDate; // Make toDate nullable
  // int year;
  bool isActive;
  // DateTime createdAt;
  // String createdBy;
  // DateTime updatedAt;
  // String updatedBy;

  HolidayResponse({
    required this.holidayId,
    required this.title,
    // required this.description,
    required this.fromDate,
    required this.toDate,
    // required this.year,
    required this.isActive,
    // required this.createdAt,
    // required this.createdBy,
    // required this.updatedAt,
    // required this.updatedBy,
  });

  factory HolidayResponse.fromJson(Map<String, dynamic> json) {
    return HolidayResponse(
      holidayId: json['holidayId'],
      title: json['title'],
      // description: json['description'],
      fromDate: DateTime.parse(json['fromDate']),
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate']) : null,

      // year: json['year'],
      isActive: json['isActive'],
      // createdAt: DateTime.parse(json['createdAt']),
      // createdBy: json['createdBy'],
      // updatedAt: DateTime.parse(json['updatedAt']),
      // updatedBy: json['updatedBy'],
    );
  }
}
