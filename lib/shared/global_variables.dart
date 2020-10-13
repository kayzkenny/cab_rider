import 'package:google_maps_flutter/google_maps_flutter.dart';

String googleMapsEndpoint = 'https://maps.googleapis.com/maps/api';
String geocodeEndpoint = '$googleMapsEndpoint/geocode/json';
String placesEndpoint = '$googleMapsEndpoint/place/autocomplete/json';
String placeDetailsEndpoint = '$googleMapsEndpoint/place/details/json';
String directionsEndpoint = '$googleMapsEndpoint/directions/json';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
