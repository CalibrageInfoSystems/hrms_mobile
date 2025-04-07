// To parse this JSON data, do
//
//     final birthdayBanner = birthdayBannerFromJson(jsonString);

import 'dart:convert';

List<BirthdayBanner> birthdayBannerFromJson(String str) =>
    List<BirthdayBanner>.from(
        json.decode(str).map((x) => BirthdayBanner.fromJson(x)));

String birthdayBannerToJson(List<BirthdayBanner> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BirthdayBanner {
  final int? employeeId;
  final String? code;
  final String? employeeName;
  final String? gender;
  final String? mobileNumber;
  final String? alternateMobileNumber;
  final DateTime? originalDob;
  final DateTime? certificateDob;
  final String? emailId;
  final String? photo;
  final String? wish;

  BirthdayBanner({
    this.employeeId,
    this.code,
    this.employeeName,
    this.gender,
    this.mobileNumber,
    this.alternateMobileNumber,
    this.originalDob,
    this.certificateDob,
    this.emailId,
    this.photo,
    this.wish,
  });

  factory BirthdayBanner.fromJson(Map<String, dynamic> json) => BirthdayBanner(
        employeeId: json["employeeId"],
        code: json["code"],
        employeeName: json["employeeName"],
        gender: json["gender"],
        mobileNumber: json["mobileNumber"],
        alternateMobileNumber: json["alternateMobileNumber"],
        originalDob: json["originalDOB"] == null
            ? null
            : DateTime.parse(json["originalDOB"]),
        certificateDob: json["certificateDOB"] == null
            ? null
            : DateTime.parse(json["certificateDOB"]),
        emailId: json["emailId"],
        photo: json["photo"],
        wish: json["wish"],
      );

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "code": code,
        "employeeName": employeeName,
        "gender": gender,
        "mobileNumber": mobileNumber,
        "alternateMobileNumber": alternateMobileNumber,
        "originalDOB": originalDob?.toIso8601String(),
        "certificateDOB": certificateDob?.toIso8601String(),
        "emailId": emailId,
        "photo": photo,
        "wish": wish,
      };
}
