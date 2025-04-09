import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PermissionManager {
  static Map<String, dynamic>? _permissions;

  static Future<void> loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionsString = prefs.getString('permissions');
    if (permissionsString != null) {
      _permissions = json.decode(permissionsString);
    }
  }

  static bool hasPermission(String key) {
    if (_permissions == null) return false;
    return _permissions![key] == true;
  }
}
