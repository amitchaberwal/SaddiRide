import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saddirideadmin/Pages/Banners/ManageBanners.dart';
import 'package:saddirideadmin/Pages/Login/Splash.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Widget drawerHeader = SizedBox(
      child: Column(
        children: [
          Column(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: FirebaseAuth.instance.currentUser.photoURL,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        fit: BoxFit.cover,
                        width: 120.w,
                        height: 120.h,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser.displayName,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp),
                    ),
                  ],
                ),
          Padding(
            padding:  EdgeInsets.fromLTRB(0, 4.h, 0, 0),
            child: Text(FirebaseAuth.instance.currentUser.email,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'HOME',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.segment,
              color: Theme.of(context).accentColor,
          size: 35.r,),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,

      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).primaryColor,
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 30.h, 10.w, 15.h),
                child: drawerHeader,
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).accentColor,
                indent: 15.w,
                endIndent:30.w,
              ),
              InkWell(
                onTap: () {},
                child: ListTile(
                  title: Text('Home',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.home_rounded,
                  color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => ManageBanners()));

                },
                child: ListTile(
                  title: Text('Banners',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.tv,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: (){

                },
                child: ListTile(
                  title: Text('Vehicles Management',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.directions_car,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: (){},
                child: ListTile(
                  title: Text('Cash Requests',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.send,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: (){},
                child: ListTile(
                  title: Text('Transactions',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.monetization_on_rounded,
                      color: Theme.of(context).accentColor),
                ),
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).accentColor,
                indent: 15.w,
                endIndent: 30.w,
              ),
              InkWell(
                onTap: (){},
                child: ListTile(
                  title: Text('Setting',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.settings,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Splash()));
                },
                child: ListTile(
                  title: Text('Sign Out',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: new ListView(
        children: [

        ],
      ),
    );
  }
}
