import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  String? humainReadableAddress;
  String? locationName;
  String? locationID;
  double? locationLatitude;
  double? locationLongtitude;
  List<LatLng>? polylinePoints;

  // Constructor with named parameters
  Directions({
    this.humainReadableAddress,
    this.locationID,
    this.locationLatitude,
    this.locationLongtitude,
    this.locationName,
    this.polylinePoints,
  });

  // Getter for polylineCoordinates
  List<LatLng> get polylineCoordinates => polylinePoints ?? [];

  // Setter for polylinePoints
  void setPolylineCoordinates(List<LatLng> coordinates) {
    polylinePoints = coordinates;
  }

  // Additional properties and methods
  get distance => null;

  get duration => null;
}
