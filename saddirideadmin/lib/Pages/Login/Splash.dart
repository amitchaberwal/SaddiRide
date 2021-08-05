import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saddirideadmin/Pages/HomePage/HomePage.dart';
import 'package:saddirideadmin/Pages/Login/Login.dart';



class Splash extends StatelessWidget {
  Future getPage(BuildContext context) async{
    User user = await FirebaseAuth.instance.currentUser;
    if(user != null){
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
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
        //toolbarHeight: mapHeight(60),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          SizedBox(height: 150.h,),
          SizedBox(
            child:Image.asset('Assets/LogoAdmin.png',
              height: 300.h,),
          ),
        ],
      ),
    );
  }
}


