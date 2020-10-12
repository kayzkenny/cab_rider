import 'package:cab_rider/helpers/request_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cab_rider/shared/api_keys.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cab_rider/shared/global_variables.dart';

class HelperMethods {
  static Future<String> findCoordinateAddress(Position position) async {
    String placeAddress = "";

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        '$googleMapsEndpoint=${position.latitude},${position.longitude}&key=$googleMapsKey';

    var response = await RequestHelper.getRequest(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
    }

    return placeAddress;
  }
}
