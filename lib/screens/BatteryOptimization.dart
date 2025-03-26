

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

class BatteryOptimization {
  static Future<bool> isIgnoringBatteryOptimizations() async {
    // You can use a plugin like android_intent_plus to check the status
    // Placeholder logic, replace with the actual implementation
    return false;
  }

  static void openBatteryOptimizationSettings() async {
    try {
      // Open the battery optimization settings
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'cis.geotrack.com.smartgetrack', // Replace with your app's package name
      );
      await intent.launch();
    } on PlatformException catch (e) {
      print("Error launching battery optimization settings: ${e.message}");

      // Handle the error gracefully here, for example, by showing a dialog to the user
    } catch (e) {
      print("Unhandled error: $e");
    }
  }
}
