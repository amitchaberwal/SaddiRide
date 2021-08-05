import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:saddiridedriver/Pages/HomePage.dart';
import 'package:saddiridedriver/Pages/Login/SignUpA.dart';

import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneAuthVerify extends StatefulWidget {

  final String appName = "VC";
  final String phone;
  PhoneAuthVerify(this.phone);

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {
  String verificationId;
  String authStatus = "";
  String _code = "";
  ProgressDialog pr;

  String appSignature;
  String otpCode;

  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    verifyPhoneNumber(context);
    SmsAutoFill().listenForCode;
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    pr.style(
        message: 'Verifying...',
        borderRadius: 10.0,
        backgroundColor: Theme.of(context).primaryColor,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Theme.of(context).secondaryHeaderColor, fontSize: 19.sp, fontWeight: FontWeight.w600)
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'OTP Verification',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        //toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          children: <Widget>[

            SizedBox(height: 10.h),
            //  Info text
            Row(
              children: <Widget>[
                SizedBox(width: 16.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Please enter the ',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontWeight: FontWeight.w400)),
                        TextSpan(
                            text: 'One Time Password',
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700)),
                        TextSpan(
                          text: ' sent to your mobile',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.sp),
              ],
            ),

            SizedBox(height: 20.h),

            SizedBox(
              width: 300.w,
              child: PinFieldAutoFill(
                decoration: BoxLooseDecoration(
                  gapSpace: 5.w,
                  textStyle: TextStyle(fontSize: 20.sp, color: Colors.black),
                  strokeColorBuilder: FixedColorBuilder(Colors.black.withOpacity(0.3)),
                ),
                currentCode: _code,
                onCodeSubmitted: (code) {},
                onCodeChanged: (code) {
                  print(code);
                  if (code.length == 6) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    otpCode = code;
                    signIn();
                  }
                },
              ),
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: 150.w,
              height: 50.h,
              child: FlatButton(
                onPressed: signIn,
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 8.w,vertical: 8.h),
                  child: Text(
                    'VERIFY',
                  ),
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> verifyPhoneNumber(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (AuthCredential authCredential) {
      },

      verificationFailed: (authException) {
        Fluttertoast.showToast(
            msg: "Authentication Failed!!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
      },
      codeSent: (String verId, [int forceCodeResent]) {
        verificationId = verId;
          Fluttertoast.showToast(
              msg: "OTP Sent",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              fontSize: 16.0
          );

      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        Fluttertoast.showToast(
            msg: "TIMEOUT",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
      },
    );
  }

  Future<void> signIn() async {

      await pr.show();
    await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    ));

      var muser = await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get();
      if(muser.exists){
        Fluttertoast.showToast(
            msg: "Logging In...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
        await pr.hide();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            HomePage()), (Route<dynamic> route) => false);
      }
      else{
        Fluttertoast.showToast(
            msg: "New Registration",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
        await pr.hide();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => SignUp()));
      }

  }


}