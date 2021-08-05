import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Bookings extends StatefulWidget {
  const Bookings({Key key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {

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
    quary = FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Booking').where('Status',whereIn: ['Completed','Cancelled']).orderBy('BookTimeStamp',descending: true);
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
          'Booking History',
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
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                FutureBuilder(
                                    future: FirebaseFirestore.instance.collection('Vehicles').doc(mProduct['VehicleID']).get(),
                                    builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                                      if (mdata.hasData) {
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
                                                              Text('Seats: ' + mdata.data['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                              Text('Category: '+mdata.data['Category'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                              Text('SubCategory: '+mdata.data['SubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                            ],
                                                          )
                                                        ]
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            (mProduct['VCategory']=='MarrigeBooking')?
                                                Padding(
                                                  padding:  EdgeInsets.only(bottom: 10.h),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(mProduct['MOrigin'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                          Icon(
                                                            Icons.arrow_right_alt_outlined,
                                                            size: 20,
                                                            color: Theme.of(context).secondaryHeaderColor,
                                                          ),
                                                          Text(mProduct['MDestination'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                        ],
                                                      ),
                                                      Text('Booking Date: ' + mProduct['BookingDate'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                      Text('Travel Date: ' + mProduct['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                      Text('Total Fare: ₹' + mProduct['TotalFare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                      Text('Status: ' + mProduct['Status'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),

                                                    ],
                                                  ),
                                                ):
                                                Padding(
                                                  padding: EdgeInsets.only(bottom:10.h),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(mProduct['Origin'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                          Icon(
                                                            Icons.arrow_right_alt_outlined,
                                                            size: 20,
                                                            color: Theme.of(context).secondaryHeaderColor,
                                                          ),
                                                          Text(mProduct['Destination'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),
                                                        ],
                                                      ),
                                                      Text('Booking Date: ' + mProduct['BookingDate'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                      Text('Travel Date: ' + mProduct['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,),
                                                      Text('Total Fare: ₹' + mProduct['TotalFare'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,),
                                                      Text('Status: ' + mProduct['Status'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,),

                                                    ],
                                                  ),
                                                )
                                          ],
                                        );
                                      } else {
                                        return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ),
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
