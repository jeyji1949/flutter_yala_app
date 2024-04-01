import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalah/Pages/FindRides.dart';
import 'package:yalah/Pages/Home.dart';
import 'package:yalah/Pages/LogIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yalah/Pages/Myrides.dart';
import 'package:yalah/Pages/UserInfo.dart';
import 'package:yalah/Pages/offerRides.dart';
import 'package:yalah/theme/theme_model.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key});

  Future<void> signUserOut(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final FirebaseAuth auth = FirebaseAuth.instance;

      await googleSignIn.signOut();
      await auth.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Widget _buildProfileImage(String uid) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserProfileData(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Icon(
            Icons.person,
            color: Color(0xFF306B74),
            size: 40,
          );
        } else if (snapshot.hasData) {
          Map<String, dynamic>? userData = snapshot.data;
          if (userData != null && userData.containsKey('profileImageUrl')) {
            String imageUrl = userData['profileImageUrl'];
            return CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            );
          } else {
            return Icon(
              Icons.person,
              color: Color(0xFF306B74),
              size: 40,
            );
          }
        } else {
          return Icon(
            Icons.person,
            color: Color(0xFF306B74),
            size: 40,
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _getUserProfileData(String uid) async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        var userData = snapshot.data();
        return userData ?? {}; // Return user data or empty map if null
      }
      return {}; // Return empty map if no user data found
    } catch (e) {
      print('Error fetching user profile data: $e');
      return {}; // Return empty map on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: currentUser != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20, // Adjust the size as needed
                          backgroundImage:
                              AssetImage("Assets/images/profilimage.jpg"),
                        ),
                        SizedBox(width: 16),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _getUserProfileData(currentUser.uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData) {
                              var userData = snapshot.data!;
                              var username = userData['nom'];
                              var isPassenger = userData['isPassenger'];
                              var isDriver = userData['isDriver'];
                              print("Username: $username");
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username ?? "",
                                    style: TextStyle(
                                      color: themeNotifier.isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (isPassenger ?? false)
                                    Text(
                                      "Passenger",
                                      style: TextStyle(
                                        color: themeNotifier.isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (isDriver ?? false)
                                    Text(
                                      "Driver",
                                      style: TextStyle(
                                        color: themeNotifier.isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ],
                    )
                  : Container(),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OfferedRidesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Find a ride'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FindRidesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_pin),
              title: Text('Offer a ride'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OfferRidesPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.trip_origin),
              title: Text('My Rides '),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyRides()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profil'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sos),
              title: Text('SOS'),
              onTap: () {
                launch('tel:177');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => signUserOut(context),
            ),
          ],
        ),
      );
    });
  }
}
