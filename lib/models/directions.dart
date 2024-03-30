import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  String? humanReadableAddress;
  String? locationName;
  String? locationID;
  double? locationLatitude;
  double? locationLongtitude;

  List<LatLng> _polylineCoordinates = [];

  List<LatLng> get polylineCoordinates => _polylineCoordinates;

  // Add getters for distance and duration
  String? distance;
  String? duration;

  Directions({
    this.humanReadableAddress,
    this.locationID,
    this.locationLatitude,
    this.locationLongtitude,
    this.locationName,
    this.distance,
    this.duration,
  });

  // Add a method to set the polyline coordinates
  void setPolylineCoordinates(List<LatLng> coordinates) {
    _polylineCoordinates = coordinates;
  }
}
