import 'package:flutter/cupertino.dart';
import 'package:yalah/app/adress.dart';
import 'package:yalah/app/assumed_far.dart';
import 'package:yalah/app/directionsDetails.dart';




class AppData extends ChangeNotifier{
  late Address userPickUpLocation,dropOffLocation;
  late DirectionDetails DDetails,totalFareAmount;
  late Fare assumedfare;

   void updatePickUpLocationAddress(Address pickUpAddress){
    userPickUpLocation=pickUpAddress;
    notifyListeners(); // when address changes this will handle the address
  }
  void updatedropOffLocationAddress(Address dropOffAddress){
    dropOffLocation=dropOffAddress;
    notifyListeners(); // when address changes this will handle the address
  }
  void updateDirectionDetails(DirectionDetails DirectionDetails){
    DDetails=DirectionDetails;
    notifyListeners(); // when address changes this will handle the address
  }
  void updateFareAmount(Fare fare){
    assumedfare=fare;
    notifyListeners(); // when address changes this will handle the address
  }

}