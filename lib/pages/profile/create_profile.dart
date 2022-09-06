import 'package:awesome_number_picker/awesome_number_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  late int _ageController = 20;

  Map<String, dynamic>? _userDetails;
  Future<void> _getUserDetails() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      setState(() {
        _userDetails = value.data();
      });
    });
  }

  void newProfile({String fName = "", String lName = "", int age = 0}) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'first_name': fName, 'last_name': lName, 'age': age});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Hello, There",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )),
            SizedBox(height: 30),
            //e-mail
            SizedBox(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(12)),
                      hintText: _userDetails?['first_name'] == null
                          ? 'Enter First Name'
                          : _userDetails!['first_name'],
                      fillColor: Colors.white,
                      filled: true),
                ),
              ),
            ),
            //password
            SizedBox(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(12)),
                      hintText: _userDetails?['last_name'] == null
                          ? 'Enter Last Name'
                          : _userDetails!['last_name'],
                      fillColor: Colors.white,
                      filled: true),
                ),
              ),
            ),
            //confirm-password
            SizedBox(
                child: Text(
              "Age",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            )),
            SizedBox(
                height: 100,
                width: 300,
                child: IntegerNumberPicker(
                  axis: Axis.horizontal,
                  initialValue:
                      _userDetails?['age'] == null ? 20 : _userDetails!['age'],
                  //_userDetails?['age'] == null ? 20 : _userDetails?['age'],
                  minValue: 1,
                  maxValue: 100,
                  onChanged: (val) => {
                    setState(() {
                      _ageController = val;
                    })
                  },
                  pickedItemTextStyle: TextStyle(color: Colors.deepPurple),
                  otherItemsDecoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.1),
                        blurRadius: 20.0, // soften the shadow
                        spreadRadius: 0.0, //extend the shadow
                      )
                    ],
                  ),
                  pickedItemDecoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(.5),
                        blurRadius: 20.0, // soften the shadow
                        spreadRadius: 0.0, //extend the shadow
                      )
                    ],
                  ),
                )),

            SizedBox(height: 10),
            //sign-in
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    newProfile(
                        fName: _firstNameController.text.trim() == ''
                            ? _userDetails!['first_name']
                            : _firstNameController.text.trim(),
                        lName: _lastNameController.text.trim() == ''
                            ? _userDetails!['last_name']
                            : _lastNameController.text.trim(),
                        age: _ageController);
                    var snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Let\'s Go',
                        message: 'Profile successfully added',
                        contentType: ContentType.success,
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(20),
                    elevation: 0,
                    primary: Colors.indigo,
                  ),
                  child: Text('Proceed'),
                ),
              ),
            ),
          ],
        ),
      ))),
    );
  }
}
