import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ytalk/pages/chat_contacts.dart';
import 'package:ytalk/pages/contacts.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> bottomNames = ['Chats', 'Calls', 'Maps', 'Contacts'];
  var pageController = PageController(initialPage: 0);
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox.fromSize(
        size: Size.fromHeight(Get.height * 0.08),
        child: BottomAppBar(
          child: Row(
            children: List.generate(4, (index) => _bottomMenu(index)),
          ),
        ),
      ),
      body: PageView(
        controller: pageController,
        children: [
          ChatContacts(),
          Container(
            child: Center(
              child: Text(bottomNames[selected]),
            ),
          ),
          Container(
            child: Center(
              child: Text(bottomNames[selected]),
            ),
          ),
          MyContacts()
        ],
      ),
    );
  }

  _bottomMenu(int index) {
    return Expanded(
      child: MaterialButton(
        onPressed: () {
          setState(() {
            selected = index;
          });
          pageController.animateToPage(index,
              duration: Duration(milliseconds: 200),
              curve: Curves.linearToEaseOut);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                index == 0
                    ? Icons.sms
                    : index == 1
                        ? Icons.call
                        : index == 2 ? Icons.map : Icons.contacts,
                size: 20,
              ),
            ),
            Text(
              bottomNames[index],
              style: GoogleFonts.arvo(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
