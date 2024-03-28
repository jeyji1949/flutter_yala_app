import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  String? humainReadableAddress;
  String? locationName;
  String? locationID;
  double? locationLatitude;
  double? locationLongtitude;

   List<LatLng> get polylineCoordinates => _polylineCoordinates;
  List<LatLng> _polylineCoordinates = [];

  // Add a method to set the polyline coordinates
  void setPolylineCoordinates(List<LatLng> coordinates) {
    _polylineCoordinates = coordinates;
  }

  Directions(
      {this.humainReadableAddress,
      this.locationID,
      this.locationLatitude,
      this.locationLongtitude,
      this.locationName});

  get distance => null;

  get duration => null;
}
