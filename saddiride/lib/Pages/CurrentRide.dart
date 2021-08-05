import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:saddiride/Pages/Home.dart';

class BookedRide extends StatefulWidget {
  const BookedRide({Key key}) : super(key: key);

  @override
  _BookedRideState createState() => _BookedRideState();
}

class _BookedRideState extends State<BookedRide> {
  int bamount = 0;
  String bookingID,DNumber,routeID,sbdate,stodayDate;
  int tamount;
  DateTime todayDate;
  bool bprocessed = false;

  Razorpay _razorpay = Razorpay();
  ProgressDialog pr;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkQuery();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response)async {
    await pr.show();
    Map<String,dynamic> orderdata = new Map();
    orderdata['TotalFare'] = tamount;
    orderdata['FarePaid'] = bamount;
    orderdata['FarePayable'] = tamount - bamount;
    orderdata['Status'] = 'Booked';
    DateTime bdt = DateTime.now();
    String sbook = DateFormat('dd-MM-yyyy').format(bdt);
    orderdata['BookingDate'] = sbook;
    Random random = new Random();
    int OTP = random.nextInt(8999) + 1000;
    orderdata['OTP'] = OTP;

    DateTime bts = new DateFormat("dd-MM-yyyy").parse(sbdate);
    orderdata['BookTimeStamp'] = bts;

    await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(bookingID).update(orderdata);
    await FirebaseFirestore.instance.collection('Driver').doc(DNumber).collection('Booking').doc(bookingID).update(orderdata);
    await FirebaseFirestore.instance.collection('Routes').doc(routeID).collection('Booking').doc(sbdate).set({
      'Status': 'Booked'
    });
    await pr.hide();
    showDialog(context: context, builder: (BuildContext context) {
      return ShowPaymentStatus(
          status: 'Success');
    });

    Fluttertoast.showToast(
        msg: "Ride Booked Successfully...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).secondaryHeaderColor,
        fontSize: 16.0
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) async{
    showDialog(context: context, builder: (BuildContext context) {
      return ShowPaymentStatus(
          status: 'Failed');
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {

  }

  checkQuery()async{
    DateTime mdate = await NTP.now();
    todayDate = mdate;
    stodayDate = DateFormat('dd-MM-yyyy').format(mdate);
    setState(() {
      bprocessed = true;
    });
    await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',isEqualTo: 'Booked').get().then((value) => Future.wait(value.docs.map((cdoc)async {
      DateTime bdate = cdoc['BookTimeStamp'].toDate();
      final diff = bdate.difference(mdate).inDays;
      if(diff < -2 ){
        await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(cdoc.id).update({
          'Status':'Completed'
        });
      }
    })));

    await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',isEqualTo: 'Query').where('BookTimeStamp',isLessThanOrEqualTo: mdate).get().then((value) => Future.wait(value.docs.map((cdoc)async {
      await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(cdoc.id).delete();
    })));

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
          'Booking',
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
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',whereIn: ['Booked','Query']).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot>snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data.docs.map((mdoc) => Padding(
                      padding:  EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
                      child:Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.only(bottom: 10.h),
                          child: Column(
                            children: [
                              FutureBuilder(
                                  future: FirebaseFirestore.instance.collection('Vehicles').doc(mdoc['VehicleID']).get(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                                    if (mdata.hasData) {
                                      if(mdoc['Status'] == 'Booked'){
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:  EdgeInsets.only(left: 8.w,bottom: 8.h,top: 8.h),
                                                  child: Container(
                                                    width: 100.w,
                                                    height: 130.h,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor,
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
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
                                                Expanded(
                                                  child: Container(
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text('Booking ID: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mdoc.id,style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),
                                                              Text(mdata.data['VehicleName'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              Text(mdata.data['VehicleNumber'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text('Driver: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mdata.data['DriverName'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text("Driver's Phone: ",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mdata.data['DriverContact'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),

                                                            ],
                                                          )
                                                        ]
                                                    ),
                                                  ),
                                                ),],
                                            ),
                                            (mdoc['VCategory'] == 'Cab' || mdoc['VCategory'] == 'Tourism')?
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(mdoc['Origin'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                    Icon(
                                                      Icons.arrow_right_alt_outlined,
                                                      size: 20,
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                    ),
                                                    Text(mdoc['Destination'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                  ],
                                                ),
                                                Text('Booking Date: ' + mdoc['BookingDate'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                Text('Travel Date: ' + mdoc['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                Text('Pickup Time: ' + mdoc['Time'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                if(mdoc['VSubCategory'] == 'Carpool')
                                                  Text('Travel Time: ' + mdoc['Time'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                Text('Total Fare: ₹' + mdoc['TotalFare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Paid Amount: ₹' + mdoc['FarePaid'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Payable Fare: ₹' + mdoc['FarePayable'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Ride Completion OTP: ' + mdoc['OTP'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                FutureBuilder(
                                                    future: FirebaseFirestore.instance.collection('Routes').doc(mdoc['RouteID']).get(),
                                                    builder: (context, AsyncSnapshot<DocumentSnapshot>mdatab) {
                                                      if (mdatab.hasData) {
                                                        return Column(
                                                          children: [
                                                            Container(width:350.w,child: Center(child: Text('PickUp: ' + mdatab.data['Pickup'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.visible))),
                                                            Container(width:350.w,child: Center(child: Text('Drop: ' + mdatab.data['Drop'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.visible))),
                                                          ],
                                                        );
                                                      } else {
                                                        return CircularProgressIndicator();
                                                      }
                                                    }),
                                                Text('Passengers',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                Column(
                                                  children: mdoc['Passengers'].map<Widget>((pass) =>
                                                      Row(
                                                        mainAxisAlignment:MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Text(pass['Name'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w300,),overflow: TextOverflow.ellipsis,),
                                                          Text(pass['Phone'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w300,),overflow: TextOverflow.ellipsis,),
                                                          Text(pass['Sex'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w300,),overflow: TextOverflow.ellipsis,),
                                                        ],
                                                      )
                                                  ).toList(),
                                                )
                                              ],
                                            ):
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(mdoc['MOrigin'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                    Icon(
                                                      Icons.arrow_right_alt_outlined,
                                                      size: 20,
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                    ),
                                                    Text(mdoc['MDestination'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Text(mdoc['VCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                    Text(mdoc['VSubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                  ],
                                                ),
                                                Text('Booking Date: ' + mdoc['BookingDate'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                Text('Travel Date: ' + mdoc['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                Text('Total Fare: ₹' + mdoc['TotalFare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Prepaid Amount: ₹' + mdoc['FarePaid'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Payable Amount: ₹' + mdoc['FarePayable'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                Text('Ride Completion OTP: ' + mdoc['OTP'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                              ],
                                            ),
                                            if(stodayDate != mdoc['Date'] && todayDate.isBefore(mdoc['BookTimeStamp'].toDate()) && bprocessed == true)
                                            Padding(
                                              padding:  EdgeInsets.symmetric(vertical: 10.h),
                                              child: SizedBox(
                                                height: 40.h,
                                                width:120.w,
                                                child: MaterialButton(
                                                  onPressed:()async{
                                                    await pr.show();
                                                    String cDNumber = mdoc['DNumber'];
                                                    String crouteID = mdoc['RouteID'];
                                                    String cbookingID = mdoc.id;
                                                    String csbdate = mdoc['Date'];
                                                    int cpAmmount = mdoc['FarePaid'];

                                                    DocumentSnapshot dsapro = await FirebaseFirestore.instance.collection('Admin').doc('AdminData').get();
                                                    DocumentSnapshot dsupro = await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get();

                                                    if(mdoc['VCategory'] == 'MarrigeBooking'){
                                                      await FirebaseFirestore.instance.collection('Routes').doc(crouteID).collection('Booking').doc(csbdate).delete();
                                                    }
                                                    else{
                                                      DocumentSnapshot ds = await FirebaseFirestore.instance.collection('Routes').doc(crouteID).collection('Booking').doc(csbdate).get();
                                                      int navseats = ds.data()['AvailableSeats'];
                                                      int finalSeats = mdoc['Passengers'].length + navseats;
                                                      await FirebaseFirestore.instance.collection('Routes').doc(crouteID).collection('Booking').doc(csbdate).update({
                                                        'AvailableSeats':finalSeats
                                                      });
                                                    }
                                                    int refundAmount = cpAmmount - ((dsapro.data()['CancelAmount'] * cpAmmount)/100).round();
                                                    await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').update({
                                                      'Wallet':refundAmount + dsupro.data()['Wallet']
                                                    });

                                                    await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(cbookingID).update({
                                                      'Status':'Cancelled'
                                                    });
                                                    await FirebaseFirestore.instance.collection('Driver').doc(cDNumber).collection('Booking').doc(cbookingID).update({
                                                      'Status':'Cancelled'
                                                    });
                                                    await pr.hide();
                                                    Fluttertoast.showToast(
                                                        msg: "Ride Cancelled Successfully...\nRefund will be credited in your wallet",
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                        backgroundColor: Theme.of(context).cardColor,
                                                        textColor: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 16.0
                                                    );

                                                  },
                                                  child: Center(
                                                    child: Text("Cancel Ride",style: TextStyle(color: Colors.black,fontSize: 12.sp,fontWeight: FontWeight.w600 ),),
                                                  ),
                                                  color: Theme.of(context).accentColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(30.0)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else{
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:  EdgeInsets.only(left: 8.w,bottom: 8.h,top: 8.h),
                                                  child: Container(
                                                    width: 100.w,
                                                    height: 130.h,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor,
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
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
                                                Expanded(
                                                  child: Container(
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Text(mdata.data['VehicleName'],style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              Text('Seats: ' + mdata.data['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              Text('Category: '+mdata.data['Category'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                              Text('SubCategory: '+mdata.data['SubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                            ],
                                                          )
                                                        ]
                                                    ),
                                                  ),
                                                ),],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(mdoc['MOrigin'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                Icon(
                                                  Icons.arrow_right_alt_outlined,
                                                  size: 20,
                                                  color: Theme.of(context).secondaryHeaderColor,
                                                ),
                                                Text(mdoc['MDestination'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(mdoc['VCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                Text(mdoc['VSubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                              ],
                                            ),
                                            Text('Query Date: ' + mdoc['QueryDate'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                            Text('Booking Date: ' + mdoc['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                            Text('Approx. Fare: ₹' + mdoc['Fare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                            (mdoc['Price'] == null)?
                                            Text('Status: Waiting for Price',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,):
                                            Column(
                                              children: [
                                                Text('Final Fare: ₹' + mdoc['Price'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                              ],
                                            ),
                                            FutureBuilder(
                                                future: FirebaseFirestore.instance.collection('Routes').doc(mdoc['RouteID']).collection('Booking').doc(mdoc['Date']).get(),
                                                builder: (context, AsyncSnapshot<DocumentSnapshot>mdatac) {
                                                  if (mdatac.hasData) {
                                                    if(mdatac.data.exists){
                                                      return Text('Already Booked',style: TextStyle(color: Colors.red,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,);
                                                    }
                                                    else{
                                                      return Column(
                                                        children: [
                                                          if(mdoc['Price']!= null)
                                                            FutureBuilder(
                                                                future: FirebaseFirestore.instance.collection('Admin').doc('AdminData').get(),
                                                                builder: (context, AsyncSnapshot<DocumentSnapshot>mdataa) {
                                                                  if (mdataa.hasData) {
                                                                    int bpart = mdataa.data['BookingAmount'];
                                                                    bamount = ((mdataa.data['BookingAmount'] * mdoc['Price'])/100).round();
                                                                    return Column(
                                                                      children: [
                                                                        Text("Pay $bpart% of fare to book ride",style: TextStyle(color: Colors.black,fontSize: 14.sp,fontWeight: FontWeight.w300 ),),
                                                                        Padding(
                                                                          padding:  EdgeInsets.symmetric(vertical: 10.h),
                                                                          child: SizedBox(
                                                                            height: 50.h,
                                                                            width:200.w,
                                                                            child: MaterialButton(
                                                                              onPressed:(){
                                                                                tamount = mdoc['Price'];
                                                                                DNumber = mdoc['DNumber'];
                                                                                routeID = mdoc['RouteID'];
                                                                                bookingID = mdoc.id;
                                                                                sbdate = mdoc['Date'];
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
                                                                              },
                                                                              child: Center(
                                                                                child: Text("Book & Pay ₹$bamount",style: TextStyle(color: Colors.black,fontSize: 14.sp,fontWeight: FontWeight.w800 ),),
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
                                                      );
                                                    }
                                                  } else {
                                                    return CircularProgressIndicator();
                                                  }
                                                }),
                                          ],
                                        );
                                      }
                                    } else {
                                      return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                                    }
                                  }),
                              if(mdoc['Status'] == 'Booked')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Status: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                    Text('Booked',style: TextStyle(color: Colors.green,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                  ],
                                ),

                              if(mdoc['Status'] == 'Query')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Status: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                    Text('Query',style: TextStyle(color: Colors.orange,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                  ],
                                ),

                              if(mdoc['Status'] == 'Cancelled')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Status: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                    Text('Cancelled',style: TextStyle(color: Colors.red,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    ).toList(),
                  );
                } else {
                  return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                }
              }),
        ],
      ),

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
