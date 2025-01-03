// class Holiday_Model {
//   final int holidayId;
//   final String title;
//   final String description;
//   final DateTime fromDate;
//   final DateTime toDate;
//   final int year;
//   final bool isActive;
//   final DateTime createdAt;
//   final String createdBy;
//   final DateTime updatedAt;
//   final String updatedBy;
//
//   Holiday_Model({
//     required this.holidayId,
//     required this.title,
//     required this.description,
//     required this.fromDate,
//     required this.toDate,
//     required this.year,
//     required this.isActive,
//     required this.createdAt,
//     required this.createdBy,
//     required this.updatedAt,
//     required this.updatedBy,
//   });
//
//   factory Holiday_Model.fromJson(Map<String, dynamic> json) {
//     return Holiday_Model(
//       holidayId: json['holidayId'],
//       title: json['title'],
//       description: json['description'],
//       fromDate: DateTime.parse(json['fromDate']),
//       toDate: DateTime.parse(json['toDate']),
//       year: json['year'],
//       isActive: json['isActive'],
//       createdAt: DateTime.parse(json['createdAt']),
//       createdBy: json['createdBy'],
//       updatedAt: DateTime.parse(json['updatedAt']),
//       updatedBy: json['updatedBy'],
//     );
//   }
// }
class Holiday_Model {
  final int holidayId;
  final String title;
  final String description;
  final DateTime fromDate;
  final DateTime? toDate;
  final int year;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;

  Holiday_Model({
    required this.holidayId,
    required this.title,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.year,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory Holiday_Model.fromJson(Map<String, dynamic> json) {
    return Holiday_Model(
      holidayId: json['holidayId'],
      title: json['title'],
      description: json['description'],
      fromDate: DateTime.parse(json['fromDate']),
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate']) : null,
      year: json['year'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedBy: json['updatedBy'],
    );
  }
}
