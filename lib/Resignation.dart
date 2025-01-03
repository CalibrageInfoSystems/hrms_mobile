class Resignation {
  int resignationId;
  String employeeCode;
  String employeeName;
  int employeeId;
  int reasonId;
  String reason;
  String? otherReason;
  String? description;
  DateTime? relievingDate;
  DateTime? assetsReturnByDate;
  bool? hasHandedOverAssets;
  DateTime? docsAcceptedAt;
  String? personalEmailId;
  DateTime? acceptedAt;
  int? acceptedById;
  String? acceptedBy;
  DateTime? rejectedAt;
  int? rejectedById;
  String? rejectedBy;
  String? reviewDescription;
  String resignationStatus;
  bool isActive;
  DateTime createdAt;
  String createdBy;
  DateTime updatedAt;
  String updatedBy;

  Resignation({
    required this.resignationId,
    required this.employeeCode,
    required this.employeeName,
    required this.employeeId,
    required this.reasonId,
    required this.reason,
    this.otherReason,
    this.description,
    this.relievingDate,
    this.assetsReturnByDate,
    this.hasHandedOverAssets,
    this.docsAcceptedAt,
    this.personalEmailId,
    this.acceptedAt,
    this.acceptedById,
    this.acceptedBy,
    this.rejectedAt,
    this.rejectedById,
    this.rejectedBy,
    this.reviewDescription,
    required this.resignationStatus,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory Resignation.fromJson(Map<String, dynamic> json) {
    return Resignation(
      resignationId: json['resignationId'],
      employeeCode: json['employeeCode'],
      employeeName: json['employeeName'],
      employeeId: json['employeeId'],
      reasonId: json['reasonId'],
      reason: json['reason'],
      otherReason: json['otherReason'],
      description: json['description'],
      relievingDate: json['relievingDate'] != null
          ? DateTime.parse(json['relievingDate'])
          : null,
      assetsReturnByDate: json['assetsReturnByDate'] != null
          ? DateTime.parse(json['assetsReturnByDate'])
          : null,
      hasHandedOverAssets: json['hasHandedOverAssets'],
      docsAcceptedAt: json['docsAcceptedAt'] != null
          ? DateTime.parse(json['docsAcceptedAt'])
          : null,
      personalEmailId: json['personalEmailId'],
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      acceptedById: json['acceptedById'],
      acceptedBy: json['acceptedBy'],
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      rejectedById: json['rejectedById'],
      rejectedBy: json['rejectedBy'],
      reviewDescription: json['reviewDescription'],
      resignationStatus: json['resignationStatus'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resignationId': resignationId,
      'employeeCode': employeeCode,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'reasonId': reasonId,
      'reason': reason,
      'otherReason': otherReason,
      'description': description,
      'relievingDate': relievingDate?.toIso8601String(),
      'assetsReturnByDate': assetsReturnByDate?.toIso8601String(),
      'hasHandedOverAssets': hasHandedOverAssets,
      'docsAcceptedAt': docsAcceptedAt?.toIso8601String(),
      'personalEmailId': personalEmailId,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'acceptedById': acceptedById,
      'acceptedBy': acceptedBy,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectedById': rejectedById,
      'rejectedBy': rejectedBy,
      'reviewDescription': reviewDescription,
      'resignationStatus': resignationStatus,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }
}
