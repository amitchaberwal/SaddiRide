import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AppSetting extends StatefulWidget {
  const AppSetting({key}) : super(key: key);

  @override
  _AppSettingState createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {
  Map<String,dynamic> adminData;
  Map<String,dynamic> mreg;
  Map<String,dynamic> creg;
  Map<String,dynamic> treg;
  Map<String,dynamic> mcom;
  Map<String,dynamic> ccom;
  Map<String,dynamic> tcom;
  bool processed = false;
  ProgressDialog pr;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllData();
  }
  getAllData()async{
    DocumentSnapshot addata = await FirebaseFirestore.instance.collection('Admin').doc('AdminData').get();
    adminData = addata.data();

    DocumentSnapshot mregdata = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc('MarrigeBooking').get();
    mreg = mregdata.data();

    DocumentSnapshot cregdata = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc('Cab').get();
    creg = cregdata.data();

    DocumentSnapshot tregdata = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc('Tourism').get();
    treg = tregdata.data();

    DocumentSnapshot mcomdata = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc('MarrigeBooking').get();
    mcom = mcomdata.data();

    DocumentSnapshot ccomdata = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc('Cab').get();
    ccom = ccomdata.data();

    DocumentSnapshot tcomdata = await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc('Tourism').get();
    tcom = tcomdata.data();
    setState(() {
      processed = true;
    });
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
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'App Setting',
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
          (processed == true)?
          Column(
            children: [
              Column(
                children: [
                  Text(
                    'Booking Charges',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Advance Booking Charges',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: adminData['BookingAmount'].toString()),
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
                          hintText: "Advance Booking Amount %",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        adminData['BookingAmount'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Cancellation Charges',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w,vertical: 15.h),
                    child: TextFormField(
                      controller: TextEditingController(text: adminData['CancelAmount'].toString()),
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
                          hintText: "Cancellation Charge %",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        adminData['CancelAmount'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('AdminData').update(adminData);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    'Marriage Vehicle Registration Charges',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Budget Vehicle Registration',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: mreg['Budget']['Fee'].toString()),
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
                          hintText: "Budget Registration",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        mreg['Budget']['Fee'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Premium Vehicle Registration',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w,vertical: 15.h),
                    child: TextFormField(
                      controller: TextEditingController(text: mreg['Premium']['Fee'].toString()),
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
                          hintText: "Premium Registration",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        mreg['Premium']['Fee'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc('MarrigeBooking').update(mreg);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    'Cab Registration Charges',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Commercial Vehicle Registration',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: creg['Commercial']['Fee'].toString()),
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
                          hintText: "Commercial Registration",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        creg['Commercial']['Fee'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Carpool Registration',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w,vertical: 15.h),
                    child: TextFormField(
                      controller: TextEditingController(text: creg['Carpool']['Fee'].toString()),
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
                          hintText: "Carpool Registration",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        creg['Carpool']['Fee'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc('Cab').update(creg);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    'Tourism Vehicle Registration Charges',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Budget Vehicle Registration',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: treg['Budget']['Fee'].toString()),
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
                          hintText: "Budget Registration",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        treg['Budget']['Fee'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc('Tourism').update(treg);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),


              Column(
                children: [
                  Text(
                    'Marriage Vehicle Booking Commission',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Budget Vehicle Commission',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: mcom['Budget']['Commission'].toString()),
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
                          hintText: "Budget Commission",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        mcom['Budget']['Commission'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Premium Vehicle Commission',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w,vertical: 15.h),
                    child: TextFormField(
                      controller: TextEditingController(text: mcom['Premium']['Commission'].toString()),
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
                          hintText: "Premium Commission",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        mcom['Premium']['Commission'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc('MarrigeBooking').update(mcom);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    'Cab Booking Commission',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Commercial Vehicle Commission',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: ccom['Commercial']['Commission'].toString()),
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
                          hintText: "Commercial Commission",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        ccom['Commercial']['Commission'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Carpool Commission',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w,vertical: 15.h),
                    child: TextFormField(
                      controller: TextEditingController(text: ccom['Carpool']['Commission'].toString()),
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
                          hintText: "Carpool Commission",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        ccom['Carpool']['Commission'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc('Cab').update(ccom);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    'Tourism Vehicle Booking Commission',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:15.h),
                    child: Text(
                      'Budget Vehicle Commission',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: TextFormField(
                      controller: TextEditingController(text: tcom['Budget']['Commission'].toString()),
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
                          hintText: "Budget Commission",
                          fillColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        tcom['Budget']['Commission'] = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 20.h),
                    child: SizedBox(
                      width: 170.w,
                      height: 60.h,
                      child: FlatButton(
                        onPressed:()async{
                          await pr.show();
                          await FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Commission').doc('Tourism').update(tcom);
                          await pr.hide();
                          Fluttertoast.showToast(
                              msg: "Updated...",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).secondaryHeaderColor,
                              fontSize: 16.0
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w600),
                        ),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ):
          Center(child: Image.asset("images/DualBall.gif",height: 100.h,))
        ],
      ),
    );
  }
}

