import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ytalk/models/user_model.dart';
import 'package:get/get.dart';
import 'package:ytalk/pages/chat_contacts.dart';
import 'package:ytalk/pages/dashboard.dart';
import 'package:ytalk/utils/app_routes.dart';
import 'package:ytalk/utils/commons.dart';
import 'package:ytalk/utils/count_down.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _numberCont = TextEditingController();
  TextEditingController _otpCont = TextEditingController();
  String _verificationId = '';
  String _message = '';
  String phoneNumber = '';
  var _auth = FirebaseAuth.instance;
  var _db = Firestore.instance;
  bool isLoading = false;

  int page = 0; //0 for enter phone and 1 for verifying otp;
  Timer _timer;
  int _start = 60;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    //startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (page == 1) {
          setState(() {
            if (page == 1) page = 0;
          });
          return false;
        } else {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Enter Your phone number",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w400),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Get.height * 0.02, horizontal: Get.width * 0.05),
          child: Column(
            children: [
              SizedBox(
                height: Get.height * 0.05,
              ),
              Text(
                'YTALK will send an SMS message to verify your phone number',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: page == 1
                    ? PinCodeTextField(
                        length: 6,
                        obsecureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          //activeFillColor: Colors.white,
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        // backgroundColor: Colors.blue.shade50,
                        // enableActiveFill: true,
                        // errorAnimationController: errorController,
                        controller: _otpCont,
                        onCompleted: (v) {
                          _signInWithPhoneNumber();
                        },
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            //  currentText = value;
                          });
                        },
                        beforeTextPaste: (text) {
                          print("Allowing to paste $text");
                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                          return true;
                        },
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '+92',
                                hintStyle: TextStyle(color: Colors.black87),
                              ),
                              enabled: false,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10)
                              ],
                              keyboardType: TextInputType.phone,
                              controller: _numberCont,
                              onChanged: (val) {
                                setState(() {
                                  phoneNumber = '+92$val';
                                });
                              },
                            ),
                          )
                        ],
                      ),
              ),
//              page == 1
//                  ? _start == 1
//                      ? Container(height: 300, child: CountDownTimer())
//                      : OutlineButton(
//                          onPressed: () {},
//                          child: Row(
//                            children: [Icon(Icons.update), Text('Resend')],
//                          ),
//                        )
//                  : Container()
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: Get.height * 0.08,
          child: OutlineButton(
            child: Center(
              child: Text(page == 0 ? 'Send' : "Verify"),
            ),
            onPressed: page == 0
                ? () {
                    if (_numberCont.text.length < 10) {
                      ShowMessage.toast('O bsdk sahi number daal');
                    } else {
                      _verifyPhoneNumber();
                    }
//                    setState(() {
//                      page = 1;
//                    });
                  }
                : () {
                    _signInWithPhoneNumber();
                  },
          ),
        ),
      ),
    );
  }

  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
//      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        page = 1;
        _message = 'Received phone auth credential: $phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      Get.snackbar(
          'Success', 'Please check your phone for the verification code',
          colorText: Colors.white, backgroundColor: Colors.red);
      setState(() {});
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await FirebaseAuth.instance
        .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            timeout: const Duration(seconds: 60),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .then((value) {
      print("Done");
    });
  }

  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _otpCont.text,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    setState(() {
      isLoading = true;
    });

    await _db
        .collection('Users')
        .document(user.phoneNumber.replaceAll('+92', "0"))
        .get()
        .then((value) {
      if (value.data == null) {
        _db.runTransaction((transaction) => transaction.set(
                _db
                    .collection('Users')
                    .document(user.phoneNumber.replaceAll('+92', "0")),
                {
                  'created_at': Timestamp.now(),
                  'fcm': User.userData.fcmToken,
                  'image_url': '',
                  'lat': User.userData.lat,
                  'lng': User.userData.lng,
                  'status': 1,
                  'phone_number': phoneNumber.replaceAll('+92', "0"),
                }).then((value) {
              getDataFromDb(user.phoneNumber.replaceAll('+92', "0"));
            }));
      } else {
        getDataFromDb(phoneNumber.replaceAll('+92', "0"));
        //AppRoutes.makeFirst(context, Dashboard());
      }
    });
  }

  getDataFromDb(String phoneNum) {
    _db.collection('Users').document(phoneNum).get().then((d) {
      User.userData.phoneNo = d.data['phone_number'];
      User.userData.imageUrl = d.data['image_url'];
    }).then((value) {
      // Get.snackbar('Verification Successful', 'Please complete your profile');
      AppRoutes.makeFirst(context, Dashboard());
    });
  }
}
