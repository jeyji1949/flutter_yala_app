import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalah/theme/theme_model.dart';

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
                // Filter the documents based on the condition
                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) =>
                    doc['dropOffLocation'] == widget.destination && 
                    doc['pickupLocation'] == widget.origin
                ).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No rides found for the selected origin and destination.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    // Use filteredDocs[index] instead of snapshot.data!.docs[index]
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
                              'From:\n ${filteredDocs[index]['pickupLocation']}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'To: ${filteredDocs[index]['dropOffLocation']}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Vehicle: ${filteredDocs[index]['vehicleType']}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'Price: ${filteredDocs[index]['pricePerPerson'].toString()}'),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              '${filteredDocs[index]['departureDateTime']}'),
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
