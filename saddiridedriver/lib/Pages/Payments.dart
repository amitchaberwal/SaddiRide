import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:saddiridedriver/Pages/Home.dart';
import 'package:saddiridedriver/Pages/HomePage.dart';
class Payments extends StatefulWidget {
  const Payments({Key key}) : super(key: key);

  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  String upiPhone;
  List<bool> isSelected = [true, false, false];
  String tType;
  ProgressDialog pr;

  requestTransfer(int sAmount)async{
    DateTime tdate = DateTime.now();
    String sdate = DateFormat('dd-MM-yyyy').format(tdate);
    if(sAmount != 0){
      if(upiPhone != null){
        await pr.show();
        await FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('Driver').doc().set({
          'PhoneNumber': FirebaseAuth.instance.currentUser.phoneNumber,
          'Name':Home.uProfile['Name'],
          'Email':Home.uProfile['Email'],
          'Amount':sAmount,
          'TransferType':tType,
          'TransferPhone': upiPhone,
          'Date':sdate,
          'RequestTimeStamp':tdate
        });
        await FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').update({
          'Wallet':0
        });
        Fluttertoast.showToast(
            msg: "Request Sent Successfully...\nIt may take some time to transfer.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
        await pr.hide();
        WidgetInspectorService.instance.forceRebuild();
      }
      else{
        Fluttertoast.showToast(
            msg: "Enter Your Phone Number First!!!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
      }
    }
    else{
      Fluttertoast.showToast(
          msg: "Invalid Amount",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).secondaryHeaderColor,
          fontSize: 16.0
      );
    }
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
          FutureBuilder(
              future: FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                if (mdata.hasData) {
                  return Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 40.w,vertical: 5.h),
                        child: Container(
                          width: double.infinity,
                          height: 150.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment:MainAxisAlignment.center,
                              children: [
                                Text(
                                  'My Wallet',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.w900),
                                ),
                                Padding(
                                  padding:  EdgeInsets.only(top:20.h),
                                  child: Row(
                                    mainAxisAlignment:MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Balance: ',
                                        style: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        '₹' + mdata.data['Wallet'].toString(),
                                        style: TextStyle(
                                            color: Theme.of(context).secondaryHeaderColor,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(top:20.h),
                        child: Text(
                          'Settlement',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(top:20.h),
                        child: Center(
                          child: ToggleButtons(
                            children: <Widget>[
                              Text(
                                '  GPay  ',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '  PhonePe  ',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '  Paytm  ',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600),
                              ),

                            ],
                            fillColor: Theme.of(context).accentColor,
                            isSelected: isSelected,
                            borderRadius: BorderRadius.circular(10),
                            onPressed: (int index) {
                              setState(() {
                                for (int indexBtn = 0;indexBtn < isSelected.length;indexBtn++) {
                                  if (indexBtn == index) {
                                    isSelected[indexBtn] = !isSelected[indexBtn];
                                  } else {
                                    isSelected[indexBtn] = false;
                                  }
                                  if(isSelected[indexBtn] == true){
                                    if(isSelected[0] == true){
                                      tType = 'GPay';
                                    }
                                    if(isSelected[1] == true){
                                      tType = 'PhonePe';
                                    }
                                    if(isSelected[2] == true){
                                      tType = 'Paytm';
                                    }

                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 30.h),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(30),
                                ),
                              ),
                              filled: true,
                              prefixIcon: Icon(
                                Icons.phone_android_outlined,
                                color: Theme.of(context).accentColor,
                              ),
                              hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                              hintText: "Phone Number",
                              fillColor: Theme.of(context).cardColor),
                          onChanged: (value) {
                            upiPhone = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w,vertical: 10.h),
                        child: SizedBox(
                          width: 170.w,
                          height: 60.h,
                          child: FlatButton(
                            onPressed:(){
                              requestTransfer(mdata.data['Wallet']);
                            },
                            child: Text(
                              'Request Transfer',
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
                  return Center(child: Image.asset("images/DualBall.gif",height: 100.h,));
                }
              }),
        ],
      ),
    );
  }
}
