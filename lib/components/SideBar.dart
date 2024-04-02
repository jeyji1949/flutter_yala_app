import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalah/Pages/FindRides.dart';
import 'package:yalah/Pages/Home.dart';
import 'package:yalah/Pages/LogIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yalah/Pages/MyRidesInfoModify.dart';
import 'package:yalah/Pages/MyRidesPassenger.dart';
import 'package:yalah/Pages/MyridesDRIVER.dart';
import 'package:yalah/Pages/UserInfo.dart';
import 'package:yalah/Pages/offerRides.dart';
import 'package:yalah/theme/theme_model.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key});

  void _handleRideCanceled() {
    // Update UI or perform any other action here
    print('Ride canceled');
  }

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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return CircleAvatar(
            radius: 20,
            child: Icon(
              Icons.person,
              color: Color(0xFF306B74),
              size: 40,
            ),
          );
        } else if (snapshot.hasData) {
          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          // Check if user data exists and contains profile image URL
          if (userData != null && userData.containsKey('photoURL')) {
            String imageUrl = userData['photoURL'];
            return CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            );
          } else {
            return CircleAvatar(
              radius: 20,
              child: Icon(
                Icons.person,
                color: Color(0xFF306B74),
                size: 40,
              ),
            );
          }
        } else {
          return CircleAvatar(
            radius: 20,
            child: Icon(
              Icons.person,
              color: Color(0xFF306B74),
              size: 40,
            ),
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
                  ? FutureBuilder<Map<String, dynamic>>(
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
                          var uid = currentUser.uid;
                          print("Username: $username");
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildProfileImage(uid),
                              SizedBox(width: 16),
                              Column(
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
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
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
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserProfileData(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  var isDriver = snapshot.data!['isDriver'] ?? false;
                  if (!isDriver) {
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Find a ride'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FindRidesPage()),
                        );
                      },
                    );
                  }
                }
                return SizedBox();
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserProfileData(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  var isDriver = snapshot.data!['isPassenger'] ?? false;
                  if (!isDriver) {
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Offer a Ride'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FindRidesPage()),
                        );
                      },
                    );
                  }
                }
                return SizedBox();
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserProfileData(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  var isDriver = snapshot.data!['isPassenger'] ?? false;
                  if (!isDriver) {
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('My rides '),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyRides()),
                        );
                      },
                    );
                  }
                }
                return SizedBox();
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserProfileData(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  var isDriver = snapshot.data!['isDriver'] ?? false;
                  if (!isDriver) {
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('My Rides'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerRideDetails(
                              from: 'Nador, Maroc',
                              to: 'Fès, Maroc',
                              departureDate: '06-04-2023',
                              vehicleType: 'Dacia logan 256',
                              pricePerPerson: '100 MAD',
                              availableSeats: 3,
                              onRideCanceled: _handleRideCanceled,
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                return SizedBox();
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
