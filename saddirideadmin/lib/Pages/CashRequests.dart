import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CashRequest extends StatefulWidget {
  const CashRequest({key}) : super(key: key);

  @override
  _CashRequestState createState() => _CashRequestState();
}

class _CashRequestState extends State<CashRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Cash Requests',
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
                        .push(MaterialPageRoute(builder: (BuildContext context) => UsersRequest()));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person,size: 100.r,),
                      Text("Users Cash Request",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 20.sp,fontWeight: FontWeight.w800 ),),
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
                        .push(MaterialPageRoute(builder: (BuildContext context) => DriversRequest()));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car,size: 100.r,),
                      Text("Drivers Cash Request",style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 20.sp,fontWeight: FontWeight.w800 ),),
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
class UsersRequest extends StatefulWidget {
  const UsersRequest({key}) : super(key: key);

  @override
  _UsersRequestState createState() => _UsersRequestState();
}

class _UsersRequestState extends State<UsersRequest> {
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
    quary = FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('User').where('Status',isEqualTo: 'Requested');
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
          'User Cash Request',
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
                              var res =  await showDialog(context: context,
                                  builder: (BuildContext context){
                                    return ShowCashRequest(vid: mProduct.id,usertype: 'User',);
                                  }
                              );
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

class DriversRequest extends StatefulWidget {
  const DriversRequest({key}) : super(key: key);

  @override
  _DriversRequestState createState() => _DriversRequestState();
}

class _DriversRequestState extends State<DriversRequest> {

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
    quary = FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('Driver').where('Status',isEqualTo: 'Requested');
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
          'Driver Cash Request',
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
                              var res =  await showDialog(context: context,
                                  builder: (BuildContext context){
                                    return ShowCashRequest(vid: mProduct.id,usertype: 'Driver',);
                                  }
                              );
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
class ShowCashRequest extends StatefulWidget {
  final String vid,usertype;
  const ShowCashRequest({key, this.vid, this.usertype}) : super(key: key);

  @override
  _ShowCashRequestState createState() => _ShowCashRequestState();
}

class _ShowCashRequestState extends State<ShowCashRequest> {
  String remarks;
  String groupValue = 'Completed';
  ProgressDialog pr;

  processRequest(BuildContext context)async{
    await pr.show();
    await FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection(widget.usertype).doc(widget.vid).update({
      'Status':groupValue,
      'Remarks':remarks,
    });
    DocumentSnapshot cpRequest = await FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection(widget.usertype).doc(widget.vid).get();
    if(groupValue == 'Completed'){
      await FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('Completed').doc().set(cpRequest.data());
    }
    if(groupValue == 'Declined'){
      await FirebaseFirestore.instance.collection(widget.usertype).doc(widget.vid).collection('Account').doc('Profile').update({'Wallet':cpRequest.data()['Amount']});
    }
    await pr.hide();
    Fluttertoast.showToast(
        msg: "Request Submitted...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).secondaryHeaderColor,
        fontSize: 16.0
    );
    Navigator.of(context).pop('success');
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
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Theme.of(context).secondaryHeaderColor, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
            height: 370.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView(
              children: [
                Center(
                  child: Padding(
                    padding:  EdgeInsets.only(top:10.h),
                    child: Text('Cash Request',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18.sp),
                    ),
                  ),
                ),
                FutureBuilder(
                    future: FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection(widget.usertype).doc(widget.vid).get(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                      if (mdata.hasData) {
                        return Column(
                          children: [
                            Container(width:300.w,child: Center(child: Text(mdata.data.id,style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 16.sp,fontWeight: FontWeight.w800,),overflow: TextOverflow.ellipsis,))),
                            Container(width:300.w,child: Center(child: Text(mdata.data['Name'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                            Container(width:300.w,child: Center(child: Text(mdata.data['Email'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                            Container(width:300.w,child: Center(child: Text('Date: '+ mdata.data['Date'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                            Container(width:300.w,child: Center(child: Text('Amount: ₹'+ mdata.data['Amount'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600,),overflow: TextOverflow.ellipsis,))),
                            Container(width:300.w,child: Center(child: Text('Transfer Type: '+ mdata.data['TransferType'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                            Container(width:300.w,child: Center(child: Text('Transfer Number: '+ mdata.data['TransferPhone'],style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w400,),overflow: TextOverflow.ellipsis,))),
                            Row(
                              children: [
                                Flexible(child: ListTile(title: Text('Completed',style: TextStyle(color: Colors.green,fontSize: 12.sp,fontWeight: FontWeight.w400),),leading: Radio(value: "Completed", groupValue: groupValue, onChanged:(e)=>valueChanged(e)))),
                                Flexible(child: ListTile(title: Text('Declined',style: TextStyle(color: Colors.red,fontSize: 12.sp,fontWeight: FontWeight.w400),),leading: Radio(value: "Declined", groupValue: groupValue, onChanged:(e)=> valueChanged(e)))),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 15.h),
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
                                    hintText: "Remarks",
                                    fillColor: Theme.of(context).cardColor),
                                onChanged: (value) {
                                  remarks = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 60.w),
                              child: SizedBox(
                                width: 170.w,
                                height: 60.h,
                                child: FlatButton(
                                  onPressed:(){
                                    processRequest(context);
                                  },
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
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
            )
        ));
  }
  valueChanged(e){
    setState(() {
      switch (e) {
        case "Completed":
          groupValue = e;
          break;
        case "Declined":
          groupValue = e;
          break;
      }
    });
  }
}



