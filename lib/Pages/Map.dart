import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yalah/theme/theme_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController googleMapController;

  Set<Marker> markers = {};
  Position? _currentPosition;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(37.15478, -122.78945),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        return Scaffold(
            appBar: AppBar(
                // App bar configuration
                ),
            body: SingleChildScrollView(
              child: Column(
                // Changed child to children
                children: [
                  // Added children list
                  SizedBox(
                    width: size.width * 1,
                    height: size.height * 0.6,
                    child: GoogleMap(
                      initialCameraPosition: initialPosition,
                      markers: markers,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      myLocationEnabled: true, // Enable my location button
                      onMapCreated: (GoogleMapController controller) {
                        googleMapController = controller;
                      },
                      onTap: (LatLng latLng) {
                        _updateMarkers(latLng);
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'From',
                              hintText: 'Enter pickup location',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'To',
                              hintText: 'Enter destination',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                _currentPosition = await _determinePosition();
                if (_currentPosition != null) {
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 14,
                      ),
                    ),
                  );
                }
              },
              label: const Text("Current Location"),
              icon: const Icon(Icons.location_history),
            ));
      },
    );
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Location Services Disabled"),
            content:
                Text("Please enable location services to use this feature."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position? position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("An error occurred: $e"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      return null;
    }
  }

  void _updateMarkers(LatLng latLng) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('selectedLocation'),
          position: latLng,
          draggable: true,
          onDragEnd: (LatLng position) {
            // Perform actions when the marker is dragged to a new position
          },
        ),
      );
    });
  }
}
