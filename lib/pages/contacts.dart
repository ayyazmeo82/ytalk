import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ytalk/models/user_model.dart';
import 'package:ytalk/pages/chat_screen.dart';
import 'package:ytalk/utils/colors.dart';
import 'package:ytalk/utils/commons.dart';
import 'package:ytalk/utils/loader.dart';

class MyContacts extends StatefulWidget {
  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  List<Contact> contacts;
  List<Contact> contactsFiltered = [];
  bool isLoading = true;

  var _db = Firestore.instance;
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();
  List<String> yTalkNumbers = [];
  allYTalkContacts() {
    Firestore.instance.collection('Users').getDocuments().then((docs) {
      docs.documents.forEach((element) {
        setState(() {
          yTalkNumbers.add(element.data['phone_number'].toString());
        });
      });
    });
  }

  isNumberRegistered(String phoneNumber) {
    bool isYTalk = false;
    yTalkNumbers.forEach((element) async {
      isYTalk = element.replaceAll("+92", "0").toString() == phoneNumber;
      print(isYTalk);
    });
    return isYTalk;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    allYTalkContacts();
//    refreshContacts();
    getAllContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });

      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }

  getAllContacts() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
      int colorIndex = 0;
      List<Contact> _contacts = (await ContactsService.getContacts()).toList();
      _contacts.forEach((contact) {
        Color baseColor = colors[colorIndex];
        contactsColorMap[contact.displayName] = baseColor;
        colorIndex++;
        if (colorIndex == colors.length) {
          colorIndex = 0;
        }
      });
      setState(() {
        contacts = _contacts;
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  updateContact() async {
    Contact ninja = contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    getAllContacts();
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.restricted) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: themeColor,
          title: Row(
            children: <Widget>[
              InkWell(
                  child: Container(
                      margin: EdgeInsets.only(right: 7),
                      height: 30,
                      // width: 30,
                      child: Icon(Icons.arrow_back_ios,
                          size: MediaQuery.of(context).size.height * 0.024)),
                  onTap: () {}),
              Text("Contacts", style: GoogleFonts.arvo(fontSize: 14))
            ],
          ),
          bottom: TabBar(
            tabs: <Widget>[
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                child: Text("YTALK Contacts",
                    style: GoogleFonts.arvo(fontSize: 14)),
              ),
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                child: Text(
                  "All Contacts",
                  style: GoogleFonts.arvo(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
//      floatingActionButton: FloatingActionButton(
//        backgroundColor: themeBlack,
//        child: Icon(Icons.add),
//        onPressed: () {
//          Navigator.of(context).pushNamed("/add").then((_) {
//            refreshContacts();
//          });
//        },
//      ),

        body: TabBarView(
          children: <Widget>[
            _yTalkContacts(isSearching),
            _phoneContacts(isSearching),
          ],
        ),
      ),
    );
  }

  Widget _phoneContacts(bool isSearching) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
                isDense: true,
                hintText: 'Search',
                border: new OutlineInputBorder(
                    borderSide:
                        new BorderSide(color: Theme.of(context).primaryColor)),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).primaryColor)),
          ),
        ),
        contacts != null
            ? Expanded(
                child: ListView.builder(
                  itemCount: isSearching == true
                      ? contactsFiltered.length
                      : contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Contact c = contacts?.elementAt(index);
                    Contact c = isSearching == true
                        ? contactsFiltered.elementAt(index)
                        : contacts.elementAt(index);
                    if (c.phones.length != 0) {
                      return ListTile(
                        onTap: () {
//                          Navigator.pop(context, c);
                          // ShowMessage.toast();
                        },
                        leading: (c.avatar != null && c.avatar.length > 0)
                            ? CircleAvatar(
                                backgroundColor: themeColor,
                                backgroundImage: MemoryImage(c.avatar))
                            : CircleAvatar(
                                backgroundColor: themeColor,
                                child: Text(c.initials())),
                        title: Text(c.displayName ?? ""),
                      );
                    } else
                      return Container();
                  },
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }

  Widget _yTalkContacts(bool isSearching) {
    return Column(
      children: <Widget>[
        Container(
          height: Get.height * 0.01,
        ),
        contacts != null
            ? Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    Contact c = contacts.elementAt(index);
                    if (c.phones.length != 0) {
                      return /*isYTalk
                          ? Container()
                          :*/
                          isNumberRegistered(c.phones
                                  .elementAt(0)
                                  .value
                                  .replaceAll("+92", "0")
                                  .toString())
                              ? ListTile(
                                  onTap: () {
                                    _startOrCreateRoom(c.phones.first.value
                                        .toString()
                                        .replaceAll("+92", '0'));
                                  },
                                  leading:
                                      (c.avatar != null && c.avatar.length > 0)
                                          ? CircleAvatar(
                                              backgroundColor: themeColor,
                                              backgroundImage:
                                                  MemoryImage(c.avatar))
                                          : CircleAvatar(
                                              backgroundColor: themeColor,
                                              child: Text(c.initials())),
                                  title: Text(c.displayName ?? ""),
                                  trailing: Text(
                                    'YTalk',
                                    style: GoogleFonts.arvo(fontSize: 14),
                                  ),
                                )
                              : Container();
                    } else
                      return Container();
                  },
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }

  _startOrCreateRoom(String phoneNumber) {
    showDialog(context: context, builder: (context) => Loader());
    List users = [];
    List<String> createUsers = [User.userData.phoneNo, phoneNumber];
    var timeStamp = Timestamp.now().millisecondsSinceEpoch.toString();
    _db.collection('ChatRooms').getDocuments().then((value) {
      var docs = value.documents;
      for (int i = 0; i <= docs.length; i++) {
        if (docs[i].data['users'][0].toString() == User.userData.phoneNo &&
            docs[i].data['users'][1].toString() == phoneNumber) {
          Navigator.pop(context);
          GetNav.to(ChatScreen(
            roomId: docs[i].data['room_id'],
          ));
          break;
        } else {
          _db.collection('ChatRooms').document(timeStamp).setData({
            'created_at': Timestamp.now(),
            // 'created_by': User.userData.,
            'multi_chat': false,
            'room_id': timeStamp,
            'status': 0,
            'users': createUsers
          }).then((value) {
            Navigator.pop(context);
            GetNav.to(ChatScreen(
              roomId: timeStamp,
            ));
          });
          break;
        }
      }
    });
  }
}

