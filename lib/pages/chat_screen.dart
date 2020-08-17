import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ytalk/models/user_model.dart';
import 'package:ytalk/utils/colors.dart';
import 'package:ytalk/utils/full_photo_hero.dart';
import 'package:ytalk/utils/loader.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  ChatScreen({this.roomId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldState> _sellerscaffoldKey =
      new GlobalKey<ScaffoldState>();

  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  var listMessage;
  String roomId;

  bool isLoading;
  bool isShowSticker;
  String imageUrl;
// send message function
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection('Chats')
          .document(DateTime.now().millisecondsSinceEpoch.toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'created_at': Timestamp.now(),
            'message': content,
            'room_id': roomId,
            'sender': User.userData.phoneNo,
            'type': type // 1 for image, 0 for text message
          },
        );
        /*.then((value) {
          Firestore.instance
              .collection('ChatRoom')
              .document(roomId)
              .get()
              .then((value) {
            List<dynamic> users = value.data['users'].toList();
            users.forEach((element) {
              if (element != User.userData.email) {
//                GetFcm.getFcm(element).then((value) {
////                  InAppNotifications.sendNotification(
////                    'New Message',
////                    content,
////                    User.userData.email,
////                    element,
////                  );
//                  PushNotification.sendNotification(
//                      value, content, "New Message");
//                });
              }
            });
          });
        });*/
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

// upload Image
  File imageFile;
  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child('ChatMedia/$fileName');
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  @override
  void initState() {
    roomId = widget.roomId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _sellerscaffoldKey,
        // drawer: DrawerPage(context),
        appBar: AppBar(
          backgroundColor: Color(0xFF565973),
        ),
        //  drawer: HomeDrawer(),
        body: Column(
          children: <Widget>[buildListMessage(), buildInput()],
        ));
  }

  Widget buildInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, top: 5),
      color: Colors.white,
      //height: MediaQuery.of(context).size.height / 12,
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: Colors.grey,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.grey, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration(
                  //Add th Hint text here.
                  hintText: "Type a message a here...",
                  contentPadding: EdgeInsets.only(top: 5, left: 14),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(70)),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  onSendMessage(textEditingController.text, 0);
                },
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['sender'] == User.userData.phoneNo) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  padding:
                      EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
                  margin: EdgeInsets.only(top: 4, left: 80, bottom: 4),
                  width: 200.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(1),
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      gradient: LinearGradient(
                        colors: [
                          Color(index == 0 ? 0xffE47C79 : 0xffD04593),
                          Color(index == 0 ? 0xffD04593 : 0xffE14841)
                        ],
                      )),
                  child: Text(
                    document['message'],
                    maxLines: null,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset(
                            'images/placeholder.png',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: document['message'],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FullPhotoHero(url: document['message'])));
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
          // Sticker
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['type'] == 0
                    ? Container(
                        padding: EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 10),
                        margin: EdgeInsets.only(
                            top: 4, left: 5, bottom: 4, right: 50),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(1),
                                bottomRight: Radius.circular(8),
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                            gradient: LinearGradient(
                              colors: [
                                Color(index == 0 ? 0xffE47C79 : 0xffD04593),
                                Color(index == 0 ? 0xffD04593 : 0xffE14841)
                              ],
                            )),
                        child: Text(
                          document['message'],
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container(
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(50.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: document['message'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
//                            Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) =>
//                                        FullPhoto(url: document['message'])));
                          },
                          padding: EdgeInsets.all(0),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                      )
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd-MM, hh:mm a')
                          .format(document['created_at'].toDate()),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: roomId == ''
          ? Loader(
              color: themeColor,
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('Chats')
                  .orderBy('created_at', descending: true)
                  .where('room_id', isEqualTo: roomId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Loader(color: themeColor));
                } else if (snapshot.data.documents.isEmpty) {
                  return Center(
                    child: Text("Send your first message"),
                  );
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['msg_from'] == '') ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['msg_from'] != '') ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}
