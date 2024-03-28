import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/AuthService.dart';
import 'package:yalah/Pages/SignUp.dart';
import 'package:yalah/Pages/FindRides.dart';

import '../theme/theme_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                themeNotifier.isDark ? "" : "",
                style: TextStyle(
                    color: themeNotifier.isDark
                        ? Colors.white
                        : Colors.grey.shade900),
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
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Container(
                  width: size.width,
                  height: size.height,
                  padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: size.height * 0.2,
                      top: size.height * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hello, \nWelcome Back",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: size.width * 0.1,
                            ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email or Phone number"),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                            ),
                            child: TextField(
                              obscureText: true,
                              controller: passwordController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: showResetPasswordDialog,
                                  child: Text(
                                    "Forgot Password ?",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          MaterialButton(
                            onPressed: () {
                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                showEmptyFieldDialog();
                              } else {
                                signInUser();
                              }
                            },
                            elevation: 0,
                            padding: const EdgeInsets.all(18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: const Color(0xff6369D1),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpPage()),
                                    );
                                  },
                                  child: Text(
                                    'Create account',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Continue with",
                                style: TextStyle(
                                  fontSize:
                                      16, // Adjust the font size as needed
                                ),
                              ),
                              GestureDetector(
                                onTap: () => AuthService().signInWithGoogle(),
                                child: const Image(
                                  width: 30,
                                  image:
                                      AssetImage('Assets/images/gooogle.png'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  void showEmailNotFoundDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      desc: 'This account does not exist. Please create one.',
      btnOkOnPress: () {},
    ).show();
  }

  void signInUser() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>const FindRidesPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('User not found');
        showEmailNotFoundDialog();
      } else if (e.code == 'wrong-password') {
        print('Wrong password');
        showWrongPasswordDialog();
      } else {
        // Handle other errors
        print('Error: ${e.message}');
        showGenericErrorDialog('Error: ${e.message}');
      }
    } catch (e) {
      // Handle other errors
      print('Error: $e');
      showGenericErrorDialog('Error: $e');
    }
  }

  void showGenericErrorDialog(String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      desc: 'Account not found',
      btnOkOnPress: () {},
    ).show();
  }

  void showWrongPasswordDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      desc: 'Incorrect password. Please try again.',
      btnOkOnPress: () {},
    ).show();
  }

  Future<bool> checkEmailExists(String email) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: email)
        .get();
    return query.docs.isNotEmpty;
  }

  void showEmptyFieldDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      desc: 'Please fill in all fields!',
      btnOkOnPress: () {
        print('Dialog closed with OK');
      },
    ).show();
  }

  void showResetPasswordDialog() {
    if (emailController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        desc: 'Please enter your e-mail!',
        btnOkOnPress: () {
          print('Dialog closed with OK');
        },
      ).show();
    } else {
      try {
        FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text,
        );
        showResetPasswordSuccessDialog();
      } catch (e) {
        print(e);
      }
    }
  }

  void showResetPasswordSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: '',
      desc: 'Please check your mailbox to retrieve your password!',
      btnOkOnPress: () {
        print('Dialog closed with OK');
      },
    ).show();
  }
}
