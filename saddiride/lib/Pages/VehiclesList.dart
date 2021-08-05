import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:saddiride/Pages/Home.dart';
class VehiclesList extends StatefulWidget {
  final String vcat,vsubcat,origin,destination,tdate;
  const VehiclesList({Key key, this.vcat, this.vsubcat, this.origin, this.destination, this.tdate}) : super(key: key);

  @override
  _VehiclesListState createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
  List<DocumentSnapshot> products = [];
  bool zeroProducts = false;
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 10;
  DocumentSnapshot lastDocument;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getProducts();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 0) {
        getProducts();
      }
    });

  }
  getProducts() async {
    if (!hasMore) {
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    Query quary;
    if(widget.vcat == 'Cab' && widget.vsubcat == 'Commercial'){
       quary = FirebaseFirestore.instance.collection('Routes').where('VehicleCategory',isEqualTo: widget.vcat).where('VehicleSubCategory',isEqualTo: widget.vsubcat).where('Origin',isEqualTo: widget.origin).where('Destination',isEqualTo: widget.destination);
    }
    if(widget.vcat == 'Cab' && widget.vsubcat == 'Carpool'){
       quary = FirebaseFirestore.instance.collection('Routes').where('VehicleCategory',isEqualTo: widget.vcat).where('VehicleSubCategory',isEqualTo: widget.vsubcat).where('Origin',isEqualTo: widget.origin).where('Destination',isEqualTo: widget.destination).where('Date',isEqualTo: widget.tdate);
    }
    if(widget.vcat == 'MarrigeBooking'){
       quary = FirebaseFirestore.instance.collection('Routes').where('VehicleCategory',isEqualTo: widget.vcat).where('VehicleSubCategory',isEqualTo: widget.vsubcat).where('Origin',isEqualTo: widget.origin);    }
    if(widget.vcat == 'Tourism'){
       quary = FirebaseFirestore.instance.collection('Routes').where('VehicleCategory',isEqualTo: widget.vcat).where('VehicleSubCategory',isEqualTo: widget.vsubcat).where('Origin',isEqualTo: widget.origin).where('Destination',isEqualTo: widget.destination);
    }

    if (lastDocument == null) {
      quary = quary.limit(documentLimit);
      querySnapshot = await  quary.get();
      if(querySnapshot.docs.isEmpty){
        setState(() {
          zeroProducts = true;
        });
      }

    } else {
      quary = quary.startAfterDocument(lastDocument).limit(documentLimit);
      querySnapshot = await  quary.get();
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    products.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Rides',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          if(!zeroProducts)
            Column(
              children: [
                if(products.length != 0)
                  Column(
                    children: products.map((mProduct) =>
                        FutureBuilder(
                            future: FirebaseFirestore.instance.collection('Vehicles').doc(mProduct.data()['VehicleID']).get(),
                            builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                              if (mdata.hasData) {
                                if(mdata.data['Status'] == 'Approved'){
                                  return Padding(
                                    padding:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                                    child: Container(
                                      width: double.infinity,
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
                                                  child: Hero(
                                                    tag: mdata.data['VehicleImage'],
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl:mdata.data['VehicleImage'],
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif")),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Container(width:200.w,child: Center(child: Text(mdata.data['VehicleName'],style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                                        if(widget.vcat == 'Cab' || widget.vcat == 'Tourism')
                                                        Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(mProduct['Origin'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                Icon(
                                                                  Icons.arrow_right_alt_outlined,
                                                                  size: 20,
                                                                  color: Theme.of(context).secondaryHeaderColor,
                                                                ),
                                                                Text(mProduct['Destination'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text('Time: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                Text(mProduct['Time'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              ],
                                                            ),
                                                            if(widget.vcat == 'Cab' && widget.vsubcat == 'Carpool')
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text('Date: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mProduct['Date'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text('Fare: ₹',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                Text(mProduct['Fare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              ],
                                                            ),
                                                            FutureBuilder(
                                                                future: FirebaseFirestore.instance.collection('Routes').doc(mProduct.id).collection('Booking').doc(widget.tdate).get(),
                                                                builder: (context, AsyncSnapshot<DocumentSnapshot>mdatab) {
                                                                  if (mdatab.hasData) {
                                                                    int tseats = 0;
                                                                    if(mdatab.data.exists){
                                                                      tseats = mdatab.data['AvailableSeats'];
                                                                      if(mdatab.data['AvailableSeats']>0){
                                                                        return Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text('Available Seats: '+ mdatab.data['AvailableSeats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                                Icon(
                                                                                  Icons.event_seat,
                                                                                  size: 20,
                                                                                  color: Theme.of(context).secondaryHeaderColor,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
                                                                              child: SizedBox(
                                                                                height: 50.h,
                                                                                width:120.w,
                                                                                child: MaterialButton(
                                                                                  onPressed:(){
                                                                                    if(widget.vcat == 'Cab' && widget.vsubcat == 'Commercial'){
                                                                                      Navigator.of(context)
                                                                                          .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], destination: mProduct['Destination'], sdate: widget.tdate,dNumber: mdata.data['PhoneNumber'],stime: mProduct['Time'],vname: mdata.data['VehicleName'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: tseats,routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));
                                                                                    }
                                                                                    if(widget.vcat == 'Cab' && widget.vsubcat == 'Carpool'){
                                                                                      Navigator.of(context)
                                                                                          .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], destination: mProduct['Destination'], sdate: widget.tdate,dNumber: mdata.data['PhoneNumber'],stime: mProduct['Time'],vname: mdata.data['VehicleName'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: tseats,routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));

                                                                                    }
                                                                                    if(widget.vcat == 'Tourism'){
                                                                                      Navigator.of(context)
                                                                                          .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], destination: mProduct['Destination'], sdate: widget.tdate,dNumber: mdata.data['PhoneNumber'],vname: mdata.data['VehicleName'],stime: mProduct['Time'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: tseats,routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));
                                                                                    }
                                                                                  },
                                                                                  child: Center(
                                                                                    child: Text("Book Ride",style: TextStyle(color: Colors.black,fontSize: 14.sp,fontWeight: FontWeight.w600 ),),
                                                                                  ),
                                                                                  color: Theme.of(context).accentColor,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }
                                                                      else{
                                                                        return Text('Booked',style: TextStyle(color: Colors.red,fontSize: 16.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,);
                                                                      }
                                                                    }
                                                                    else{
                                                                      tseats = mdata.data['Seats'];
                                                                      return Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Text('Available Seats: '+ mdata.data['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                              Icon(
                                                                                Icons.event_seat,
                                                                                size: 20,
                                                                                color: Theme.of(context).secondaryHeaderColor,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Padding(
                                                                            padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
                                                                            child: SizedBox(
                                                                              height: 50.h,
                                                                              width:120.w,
                                                                              child: MaterialButton(
                                                                                onPressed:(){
                                                                                  if(widget.vcat == 'Cab' && widget.vsubcat == 'Commercial'){
                                                                                    Navigator.of(context)
                                                                                        .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], destination: mProduct['Destination'], sdate: widget.tdate,dNumber: mdata.data['PhoneNumber'],stime: mProduct['Time'],vname: mdata.data['VehicleName'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: tseats,routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));
                                                                                  }
                                                                                  if(widget.vcat == 'Cab' && widget.vsubcat == 'Carpool'){
                                                                                    Navigator.of(context)
                                                                                        .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], destination: mProduct['Destination'], sdate: widget.tdate,dNumber: mdata.data['PhoneNumber'],stime: mProduct['Time'],vname: mdata.data['VehicleName'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: tseats,routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));

                                                                                  }
                                                                                  if(widget.vcat == 'Tourism'){
                                                                                    Navigator.of(context)
                                                                                        .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], destination: mProduct['Destination'], sdate: widget.tdate,dNumber: mdata.data['PhoneNumber'],vname: mdata.data['VehicleName'],stime: mProduct['Time'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: tseats,routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));
                                                                                  }
                                                                                },
                                                                                child: Center(
                                                                                  child: Text("Book Ride",style: TextStyle(color: Colors.black,fontSize: 14.sp,fontWeight: FontWeight.w600 ),),
                                                                                ),
                                                                                color: Theme.of(context).accentColor,
                                                                                shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }
                                                                  } else {
                                                                    return CircularProgressIndicator();
                                                                  }
                                                                }),
                                                          ],
                                                        ),
                                                        if(widget.vcat == 'MarrigeBooking')
                                                          Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text('City: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mProduct['Origin'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text('Fare: ₹',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mProduct['Fare'].toString() + ' per Km',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text('Available Seats: '+ mdata.data['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Icon(
                                                                    Icons.event_seat,
                                                                    size: 20,
                                                                    color: Theme.of(context).secondaryHeaderColor,
                                                                  ),
                                                                ],
                                                              ),
                                                              FutureBuilder(
                                                                  future: FirebaseFirestore.instance.collection('Routes').doc(mProduct.id).collection('Booking').doc(widget.tdate).get(),
                                                                  builder: (context, AsyncSnapshot<DocumentSnapshot>mdatab) {
                                                                    if (mdatab.hasData) {
                                                                      if(mdatab.data.exists){
                                                                          return Text('Booked',style: TextStyle(color: Colors.red,fontSize: 16.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,);
                                                                      }
                                                                      else{
                                                                        return Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
                                                                              child: SizedBox(
                                                                                height: 50.h,
                                                                                width:120.w,
                                                                                child: MaterialButton(
                                                                                  onPressed:(){
                                                                                    if(widget.vcat == 'MarrigeBooking'){
                                                                                      Navigator.of(context)
                                                                                          .push(MaterialPageRoute(builder: (BuildContext context) => BookRide(origin: mProduct['Origin'], dNumber: mdata.data['PhoneNumber'],sdate: widget.tdate,vname: mdata.data['VehicleName'],vimg: mdata.data['VehicleImage'],vid: mProduct['VehicleID'],avseats: mdata.data['Seats'],routeid: mProduct.id,fare: mProduct['Fare'],vcat: mProduct['VehicleCategory'],vsubcat: mProduct['VehicleSubCategory'],)));
                                                                                    }
                                                                                  },
                                                                                  child: Center(
                                                                                    child: Text("Book Ride",style: TextStyle(color: Colors.black,fontSize: 14.sp,fontWeight: FontWeight.w600 ),),
                                                                                  ),
                                                                                  color: Theme.of(context).accentColor,
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      }
                                                                    } else {
                                                                      return CircularProgressIndicator();
                                                                    }
                                                                  }),
                                                            ],
                                                          ),
                                                      ]
                                                  ),
                                                ),
                                              ),],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                else{
                                  return Container(height: 0,width: 0,);
                                }
                              } else {
                                return Container(height: 0,width: 0,);
                              }
                            }),
                    ).toList(),
                  ),
                if(isLoading && hasMore)
                  Padding(
                      padding:  EdgeInsets.only(top:5.h),
                      child: Center(
                          child: Image.asset(
                            "images/DualBall.gif",
                            height: 100,
                          )))
              ],
            ),

        ],
      ),

    );
  }
}

