import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:provider/provider.dart';
import 'package:yalah/components/SideBar.dart';
import 'package:yalah/theme/theme_model.dart';

class PassengerRideDetails extends StatelessWidget {
  final String from;
  final String to;
  final String departureDate;
  final String vehicleType;
  final String pricePerPerson;
  final int availableSeats;
  final VoidCallback onRideCanceled; // Define callback function

  PassengerRideDetails({
    required this.from,
    required this.to,
    required this.departureDate,
    required this.vehicleType,
    required this.pricePerPerson,
    required this.availableSeats,
    required this.onRideCanceled, // Pass the callback function
  });

  void _showConfirmationDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      desc: 'Are you sure you want to cancel this ride?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        // Call the callback function when the ride is canceled
        onRideCanceled();
      },
    ).show();
  }

  
void _handleRideCanceled() {
  // Update UI or perform any other action here
  print('Ride canceled');
}

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff60E1E0),
          elevation: 0,
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
        drawer: MyDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: $from',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'To: $to',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Departure Date: $departureDate',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Vehicle Type: $vehicleType',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Price Per Person: $pricePerPerson',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Available Seats: $availableSeats',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        _showConfirmationDialog(context);
                      },
                      elevation: 0,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: const Color(0xffff5a5f),
                      child: const Text(
                        "Cancel Ride",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                     
                      },
                      elevation: 0,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: const Color(0xff60E1E0),
                      child: const Text(
                        "Contact Driver",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
