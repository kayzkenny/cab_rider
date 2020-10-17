import 'dart:math';

import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:cab_rider/models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cab_rider/models/address.dart';
import 'package:cab_rider/shared/api_keys.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cab_rider/providers/app_data.dart';
import 'package:cab_rider/helpers/request_helper.dart';
import 'package:cab_rider/shared/global_variables.dart';
import 'package:cab_rider/models/direction_details.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HelperMethods {
  static Future<String> findCoordinateAddress(
    Position position,
    BuildContext context,
  ) async {
    String placeAddress = "";

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        '$geocodeEndpoint?latlng=${position.latitude},${position.longitude}&key=$googleMapsKey';

    var response = await RequestHelper.getRequest(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address(
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: placeAddress,
      );

      Provider.of<AppData>(
        context,
        listen: false,
      ).updatePickupAddress(pickupAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> getDirectionDetails(
    LatLng startPosition,
    LatLng endPosition,
  ) async {
    String url =
        '$directionsEndpoint?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$googleMapsKey';
    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(
      durationText: response['routes'][0]['legs'][0]['duration']['text'],
      durationValue: response['routes'][0]['legs'][0]['duration']['value'],
      distanceText: response['routes'][0]['legs'][0]['distance']['text'],
      distanceValue: response['routes'][0]['legs'][0]['distance']['value'],
      encodedPoints: response['routes'][0]['overview_polyline']['points'],
    );

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details) {
    // per km = $0.3, per min = $0.2, base fare = $3,

    double baseFare = 3;
    double distanceFare = (details.distanceValue / 1000) * 0.3;
    double timeFare = (details.durationValue / 60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }

  static Future<void> getCurrentUserInfo() async {
    currentFirebaseUser = auth.FirebaseAuth.instance.currentUser;
    String userId = currentFirebaseUser.uid;

    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('users/$userId');

    userRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentUserInfo = User.fromSnapshot(snapshot);
        print(currentUserInfo.fullName);
      }
    });
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);

    return randInt.toDouble();
  }
}
