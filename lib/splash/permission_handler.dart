//import 'package:flutter/cupertino.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:ytalk/auth/sign_up.dart';
//import 'package:ytalk/utils/app_routes.dart';
//
//class MyPermissions {
//  getPermissions(BuildContext context) async {
//    Permission permission;
//    askPermissionNow(Permission.contacts).then((value) {
//      if (value.isGranted) {
//        askPermissionNow(Permission.location).then((value) {
//          if (value.isGranted) {
//            askPermissionNow(Permission.photos).then((value) {
//              AppRoutes.makeFirst(context, SignUp());
//            });
//          } else {
//            askPermissionNow(Permission.location);
//          }
//        });
//      } else {
//        askPermissionNow(Permission.contacts);
//      }
//    });
//  }
//
//  Future<PermissionStatus> askPermissionNow(Permission permit) async {
//    PermissionStatus status;
//    if (await permit.isUndetermined ||
//        await permit.isDenied ||
//        await permit.isRestricted) {
//      status = await permit.request();
//    }
//    return status;
//  }
//}
