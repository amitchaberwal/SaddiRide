import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path/path.dart';
class VehicleRegistration extends StatefulWidget {
  const VehicleRegistration({Key key}) : super(key: key);

  @override
  _VehicleRegistrationState createState() => _VehicleRegistrationState();
}

class _VehicleRegistrationState extends State<VehicleRegistration> {
  String vnumber,vcat,vsubcat,vname,dname,dcontact,vseats,im1,im2,im3;

  File _imageFile = null,_imageFile1 = null,_imageFile2 = null;

  final picker = ImagePicker();
  ProgressDialog pr;

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }
  Future pickImageA() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile1 = File(pickedFile.path);
    });
  }
  Future pickImageB() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile2 = File(pickedFile.path);
    });
  }
  Future uploadData(BuildContext context)async{
    if (_imageFile == null || _imageFile1 == null || _imageFile2 == null) {
      Fluttertoast.showToast(
          msg: "Select images First!!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).secondaryHeaderColor,
          fontSize: 16.0
      );
    }
    else {
      if (vcat == null || vsubcat == null || vnumber == null || dname == null|| dcontact == null) {
        Fluttertoast.showToast(
            msg: "Please fill all details..",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
      }
      else{
        await pr.show();
        String uphone = FirebaseAuth.instance.currentUser.phoneNumber;
        DocumentReference dref = Firestore.instance.collection('Vehicles').doc();
        String did = dref.id;

        String fileName = basename(_imageFile.path);
        Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('Vehicles/$did/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        await taskSnapshot.ref.getDownloadURL().then(
                (value) => im1 = value
        );

        String fileName1 = basename(_imageFile1.path);
        Reference firebaseStorageRef1= FirebaseStorage.instance.ref().child('Vehicles/$did/$fileName1');
        UploadTask uploadTask1 = firebaseStorageRef1.putFile(_imageFile1);
        TaskSnapshot taskSnapshot1 = await uploadTask1;
        await taskSnapshot1.ref.getDownloadURL().then(
                (value) => im2 = value
        );

        String fileName2 = basename(_imageFile2.path);
        Reference firebaseStorageRef2 = FirebaseStorage.instance.ref().child('Vehicles/$did/$fileName2');
        UploadTask uploadTask2 = firebaseStorageRef2.putFile(_imageFile2);
        TaskSnapshot taskSnapshot2 = await uploadTask2;
        await taskSnapshot2.ref.getDownloadURL().then(
                (value) => im3 = value
        );
        await dref.set({
          'PhoneNumber':uphone,
          'VehicleName': vname,
          'VehicleNumber': vnumber,
          'Category' : vcat,
          'SubCategory' : vsubcat,
          'DriverName' : dname,
          'DriverContact' : dcontact,
          'Status' : 'Awaiting Confirmation',
          'Seats' : int.parse(vseats),
          'VehicleImage': im1,
          'RCImage': im2,
          'DLImage': im3,});
        Fluttertoast.showToast(
            msg: "Registration Successful...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).secondaryHeaderColor,
            fontSize: 16.0
        );
        await pr.hide();
        Navigator.of(context).pop();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'Registering...',
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
          'Vehicle Registration',
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h,horizontal: 15.w),
            child: DropdownButtonFormField(
              hint: Text(
                'Choose Category',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor),
              ),
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              value: vcat,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                ),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              onChanged: (newValue) async{
                setState(() {
                  vcat = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: "MarrigeBooking",
                  child: Text(
                    "Marriage Booking",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
                DropdownMenuItem(
                  value: "Cab",
                  child: Text(
                    "Cab",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
                DropdownMenuItem(
                  value: "Tourism",
                  child: Text(
                    "Tourism",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
              ],
            ),
          ),
          if(vcat == 'MarrigeBooking')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: DropdownButtonFormField(
              hint: Text(
                'Choose SubCategory',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor),
              ),
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              value: vsubcat,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                ),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              onChanged: (newValue) async{
                setState(() {
                  vsubcat = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: "Budget",
                  child: Text(
                    "Budget Vehicle",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
                DropdownMenuItem(
                  value: "Premium",
                  child: Text(
                    "Premium Vehicle",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
              ],
            ),
          ),
          if(vcat == 'Cab')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: DropdownButtonFormField(
              hint: Text(
                'Choose SubCategory',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor),
              ),
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              value: vsubcat,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                ),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              onChanged: (newValue) async{
                setState(() {
                  vsubcat = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: "Carpool",
                  child: Text(
                    "Car Pooling",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
                DropdownMenuItem(
                  value: "Commercial",
                  child: Text(
                    "Commercial Cab",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
              ],
            ),
          ),
          if(vcat == 'Tourism')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: DropdownButtonFormField(
              hint: Text(
                'Choose SubCategory',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor),
              ),
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              value: vsubcat,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                ),
              ),
              dropdownColor: Theme.of(context).primaryColor,
              onChanged: (newValue) async{
                setState(() {
                  vsubcat = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: "Budget",
                  child: Text(
                    "Budget",style: TextStyle(
                      color:
                      Theme.of(context).secondaryHeaderColor),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:  EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30),
                    ),
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.directions_car_outlined,
                    color: Theme.of(context).accentColor,
                  ),
                  hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  hintText: "Vehicle Number",
                  fillColor: Theme.of(context).cardColor),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                vnumber = value;
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30),
                    ),
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.drive_file_rename_outline,
                    color: Theme.of(context).accentColor,
                  ),
                  hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  hintText: "Vehicle Name",
                  fillColor: Theme.of(context).cardColor),
              onChanged: (value) {
                vname = value;
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
            child: TextField(
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
                    Icons.event_seat,
                    color: Theme.of(context).accentColor,
                  ),
                  hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                  hintText: "Passenger Seats in Vehicle",
                  fillColor: Theme.of(context).cardColor),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                vseats = value;
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
            child: TextField(
              keyboardType: TextInputType.name,
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
                  hintText: "Driver Name",
                  fillColor: Theme.of(context).cardColor),
              onChanged: (value) {
                dname = value;
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 0),
            child: TextField(
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
                  hintText: "Driver's Phone Number",
                  fillColor: Theme.of(context).cardColor),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                dcontact = value;
              },
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top:10.h),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    height: 200.h,
                    width: 320.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: _imageFile != null
                          ? ClipRRect(
                        child: Image.file(_imageFile,fit: BoxFit.cover,),
                      ) : FlatButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 100.r,
                              color: Theme.of(context).accentColor,
                            ),
                            Text(
                              "Select Vehicle's Photo",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onPressed: pickImage,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top:10.h),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    height: 200.h,
                    width: 320.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: _imageFile1 != null
                          ? ClipRRect(
                        child: Image.file(_imageFile1,fit: BoxFit.cover,),
                      ) : FlatButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sticky_note_2_rounded,
                              size: 100.r,
                              color: Theme.of(context).accentColor,
                            ),
                            Text(
                              "Select Vehicle's RC Photo",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onPressed: pickImageA,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top:10.h),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Container(
                    height: 200.h,
                    width: 320.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: _imageFile2 != null
                          ? ClipRRect(
                        child: Image.file(_imageFile2,fit: BoxFit.cover,),
                      ) : FlatButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_rounded,
                              size: 100.r,
                              color: Theme.of(context).accentColor,
                            ),
                            Text(
                              "Select Driver License Photo",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onPressed: pickImageB,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if(vcat != null && vsubcat != null)
            FutureBuilder(
                future: FirebaseFirestore.instance.collection('Admin').doc('Vehicles').collection('Registration').doc(vcat).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot>mdata) {
                  if (mdata.hasData) {
                    return Padding(
                      padding:  EdgeInsets.fromLTRB(0, 10.h, 0, 0),
                      child:Column(
                        children: [
                          Center(
                            child: Text('Registration Fee: ₹' + mdata.data[vsubcat]['Fee'].toString(),style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600),),
                          ),
                          Center(
                            child: Text('Subscription Period: ' + mdata.data[vsubcat]['Tenure'].toString() + ' Months',style: TextStyle(color: Theme.of(context).secondaryHeaderColor,fontSize: 14.sp,fontWeight: FontWeight.w600),),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),

          Padding(
            padding:  EdgeInsets.symmetric(vertical: 15.h,horizontal: 80.w),
            child: SizedBox(
              width: 10.w,
              height: 60.h,
              child: MaterialButton(
                onPressed:()=>uploadData(context),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
