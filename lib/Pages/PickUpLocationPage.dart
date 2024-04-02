import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/Home.dart';
import 'package:yalah/Pages/offerRides.dart';
import 'package:yalah/theme/theme_model.dart';

class RideDetail extends StatelessWidget {
  final String pickupLocation;
  final String dropLocation;
  final String departureDateTime;
  final String vehicleType;
  final int pricePerPerson;
  final int numberOfSeats;

  RideDetail({
    required this.pickupLocation,
    required this.dropLocation,
    required this.departureDateTime,
    required this.vehicleType,
    required this.pricePerPerson,
    required this.numberOfSeats,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff60E1E0),
            elevation: 0,
            title: Text(
              themeNotifier.isDark
                  ? "Offered Ride Details"
                  : "Offered Ride Details",
              style: TextStyle(
                  color: themeNotifier.isDark
                      ? Colors.white
                      : Colors.grey.shade900),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back when arrow is pressed
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  themeNotifier.isDark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny,
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
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationRow(
                    icon: Icons.trip_origin, text: pickupLocation),
                SizedBox(height: 10),
                _buildLocationRow(icon: Icons.location_pin, text: dropLocation),
                SizedBox(height: 20),
                Text(
                  'Departure Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  departureDateTime,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Vehicle Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  vehicleType,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Price Per Person',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text(
                  pricePerPerson.toString() + ' MAD',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Availaibale seats',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Text(
                  numberOfSeats.toString(),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OfferedRidesPage()),
                    );
                  },
                  elevation: 0,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: const Color(0xffff5a5f),
                  child: const Center(
                    child: Text(
                      "Start ride",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }
}
