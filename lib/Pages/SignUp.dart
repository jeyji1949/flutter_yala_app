import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/LogIn.dart';
import 'package:yalah/Pages/verifyEmail.dart';
import '../theme/theme_model.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Country country = Country(
    phoneCode: "212",
    countryCode: "MAR",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Morocco",
    example: "Morocco",
    displayName: "Morocco",
    displayNameNoCountryCode: "MAR",
    e164Key: "",
  );

  var phoneMaskFormatter = MaskTextInputFormatter(
    mask: '#########',
    filter: {"#": RegExp(r'[0-9]')},
  );

  void _showErrorDialog(String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      desc: errorMessage,
      btnOkOnPress: () {},
    ).show();
  }

  bool _validateEmail() {
    String email = _emailController.text.trim();
    return EmailValidator.validate(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 8;
  }

  void _registerUser() {
    var nom = _nameController.text.trim();
    var email = _emailController.text.trim();
    var password = _passwordController.text.trim();
    var confirmPassword = _confirmPasswordController.text.trim();
    var phoneNumber = phoneController.text.trim();

    if (nom.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      _showErrorDialog('Please fill in all fields !');
    } else if (!_validateEmail()) {
      _showErrorDialog('Email not valid !!');
    } else if (password != confirmPassword) {
      _showErrorDialog('Unmatched passwords');
    } else if (!_validatePassword(password)) {
      _showErrorDialog('Password must contain at least 8 characters');
    } else {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        String? userID = value.user?.uid;
        if (userID != null) {
          // Send email verification
          value.user?.sendEmailVerification().then((_) {
            // Save user data to Firestore
            FirebaseFirestore.instance.collection('users').doc(userID).set({
              'userID': userID,
              'nom': nom,
              'email': email,
              'password': password,
              'phone Number': phoneNumber,
              'createAt': DateTime.now(),
              'emailVerified': false, // Mark email as not verified initially
            }).then((_) {
              // Show success message or navigate to next screen
              _showErrorDialog(
                  "A verification link is sent to your mailbox please check it ");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmailVerificationScreen()),
              );
            }).catchError((error) {
              _showErrorDialog('Error saving user data: $error');
            });
          }).catchError((error) {
            _showErrorDialog('Error sending verification email: $error');
          });
        }
      }).catchError((error) {
        // Erreur lors de l'enregistrement
        print('Registration error: $error');
        _showErrorDialog('Already registred login with that email');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff60E1E0),
              elevation: 0,
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
            body: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Ensure keyboard is dismissed when tapping outside of text fields
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  width: size.width,
                  height: size.height,
                  padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: size.height * 0.02,
                      bottom: size.height * 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sign Up",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: size.width * 0.1),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            child: TextField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Full Name",
                              ),
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
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                              ),
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
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [phoneMaskFormatter],
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        countryListTheme:
                                            const CountryListThemeData(
                                          bottomSheetHeight: 500,
                                        ),
                                        onSelect: (Value) {
                                          setState(() {
                                            country = Value;
                                          });
                                        },
                                      );
                                    },
                                    child: Text(
                                      "${country.flagEmoji}"
                                      "+"
                                      "${country.phoneCode}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 22),
                                    ),
                                  ),
                                ),
                                suffixIcon: phoneController.text.length > 9
                                    ? Container(
                                        height: 30,
                                        width: 30,
                                        margin: const EdgeInsets.all(10.0),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                        child: const Icon(
                                          Icons.done,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    : null,
                              ),
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
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                              ),
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
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Confirm Password",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          MaterialButton(
                            onPressed: () {
                              _registerUser();
                            },
                            elevation: 10,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            color: const Color(0xff6369D1),
                            child: const Center(
                                child: Text("Sign Up",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account? ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage()));
                                      },
                                      child: Text(
                                        'Login',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ])),
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
}