class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact);

  final Contact _contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.share),
//            onPressed: () => shareVCFCard(context, contact: _contact),
//          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => ContactsService.deleteContact(_contact),
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UpdateContactsPage(
                  contact: _contact,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Name"),
              trailing: Text(_contact.givenName ?? ""),
            ),
            ListTile(
              title: Text("Middle name"),
              trailing: Text(_contact.middleName ?? ""),
            ),
            ListTile(
              title: Text("Family name"),
              trailing: Text(_contact.familyName ?? ""),
            ),
            ListTile(
              title: Text("Prefix"),
              trailing: Text(_contact.prefix ?? ""),
            ),
            ListTile(
              title: Text("Suffix"),
              trailing: Text(_contact.suffix ?? ""),
            ),
            ListTile(
              title: Text("Birthday"),
              trailing: Text(_contact.birthday != null
                  ? DateFormat('dd-MM-yyyy').format(_contact.birthday)
                  : ""),
            ),
            ListTile(
              title: Text("Company"),
              trailing: Text(_contact.company ?? ""),
            ),
            ListTile(
              title: Text("Job"),
              trailing: Text(_contact.jobTitle ?? ""),
            ),
            ListTile(
              title: Text("Account Type"),
              trailing: Text((_contact.androidAccountType != null)
                  ? _contact.androidAccountType.toString()
                  : ""),
            ),
            AddressesTile(_contact.postalAddresses),
            ItemsTile("Phones", _contact.phones.take(1)),
            ItemsTile("Emails", _contact.emails)
          ],
        ),
      ),
    );
  }
}

class AddressesTile extends StatelessWidget {
  AddressesTile(this._addresses);

