import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/RidesDetails.dart';
import 'package:yalah/components/SideBar.dart';
import 'package:yalah/theme/theme_model.dart';

class OfferedRidesPage extends StatelessWidget {
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
              themeNotifier.isDark ? "All Rides" : "All Rides",
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
          drawer: MyDrawer(),
          body: RideList(),
        );
      },
    );
  }
}

class RideList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rides').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final rides = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index].data() as Map<String, dynamic>;
              return RideItem(ride: ride);
            },
          );
        }
      },
    );
  }
}

class RideItem extends StatelessWidget {
  final Map<String, dynamic> ride;
  

  const RideItem({Key? key, required this.ride}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    final String? userId = ride['userID']; // Get userID from ride map

    // Check if userId is not null and not empty
    if (userId != null && userId.isNotEmpty) {
      return Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(15.0),
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
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildProfileImage(userData['photoURL']),
                      SizedBox(width: 10),
                      Text(userData['nom'] ?? 'Username not available'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('From: ${ride['pickupLocation']}'),
                  SizedBox(height: 10),
                  Text('To: ${ride['dropOffLocation']}'),
                  SizedBox(height: 10),
                  Text('Vehicle: ${ride['vehicleType']}'),
                  SizedBox(height: 10),
                  Text('Price:  ${ride['pricePerPerson']} ' + 'MAD'),
                  SizedBox(height: 10),
                  Text('Departure Date: ${ride['departureDateTime']}'),
                  SizedBox(height: 10),
                  MaterialButton(
                    child: const Text("See Ride"),
                    textColor: Colors.white,
                    color: Color(0xffff5a5f),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideDetailsPage(ride: ride,),
                        ),
                      );
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                  ),
                ],
              );
            } else {
              return Text('No user data found');
            }
          },
        ),
      );
    } else {
      return Text('UserID is null or empty');
    }
  }

  Widget _buildProfileImage(String? imageUrl) {
    return CircleAvatar(
      radius: 20,
      child: imageUrl != null
          ? CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            )
          : Icon(
              Icons.person,
              color: Color(0xFF306B74),
              size: 40,
            ),
    );
  }
}
