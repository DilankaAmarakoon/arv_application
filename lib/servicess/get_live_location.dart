import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GetLiveLocation {
  Future<Position?> getCurrentLocation() async {
    final permissionStatus = await Permission.location.request();
    if (!permissionStatus.isGranted) {
      print("Location permission denied");
      return null;
    }

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
