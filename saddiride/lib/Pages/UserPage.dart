import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:saddiride/Pages/AccountPage.dart';
import 'package:saddiride/Pages/Home.dart';
import 'package:saddiride/Pages/Login/LoginPageA.dart';
class UserPage extends StatefulWidget {
  const UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Account',
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
          FutureBuilder(
              future: FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                if (mdata.hasData) {
                  return Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(top:30.h),
                        child: Column(
                          children: [
                            Hero(
                              tag:'pimg',
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:mdata.data['ProfileImage'],
                                  placeholder: (context, url) => Center(child: Image.asset("images/Spinner2.gif")),
                                  fit: BoxFit.cover,
                                  width: 160.r,
                                  height: 160.r,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top:30.h),
                              child: Text(mdata.data['Name'],
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp),
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.only(top:4.h),
                              child: Text(
                                FirebaseAuth.instance.currentUser.phoneNumber,
                                style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top:10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.monetization_on_rounded,color: Theme.of(context).accentColor,size: 25.r,),
                                  SizedBox(width: 5.w,),
                                  Text(mdata.data['Wallet'].toString(),
                                    style: TextStyle(
                                        color: Theme.of(context).secondaryHeaderColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50.h,),
                      GestureDetector(
                        onTap:(){
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (BuildContext context) => AccountPage(udata: mdata.data.data(),)));
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person,color: Theme.of(context).accentColor,size: 30.r,),
                              SizedBox(width: 20.w,),
                              Text('Edit Profile',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: Theme.of(context).accentColor,thickness: 1,indent: 50.w,endIndent: 50.w,),
                      GestureDetector(
                        onTap:()async{
                          var status = await showDialog(context: context, builder: (BuildContext context) {
                            return Settlement(
                                sAmount: mdata.data['Wallet']);
                          });
                          if(status == 'Success'){
                            print(status);
                            WidgetInspectorService.instance.forceRebuild();
                          }
                },
                        child: Container(
                          width: double.infinity,
                          height: 80.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.monetization_on_rounded,color: Theme.of(context).accentColor,size: 30.r,),
                              SizedBox(width: 20.w,),
                              Text('Settlements',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: Theme.of(context).accentColor,thickness: 1,indent: 50.w,endIndent: 50.w,),
                      GestureDetector(
                        onTap:()async{
                          try {
                            await FirebaseAuth.instance.signOut();
                            Fluttertoast.showToast(
                                msg: "Logged Out...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Theme.of(context).cardColor,
                                textColor: Theme.of(context).secondaryHeaderColor,
                                fontSize: 16.0);
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                LoginPage()), (Route<dynamic> route) => false);
                          } catch (e) {
                            print(e.toString());
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout,color: Theme.of(context).accentColor,size: 30.r,),
                              SizedBox(width: 20.w,),
                              Text('SignOut',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18.sp),
                              ),
                            ],
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
class Settlement extends StatefulWidget {
  final int sAmount;
  const Settlement({Key key, this.sAmount}) : super(key: key);

  @override
  _SettlementState createState() => _SettlementState();
}

class _SettlementState extends State<Settlement> {
  ProgressDialog pr;
  String upiPhone;
  List<bool> isSelected = [true, false, false];
  String tType;

  requestTransfer(BuildContext context)async{
    DateTime tdate = DateTime.now();
    String sdate = DateFormat('dd-MM-yyyy').format(tdate);
    if(widget.sAmount != 0){
      if(upiPhone != null){
        await pr.show();
        await FirebaseFirestore.instance.collection('Admin').doc('CashRequests').collection('User').doc().set({
          'PhoneNumber': FirebaseAuth.instance.currentUser.phoneNumber,
          'Name':Home.uProfile['Name'],
          'Email':Home.uProfile['Email'],
          'Amount':widget.sAmount,
          'TransferType':tType,
          'TransferPhone': upiPhone,
          'Date':sdate,
          'RequestTimeStamp':tdate
        });
        await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').update({
          'Wallet':0
        });
        await pr.hide();
        Fluttertoast.showToast(
            msg: "Request Sent Successfully...\nIt may take some time to transfer.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
        Navigator.of(context).pop('Success');
      }
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
            child: ListView(
              children: [
                Center(
                  child: Padding(
                    padding:  EdgeInsets.only(top:10.h),
                    child: Text('Credit Transfer',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18.sp),
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(top: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Amount: ₹',
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp),
                      ),
                      Text(widget.sAmount.toString(),
                        style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:  EdgeInsets.only(top:10.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 15.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: SizedBox(
                    width: 170.w,
                    height: 60.h,
                    child: FlatButton(
                      onPressed:(){
                        requestTransfer(context);
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
            )
        ));
  }
}

