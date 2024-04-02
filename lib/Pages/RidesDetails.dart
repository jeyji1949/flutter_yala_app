import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalah/theme/theme_model.dart';

class RideDetailsPage extends StatelessWidget {
  final Map<String, dynamic> ride;

  const RideDetailsPage({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff60E1E0),
            elevation: 0,
            title: Text(
              themeNotifier.isDark ? "" : "",
              style: TextStyle(
                color:
                    themeNotifier.isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back when arrow is pressed
              },
            ),
          ),
          body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From: ${ride['pickupLocation']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'To: ${ride['dropOffLocation']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Vehicle: ${ride['vehicleType']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Price: ${ride['pricePerPerson']} MAD',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Departure Date: ${ride['departureDateTime']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          MaterialButton(
                            child: const Text("Contact"),
                            textColor: Colors.white,
                            color: Color(0xffff5a5f),
                            onPressed: () {
                              launchWhatsApp();
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                          ),
                        ],
                      ),
                    ),
                  ])));
    });
  }

  void launchWhatsApp() async {
    try {
      // Fetch user data using the provided userID

      // Extract phone number from user data
      String phoneNumber = '+212613069953';
      // Construct WhatsApp message
      String message =
          'Hello, I saw your post on yala app about travelling. Can we discuss it?';

      // Construct WhatsApp URL
      String url = 'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';

      // Launch WhatsApp
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }
}
