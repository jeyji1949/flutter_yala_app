import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalah/theme/theme_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchedRidesPage extends StatefulWidget {
  final String origin;
  final String destination;

  const SearchedRidesPage({
    Key? key,
    required this.origin,
    required this.destination,
  }) : super(key: key);

  @override
  _SearchedRidesPageState createState() => _SearchedRidesPageState();
}

class _SearchedRidesPageState extends State<SearchedRidesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
              themeNotifier.isDark ? "Availaibale Rides" : "Availaibale Rides",
              style: TextStyle(
                  color: themeNotifier.isDark
                      ? Colors.white
                      : Colors.grey.shade900),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
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
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('rides').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Filter the documents based on the condition
                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
                    .where((doc) =>
                        doc['dropOffLocation'] == widget.destination &&
                        doc['pickupLocation'] == widget.origin)
                    .toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                      child: Text(
                          'No rides found for the selected origin and destination.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount:
                      filteredDocs.length + 1, // Add 1 for the second container
                  itemBuilder: (context, index) {
                    if (index == filteredDocs.length) {
                      // This is where the second container will be displayed
                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('From: \n Nador, Maroc'),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Ahmed EL'),
                                      CircleAvatar(
                                        radius: 20, // Adjust the size as needed
                                        backgroundImage: AssetImage(
                                            "Assets/images/profil1.jpg"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('to: \n Fès'),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Price per person : 200 MAD'),
                                Icon(Icons.attach_money), // Price icon
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Car: Clio C15'),
                                Icon(Icons.car_crash_rounded), // Price icon
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('07/04/2024'),
                                Icon(Icons.date_range), // Seats icon
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Available seats: 2'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.event_seat),
                                Icon(Icons.event_seat),
                              ],
                            ),
                            Text('★★★☆☆'), // Example stars
                            SizedBox(height: 10),
                            MaterialButton(
                              child: const Text("Contact"),
                              textColor: Colors.white,
                              color: Color(0xffff5a5f),
                              onPressed: () {
                                launchWhatsApp();
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // This is where the first container will be displayed
                      final doc = filteredDocs[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('From: \n Nador, Maroc'),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Nadia'),
                                      CircleAvatar(
                                        radius: 20, // Adjust the size as needed
                                        backgroundImage: AssetImage(
                                            "Assets/images/profil.jpg"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('to: \n Fès, Maroc'),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Price per person : 100 MAD'),
                                Icon(Icons.attach_money), // Price icon
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Car: Dacia logane 256'),
                                Icon(Icons.car_crash_rounded), // Price icon
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('06/04/2024'),
                                Icon(Icons.date_range), // Seats icon
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Available seats: 4'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.event_seat),
                                Icon(Icons.event_seat),
                                Icon(Icons.event_seat),
                                Icon(Icons.event_seat), // Seats icon
                              ],
                            ),
                            Text('★★★★☆'), // Example stars
                            SizedBox(height: 10),
                            MaterialButton(
                              child: const Text("Contact"),
                              textColor: Colors.white,
                              color: Color(0xffff5a5f),
                              onPressed: () {
                                launchWhatsApp();
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  void launchWhatsApp() async {
    String phoneNumber = '+212613069953';
    String message =
        'Hello, I saw your post on yala app about travelling can we Discuss it';

    String url = 'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';

    try {
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
