import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yalah/Pages/findRides.dart';
import 'package:yalah/Pages/offerRides.dart';
import 'package:yalah/Pages/welcome.dart'; // Import your pages

class WrapperPage extends StatelessWidget {
  const WrapperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User logged in
          if (snapshot.hasData) {
            // Retrieve user data from Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // Still loading user data
                  return CircularProgressIndicator();
                } else if (userSnapshot.hasError) {
                  // Error fetching user data
                  return Text('Error: ${userSnapshot.error}');
                } else {
                  // User data loaded successfully
                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  // Check if user is a driver or passenger based on some indication in user data
                  bool isDriver = userData['isDriver'] ?? false;

                  // Navigate user based on their role
                  if (isDriver) {
                    // User is a driver, navigate to OfferRidesPage
                    return OfferRidesPage();
                  } else {
                    // User is a passenger, navigate to FindRidesPage
                    return FindRidesPage();
                  }
                }
              },
            );
          }
          // User not logged in
          else {
            return const IntroductionAnimationScreen();
          }
        },
      ),
    );
  }
}
