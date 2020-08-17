import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ytalk/models/user_model.dart';
import 'package:ytalk/pages/chat_screen.dart';
import 'package:ytalk/utils/colors.dart';
import 'package:ytalk/utils/commons.dart';
import 'package:ytalk/utils/loader.dart';
import 'package:ytalk/utils/network_avatar.dart';

class ChatContacts extends StatefulWidget {
  static final String path = "lib/src/pages/misc/ChatContacts.dart";

  @override
  _ChatContactsState createState() => _ChatContactsState();
}

class _ChatContactsState extends State<ChatContacts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF363846),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
            child: Text(
              'Chats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
//          Padding(
//            padding: const EdgeInsets.all(20.0),
//            child: Container(
//              decoration: BoxDecoration(
//                color: Color(0xFF414350),
//                borderRadius: BorderRadius.circular(5.0),
//                boxShadow: [
//                  BoxShadow(
//                    color: Colors.black54,
//                    offset: Offset(0.0, 1.5),
//                    blurRadius: 1.0,
//                    spreadRadius: -1.0,
//                  ),
//                ],
//              ),
//              child: SingleChildScrollView(
//                scrollDirection: Axis.horizontal,
//                physics: const BouncingScrollPhysics(),
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Row(
//                      children: List.generate(10, (index) {
//                    return OnlinePersonAction(
//                      personImagePath: "",
//                      actColor: Colors.greenAccent,
//                    );
//                  })),
//                ),
//              ),
//            ),
//          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            child: Text(
              'NewsFeed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Search your friends...',
                  hintStyle: TextStyle(
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: Color(0xFF414350),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  border: InputBorder.none),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: StreamBuilder(
                    stream:
                        Firestore.instance.collection("ChatRooms").snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return SpinKitFadingCircle(
                          color: themeColor,
                        );
                      } else if (snapshot.data.documents.length == 0) {
                        return Center(
                          child: Text("Start a new conversation"),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              snapshot.data.documents.length, (index) {
                            DocumentSnapshot doc =
                                snapshot.data.documents[index];
                            List<dynamic> users = doc.data['users'].toList();

                            bool isMyChat = false;
                            users.forEach((element) {
                              if (element == User.userData.phoneNo) {
                                isMyChat = true;
                              }
                            });
                            if (!isMyChat) {
                              return Container();
                            } else {
                              return Material(
                                color: Colors.transparent,
                                child: _chatContact(doc),
                              );
                            }
                          }),
                        );
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatContact(DocumentSnapshot doc) {
    return InkWell(
      onTap: () {
        GetNav.to(ChatScreen(
          roomId: doc.documentID,
        ));
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF565973), width: 1.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 6.0, 16.0, 6.0),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  child: NetworkAvatar(
                    imageUrl: doc.data['image_url'] ?? "",
                    radius: 25,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          doc.data['phone_number'] ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(width: 6.0),
                        Text(
                          'time',
                          style: TextStyle(
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'message',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
//            Row(
//              children: <Widget>[
//                Container(
//                  width: 42.0,
//                  height: 42.0,
//                  decoration: BoxDecoration(
//                    color: Color(0xFF414350),
//                    borderRadius: BorderRadius.circular(50.0),
//                  ),
//                  child: IconButton(
//                    color: Color(0xFF5791FB),
//                    icon: Icon(Icons.call),
//                    onPressed: () {},
//                  ),
//                ),
//                SizedBox(width: 10.0),
//                Container(
//                  width: 42.0,
//                  height: 42.0,
//                  decoration: BoxDecoration(
//                    color: Color(0xFF414350),
//                    borderRadius: BorderRadius.circular(50.0),
//                  ),
//                  child: IconButton(
//                    color: Color(0xFF5791FB),
//                    icon: Icon(Icons.videocam),
//                    onPressed: () {},
//                  ),
//                ),
//              ],
//            ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnlinePersonAction extends StatelessWidget {
  final String personImagePath;
  final Color actColor;
  const OnlinePersonAction({
    Key key,
    this.personImagePath,
    this.actColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            padding: const EdgeInsets.all(3.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                width: 2.0,
                color: const Color(0xFF558AED),
              ),
            ),
            child: Container(
              width: 54.0,
              height: 54.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                image: DecorationImage(
                    image: NetworkImage(personImagePath), fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10.0,
          right: 10.0,
          child: Container(
            width: 10.0,
            height: 10.0,
            decoration: BoxDecoration(
              color: actColor,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                width: 1.0,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Friend {
  String name, image, message, msgTime;

  Friend(this.name, this.image, this.message, this.msgTime);
}

final List<Friend> friends = [
  Friend('John', "", 'Hello, how are you?', '1 hr.'),
  Friend('RIna', "", 'Hello, how are you?', '1 hr.'),
  Friend('Brad', "", 'Hello, how are you?', '1 hr.'),
  Friend('Don', "", 'Hello, how are you?', '1 hr.'),
  Friend('Mukambo', "", 'Hello, how are you?', '1 hr.'),
  Friend('Sid', "", 'Hello, how are you?', '1 hr.'),
];
