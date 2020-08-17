import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ShowMessage {
  static void toast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        fontSize: 16,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 5,
        gravity: ToastGravity.CENTER);
  }

  static void snackBar(String title, String message) {
    Get.snackbar(title, message,
        backgroundColor: Colors.orange, colorText: Colors.white);
  }
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

class GetNav {
  static void to(Widget page) {
    Get.to(page,
        transition: Transition.cupertino,
        duration: Duration(milliseconds: 400),
        opaque: true);
  }
}
