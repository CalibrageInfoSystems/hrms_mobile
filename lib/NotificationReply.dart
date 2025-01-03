import 'dart:convert';

class NotificationReply {
  final int notificationId;
  final int notificationReplyId;
  final int employeeId;
  final String code;
  final String employeeName;
  final String message;
  final DateTime createdAt;
  final String createdBy;

  NotificationReply({
    required this.notificationId,
    required this.notificationReplyId,
    required this.employeeId,
    required this.code,
    required this.employeeName,
    required this.message,
    required this.createdAt,
    required this.createdBy,
  });

  // Factory method to create a NotificationReply from JSON
  factory NotificationReply.fromJson(Map<String, dynamic> json) {
    return NotificationReply(
      notificationId: json['notificationId'],
      notificationReplyId: json['notificationReplyId'],
      employeeId: json['employeeId'],
      code: json['code'],
      employeeName: json['employeeName'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }
}
