import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yalah/theme/theme_model.dart';

class OfferedRidesPage extends StatefulWidget {
  @override
  _OfferedRidesPageState createState() => _OfferedRidesPageState();
}

class _OfferedRidesPageState extends State<OfferedRidesPage> {
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
              themeNotifier.isDark ? "Offered Rides" : "Offered Rides",
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
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
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
                          Text(
                              'From:\n ${snapshot.data?.docs[index]['pickupLocation']}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'To: ${snapshot.data?.docs[index]['dropOffLocation']}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Vehicle: ${snapshot.data?.docs[index]['vehicleType']}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Price: ${snapshot.data?.docs[index]['pricePerPerson'].toString()}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              '${snapshot.data!.docs[index]['departureDateTime']}'),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
}
