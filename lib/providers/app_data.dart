import 'package:flutter/material.dart';
import 'package:cab_rider/models/address.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }
}
