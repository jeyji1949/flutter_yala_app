import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalah/theme/theme_model.dart';

class codeVerification extends StatefulWidget {
  @override
  State<codeVerification> createState() => _codeVerification();
}

class _codeVerification extends State<codeVerification> {
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
      e164Key: "");
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff6369D1),
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
          body: SafeArea(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.shade50,
                    ),
                    child: Image.asset('Assets\images\otp.jpg'),
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
                  TextFormField(
                    cursorColor: Colors.blue,
                    controller: phoneController,
                    decoration: InputDecoration(
                        hintText: "Enter phone number",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              showCountryPicker(
                                  context: context,
                                  countryListTheme: const CountryListThemeData(
                                    bottomSheetHeight: 500,
                                  ),
                                  onSelect: (Value) {
                                    setState(() {
                                      country = Value;
                                    });
                                  });
                            },
                            child: Text(
                              "${country.flagEmoji}" + "${country.phoneCode}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 14),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          )));
    });
  }
}
