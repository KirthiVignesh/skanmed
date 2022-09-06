import 'package:flutter/cupertino.dart';
import 'package:skanmed/pages/profile/create_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserDetails();
  }

  // bool _availStatus = true;

  final user = FirebaseAuth.instance.currentUser!;
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

  // Future changeAvail() async {
  //   setState() {
  //     _availStatus = !_availStatus;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CreateProfile()));
        },
        child: Icon(FlutterRemix.pencil_line),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            FlutterRemix.arrow_left_line,
            color: Colors.black,
            size: 32,
          ),
        ),
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                icon: Icon(FlutterRemix.logout_box_r_line),
                onPressed: () {
                  CoolAlert.show(
                      context: context,
                      type: CoolAlertType.confirm,
                      onConfirmBtnTap: () {
                        FirebaseAuth.instance.signOut();
                        final GoogleSignIn googleSignIn = new GoogleSignIn();
                        googleSignIn.isSignedIn().then((s) {
                          googleSignIn.signOut();
                        });
                        Navigator.pop(context);
                      },
                      text: "Are you sure you want to log out");
                },
                color: Colors.black),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Text(
            _userDetails == null
                ? "Hi There"
                : "Hi ${_userDetails?['first_name']}",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //pfp
              Container(
                height: 100,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    FlutterRemix.account_circle_line,
                    size: 84,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  height: 540,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            _userDetails == null
                                ? "Enter your Details"
                                : '${_userDetails?['first_name']} ${_userDetails?['last_name']}',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(FlutterRemix.mail_fill, size: 20),
                          SizedBox(width: 5),
                          Text('${user.email}', style: TextStyle(fontSize: 16))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(FlutterRemix.phone_fill),
                          SizedBox(width: 5),
                          Text('${_userDetails?['number']}',
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(FlutterRemix.map_pin_2_fill),
                          SizedBox(width: 5),
                          Text('${_userDetails?['city']}',
                              style: TextStyle(fontSize: 16))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