class BookRide extends StatefulWidget {
  final String origin,destination,sdate,routeid,stime,vid,vcat,vsubcat,vname,vimg,dNumber;
  final int fare,avseats;
  const BookRide({Key key, this.origin, this.destination, this.sdate, this.routeid, this.stime,  this.vid, this.vcat, this.vsubcat, this.fare, this.avseats, this.vname, this.vimg, this.dNumber}) : super(key: key);

  @override
  _BookRideState createState() => _BookRideState();
}

class _BookRideState extends State<BookRide> {
  List<Map> passengerList = [];
  String morigin,mdestination;
  int mdistance;
  Razorpay _razorpay = Razorpay();
  int bamount = 0;
  int tfare = 0;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    tfare = widget.fare;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  bookRide()async{

    String bookingID = new DateTime.now().millisecondsSinceEpoch.toString();
    if(widget.vcat == 'Cab' ||widget.vcat == 'Tourism' ){
      await pr.show();
      Map<String,dynamic> orderdata = new Map();
      orderdata['RouteID'] = widget.routeid;
      orderdata['Origin'] = widget.origin;
      if(widget.destination != null)
        orderdata['Destination'] = widget.destination;
      if(widget.stime!=null)
        orderdata['Time'] = widget.stime;
      if(widget.sdate != null)
        orderdata['Date'] = widget.sdate;
      orderdata['VehicleID'] = widget.vid;
      orderdata['VCategory'] = widget.vcat;
      orderdata['VSubCategory'] = widget.vsubcat;
      orderdata['TotalFare'] = widget.fare * passengerList.length;
      orderdata['FarePaid'] = bamount;
      orderdata['FarePayable'] = widget.fare * passengerList.length - bamount;
      orderdata['Status'] = 'Booked';
      orderdata['DNumber'] = widget.dNumber;
      orderdata['Passengers'] = passengerList;
      DateTime bdt = DateTime.now();
      String sbook = DateFormat('dd-MM-yyyy').format(bdt);
      orderdata['BookingDate'] = sbook;
      orderdata['BookiePhone'] = FirebaseAuth.instance.currentUser.phoneNumber;
      orderdata['BookieName'] = Home.uProfile['Name'];

      DateTime bts = new DateFormat("dd-MM-yyyy").parse(widget.sdate);
      orderdata['BookTimeStamp'] = bts;

      Random random = new Random();
      int OTP = random.nextInt(8999) + 1000;

      orderdata['OTP'] = OTP;
      int seatsav = widget.avseats - passengerList.length;

      await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(bookingID).set(orderdata);
      await FirebaseFirestore.instance.collection('Driver').doc(widget.dNumber).collection('Booking').doc(bookingID).set(orderdata);
      await FirebaseFirestore.instance.collection('Routes').doc(widget.routeid).collection('Booking').doc(widget.sdate).set({
        'AvailableSeats': seatsav
      });
      await pr.hide();
      showDialog(context: context, builder: (BuildContext context) {
        return ShowPaymentStatus(
            status: 'Success');
      });
    }
    if(widget.vcat == 'MarrigeBooking'){
      if(morigin!= null && mdestination != null && mdistance != null){
        await pr.show();
        Map<String,dynamic> orderdata = new Map();
        orderdata['DNumber'] = widget.dNumber;
        orderdata['RouteID'] = widget.routeid;
        orderdata['City'] = widget.origin;
        orderdata['Date'] = widget.sdate;
        orderdata['VehicleID'] = widget.vid;
        orderdata['VCategory'] = widget.vcat;
        orderdata['VSubCategory'] = widget.vsubcat;
        orderdata['Fare'] = widget.fare;
        orderdata['Status'] = 'Query';
        orderdata['Price'] = null;

        orderdata['MOrigin'] = morigin;
        orderdata['MDestination'] = mdestination;
        orderdata['MDistance'] = mdistance;

        DateTime bdt = DateTime.now();
        String sbook = DateFormat('dd-MM-yyyy').format(bdt);
        orderdata['QueryDate'] = sbook;

        DateTime bts = new DateFormat("dd-MM-yyyy").parse(widget.sdate);
        orderdata['BookTimeStamp'] = bts;

        orderdata['BookiePhone'] = FirebaseAuth.instance.currentUser.phoneNumber;
        orderdata['BookieName'] = Home.uProfile['Name'];

        await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(bookingID).set(orderdata);
        await FirebaseFirestore.instance.collection('Driver').doc(widget.dNumber).collection('Booking').doc(bookingID).set(orderdata);
        await pr.hide();
        showDialog(context: context, builder: (BuildContext context) {
          return ShowPaymentStatus(
              status: 'Success');
        });

        Fluttertoast.showToast(
            msg: "Query Sent to Driver.Wait for reply",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
      }
      else{
        Fluttertoast.showToast(
            msg: "Please fill All Details!!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
      }

    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response)async {
    bookRide();
  }

  void _handlePaymentError(PaymentFailureResponse response) async{
    showDialog(context: context, builder: (BuildContext context) {
      return ShowPaymentStatus(
          status: 'Failed');
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {

  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'Processing...',
        borderRadius: 10.0,
        backgroundColor: Theme.of(context).primaryColor,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 19.sp, fontWeight: FontWeight.w600)
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Book Ride',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
            child: Container(
              width: 200.w,
              height: 400.h,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Hero(
                tag: widget.vimg,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    imageUrl:widget.vimg,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif")),
                  ),
                ),
              ),
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(width:200.w,child: Center(child: Text(widget.vname,style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Available Seats: '+ widget.avseats.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                    Icon(
                      Icons.event_seat,
                      size: 20,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ],
                ),
                if(widget.vcat == 'Cab' || widget.vcat == 'Tourism')
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.origin.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                          Icon(
                            Icons.arrow_right_alt_outlined,
                            size: 20,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          Text(widget.destination.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      if(widget.stime !=null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Time: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                          Text(widget.stime.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Date: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                            Text(widget.sdate.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Fare: ₹',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                          Text(tfare.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(left:20.w),
                            child: Text('Passenger List',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800 ),),
                          ),
                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal:10.w,vertical: 10.h),
                            child: SizedBox(
                              height: 50.h,
                              width: 60.w,
                              child: FlatButton(
                                onPressed:()async{
                                  if(passengerList.length<widget.avseats){
                                    var passenger = await showDialog(context: context,
                                        builder: (BuildContext context){
                                          return AddPassenger();
                                        }
                                    );
                                    print(passenger);
                                    if(passenger != null){
                                      setState(() {
                                        passengerList.add(passenger);
                                        tfare = widget.fare * passengerList.length;
                                      });
                                    }
                                  }
                                  else{
                                    Fluttertoast.showToast(
                                        msg: "Can't add more pessengers",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Theme.of(context).cardColor,
                                        textColor: Theme.of(context).secondaryHeaderColor,
                                        fontSize: 16.0
                                    );
                                  }
                                },
                                child: Center(
                                  child: Icon(Icons.person_add_alt_1,size: 25.r,),
                                ),
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children:passengerList.map((pass) =>
                            Padding(
                                padding:  EdgeInsets.symmetric(horizontal: 30.w,vertical: 5.h),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(vertical: 10.h),
                                        child: Column(
                                          children: [
                                            Text(pass['Name'],style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800 ),),
                                            Text('Phone: ' + pass['Phone'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600 ),),
                                            Text('Age: ' + pass['Age'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600 ),),
                                            Text('S: ' + pass['Sex'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600 ),),

                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: Icon(Icons.delete,color: Theme.of(context).accentColor,size: 20.r,),
                                        onPressed: (){
                                          setState(() {
                                            passengerList.remove(pass);
                                            tfare = widget.fare * passengerList.length;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                )
                            )
                        ).toList(),
                      ),
                      FutureBuilder(
                          future: FirebaseFirestore.instance.collection('Admin').doc('AdminData').get(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot>mdataa) {
                            if (mdataa.hasData) {
                              int bpart = mdataa.data['BookingAmount'];
                              bamount = ((mdataa.data['BookingAmount'] * tfare)/100).round();
                              return Column(
                                children: [
                                  Text("Pay $bpart% of fare to book ride",style: TextStyle(color: Colors.black,fontSize: 14.sp,fontWeight: FontWeight.w300 ),),
                                  Padding(
                                    padding:  EdgeInsets.symmetric(horizontal: 70.w,vertical: 10.h),
                                    child: SizedBox(
                                      height: 60.h,
                                      child: MaterialButton(
                                        onPressed:(){
                                          if(passengerList.length != 0){
                                            var options = {
                                              'key': 'rzp_test_nL1xxOCNa7Fdlh',
                                              'amount': bamount * 100,
                                              'name': 'Saadi Ride',
                                              'description': 'Payment for Ride Booking',
                                              'prefill': {'contact': FirebaseAuth.instance.currentUser.phoneNumber, 'email': Home.uProfile['Email']},
                                              'external': {
                                                'wallets': ['paytm']
                                              }
                                            };
                                            try {
                                              _razorpay.open(options);
                                            } catch (e) {
                                              debugPrint(e);
                                            }
                                          }
                                          else{
                                            Fluttertoast.showToast(
                                                msg: "Please Add Passenger...",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Theme.of(context).cardColor,
                                                textColor: Theme.of(context).secondaryHeaderColor,
                                                fontSize: 16.0
                                            );
                                          }

                                        },
                                        child: Center(
                                          child: Text("Pay ₹$bamount",style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w800 ),),
                                        ),
                                        color: Theme.of(context).accentColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0)),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),

                    ],
                  ),
                if(widget.vcat == 'MarrigeBooking')
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('City: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                          Text(widget.origin.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Fare: ₹',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                          Text(widget.fare.toString() + ' per Km',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Date: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                          Text(widget.sdate.toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      Padding(
                        padding:  EdgeInsets.symmetric(vertical: 10.h),
                        child: Text(
                          'Trip Information',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Origin',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(
                                width: 130.w,
                                child: TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: new InputDecoration(
                                      border: new OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(15),
                                        ),
                                      ),
                                      filled: true,
                                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                      hintText: "Origin",
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    morigin = value.toUpperCase();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Destination',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(
                                width: 130.w,
                                child: TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: new InputDecoration(
                                      border: new OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(15),
                                        ),
                                      ),
                                      filled: true,
                                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                      hintText: "Destination",
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    mdestination = value.toUpperCase();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding:  EdgeInsets.only(top:10.h),
                        child: SizedBox(
                          width: 150.w,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: new InputDecoration(
                                border: new OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(15),
                                  ),
                                ),
                                filled: true,
                                hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                hintText: "Approx. Distance",
                                fillColor: Theme.of(context).cardColor),
                            onChanged: (value) {
                              mdistance = int.parse(value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 100.w,vertical: 10.h),
                        child: SizedBox(
                          height: 60.h,
                          child: MaterialButton(
                            onPressed:(){
                              bookRide();
                            },
                            child: Center(
                              child: Text("Query Price",style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w800 ),),
                            ),
                            color: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                        ),
                      ),
                    ],

                  ),

              ]
          ),
        ],
      ),
    );
  }
}
class AddPassenger extends StatefulWidget {
  const AddPassenger({Key key}) : super(key: key);

  @override
  _AddPassengerState createState() => _AddPassengerState();
}

class _AddPassengerState extends State<AddPassenger> {
  Map<String,dynamic> pinfo = new Map();
  String groupValue = "Male";
  valueChanged(e){
    setState(() {
      switch (e) {
        case "Female":
          groupValue = e;
          break;
        case "Male":
          groupValue = e;
          break;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
          height: 400.h,
          margin: EdgeInsets.only(top: 1.h),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView(children: <Widget>[
            Padding(
              padding:  EdgeInsets.only(top: 10.h,bottom: 10.h),
              child: Center(
                child: Text(
                  'Passenger Info',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
              child: SizedBox(
                width: 200.w,
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30),
                        ),
                      ),
                      filled: true,
                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      hintText: "Name",
                      fillColor: Theme.of(context).primaryColor),
                  onChanged: (value) {
                    pinfo['Name'] = value;
                  },
                ),
              ),
            ),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
              child: SizedBox(
                width: 200.w,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30),
                        ),
                      ),
                      filled: true,
                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      hintText: "Phone Number",
                      fillColor: Theme.of(context).primaryColor),
                  onChanged: (value) {
                    pinfo['Phone'] = value;
                  },
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 100.w,vertical: 5.h),
              child: SizedBox(
                width: 60.w,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(15),
                        ),
                      ),
                      filled: true,
                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      hintText: "Age",
                      fillColor: Theme.of(context).primaryColor),
                  onChanged: (value) {
                    pinfo['Age'] = value;
                  },
                ),
              ),
            ),
            Row(
              children: [
                Flexible(child: ListTile(title: Text('Female',style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),leading: Radio(value: "Female", groupValue: groupValue, onChanged:(e)=> valueChanged(e),))),
                Flexible(child: ListTile(title: Text('Male',style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),leading: Radio(value: "Male", groupValue: groupValue, onChanged:(e)=> valueChanged(e),))),
              ],
            ),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 70.w,vertical: 10.h),
              child: SizedBox(
                height: 60.h,
                child: MaterialButton(
                  onPressed:(){
                    if(pinfo['Name']!=null && pinfo['Phone']!=null && pinfo['Age']!=null){
                      pinfo['Sex'] = groupValue;
                      Navigator.of(context).pop(pinfo);
                    }
                    else{
                      Fluttertoast.showToast(
                          msg: "Fill All Details...",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Theme.of(context).cardColor,
                          textColor: Theme.of(context).secondaryHeaderColor,
                          fontSize: 16.0
                      );
                    }
                  },
                  child: Center(
                    child: Text("Submit",style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w800 ),),
                  ),
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
            ),

          ])),
    );
  }
}

class ShowPaymentStatus extends StatefulWidget {
  final String status;
  const ShowPaymentStatus({Key key, this.status}) : super(key: key);

  @override
  _ShowPaymentStatusState createState() => _ShowPaymentStatusState();
}

class _ShowPaymentStatusState extends State<ShowPaymentStatus> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
            height: 300.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: (widget.status == 'Success')?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 70.r,
                    child: Icon(Icons.done,color: Theme.of(context).primaryColor,size: 50.r,)),
                Padding(
                  padding:  EdgeInsets.only(top:20.h),
                  child: Text(
                    'Booked Successfully',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ):
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 70.r,
                    child: Icon(Icons.close,color: Theme.of(context).primaryColor,size: 50.r,)),
                Padding(
                  padding:  EdgeInsets.only(top:20.h),
                  child: Text(
                    'Booking Failed',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
        ));
  }
}




