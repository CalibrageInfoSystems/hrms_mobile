
import 'package:geolocator/geolocator.dart';

class LocationServiceRepository {
  LocationServiceRepository();

  Future<Position> fetchLocationByDeviceGPS() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        //throw ('Location services are disabled. Please enable them in settings.'); //TODO: Add custom error message
      }

      // Check current location permission
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      // Handle granted permissions
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Fetch the current location
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } else {
        throw ('Location permissions are denied. Please grant them to proceed.');
      }
    } catch (e) {
      rethrow; // Pass the exception to the caller
    }
  }

}
