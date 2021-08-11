import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
class Vehicles extends StatefulWidget {
  const Vehicles({key}) : super(key: key);

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Vehicle Management',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body:ListView(
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30.w,vertical: 10.h),
            child: SizedBox(
              height: 250.h,
              child: MaterialButton(
                onPressed:(){
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => VerificationRequest()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.car_repair,size: 100.r,),
                    Text("Verification Request",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 20.sp,fontWeight: FontWeight.w800 ),),
                  ],
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30.w,vertical: 10.h),
            child: SizedBox(
              height: 250.h,
              child: MaterialButton(
                onPressed:(){
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) => VerifiedVehicles()));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,size: 100.r,),
                    Text("Verified Vehicles",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 20.sp,fontWeight: FontWeight.w800 ),),
                  ],
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      )
    );
  }
}

class VerificationRequest extends StatefulWidget {
  const VerificationRequest({key}) : super(key: key);

  @override
  _VerificationRequestState createState() => _VerificationRequestState();
}

class _VerificationRequestState extends State<VerificationRequest> {
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
    quary = FirebaseFirestore.instance.collection('Vehicles').where('Status',isEqualTo: 'Awaiting Confirmation');
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
          'Verification Requests',
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
                          padding:  EdgeInsets.fromLTRB(10, 10.h, 10, 0),
                          child:InkWell(
                            onTap: ()async{
                             var res =  await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (BuildContext context) => SingleRequest(vid: mProduct.id,)));
                             if(res == 'success'){
                               setState(() {
                                 products.remove(mProduct);
                               });
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
                  ),
                if(isLoading && hasMore)
                  Padding(
                      padding:  EdgeInsets.only(top:5.h),
                      child: Center(child: Image.asset("images/DualBall.gif",height: 100.h,)))
              ],
            ),
        ],

      ),
    );
  }
}

class VerifiedVehicles extends StatefulWidget {
  const VerifiedVehicles({key}) : super(key: key);

  @override
  _VerifiedVehiclesState createState() => _VerifiedVehiclesState();
}

class _VerifiedVehiclesState extends State<VerifiedVehicles> {

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
    quary = FirebaseFirestore.instance.collection('Vehicles').where('Status',isEqualTo: 'Approved');
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
          'Verified Vehicles',
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
                          padding:  EdgeInsets.fromLTRB(10, 10.h, 10, 0),
                          child:InkWell(
                            onTap: (){
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
                                                Container(width:200.w,child: Center(child: Text('Subscribed till: ' + DateFormat('dd-MM-yyyy').format(mProduct['ExTime'].toDate()),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 12.sp,fontWeight: FontWeight.w300,),overflow: TextOverflow.ellipsis,))),
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
                  ),
                if(isLoading && hasMore)
                  Padding(
                      padding:  EdgeInsets.only(top:5.h),
                      child: Center(child: Image.asset("images/DualBall.gif",height: 100.h,)))
              ],
            ),
        ],
      ),
    );
  }
}

class SingleRequest extends StatefulWidget {
  final String vid;
  const SingleRequest({ key, this.vid}) : super(key: key);

  @override
  _SingleRequestState createState() => _SingleRequestState();
}

class _SingleRequestState extends State<SingleRequest> {
  String groupValue = 'Awaiting Payment';
  ProgressDialog pr;
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
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Theme.of(context).secondaryHeaderColor, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Verification',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('Vehicles').doc(widget.vid).get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
            if (mdata.hasData) {
              return ListView(
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 70.w),
                    child: Container(
                      height: 350.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: InkWell(
                          onTap: (){
                            showDialog(context: context,
                                builder: (BuildContext context){
                                  return ShowImage(image: mdata.data['VehicleImage'],);
                                }
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl:mdata.data['VehicleImage'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif")),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top:20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: (){
                                showDialog(context: context,
                                    builder: (BuildContext context){
                                      return ShowImage(image: mdata.data['RCImage'],);
                                    }
                                );
                              },
                              child: Container(
                                height: 150.h,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: CachedNetworkImage(
                                    imageUrl:mdata.data['RCImage'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif")),
                                  ),
                                ),
                              ),
                            ),
                            Text("Vehicle RC",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400 ),)
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: (){
                                showDialog(context: context,
                                    builder: (BuildContext context){
                                      return ShowImage(image: mdata.data['DLImage'],);
                                    }
                                );
                              },
                              child: Container(
                                height: 150.h,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: CachedNetworkImage(
                                    imageUrl:mdata.data['DLImage'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif")),
                                  ),
                                ),
                              ),
                            ),
                            Text("Driver License",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400 ),)
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  Center(child: Text(mdata.data['VehicleName'],style: TextStyle(color: Theme.of(context).accentColor,fontSize: 20.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text('Vehicle Number: '+mdata.data['VehicleNumber'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text( 'Category: '+ mdata.data['Category'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text('Subcategory: '+ mdata.data['SubCategory'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text('Seats: '+ mdata.data['Seats'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text('Driver: '+ mdata.data['DriverName'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text('Driver Contact: '+ mdata.data['DriverContact'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,)),
                  Center(child: Text('Phone: '+ mdata.data['PhoneNumber'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,)),
                  Row(
                    children: [
                      Flexible(child: ListTile(title: Text('Verified',style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),leading: Radio(value: "Awaiting Payment", groupValue: groupValue, onChanged:(e)=>valueChanged(e)))),
                      Flexible(child: ListTile(title: Text('Block',style: TextStyle(color: Theme.of(context).secondaryHeaderColor),),leading: Radio(value: "Blocked", groupValue: groupValue, onChanged:(e)=> valueChanged(e)))),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 60.h,
                        width: 200.w,
                        child: MaterialButton(
                          onPressed:()async{
                            await pr.show();
                            await FirebaseFirestore.instance.collection('Vehicles').doc(widget.vid).update(
                                {'Status': groupValue});
                            await pr.hide();
                            Navigator.of(context).pop('success');
                          },
                          child: Center(child: Text("Submit",style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 16.sp,fontWeight: FontWeight.w500 ),)),
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h,)
                ],
              );
            } else {
              return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
            }
          }),
    );
  }
  valueChanged(e){
    setState(() {
      switch (e) {
        case "Awaiting Payment":
          groupValue = e;
          break;
        case "Blocked":
          groupValue = e;
          break;
      }
    });
  }
}

class ShowImage extends StatefulWidget {
  final String image;
  const ShowImage({key, this.image}) : super(key: key);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  TransformationController controller = TransformationController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
          height: 600.h,
          child: InteractiveViewer(
            child: CachedNetworkImage(
          imageUrl: widget.image,
          placeholder: (context, url) =>
              Center(child: Image.asset("images/Ripple2.gif")),
          fit: BoxFit.contain,
          height: 600.h,
          ),
            transformationController: controller,
            boundaryMargin: EdgeInsets.all(5.0),
          )),
    );
  }
}





