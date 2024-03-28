import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("error");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("error");
    }
    return null;
  }

  //Googlr sign In
 signInWithGoogle() async {
    try {
      // Commencer le processus d'authentification avec Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtenir les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Créer une nouvelle référence d'authentification pour l'utilisateur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter à Firebase avec les informations d'authentification Google
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Récupérer les données de l'utilisateur Google
      final User? user = userCredential.user;
      final String email = googleUser.email;
      final String? displayName = googleUser.displayName;
      final String? photoUrl = googleUser.photoUrl;

      

      // Enregistrer les informations dans Firestore
      await FirebaseFirestore.instance
          .collection("usersGoogle")
          .doc(user!.uid)
          .set({
        'user': user.uid,
        'email': email,
        'name': displayName ?? "",
        'photoUrl': photoUrl ?? "",
        'createAt': DateTime.now(),
      });

      // Retourner l'utilisateur connecté
      return user;
    } catch (error) {
      print("Erreur lors de la connexion avec Google: $error");
      return null;
    }
  }

  //phone number sign in
  void verifyPhoneNumber() async {
    final TextEditingController _phoneNumberController =
        TextEditingController();
    String phoneNumber = _phoneNumberController.text.trim();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print('Phone verification failed: $e');
      },
      codeSent: (String verificationId, int? resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
