import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';
import 'package:progress_dialog/progress_dialog.dart';
class Bookings extends StatefulWidget {
  const Bookings({Key key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {

  int mOtp;
  ProgressDialog pr;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkQuery();
  }
  checkQuery()async{
    DateTime mdate = await NTP.now();

    await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',isEqualTo: 'Booked').get().then((value) => Future.wait(value.docs.map((cdoc)async {
      DateTime bdate = cdoc['BookTimeStamp'].toDate();
      final diff = bdate.difference(mdate).inDays;
      if(diff < -2 ){
        await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(cdoc.id).update({
          'Status':'Completed'
        });
      }
    })));
    await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',isEqualTo: 'Query').where('BookTimeStamp',isLessThanOrEqualTo: mdate).get().then((value) => Future.wait(value.docs.map((cdoc)async {
      await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(cdoc.id).delete();
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
      body: ListView(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',whereIn: ['Booked','Query']).snapshots(),
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
                                                                  Text('Booked By: ',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mdoc['BookieName'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text("Phone: ",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                                  Text(mdoc['BookiePhone'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
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
                                                if(mdoc['VCategory'] == 'Cab')
                                                  Text('Pickup Time: ' + mdoc['Time'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                Text('Total Fare: ₹' + mdoc['TotalFare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Paid Amount: ₹' + mdoc['FarePaid'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                Text('Payable Fare: ₹' + mdoc['FarePayable'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
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
                                                ),
                                                Padding(
                                                  padding:  EdgeInsets.only(top:10.h),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width:100.w,
                                                        height: 50.h,
                                                        child: TextField(
                                                          keyboardType: TextInputType.number,
                                                          decoration: new InputDecoration(
                                                              border: new OutlineInputBorder(
                                                                borderSide: BorderSide.none,
                                                                borderRadius: const BorderRadius.all(
                                                                  const Radius.circular(12),
                                                                ),
                                                              ),
                                                              filled: true,
                                                              hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                                              hintText: "OTP",
                                                              fillColor: Theme.of(context).primaryColor),
                                                          onChanged: (value) {
                                                            mOtp = int.parse(value);
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(width: 20.w,),
                                                      SizedBox(
                                                        width: 150.w,
                                                        height: 50.h,
                                                        child: MaterialButton(
                                                          onPressed:()async{
                                                            if(mOtp == mdoc['OTP']){
                                                              await pr.show();
                                                              await FirebaseFirestore.instance.collection('User').doc(mdoc['BookiePhone']).collection('Booking').doc(mdoc.id).update({'Price':'Status'});
                                                              await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(mdoc.id).update({'Status':'Completed'});
                                                              DocumentSnapshot dcs = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc(mdoc['VCategory']).get();
                                                              DocumentSnapshot dpro = await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get();
                                                              int acomm = dcs.data()[mdoc['VSubCategory']]['Commission'];
                                                              int payble = ((mdoc['TotalFare'] * acomm)/100).round();
                                                              int gAmmount = mdoc['FarePaid'] - payble;
                                                              int finalAmount = dpro['Wallet'] + gAmmount;
                                                              await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').update({'Wallet':finalAmount});
                                                              Fluttertoast.showToast(
                                                                  msg: "Ride Completed...\nBalance Credited to your wallet",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.BOTTOM,
                                                                  backgroundColor: Theme.of(context).cardColor,
                                                                  textColor: Theme.of(context).secondaryHeaderColor,
                                                                  fontSize: 16.0
                                                              );
                                                              await pr.hide();
                                                            }
                                                            else{
                                                              Fluttertoast.showToast(
                                                                  msg: "Wrong OTP...",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.BOTTOM,
                                                                  backgroundColor: Theme.of(context).cardColor,
                                                                  textColor: Theme.of(context).secondaryHeaderColor,
                                                                  fontSize: 16.0
                                                              );

                                                            }

                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'Complete Ride',
                                                              style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                          color: Theme.of(context).accentColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                                Padding(
                                                  padding:  EdgeInsets.only(top:10.h),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width:100.w,
                                                        height: 50.h,
                                                        child: TextField(
                                                          keyboardType: TextInputType.number,
                                                          decoration: new InputDecoration(
                                                              border: new OutlineInputBorder(
                                                                borderSide: BorderSide.none,
                                                                borderRadius: const BorderRadius.all(
                                                                  const Radius.circular(12),
                                                                ),
                                                              ),
                                                              filled: true,
                                                              hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                                              hintText: "OTP",
                                                              fillColor: Theme.of(context).primaryColor),
                                                          onChanged: (value) {
                                                            mOtp = int.parse(value);
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(width: 20.w,),
                                                      SizedBox(
                                                        width: 150.w,
                                                        height: 50.h,
                                                        child: MaterialButton(
                                                          onPressed:()async{
                                                            if(mOtp == mdoc['OTP']){
                                                              await pr.show();
                                                              await FirebaseFirestore.instance.collection('User').doc(mdoc['BookiePhone']).collection('Booking').doc(mdoc.id).update({'Price':'Status'});
                                                              await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(mdoc.id).update({'Status':'Completed'});
                                                              DocumentSnapshot dcs = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc(mdoc['VCategory']).get();
                                                              DocumentSnapshot dpro = await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get();
                                                              int acomm = dcs.data()[mdoc['VSubCategory']]['Commission'];
                                                              int payble = ((mdoc['TotalFare'] * acomm)/100).round();
                                                              int gAmmount = mdoc['FarePaid'] - payble;
                                                              int finalAmount = dpro['Wallet'] + gAmmount;
                                                              await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').update({'Wallet':finalAmount});
                                                              Fluttertoast.showToast(
                                                                  msg: "Ride Completed...\nBalance Credited to your wallet",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.BOTTOM,
                                                                  backgroundColor: Theme.of(context).cardColor,
                                                                  textColor: Theme.of(context).secondaryHeaderColor,
                                                                  fontSize: 16.0
                                                              );
                                                              await pr.hide();
                                                            }
                                                            else{
                                                              Fluttertoast.showToast(
                                                                  msg: "Wrong OTP...",
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  gravity: ToastGravity.BOTTOM,
                                                                  backgroundColor: Theme.of(context).cardColor,
                                                                  textColor: Theme.of(context).secondaryHeaderColor,
                                                                  fontSize: 16.0
                                                              );

                                                            }
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'Complete Ride',
                                                              style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                          color: Theme.of(context).accentColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
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
                                                      int mPrice;
                                                      return Column(
                                                        children: [
                                                            Padding(
                                                              padding:  EdgeInsets.only(top:10.h),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SizedBox(
                                                                    width:100.w,
                                                                    height: 50.h,
                                                                    child: TextField(
                                                                      keyboardType: TextInputType.number,
                                                                      decoration: new InputDecoration(
                                                                          border: new OutlineInputBorder(
                                                                            borderSide: BorderSide.none,
                                                                            borderRadius: const BorderRadius.all(
                                                                              const Radius.circular(12),
                                                                            ),
                                                                          ),
                                                                          filled: true,
                                                                          hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                                                          hintText: "Price",
                                                                          fillColor: Theme.of(context).primaryColor),
                                                                      onChanged: (value) {
                                                                        mPrice = int.parse(value);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 20.w,),
                                                                  SizedBox(
                                                                    width: 100.w,
                                                                    height: 50.h,
                                                                    child: MaterialButton(
                                                                      onPressed:()async{
                                                                        await pr.show();
                                                                        await FirebaseFirestore.instance.collection('User').doc(mdoc['BookiePhone']).collection('Booking').doc(mdoc.id).update({'Price':mPrice});
                                                                        await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').doc(mdoc.id).delete();
                                                                        Fluttertoast.showToast(
                                                                            msg: "Price Sent...",
                                                                            toastLength: Toast.LENGTH_SHORT,
                                                                            gravity: ToastGravity.BOTTOM,
                                                                            backgroundColor: Theme.of(context).cardColor,
                                                                            textColor: Theme.of(context).secondaryHeaderColor,
                                                                            fontSize: 16.0
                                                                        );
                                                                        await pr.hide();
                                                                      },
                                                                      child: Center(
                                                                        child: Text(
                                                                          'Send Price',
                                                                          style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ),
                                                                      color: Theme.of(context).accentColor,
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(12.0)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
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
                              SizedBox(height: 10.h,),
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
                  return CircularProgressIndicator();
                }
              }),
        ],
      ),
    );
  }
}
