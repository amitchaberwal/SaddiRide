import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:saddiridedriver/Pages/Home.dart';
import 'package:saddiridedriver/Pages/Vehicle/Routes.dart';
import 'package:saddiridedriver/Pages/Vehicle/VRegistration.dart';


class MyVehicles extends StatefulWidget {
  const MyVehicles({Key key}) : super(key: key);

  @override
  _MyVehiclesState createState() => _MyVehiclesState();
}

class _MyVehiclesState extends State<MyVehicles> {
  String vid;
  int vtenure;
  Razorpay _razorpay = Razorpay();
  DateTime nTime;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print(Timestamp.now());
    print(getTime());
  }
  Future<DateTime>getTime()async{
    DateTime mdate = await NTP.now();
    return mdate;
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response)async {
    DateTime tTime = await getTime();
    DateTime exTime = tTime.add(Duration(days: 30*vtenure));
    print(tTime);
    print(exTime);
    await FirebaseFirestore.instance.collection('Vehicles').doc(vid).update({
      'Status':'Approved',
      'STime' : tTime,
      'ExTime' : exTime,
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) async{

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ListView(
        children:[
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 15.h,horizontal: 60.w),
            child: SizedBox(
              width: 10.w,
              height: 60.h,
              child: MaterialButton(
                onPressed:(){
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => VehicleRegistration()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car,color: Theme.of(context).secondaryHeaderColor,size: 25.r,),
                      Text(
                        'Vehicle Registration',
                        style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Vehicles').where('PhoneNumber',isEqualTo: FirebaseAuth.instance.currentUser.phoneNumber).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot>snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data.docs.map((mdoc) => Padding(
                      padding:  EdgeInsets.fromLTRB(10, 10.h, 10, 0),
                      child:InkWell(
                        onTap: (){
                          if(mdoc['Status'] == 'Approved'){
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (BuildContext context) => Routes(vid: mdoc.id,vcat: mdoc['Category'],vsubcat: mdoc['SubCategory'],)));
                          }
                        },
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
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: CachedNetworkImage(
                                          imageUrl:mdoc['VehicleImage'],
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
                                            Container(width:200.w,child: Center(child: Text(mdoc['VehicleName'],style: TextStyle(color: Theme.of(context).accentColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),
                                            Container(width:200.w,child: Center(child: Text('Vehicle Number: '+mdoc['VehicleNumber'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                                            Container(width:200.w,child: Center(child: Text( 'Category: '+ mdoc['Category'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                            Container(width:200.w,child: Center(child: Text('Subcategory: '+ mdoc['SubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                            Container(width:200.w,child: Center(child: Text('Seats: '+ mdoc['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                            Container(width:200.w,child: Center(child: Text('Driver: '+ mdoc['DriverName'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                            Container(width:200.w,child: Center(child: Text('Driver Contact: '+ mdoc['DriverContact'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),

                                            if(mdoc['Status'] == 'Awaiting Confirmation' || mdoc['Status'] == 'Awaiting Payment')
                                              Container(width:200.w,child: Center(child: Text(mdoc['Status'],style: TextStyle(color: Colors.orange[400],fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),

                                            if(mdoc['Status'] == 'Approved')
                                              Column(
                                                children: [
                                                  Container(width:220.w,child: Center(child: Text('Subscribed Till: ' + DateFormat('dd-MM-yyyy').format(mdoc['ExTime'].toDate()).toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                                                  Container(width:200.w,child: Center(child: Text(mdoc['Status'],style: TextStyle(color: Colors.green,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),
                                                ],
                                              ),

                                            if(mdoc['Status'] == 'Blocked' || mdoc['Status'] == 'Subscription Expired')
                                              Container(width:200.w,child: Center(child: Text(mdoc['Status'],style: TextStyle(color: Colors.red,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),

                                            if(mdoc['Status'] == 'Awaiting Payment' || mdoc['Status'] == 'Subscription Expired')
                                              FutureBuilder(
                                                  future: FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc(mdoc['Category']).get(),
                                                  builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                                                    if (mdata.hasData) {
                                                      return Padding(
                                                        padding:  EdgeInsets.fromLTRB(0, 5.h, 0, 5.h),
                                                        child:SizedBox(
                                                          width: 120.w,
                                                          height: 40.h,
                                                          child: MaterialButton(
                                                            onPressed:(){
                                                              vid = mdoc.id;
                                                              vtenure = mdata.data[mdoc['SubCategory']]['Tenure'];
                                                              var options = {
                                                                'key': 'rzp_test_nL1xxOCNa7Fdlh',
                                                                'amount': mdata.data[mdoc['SubCategory']]['Fee'] * 100,
                                                                'name': 'Saddi Ride',
                                                                'description': 'Payment for Vehicle Registration',
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
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(5.0),
                                                              child: Text(
                                                                'Pay: ₹' + mdata.data[mdoc['SubCategory']]['Fee'].toString(),
                                                                style: TextStyle(fontSize: 14.sp,color: Theme.of(context).primaryColor),
                                                              ),
                                                            ),
                                                            color: Theme.of(context).accentColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(20.0)),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                                                    }
                                                  }),
                                          ]
                                      ),
                                    ),
                                  ),],
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
        ]
      ),

    );
  }
}
