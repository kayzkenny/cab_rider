import 'dart:async';

import 'package:cab_rider/screens/search_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cab_rider/styles/styles.dart';
import 'package:cab_rider/screens/brand_colors.dart';
import 'package:cab_rider/widgets/brand_divider.dart';
import 'package:cab_rider/helpers/helper_methods.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  Position currentPosition;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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

    String address = await HelperMethods.findCoordinateAddress(
      position,
      context,
    );
    print(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
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
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() => mapBottomPadding = 300);
              setupPositionLocator();
            },
          ),
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () => scaffoldKey.currentState.openDrawer(),
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
                    Icons.menu_outlined,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 300,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchPage(),
                          ),
                        );
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
        ],
      ),
    );
  }
}
