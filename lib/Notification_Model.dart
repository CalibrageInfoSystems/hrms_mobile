class Notification_model {
  final int notificationId;
  final int employeeId;
  final String employeeName;
  final String? code;
  final String message;
  final int messageTypeId;
  final String messageType;
  final String notifyTill;
  final bool isActive;
  final String createdAt;
  final String createdBy;

  Notification_model({
    required this.notificationId,
    required this.employeeId,
    required this.employeeName,
    this.code,
    required this.message,
    required this.messageTypeId,
    required this.messageType,
    required this.notifyTill,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
  });

  factory Notification_model.fromJson(Map<String, dynamic> json) {
    return Notification_model(
      notificationId: json['notificationId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      code: json['code'],
      message: json['message'],
      messageTypeId: json['messageTypeId'],
      messageType: json['messageType'],
      notifyTill: json['notifyTill'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
    );
  }
}
