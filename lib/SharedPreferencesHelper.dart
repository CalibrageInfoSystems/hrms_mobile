import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String CataGories = 'categories';
  String isLogin = "islogin";

//set data into shared preferences like this
//+
  static const String CHURCH_DATA = "church_data";

  static Future<bool> getBool(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key) ?? false;
  }

  static Future<void> putBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  static Future<void> saveCategories(Map<String, dynamic> jsonResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(jsonResponse);
    await prefs.setString('response_key', jsonString);
    print('Response saved to SharedPreferences: $jsonString');
  }

  static Future<Map<String, dynamic>?> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('response_key');
    if (jsonString != null && jsonString.isNotEmpty) {
      final jsonMap = jsonDecode(jsonString);
      print('Get the Response: $jsonString');
      return jsonMap;
    } else {
      return null;
    }
  }
  // Future<void> setIsLogin(bool islogin) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setBool(this.isLogin, islogin);
//   }
//
//   Future<bool> getIsLogin() async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     bool auth_token;
//     auth_token = pref.getBool(this.isLogin) ?? null;
//     return auth_token;
//   }
}
