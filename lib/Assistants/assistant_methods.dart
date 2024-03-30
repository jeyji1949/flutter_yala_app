import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yalah/infoHadler/app_info.dart';
import 'package:yalah/map/Map_key.dart';
import 'package:yalah/Assistants/request_assitant.dart';
import 'package:yalah/models/directions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class AssitantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.latitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongtitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAdress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<Directions> getDirections(
      LatLng origin, LatLng destination) async {
    // Implement logic to fetch directions from an API
    // For example, you can use Google Directions API or any other routing service

    // Placeholder implementation
    return Directions(); // Return a Directions object with the required data
  }


}
