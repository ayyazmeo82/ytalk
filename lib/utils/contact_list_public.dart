import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytalk/models/user_model.dart';

List<Contact> _contacts = [];
List<MyContactsList> _myContacts = [];

Future<bool> getAllContacts() async {
  PermissionStatus permissionStatus = await _getContactPermission();
  if (permissionStatus == PermissionStatus.granted) {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    User.userData.lat = position.latitude;
    User.userData.lng = position.longitude;
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    _contacts = (await ContactsService.getContacts()).toList();

    _contacts.forEach((contact) {
      var number = contact.phones.elementAt(0) == null
          ? ""
          : contact.phones
              ?.elementAt(0)
              ?.value
              ?.toString()
              .replaceAll('+92', '');
      print(contact.displayName);
      MyContactsList c = MyContactsList(
          name: contact.displayName, avatar: contact.avatar, number: number);
      _myContacts.add(c);

      Color baseColor = colors[colorIndex];
      //contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
  } else {
//   / _getContactPermission(permissionStatus);
  }
  return true;
}

Future<PermissionStatus> _getContactPermission() async {
  PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.restricted) {
    Map<PermissionGroup, PermissionStatus> permissionStatus =
        await PermissionHandler().requestPermissions([
      PermissionGroup.contacts,
      PermissionGroup.location,
      PermissionGroup.photos
    ]);
    return permissionStatus[PermissionGroup.contacts] ??
        PermissionStatus.unknown;
  } else {
    return permission;
  }
}

class MyContactsList {
  String name;
  String number;
  Uint8List avatar;

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'number': this.number,
      'avatar': this.avatar,
    };
  }

  factory MyContactsList.fromMap(Map<String, dynamic> map) {
    return new MyContactsList(
      name: map['name'] as String,
      number: map['number'] as String,
      avatar: map['avatar'] as Uint8List,
    );
  }

  MyContactsList({this.name, this.number, this.avatar});
}
