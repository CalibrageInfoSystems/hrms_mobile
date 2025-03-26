import 'dart:convert';

LeadInfoModel leadInfoModelFromJson(String str) =>
    LeadInfoModel.fromJson(json.decode(str));

String leadInfoModelToJson(LeadInfoModel data) => json.encode(data.toJson());

class LeadInfoModel {
  final int? id;
  final String? code;
  final int? isCompany;
  final String? name;
  final dynamic companyName;
  final String? phoneNumber;
  final String? email;
  final String? comments;
  final double? latitude;
  final double? longitude;
  String? Address;
  final int? createdByUserId;
  final String? createdDate;
  final int? updatedByUserId;
  final String? updatedDate;
  final int? serverUpdatedStatus;

  LeadInfoModel({
    this.id,
    this.code,
    this.isCompany,
    this.name,
    this.companyName,
    this.phoneNumber,
    this.email,
    this.comments,
    this.latitude,
    this.longitude,
    this.Address,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
    this.serverUpdatedStatus,
  });

  factory LeadInfoModel.fromJson(Map<String, dynamic> json) => LeadInfoModel(
        id: json["Id"],
        code: json["code"],
        isCompany: json["IsCompany"],
        name: json["Name"],
        companyName: json["CompanyName"],
        phoneNumber: json["PhoneNumber"],
        email: json["Email"],
        comments: json["Comments"],
        latitude: json["Latitude"]?.toDouble(),
        longitude: json["Longitude"]?.toDouble(),
         Address:json['Address'],
        createdByUserId: json["CreatedByUserId"],
        createdDate: json["CreatedDate"],
        updatedByUserId: json["UpdatedByUserId"],
        updatedDate: json["UpdatedDate"],
        serverUpdatedStatus: json["ServerUpdatedStatus"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "code": code,
        "IsCompany": isCompany,
        "Name": name,
        "CompanyName": companyName,
        "PhoneNumber": phoneNumber,
        "Email": email,
        "Comments": comments,
        "Latitude": latitude,
        "Longitude": longitude,
      'Address':Address,
        "CreatedByUserId": createdByUserId,
        "CreatedDate": createdDate,
        "UpdatedByUserId": updatedByUserId,
        "UpdatedDate": updatedDate,
        "ServerUpdatedStatus": serverUpdatedStatus,
      };
}
