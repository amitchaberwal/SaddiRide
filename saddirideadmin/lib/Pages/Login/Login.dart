import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saddirideadmin/Pages/HomePage/HomePage.dart';
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    User _user = null;
    void signInwithGoogle(BuildContext context)async
    {
      final GoogleSignInAccount googleSignInAccount =
      await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      _user = await _auth.currentUser;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        centerTitle: true,
        elevation: 0,
        //toolbarHeight: mapHeight(60),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 150.h,),
          SizedBox(
            child:Image.asset('Assets/LogoAdmin.png',
              height: 300.h,),
          ),
          SizedBox(
            height: 150.h,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 60.h,
              width: 250.w,
              child: FlatButton(
                onPressed:(){
                  signInwithGoogle(context);
                  },
                child: Center(child: Text("Login With Google",style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 16.sp,fontWeight: FontWeight.w500 ),)),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
