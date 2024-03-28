import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yalah/Pages/CompleteInfoPage.dart';


class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    checkEmailVerification();
  }

  Future<void> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser; // Refresh user data
      setState(() {
        isEmailVerified = user!.emailVerified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      // If email is verified, navigate to login page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfil()));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A verification email has been sent to your email address.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Refresh email verification status
                checkEmailVerification();
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
