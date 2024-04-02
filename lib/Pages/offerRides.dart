import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart' as flutter_google_places;
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/PickUpLocationPage.dart';
import 'package:yalah/components/SideBar.dart';
import 'package:yalah/theme/theme_model.dart';
import 'package:intl/intl.dart';

class OfferRidesPage extends StatefulWidget {
  @override
  _OfferRidesPageState createState() => _OfferRidesPageState();
}

class _OfferRidesPageState extends State<OfferRidesPage> {
  final TextEditingController _pickupLocationController =
      TextEditingController();
  final TextEditingController _DropOffLocationController =
      TextEditingController();
  final TextEditingController _departureDateTimeController =
      TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _farePerSeatController = TextEditingController();
  int availableSeats = 3;
  late GooglePlace googlePlace;

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _DropOffLocationController.dispose();
    _departureDateTimeController.dispose();
    _vehicleController.dispose();
    _farePerSeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff60E1E0),
            elevation: 0,
            title: Text(
              themeNotifier.isDark ? "Offer rides" : "Offer rides",
              style: TextStyle(
                color:
                    themeNotifier.isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  themeNotifier.isDark
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  color: themeNotifier.isDark
                      ? Colors.white
                      : Colors.grey.shade900,
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Let's travel together",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: Image.asset(
                            "Assets/images/20944127.jpg",
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _pickupLocationController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Pickup Location",
                                prefixIcon: Icon(Icons.location_city_sharp),
                              ),
                              onTap: () async {
                                performPickupAutoComplete();
                              },
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _DropOffLocationController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Drop Off location",
                                prefixIcon: Icon(Icons.location_city_sharp),
                              ),
                              onTap: () async {
                                performDropOffAutoComplete();
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _departureDateTimeController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Departure Date",
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    readOnly: true,
                                    onTap: () {
                                      _selectDate(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _vehicleController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Vehicle Type",
                                      prefixIcon: Icon(Icons.directions_car),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _farePerSeatController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Price Per Person",
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.person),
                                SizedBox(width: 10),
                                DropdownButton<int>(
                                  value: availableSeats,
                                  icon: Icon(Icons.arrow_drop_down),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        availableSeats = newValue;
                                      });
                                    }
                                  },
                                  items: <int>[1, 2, 3, 4, 5].map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(width: 10),
                                Text('Available Seats: $availableSeats'),
                              ],
                            ),
                            SizedBox(height: 20),
                            MaterialButton(
                              onPressed: () => _publishRide(context),
                              elevation: 0,
                              padding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: const Color(0xffff5a5f),
                              child: const Center(
                                child: Text(
                                  "Share Ride",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _publishRide(BuildContext context) async {
    // Extract ride details from text controllers
    String pickupLocation = _pickupLocationController.text;
    String dropOffLocation = _DropOffLocationController.text;
    String departureDateTime = _departureDateTimeController.text;
    String vehicleType = _vehicleController.text;
    int pricePerPerson = int.tryParse(_farePerSeatController.text) ?? 0;
    int numberOfSeats = availableSeats;
    String userID = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('rides').add({
      'userID': userID,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'departureDateTime': departureDateTime,
      'vehicleType': vehicleType,
      'pricePerPerson': pricePerPerson,
      'numberOfSeats': numberOfSeats,
      'createAt': DateTime.now(),
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideDetail(
          pickupLocation: pickupLocation,
          dropLocation: dropOffLocation,
          departureDateTime: departureDateTime,
          vehicleType: vehicleType,
          pricePerPerson: pricePerPerson,
          numberOfSeats: numberOfSeats,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _departureDateTimeController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void performPickupAutoComplete() async {
    const kGoogleApiKey = "AIzaSyCrojA-B0fYuDVeW1vButIZxo1T9V0Ab7g";

    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "fr",
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "MAR",
      types: ["(cities)"],
      components: [
        flutter_google_places.Component(
            flutter_google_places.Component.country, "MAR")
      ],
    );

    if (p != null) {
      setState(() {
        _pickupLocationController.text = p.description!;
      });
    }
  }

  void performDropOffAutoComplete() async {
    const kGoogleApiKey = "AIzaSyCrojA-B0fYuDVeW1vButIZxo1T9V0Ab7g";

    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      language: "fr",
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "MAR",
      types: ["(cities)"],
      components: [
        flutter_google_places.Component(
            flutter_google_places.Component.country, "MAR")
      ],
    );

    if (p != null) {
      setState(() {
        _DropOffLocationController.text = p.description!;
      });
    }
  }
}
