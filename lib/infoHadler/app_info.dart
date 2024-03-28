import 'package:flutter/material.dart';
import 'package:yalah/models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  //List<String> historyTripKeyList = [];
  //List<TripHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAdress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAdress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
