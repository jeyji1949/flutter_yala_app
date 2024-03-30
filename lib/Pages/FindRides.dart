import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart' as geo_coding_location;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as flutter_google_places;
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';
import 'package:yalah/Assistants/assistant_methods.dart';
import 'package:yalah/components/SideBar.dart';
import 'package:yalah/infoHadler/app_info.dart';
import 'package:yalah/map/Map_key.dart';
import 'package:yalah/models/directions.dart';
import 'package:yalah/theme/theme_model.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';

class FindRidesPage extends StatefulWidget {
  const FindRidesPage({Key? key}) : super(key: key);

  @override
  State<FindRidesPage> createState() => _FindRidesPageState();
}

class _FindRidesPageState extends State<FindRidesPage> {
  late GoogleMapController googleMapController;
  LatLng? pickLocation;
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double bottomPaddingOfMap = 0;

  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  late GooglePlace googlePlace;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          backgroundColor: const Color(0xff60E1E0),
          elevation: 0,
          title: Text(
            themeNotifier.isDark ? "find rides " : "find rides",
            style: TextStyle(
              color: themeNotifier.isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeNotifier.isDark ? Icons.wb_sunny : Icons.nightlight_round,
                color:
                    themeNotifier.isDark ? Colors.white : Colors.grey.shade900,
              ),
              onPressed: () {
                themeNotifier.isDark
                    ? themeNotifier.isDark = false
                    : themeNotifier.isDark = true;
              },
            )
          ],
        ),
        drawer: const MyDrawer(),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                padding: EdgeInsets.only(
                    top: size.height * 0.1, bottom: size.height * 0.02),
                child: GoogleMap(
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  polylines: polylineSet,
                  markers: markerSet,
                  circles: circleSet,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    googleMapController = controller;
                    setState(() {});

                    locateUserPosition();
                  },
                  onCameraMove: (CameraPosition? position) {
                    if (position != null && pickLocation != position.target) {
                      setState(() {
                        pickLocation = position.target;
                      });
                    }
                  },
                  onCameraIdle: () {
                    getAdressFromLatLng();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: themeNotifier.isDark
                              ? Color(0xffff5a5f)
                              : Colors.lightBlue,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: originController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "From",
                              ),
                              onTap: () async {
                                performAutoComplete();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: themeNotifier.isDark
                              ? Color(0xffff5a5f)
                              : Colors.lightBlue,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: destinationController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "To",
                              ),
                              onTap: () async {
                                performAutoComplete();
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            searchForRide(originController.text,destinationController.text);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void locateUserPosition() async {
    try {
      geo.Position cPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      LatLng LatLngPosition = LatLng(cPosition.latitude, cPosition.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: LatLngPosition, zoom: 15);

      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String humanReadableAddress =
          // ignore: use_build_context_synchronously
          await AssitantMethods.searchAddressForGeographicCoOrdinates(
              cPosition, context);
      // ignore: avoid_print
      print('this is our address = $humanReadableAddress');
    } catch (e) {
      if (e is geo.PermissionDeniedException) {
        // Handle the case where the user denied location permission
        print('User denied location permission');
      } else {
        // Handle other exceptions
        print('Error occurred: $e');
      }
    }

    //InitializedGeofireListener();

    //AssitantMethods.readTripsKeysForOnLineUser();
  }

  void getAdressFromLatLng() async {
    try {
      if (pickLocation != null) {
        GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapKey,
        );

        setState(() {
          Directions userPickUpAddress = Directions();
          userPickUpAddress.locationLatitude = pickLocation!.latitude;
          userPickUpAddress.locationLongtitude = pickLocation!.longitude;
          userPickUpAddress.locationName = data.address;

          Provider.of<AppInfo>(context, listen: false)
              .updatePickUpLocationAdress(userPickUpAddress);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Position?> checkIfLocationPermissionAllowed() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Location Services Disabled"),
            content: const Text(
                "Please enable location services to use this feature."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
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
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return null;
    }
  }

  void getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<geo_coding_location.Placemark> placemarks =
          await geo_coding_location.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geo_coding_location.Placemark placemark = placemarks.first;
        print(
            'Address: ${placemark.street}, ${placemark.locality}, ${placemark.country}');
      } else {
        print('No address found for the given coordinates.');
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  void searchForRide(String origin, String destination) async {
    try {
      // Convert origin and destination to coordinates
      LatLng? originLatLng = await _convertAddressToLatLng(origin);
      LatLng? destinationLatLng = await _convertAddressToLatLng(destination);


      // Display markers for origin and destination on the map
      Marker originMarker = Marker(
        markerId: MarkerId('Origin'),
        position: originLatLng!!,
        infoWindow: InfoWindow(title: 'Origin'),
      );

      Marker destinationMarker = Marker(
        markerId: MarkerId('Destination'),
        position: destinationLatLng!!,
        infoWindow: InfoWindow(title: 'Destination'),
      );

      setState(() {
        markerSet.clear(); // Clear previous markers
        markerSet.add(originMarker);
        markerSet.add(destinationMarker);
      });
      googleMapController.animateCamera(CameraUpdate.newLatLng(originLatLng));
          // Calculate route using Directions API
      Directions directions = await AssitantMethods.getDirections(
        originLatLng,
        destinationLatLng,
      );
      // Display polyline for the route on the map
      setState(() {
        polylineSet.clear(); // Clear previous polylines
        polylineSet.add(
          Polyline(
            polylineId: const PolylineId('Route'),
            points: [
              originLatLng,
              destinationLatLng
            ],
            color: Colors.blue,
            width: 5,
          ),
        );
      });

      // Display trip information
      print('Distance: ${directions.distance}');
      print('Duration: ${directions.duration}');
        } catch (e) {
      print('Error searching for ride: $e');
    }
  }

  Future<LatLng?> _convertAddressToLatLng(String address) async {
    try {
      List<geo_coding_location.Location> locations = await geo_coding_location.locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  void performAutoComplete() async {
    String kGoogleApiKey = mapKey;

    // ignore: unused_local_variable
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay,
        language: "fr",
        offset: 0,
        radius: 1000,
        strictbounds: false,
        region: "MAR",
        types: [
          "(cities)"
        ],
        components: [
          flutter_google_places.Component(
              flutter_google_places.Component.country, "MAR")
        ]);
    if (p != null) {
      setState(() {
        if (originController.text.isEmpty) {
          originController.text = p.description!;
        } else {
          destinationController.text = p.description!;
        }
      });
    }
  }
}
