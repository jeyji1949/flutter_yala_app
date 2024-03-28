import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/OTP.dart';
import 'package:yalah/theme/theme_model.dart';

class PhoneVerification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Consumer<ThemeModel>(
      builder: (context, ThemeModel themeNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xffff5a5f),
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
              ),
            ],
          ),
          body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Ensure keyboard is dismissed when tapping outside of text fields
                FocusScope.of(context).unfocus();
              },
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Image.asset('Assets/images/otp.png'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Few steps To verify your account",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: size.width * 0.1),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add your phone number. We'll send a verification code",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              obscureText: false,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              cursorColor: Color(0xffff5a5f),
                              controller: phoneController,
                              inputFormatters: [phoneMaskFormatter],
                              decoration: InputDecoration(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        MaterialButton(
                          onPressed: () {
                            sendCode();
                          },
                          elevation: 0,
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: const Color(0xff087e8b),
                          child: SizedBox(
                            width: 100,
                            child: const Center(
                              child: Text(
                                "Send code",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }

  sendCode() async {
    if (!isValidPhoneNumber(phoneController.text)) {
      Get.snackbar('Error', 'Please enter a valid phone number.');
      return;
    }
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          print('completed');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Otp(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.code);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}

bool isValidPhoneNumber(String phoneNumber) {
  // Regular expression to match E.164 phone number format
  RegExp regExp = RegExp(r'^\+[1-9]\d{1,14}$');
  return regExp.hasMatch(phoneNumber);
}
