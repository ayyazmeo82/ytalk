import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class Loader extends StatelessWidget {
  final Color color;
  Loader({this.color = Colors.white});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SpinKitFadingCircle(
            color: color,
          ),
        ),
      ),
    );
  }
}
