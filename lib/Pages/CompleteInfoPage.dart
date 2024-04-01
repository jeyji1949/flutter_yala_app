import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yalah/Pages/FindRides.dart';
import 'package:yalah/theme/theme_model.dart';

class UserProfil extends StatefulWidget {
  @override
  _UserProfilState createState() => _UserProfilState();
}

class _UserProfilState extends State<UserProfil> {
  File? _imageFile;
  final picker = ImagePicker();
  final TextEditingController adressController = TextEditingController();
  final TextEditingController IDController = TextEditingController();
  final TextEditingController vehiculeController = TextEditingController();
  bool isPassengerSelected = false;
  bool isDriverSelected = false;

  void _showErrorDialog(String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      desc: errorMessage,
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _getImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Choose an option"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Text("Pick from gallery"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: Text("Capture from camera"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload image to Firebase storage
      if (_imageFile != null) {
        final storage = FirebaseStorage.instance;
        final String uid =
            FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
        final Reference storageRef =
            storage.ref().child('user_profile_images/$uid/${DateTime.now()}');
        await storageRef.putFile(_imageFile!);
        String imageUrl = await storageRef.getDownloadURL();
        // You can save the imageUrl to Firestore or use it as needed
        print('Image uploaded to Firebase storage: $imageUrl');
      }
    }
  }

  Future<void> _uploadUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get values from text controllers
    String city = adressController.text;
    String cin = IDController.text;
    bool isPassenger = isPassengerSelected;
    bool isDriver = isDriverSelected;
    String vehicleType = vehiculeController.text;

    // Validate CIN format and check checkbox selection
    if (validateCIN(cin) && (isPassengerSelected || isDriverSelected)) {
      // CIN is valid and at least one checkbox is selected, proceed with further actions

      try {
        // Get download URL of the uploaded image from Firebase Storage
        String photoURL = '';
        if (_imageFile != null) {
          final storage = FirebaseStorage.instance;
          final String uid =
              FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
          final Reference storageRef =
              storage.ref().child('user_profile_images/$uid/${DateTime.now()}');
          await storageRef.putFile(_imageFile!);
          photoURL = await storageRef.getDownloadURL();
        }

        // Update the user information in Firestore including photo URL
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'city': city,
          'cin': cin,
          'isPassenger': isPassenger,
          'isDriver': isDriver,
          'vehicleType': vehicleType,
          'photoURL': photoURL, // Include photo URL in the document update
        });

        // Navigate to the main screen after successful upload
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FindRidesPage()),
        );
      } catch (e) {
        // Handle any errors that occur during Firestore update
        print('Error uploading user info: $e');
        _showErrorDialog('An error occurred while uploading user information.');
      }
    } else if (!validateCIN(cin)) {
      _showErrorDialog('Invalid CIN format');
    } else if (!isPassengerSelected && !isDriverSelected) {
      _showErrorDialog('Please select one option (Passenger or Driver).');
    } else if (city.isEmpty || cin.isEmpty) {
      _showErrorDialog('All fields must be fill in');
    }
  }

  bool validateCIN(String cin) {
    // Regular expression for CIN validation
    RegExp regex = RegExp(r'^[A-Z]{1,2}\d{6}$');

    // Check if the CIN matches the regular expression
    return regex.hasMatch(cin);
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
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Let's Complete your registration by \nadding some additional Info ",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        _getImage();
                      },
                      child: _imageFile != null
                          ? CircleAvatar(
                              radius: 65,
                              backgroundImage: FileImage(_imageFile!),
                            )
                          : CircleAvatar(
                              radius: 65,
                              child: Icon(Icons.camera_enhance),
                              backgroundColor: Colors.amber,
                            ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: TextField(
                        controller: adressController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "City",
                          prefixIcon: Icon(Icons.location_city_sharp),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: TextField(
                        controller: IDController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "CIN",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Row(
                        children: [
                          Checkbox(
                            value: isPassengerSelected,
                            onChanged: (value) {
                              setState(() {
                                isPassengerSelected = value!;
                                if (value == true) {
                                  isDriverSelected =
                                      false; // Réinitialiser l'état de l'autre case
                                }
                              });
                            },
                            shape: const CircleBorder(),
                            activeColor: Colors.orange,
                          ),
                          Text("I am passenger"),
                          Checkbox(
                            value: isDriverSelected,
                            onChanged: (value) {
                              setState(() {
                                isDriverSelected = value!;
                                if (value == true) {
                                  isPassengerSelected = false;
                                }
                              });
                            },
                            shape: const CircleBorder(),
                            activeColor: Colors.orange,
                          ),
                          Text("I am driver"),
                        ],
                      ),
                    ),
                    if (isDriverSelected) ...[
                      SizedBox(height: 16.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: TextField(
                          controller: vehiculeController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Vehicule type , Ex: Dacia Sandero 4856",
                            prefixIcon: Icon(Icons.car_rental),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 20,
                    ),
                    Column(children: [
                      MaterialButton(
                        onPressed: () {
                          _uploadUserInfo();
                        },
                        elevation: 10,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        color: const Color(0xff6369D1),
                        child: const Center(
                            child: Text("Submit",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ])
                  ],
                ),
              ),
            ),
          ));
    });
  }
}