  final Iterable<PostalAddress> _addresses;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text("Addresses")),
        Column(
          children: _addresses
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Street"),
                          trailing: Text(a.street ?? ""),
                        ),
                        ListTile(
                          title: Text("Postcode"),
                          trailing: Text(a.postcode ?? ""),
                        ),
                        ListTile(
                          title: Text("City"),
                          trailing: Text(a.city ?? ""),
                        ),
                        ListTile(
                          title: Text("Region"),
                          trailing: Text(a.region ?? ""),
                        ),
                        ListTile(
                          title: Text("Country"),
                          trailing: Text(a.country ?? ""),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AddContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  Contact contact = Contact();
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a contact"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _formKey.currentState.save();
              contact.postalAddresses = [address];
              ContactsService.addContact(contact);
              Navigator.of(context).pop();
            },
            child: Icon(Icons.save, color: Colors.white),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Middle name'),
                onSaved: (v) => contact.middleName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last name'),
                onSaved: (v) => contact.familyName = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prefix'),
                onSaved: (v) => contact.prefix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Suffix'),
                onSaved: (v) => contact.suffix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) =>
                    contact.phones = [Item(label: "mobile", value: v)],
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onSaved: (v) =>
                    contact.emails = [Item(label: "work", value: v)],
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company'),
                onSaved: (v) => contact.company = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Job'),
                onSaved: (v) => contact.jobTitle = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Street'),
                onSaved: (v) => address.street = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'City'),
                onSaved: (v) => address.city = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Region'),
                onSaved: (v) => address.region = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Postal code'),
                onSaved: (v) => address.postcode = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Country'),
                onSaved: (v) => address.country = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateContactsPage extends StatefulWidget {
  UpdateContactsPage({@required this.contact});

  final Contact contact;

  @override
  _UpdateContactsPageState createState() => _UpdateContactsPageState();
}

class _UpdateContactsPageState extends State<UpdateContactsPage> {
  Contact contact;
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Contact"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async {
              _formKey.currentState.save();
              contact.postalAddresses = [address];
              await ContactsService.updateContact(contact).then((_) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyContacts()));
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: contact.givenName ?? "",
                decoration: const InputDecoration(labelText: 'First name'),
                onSaved: (v) => contact.givenName = v,
              ),
              TextFormField(
                initialValue: contact.middleName ?? "",
                decoration: const InputDecoration(labelText: 'Middle name'),
                onSaved: (v) => contact.middleName = v,
              ),
              TextFormField(
                initialValue: contact.familyName ?? "",
                decoration: const InputDecoration(labelText: 'Last name'),
                onSaved: (v) => contact.familyName = v,
              ),
              TextFormField(
                initialValue: contact.prefix ?? "",
                decoration: const InputDecoration(labelText: 'Prefix'),
                onSaved: (v) => contact.prefix = v,
              ),
              TextFormField(
                initialValue: contact.suffix ?? "",
                decoration: const InputDecoration(labelText: 'Suffix'),
                onSaved: (v) => contact.suffix = v,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
                onSaved: (v) =>
                    contact.phones = [Item(label: "mobile", value: v)],
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                onSaved: (v) =>
                    contact.emails = [Item(label: "work", value: v)],
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                initialValue: contact.company ?? "",
                decoration: const InputDecoration(labelText: 'Company'),
                onSaved: (v) => contact.company = v,
              ),
              TextFormField(
                initialValue: contact.jobTitle ?? "",
                decoration: const InputDecoration(labelText: 'Job'),
                onSaved: (v) => contact.jobTitle = v,
              ),
              TextFormField(
                initialValue: address.street ?? "",
                decoration: const InputDecoration(labelText: 'Street'),
                onSaved: (v) => address.street = v,
              ),
              TextFormField(
                initialValue: address.city ?? "",
                decoration: const InputDecoration(labelText: 'City'),
                onSaved: (v) => address.city = v,
              ),
              TextFormField(
                initialValue: address.region ?? "",
                decoration: const InputDecoration(labelText: 'Region'),
                onSaved: (v) => address.region = v,
              ),
              TextFormField(
                initialValue: address.postcode ?? "",
                decoration: const InputDecoration(labelText: 'Postal code'),
                onSaved: (v) => address.postcode = v,
              ),
              TextFormField(
                initialValue: address.country ?? "",
                decoration: const InputDecoration(labelText: 'Country'),
                onSaved: (v) => address.country = v,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
