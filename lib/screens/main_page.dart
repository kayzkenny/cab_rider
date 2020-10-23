import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cab_rider/styles/styles.dart';
import 'package:cab_rider/providers/app_data.dart';
import 'package:cab_rider/helpers/fire_helper.dart';
import 'package:cab_rider/widgets/taxi_button.dart';
import 'package:cab_rider/screens/search_page.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/models/nearby_driver.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:cab_rider/widgets/brand_divider.dart';
import 'package:cab_rider/helpers/helper_methods.dart';
import 'package:cab_rider/widgets/progress_dialog.dart';
import 'package:cab_rider/shared/global_variables.dart';
import 'package:cab_rider/models/direction_details.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  Position currentPosition;
  DatabaseReference rideRef;
  BitmapDescriptor nearbyIcon;
  GoogleMapController mapController;
  bool drawerCanOpen = true;
  bool nearbyDriversKeysLoaded = false;
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double mapBottomPadding = 0;
  double searchSheetHeight = 300;
  double requestingSheetHeight = 0;
  double rideDetailsSheetHeight = 0;
  List<LatLng> polylineCoordinates = [];
  DirectionDetails tripDirectionDetails;
  Completer<GoogleMapController> _controller = Completer();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> setupPositionLocator() async {
    Position position = await getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    currentPosition = position;

    LatLng pos = LatLng(
      position.latitude,
      position.longitude,
    );

    CameraPosition cp = CameraPosition(
      target: pos,
      zoom: 14,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(cp),
    );

    // set the current pickup address with provider
    await HelperMethods.findCoordinateAddress(position, context);

    await startGeofireListener();
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(
      context,
      listen: false,
    ).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(status: 'Please wait...'),
    );

    var thisDetails = await HelperMethods.getDirectionDetails(
      pickLatLng,
      destinationLatLng,
    );

    setState(() => tripDirectionDetails = thisDetails);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(
      thisDetails.encodedPoints,
    );

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((point) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });
    }

    _polylines.clear();

    Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color: Color.fromARGB(255, 95, 109, 237),
      points: polylineCoordinates,
      jointType: JointType.round,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    setState(() => _polylines.add(polyline));

    // make polyline fit inside the map
    LatLngBounds bounds;

    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: destinationLatLng,
        northeast: pickLatLng,
      );
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          pickLatLng.latitude,
          destinationLatLng.longitude,
        ),
        northeast: LatLng(
          destinationLatLng.latitude,
          pickLatLng.longitude,
        ),
      );
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          destinationLatLng.latitude,
          pickLatLng.longitude,
        ),
        northeast: LatLng(
          pickLatLng.latitude,
          destinationLatLng.longitude,
        ),
      );
    } else {
      bounds = LatLngBounds(
        southwest: pickLatLng,
        northeast: destinationLatLng,
      );
    }

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );

    Marker pickupMarker = Marker(
      position: pickLatLng,
      markerId: MarkerId('pickup'),
      infoWindow: InfoWindow(
        title: pickup.placeName,
        snippet: 'My Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      position: destinationLatLng,
      markerId: MarkerId('destination'),
      infoWindow: InfoWindow(
        title: destination.placeName,
        snippet: 'Destination',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: BrandColors.colorGreen,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  Future<void> showDetailSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsSheetHeight = 270;
      drawerCanOpen = false;
      // mapBottomPadding = 0; depends on platfrom
    });
  }

  Future<void> showRequestingSheet() async {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 210;
      mapBottomPadding = 200;

      drawerCanOpen = true;
    });

    await createRideRequest();
  }

  Future<void> createRideRequest() async {
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(
      context,
      listen: false,
    ).pickupAddress;

    var destination = Provider.of<AppData>(
      context,
      listen: false,
    ).destinationAddress;

    Map<String, dynamic> pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map<String, dynamic> destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map<String, dynamic> rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'cash',
      'driver_id': 'waiting',
    };

    await rideRef.set(rideMap);
  }

  Future<void> cancelRequest() async => await rideRef.remove();

  Future<void> startGeofireListener() async {
    await Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
      currentPosition.latitude,
      currentPosition.longitude,
      20,
    ).listen((map) {
      print(map);

      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );

            FireHelper.nearbyDriverList.add(nearbyDriver);

            if (nearbyDriversKeysLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyDriver nearbyDriver = NearbyDriver(
              key: map['key'],
              latitude: map['latitude'],
              longitude: map['longitude'],
            );

            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyDriversKeysLoaded = true;
            updateDriversOnMap();

            break;
        }
      }
    });
  }

  Future<void> resetApp() async {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = 300;
      drawerCanOpen = true;
    });

    await setupPositionLocator();
  }

  Future<void> createMarker() async {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );

      nearbyIcon = await BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        (Platform.isIOS) ? 'images/car_ios.png' : 'images/car_android.png',
      );
    }
  }

  void updateDriversOnMap() {
    setState(() => _markers.clear());

    Set<Marker> tempMarkers = Set<Marker>();

    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);

      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );

      tempMarkers.add(thisMarker);
    }

    setState(() => _markers = tempMarkers);
  }

  @override
  void initState() {
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,

        /// Navigation Drawer
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Container(
                height: 160,
                color: Colors.white,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        'images/user_icon.png',
                        height: 60,
                        width: 60,
                      ),
                      SizedBox(width: 15),
                      Container(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kenny',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Brand-Bold',
                              ),
                              overflow: TextOverflow.clip,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'View Profile',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // BrandDivider(),
              ListTile(
                leading: Icon(Icons.card_giftcard_outlined),
                title: Text(
                  'Free Rides',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.credit_card_outlined),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.history_outlined),
                title: Text(
                  'Ride History',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.contact_support_outlined),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  'About',
                  style: kDrawerItemStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() => mapBottomPadding = 300);
              setupPositionLocator();
            },
          ),

          /// Navigation Menu
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () => (drawerCanOpen)
                  ? scaffoldKey.currentState.openDrawer()
                  : resetApp(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerCanOpen) ? Icons.menu_outlined : Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          /// SearchSheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        'Nice to see you!',
                        style: TextStyle(fontSize: 10.0),
                      ),
                      Text(
                        'Where are you going?',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'Brand-Bold',
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          var response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(),
                            ),
                          );

                          if (response == 'getDirection') {
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 10),
                                Text('Search Destination'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Home'),
                              SizedBox(height: 4),
                              Text(
                                'Your residential address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      BrandDivider(),
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: BrandColors.colorDimText,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(height: 4),
                              Text(
                                'Your office address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: BrandColors.colorDimText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: rideDetailsSheetHeight,
                padding: EdgeInsets.symmetric(vertical: 18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: BrandColors.colorAccent1,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'images/taxi.png',
                            height: 70,
                            width: 70,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Taxi',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'Brand-Bold'),
                              ),
                              if (tripDirectionDetails != null)
                                Text(
                                  tripDirectionDetails.distanceText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: BrandColors.colorTextLight,
                                  ),
                                ),
                            ],
                          ),
                          Spacer(),
                          if (tripDirectionDetails != null)
                            Text(
                              '\$${HelperMethods.estimateFares(tripDirectionDetails)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Brand-Bold',
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 18,
                            color: BrandColors.colorTextLight,
                          ),
                          SizedBox(width: 4),
                          Text('Cash'),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: BrandColors.colorTextLight,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: TaxiButton(
                        title: 'REQUEST CAB',
                        color: BrandColors.colorGreen,
                        onPressed: () {
                          showRequestingSheet();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Requesting Ride Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: requestingSheetHeight,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextLiquidFill(
                        text: 'Requesting a Ride',
                        waveColor: BrandColors.colorTextSemiLight,
                        boxBackgroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontSize: 22.0,
                          fontFamily: 'Brand-Bold',
                        ),
                        boxHeight: 40.0,
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        await cancelRequest();
                        await resetApp();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            width: 1.0,
                            color: BrandColors.colorLightGrayFair,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 25,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Cancel Ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
