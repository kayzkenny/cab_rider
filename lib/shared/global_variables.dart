import 'package:cab_rider/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_maps_flutter/google_maps_flutter.dart';

String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';
String geocodeEndpoint = '$googleMapsEndpoint/geocode/json';
String directionsEndpoint = '$googleMapsEndpoint/directions/json';
String googleMapsEndpoint = 'https://maps.googleapis.com/maps/api';
String placesEndpoint = '$googleMapsEndpoint/place/autocomplete/json';
String placeDetailsEndpoint = '$googleMapsEndpoint/place/details/json';

User currentUserInfo;
auth.User currentFirebaseUser;

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
