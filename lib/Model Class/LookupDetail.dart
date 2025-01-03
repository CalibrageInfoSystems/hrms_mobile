class LookupDetail {
  final int lookupDetailId;
  final String code;
  final String name;
  final int lookupId;
  final String? description;
  final bool isActive;
  final String? fkeySelfId;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String updatedBy;

  LookupDetail({
    required this.lookupDetailId,
    required this.code,
    required this.name,
    required this.lookupId,
    this.description,
    required this.isActive,
    this.fkeySelfId,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory LookupDetail.fromJson(Map<String, dynamic> json) {
    return LookupDetail(
      lookupDetailId: json['lookupDetailId'],
      code: json['code'],
      name: json['name'],
      lookupId: json['lookupId'],
      description: json['description'],
      isActive: json['isActive'],
      fkeySelfId: json['fkeySelfId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }
}
