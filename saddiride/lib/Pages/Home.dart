import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:saddiride/Pages/VehiclesList.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  static Map<String,dynamic> uProfile;
  const Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String sitem = "";
  bool processed = false;
  List<DocumentSnapshot> banners = [];
  bool bprocessed = false;
  List<String> locList = ['India'];

  @override
  void initState() {
    super.initState();
    getBanners();
  }
  getProfile()async{
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection('User').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get();
    Home.uProfile = ds.data();
    locList.add(ds.data()['PinCode']);
  }
  getBanners() async {
    await getProfile();
    print(locList);
    QuerySnapshot querySnapshot;
    querySnapshot = await FirebaseFirestore.instance.collection('Banners').where('Location',arrayContainsAny: locList).orderBy('PostDate',descending: true).get();
    banners.addAll(querySnapshot.docs);
    setState(() {
      bprocessed = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    Widget image_carousel = new Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        height: 200.h,
        child: (bprocessed == true)?
        (banners.isNotEmpty)?
        Carousel(
          borderRadius: true,
          radius: Radius.circular(20),
          boxFit: BoxFit.cover,
          images: banners.map((document) => GestureDetector(
            onTap: ()async{
              String url = document.data()['Link'];
              if (await canLaunch(url))
                await launch(url);
              else
                throw "Could not launch $url";
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                imageUrl:document.data()['Image'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: Image.asset("images/Ripple2.gif",height: 100.h,)),
              ),
            ),
          ),).toList(),
          autoplay: true,
          autoplayDuration: Duration(milliseconds: 4000),
          animationCurve: Curves.fastOutSlowIn,
          animationDuration: Duration(milliseconds: 1000),
          indicatorBgPadding: 6,
          dotSize: 4,
          dotIncreasedColor: Theme.of(context).accentColor,
          dotColor: Colors.black,
        )
            :Image.asset("images/VC_bright.png")
            :Center(child: Image.asset("images/DualBall.gif",height: 100.h,))

    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'HOME',
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
            padding:  EdgeInsets.fromLTRB(8.w, 20.h, 8.w, 8.h),
            child: image_carousel,
          ),
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 10.h),
            child: Center(
              child: Text(
                'Cab Services',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 5.w,right: 5.w),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                      child: Image.asset("Assets/CAB_Background.png")
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                    color: Color(0xFFFFDD00),
                  ),
                  child: Padding(
                    padding:  EdgeInsets.only(bottom: 30.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 150.w,
                          height: 200.h,
                          child: MaterialButton(
                            onPressed:(){
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return TripInfo(vcat: 'Cab',vsubcat: 'Commercial',);
                                  }
                              );
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("Assets/Commercial_Cab.png",color: Theme.of(context).accentColor,height: 80.h,),
                                  Padding(
                                    padding:  EdgeInsets.only(top:10.h),
                                    child: Text(
                                      'Book Cab',
                                      style: TextStyle(fontSize: 14.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                        SizedBox(
                          width: 150.w,
                          height: 200.h,
                          child: MaterialButton(
                            onPressed:(){
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return TripInfo(vcat: 'Cab',vsubcat: 'Carpool',);
                                  }
                              );
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("Assets/Carpool_Cab.png",color: Theme.of(context).accentColor,height: 80.h,),
                                  Padding(
                                    padding:  EdgeInsets.only(top:10.h),
                                    child: Text(
                                      'Carpool',
                                      style: TextStyle(fontSize: 14.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 10.h),
            child: Center(
              child: Text(
                'Marriage Booking',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 5.w,right: 5.w,),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                      child: Image.asset("Assets/MB_Background.png")
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                    color: Color(0xFFFFDD00),
                  ),
                  child: Padding(
                    padding:  EdgeInsets.only(bottom: 30.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 150.w,
                          height: 200.h,
                          child: MaterialButton(
                            onPressed:(){
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return TripInfo(vcat: 'MarrigeBooking',vsubcat: 'Premium',);
                                  }
                              );
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("Assets/Premium_Wedding.png",color: Theme.of(context).accentColor,height: 80.h,),
                                  Padding(
                                    padding:  EdgeInsets.only(top:10.h),
                                    child: Text(
                                      'Premium Vehicles',
                                      style: TextStyle(fontSize: 14.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                        SizedBox(
                          width: 150.w,
                          height: 200.h,
                          child: MaterialButton(
                            onPressed:(){
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return TripInfo(vcat: 'MarrigeBooking',vsubcat: 'Budget',);
                                  }
                              );
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("Assets/Budget_Wedding.png",color: Theme.of(context).accentColor,height: 80.h,),
                                  Padding(
                                    padding:  EdgeInsets.only(top:10.h),
                                    child: Text(
                                      'Budget Vehicles',
                                      style: TextStyle(fontSize: 14.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(vertical: 10.h),
            child: Center(
              child: Text(
                'Tours & Travel',
                style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 5.w,right: 5.w,),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                      child: Image.asset("Assets/TOUR_Background.png")
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                    color: Color(0xFFFFDD00),
                  ),
                  child: Padding(
                    padding:  EdgeInsets.only(bottom: 30.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 150.w,
                          height: 200.h,
                          child: MaterialButton(
                            onPressed:(){
                              showDialog(context: context,
                                  builder: (BuildContext context){
                                    return TripInfo(vcat: 'Tourism',vsubcat: 'Budget',);
                                  }
                              );
                            },
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("Assets/Budget_Tourism.png",color:Theme.of(context).accentColor,height: 80.h,),
                                  Padding(
                                    padding:  EdgeInsets.only(top:10.h),
                                    child: Text(
                                      'Book Traveller',
                                      style: TextStyle(fontSize: 14.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class TripInfo extends StatefulWidget {
  final String vcat,vsubcat;
  const TripInfo({Key key, this.vcat, this.vsubcat}) : super(key: key);

  @override
  _TripInfoState createState() => _TripInfoState();
}

class _TripInfoState extends State<TripInfo> {
  String origin,destination,tdate;
  DateTime _selectedDate;
  String sdate;

  void pickDateDialog() {
    showDatePicker(
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).accentColor,
                onPrimary: Theme.of(context).primaryColor,
                surface: Theme.of(context).accentColor,
                onSurface: Theme.of(context).secondaryHeaderColor,
              ),
              dialogBackgroundColor:Theme.of(context).primaryColor,
            ),
            child: child,
          );
        },

        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2050)).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        sdate = DateFormat('dd-MM-yyyy').format(_selectedDate);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
          height: 280.h,
          margin: EdgeInsets.only(top: 1.h),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView(children: <Widget>[
            Padding(
              padding:  EdgeInsets.only(top: 10.h,bottom: 10.h),
              child: Center(
                child: Text(
                  'Trip Info',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
              Column(
                children: [
                  if(widget.vcat == 'Cab' && widget.vsubcat == 'Commercial')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Origin',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "Origin",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      origin = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Destination',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "Destination",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      destination = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                  if(widget.vcat == 'Cab' && widget.vsubcat == 'Carpool')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Origin',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "Origin",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      origin = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Destination',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "Destination",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      destination = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                  if(widget.vcat == 'MarrigeBooking')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'City Name',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 150.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor,),
                                        hintText: "City Name",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      origin = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  if(widget.vcat == 'Tourism')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Origin',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "Origin",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      origin = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Destination',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    keyboardType: TextInputType.name,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "Destination",
                                        fillColor: Theme.of(context).primaryColor),
                                    onChanged: (value) {
                                      destination = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            Padding(
              padding:  EdgeInsets.fromLTRB(50.w, 10.h, 50.w, 10.h),
              child: SizedBox(
                height: 60.h,
                child: FlatButton(
                  onPressed:(){
                    pickDateDialog();
                  },
                  child: Center(
                    child: Text((_selectedDate == null)?"Choose Date":sdate,style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.w600 ),),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 70.w,vertical: 10.h),
              child: SizedBox(
                height: 60.h,
                child: FlatButton(
                  onPressed:(){
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (BuildContext context) => VehiclesList(vcat: widget.vcat,vsubcat: widget.vsubcat,origin: origin,destination: destination,tdate: sdate,)));

                  },
                  child: Center(
                    child: Text("Next",style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w800 ),),
                  ),
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
            ),

          ])),
    );
  }
}


