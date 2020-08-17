import 'dart:async';

import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ytalk/auth/sign_up.dart';
import 'package:ytalk/models/user_model.dart';
import 'package:ytalk/pages/chat_contacts.dart';
import 'package:ytalk/pages/dashboard.dart';
import 'package:ytalk/splash/permission_handler.dart';
import 'package:ytalk/utils/app_routes.dart';
import 'package:ytalk/utils/contact_list_public.dart';
import 'package:ytalk/utils/images.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<String> images = [hahaha, tuRehnyDy, teraKaam];
  int next = 0;
  random() {
    var rng = new Random();
    for (var i = 0; i < 2; i++) {
      setState(() {
        next = rng.nextInt(3);
      });
      print(next);
    }
  }

  moveToNext() {
    return Timer(Duration(seconds: 0), () async {
      getAllContacts().then((value) {
        navigatePage();
      });
    });
  }

  void navigatePage() {
    FirebaseAuth.instance.currentUser().then((val) {
//      print('${val.phoneNumber.replaceAll("+92", "0")}');
      if (val != null) {
        Firestore.instance
            .collection('Users')
            .document(val.phoneNumber.replaceAll("+92", "0"))
            .get()
            .then((d) {
          if (d.data != null) {
            User.userData.fcmToken = d.data['fcm_token'];
            User.userData.lat = d.data['lat'];
            User.userData.lng = d.data['long'];
            User.userData.phoneNo = d.data['phone_number'];
            User.userData.imageUrl = d.data['image_url'];
            User.userData.status = d.data['status'];
            User.userData.lastActive = d.data['last_active'];
          } else {
            AppRoutes.makeFirst(context, SignUp());
          }
        }).then((g) {
          AppRoutes.makeFirst(context, Dashboard());
        }).catchError((e) {
          print(e.toString());
          AppRoutes.replace(context, SignUp());
        });
      } else {
        AppRoutes.replace(context, SignUp());
      }
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    random();
    moveToNext();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircleAvatar(
            radius: 150,
            backgroundImage: AssetImage(
              images[next],
            ),
          ),
        ),
      ),
    );
  }
}
