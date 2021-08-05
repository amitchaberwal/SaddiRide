import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
class AccountPage extends StatefulWidget {
  const AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File _imageFile = null;
  bool processed = false;
  final databaseReference = FirebaseFirestore.instance;
  final picker = ImagePicker();
  ProgressDialog pr;
  Map<String,dynamic> acData = new Map();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }


  @override
  void initState() {
    super.initState();
    getData();
  }
  Future uploadData(BuildContext context) async {
    await pr.show();
    String uphone = FirebaseAuth.instance.currentUser.phoneNumber;

    if(_imageFile != null){
      String fileName = basename(_imageFile.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('Driver/$uphone/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      Reference imgRef = await FirebaseStorage.instance.refFromURL(acData['ProfileImage']);
      await imgRef.delete();
      taskSnapshot.ref.getDownloadURL().then(
              (value) => acData['ProfileImage'] = value
      );
    }
      await databaseReference.collection('Driver').doc(uphone).collection('Account').doc('Profile').update(acData);
      Fluttertoast.showToast(
          msg: "Updated Successfully...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).secondaryHeaderColor,
          fontSize: 16.0
      );
      await pr.hide();
  }

  void getData() async {
    DocumentSnapshot mydata =   await FirebaseFirestore.instance.collection('Driver').doc(await FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get();
    acData = mydata.data();
    setState(() {
      processed = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'Updating...',
        borderRadius: 10.0,
        backgroundColor: Theme.of(context).primaryColor,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Theme.of(context).secondaryHeaderColor, fontSize: 19.sp, fontWeight: FontWeight.w600)
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,

      body: new ListView(
        children: [
          Center(
            child: Padding(
              padding:  EdgeInsets.only(top:10.h),
              child: Text(
                FirebaseAuth.instance.currentUser.phoneNumber,
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 25.sp,fontWeight: FontWeight.w500),
              ),
            ),
          ),
          SizedBox(height: 80.h,),
          (processed == true)?
          Column(
            children: [
              Stack(
                children: <Widget>[
                  Center(
                    child: _imageFile != null
                        ? ClipOval(
                      child: Image.file(_imageFile,fit: BoxFit.cover,height: 150.r,width: 150.r,),
                    )
                        : FlatButton(
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:acData['ProfileImage'],
                          placeholder: (context, url) =>
                              Center(child: Image.asset("images/Ripple2.gif",height: 100.h,)),
                          fit: BoxFit.cover,
                          width: 150.r,
                          height: 150.r,
                        ),
                      ),
                      onPressed: pickImage,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 15.h),
                child: TextFormField(
                  controller: TextEditingController(text: acData['Name'],),
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30),
                        ),
                      ),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.person,
                        color: Theme.of(context).accentColor,
                      ),
                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      hintText: "Name",
                      fillColor: Theme.of(context).cardColor),
                  onChanged: (value) {
                    acData['Name'] = value;
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 15.h),
                child: TextFormField(
                  controller: TextEditingController(text: acData['Email'],),
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30),
                        ),
                      ),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.email,
                        color: Theme.of(context).accentColor,
                      ),
                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      hintText: "Email",
                      fillColor: Theme.of(context).cardColor),
                  onChanged: (value) {
                    acData['Email'] = value;
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 15.h),
                child: TextFormField(
                  controller: TextEditingController(text: acData['PinCode'],),
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
                        Icons.home,
                        color: Theme.of(context).accentColor,
                      ),
                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                      hintText: "PinCode",
                      fillColor: Theme.of(context).cardColor),
                  onChanged: (value) {
                    acData['PinCode'] = value;
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: SizedBox(
                  width: 170.w,
                  height: 60.h,
                  child: FlatButton(
                    onPressed:()=>uploadData(context),
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    color: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                ),
              ),
            ],
          )
              :Center(child: Image.asset("images/DualBall.gif",height: 100.h,))
        ],
      ),
    );
  }
}
