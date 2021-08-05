import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saddiridedriver/Pages/HomePage.dart';

import 'LoginPageA.dart';
import 'SignUpA.dart';

class Splash extends StatelessWidget {
  Future getPage(BuildContext context) async{
    User user = await FirebaseAuth.instance.currentUser;
    if(user != null){
      String mphone = await FirebaseAuth.instance.currentUser.phoneNumber;
      var muser = await FirebaseFirestore.instance.collection('Driver').doc(mphone).collection('Account').doc('Profile').get();
      if(muser.exists){
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      }
      else{
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => SignUp()));
      }
    }
    else{
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    getPage(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        centerTitle: true,
        elevation: 0,
        //toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Image.asset('Assets/Logo.png',
          height: 200.h,),
      ),
    );
  }
}

