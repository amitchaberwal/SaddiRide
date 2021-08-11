import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:saddirideadmin/Pages/Banners/ManageBanners.dart';
import 'package:saddirideadmin/Pages/CashRequests.dart';
import 'package:saddirideadmin/Pages/Login/Splash.dart';
import 'package:saddirideadmin/Pages/Setting.dart';
import 'package:saddirideadmin/Pages/Vehicles.dart';

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
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => Vehicles()));

                },
                child: ListTile(
                  title: Text('Vehicles Management',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.directions_car,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => CashRequest()));
                },
                child: ListTile(
                  title: Text('Cash Requests',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.send,
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
                onTap: (){
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => AppSetting()));
                },
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
          Center(
            child: Text(
              'Vehicle Verification Requests',
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            height: 200.h,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Vehicles').where('Status',isEqualTo: 'Awaiting Confirmation').limit(2).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot>snapshot) {
                  if (snapshot.hasData) {
                    if(snapshot.data.size !=0){
                      return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs.map((mProduct) => Padding(
                          padding:  EdgeInsets.fromLTRB(10, 10.h, 10, 0),
                          child:InkWell(
                            onTap: ()async{
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (BuildContext context) => SingleRequest(vid: mProduct.id,)));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:  EdgeInsets.only(left: 8.w,bottom: 8.h,top: 8.h),
                                        child: Container(
                                          width: 120.w,
                                          height: 170.h,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
                                            child: CachedNetworkImage(
                                              imageUrl:mProduct['VehicleImage'],
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif")),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(width:200.w,child: Center(child: Text(mProduct['VehicleName'],style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text('Vehicle Number: '+mProduct['VehicleNumber'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text( 'Category: '+ mProduct['Category'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text('Subcategory: '+ mProduct['SubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text('Seats: '+ mProduct['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text('Driver: '+ mProduct['DriverName'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text('Driver Contact: '+ mProduct['DriverContact'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                                Container(width:200.w,child: Center(child: Text('Phone: '+ mProduct['PhoneNumber'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),

                                              ]
                                          ),
                                        ),
                                      ),],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ).toList(),
                      );
                    }
                    else{
                      return Center(
                        child: Text(
                          'No New Verification Request',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    }

                  } else {
                    return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                  }
                }),
          ),
          SizedBox(height: 30.h,),
          Center(
            child: Text(
              'User Cash Request',
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            height: 160.h,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('User').where('Status',isEqualTo: 'Requested').limit(2).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot>snapshot) {
                  if (snapshot.hasData) {
                    if(snapshot.data.size !=0){
                      return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs.map((mProduct) => Padding(
                          padding:  EdgeInsets.fromLTRB(10, 10.h, 10, 0),
                          child:InkWell(
                            onTap: ()async{
                              await showDialog(context: context,
                                  builder: (BuildContext context){
                                    return ShowCashRequest(vid: mProduct.id,usertype: 'User',);
                                  }
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                child: Column(
                                  children: [
                                    Container(width:350.w,child: Center(child: Text(mProduct.id,style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text(mProduct['Name'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text(mProduct['Email'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Date: '+ mProduct['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Amount: ₹'+ mProduct['Amount'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Transfer Type: '+ mProduct['TransferType'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Transfer Number: '+ mProduct['TransferPhone'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ).toList(),
                      );
                    }
                    else{
                      return Center(
                        child: Text(
                          'No New Request',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    }

                  } else {
                    return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                  }
                }),
          ),
          SizedBox(height: 30.h,),
          Center(
            child: Text(
              'Driver Cash Request',
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800),
            ),
          ),
          Container(
            height: 160.h,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('Driver').where('Status',isEqualTo: 'Requested').limit(2).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot>snapshot) {
                  if (snapshot.hasData) {
                    if(snapshot.data.size !=0){
                      return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.docs.map((mProduct) => Padding(
                          padding:  EdgeInsets.fromLTRB(10, 10.h, 10, 0),
                          child:InkWell(
                            onTap: ()async{
                              await showDialog(context: context,
                                  builder: (BuildContext context){
                                    return ShowCashRequest(vid: mProduct.id,usertype: 'User',);
                                  }
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                child: Column(
                                  children: [
                                    Container(width:350.w,child: Center(child: Text(mProduct.id,style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text(mProduct['Name'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text(mProduct['Email'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Date: '+ mProduct['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Amount: ₹'+ mProduct['Amount'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Transfer Type: '+ mProduct['TransferType'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                    Container(width:350.w,child: Center(child: Text('Transfer Number: '+ mProduct['TransferPhone'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ).toList(),
                      );
                    }
                    else{
                      return Center(
                        child: Text(
                          'No New Request',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    }

                  } else {
                    return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                  }
                }),
          ),

        ],
      ),
    );
  }
}
