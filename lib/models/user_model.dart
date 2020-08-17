import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  // singleton
  static final User _singleton = User._internal();
  factory User() => _singleton;
  User._internal();

  static User get userData => _singleton;
  FirebaseUser user;
  Timestamp createdAt;
  Timestamp lastActive;
  String email = '';
  String fcmToken = '';
  double lat = 0.0;
  double lng = 0.0;
  String phoneNo = '';
  String imageUrl = '';
  int status = 1;
}
