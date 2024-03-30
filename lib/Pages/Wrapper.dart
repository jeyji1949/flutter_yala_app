import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yalah/Pages/FindRides.dart';
import 'package:yalah/Pages/welcome.dart';

class WrapperPage extends StatelessWidget {
  const WrapperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //user logged in
        if (snapshot.hasData) {
          return  FindRidesPage();
        }
        // user not logged in
        else {
          return const IntroductionAnimationScreen();
        }
      },
    ));
  }
}
