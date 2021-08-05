import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Routes extends StatefulWidget {
  final String vid,vcat,vsubcat;
  const Routes({Key key, this.vid, this.vcat, this.vsubcat,}) : super(key: key);

  @override
  _RoutesState createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Vehicles Routes',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          new IconButton(
            icon: Icon(
              Icons.add_box_rounded,
              color: Theme.of(context).accentColor,
              size: 35.r,
            ),
            onPressed: (){
              showDialog(context: context,
                  builder: (BuildContext context){
                    return CreateRoute(vsubcat: widget.vsubcat,vcat: widget.vcat,vid: widget.vid,);
                  }
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Routes').where('VehicleID',isEqualTo: widget.vid).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot>snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data.docs.map((mdoc) => Padding(
                      padding:  EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
                      child:Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding:  EdgeInsets.only(top:10.h,bottom: 10.h),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  if(mdoc['VehicleCategory'] == 'Cab' && mdoc['VehicleSubCategory'] == 'Commercial')
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
                                                Text(
                                                  mdoc['Origin'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
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
                                                Text(
                                                  mdoc['Destination'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.only(top:10.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Time:',
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w300),
                                                  ),
                                                  Text(
                                                    mdoc['Time'],
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Fare: ',
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w300),
                                                  ),
                                                  Text(
                                                    '₹'+mdoc['Fare'].toString(),
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),

                                  if(mdoc['VehicleCategory'] == 'Cab' && mdoc['VehicleSubCategory'] == 'Carpool')
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
                                                Text(
                                                  mdoc['Origin'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
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
                                                Text(
                                                  mdoc['Destination'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.only(top:10.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Time:',
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w300),
                                                  ),
                                                  Text(
                                                    mdoc['Time'],
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Date:',
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w300),
                                                  ),
                                                  Text(
                                                    mdoc['Date'],
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.only(top:10.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Fare: ',
                                                style: TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w300),
                                              ),
                                              Text(
                                                '₹'+mdoc['Fare'].toString(),
                                                style: TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  if(mdoc['VehicleCategory'] == 'MarrigeBooking')
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  'City',
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w300),
                                                ),
                                                Text(
                                                  mdoc['Origin'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  'PinCode',
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w300),
                                                ),
                                                Text(
                                                  mdoc['PinCode'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.only(top:10.h),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Fare: ',
                                                style: TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w300),
                                              ),
                                              Text(
                                                '₹'+mdoc['Fare'].toString() + ' per km',
                                                style: TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),

                                  if(mdoc['VehicleCategory'] == 'Tourism')
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
                                                Text(
                                                  mdoc['Origin'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
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
                                                Text(
                                                  mdoc['Destination'],
                                                  style: TextStyle(
                                                      color: Theme.of(context).secondaryHeaderColor,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w800),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.only(top:10.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Time:',
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w300),
                                                  ),
                                                  Text(
                                                    mdoc['Time'],
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Date:',
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w300),
                                                  ),
                                                  Text(
                                                    mdoc['Date'],
                                                    style: TextStyle(
                                                        color: Theme.of(context).secondaryHeaderColor,
                                                        fontSize: 14.sp,
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:  EdgeInsets.only(top:10.h),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Fare: ',
                                                style: TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w300),
                                              ),
                                              Text(
                                                '₹'+mdoc['Fare'].toString(),
                                                style: TextStyle(
                                                    color: Theme.of(context).secondaryHeaderColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  onPressed: () async {
                                    showDialog(context: context,
                                        builder: (BuildContext context){
                                          return CreateRoute(vid: widget.vid,vcat: widget.vcat,vsubcat: widget.vsubcat,routeid: mdoc.id,);
                                        }
                                    );
                                  },
                                  icon: CircleAvatar(
                                    child: Icon(Icons.edit,
                                      size: 15.r,
                                      color: Theme.of(context).secondaryHeaderColor,
                                    ),
                                    backgroundColor: Theme.of(context).accentColor,
                                    radius: 20.r,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('Routes').doc(mdoc.id).delete();
                                  },
                                  icon: Icon(Icons.delete,
                                    size: 25.r,
                                  ),
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    )
                    ).toList(),
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

class CreateRoute extends StatefulWidget {
  final String vid,vcat,vsubcat,routeid;
  const CreateRoute({Key key, this.vid, this.vcat, this.vsubcat, this.routeid}) : super(key: key);

  @override
  _CreateRouteState createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {

  Map<String,dynamic> routeData = new Map();
  ProgressDialog pr;
  bool processed = false;
  DateTime _selectedDate;
  TimeOfDay _pickedTime;
  String sdate,stime;

  @override
  void initState() {
    super.initState();
    getData();

  }
  void getData()async{
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection('Routes').doc(widget.routeid).get();
    if(ds.exists){
      routeData = ds.data();
    }
    setState(() {
      processed = true;
    });
  }
  Future uploadData(BuildContext context) async {
    await pr.show();


    if(widget.routeid != null){
      await FirebaseFirestore.instance.collection('Routes').doc(widget.routeid).update(routeData);
    }
    else{
      routeData['VehicleID'] = widget.vid;
      routeData['VehicleCategory'] = widget.vcat;
      routeData['VehicleSubCategory'] = widget.vsubcat;
      await FirebaseFirestore.instance.collection('Routes').doc().set(routeData);
    }

    Fluttertoast.showToast(
        msg: "Route Created Successfully...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Theme.of(context).secondaryHeaderColor,
        fontSize: 16.0
    );
    await pr.hide();
    Navigator.pop(context);
  }
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
        routeData['Date'] = DateFormat('dd-MM-yyyy').format(_selectedDate);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(
        message: 'Uploading...',
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
          height: 400.h,
          margin: EdgeInsets.only(top: 1.h),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView(children: <Widget>[
            Padding(
              padding:  EdgeInsets.only(top: 10.h),
              child: Center(
                child: Text(
                  'Route',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if(processed == true)
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
                                  controller: TextEditingController(text: routeData['Origin']),
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
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    routeData['Origin'] = value.toUpperCase();
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
                                  controller: TextEditingController(text: routeData['Destination']),
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
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    routeData['Destination'] = value.toUpperCase();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'PickUp',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(
                                width: 130.w,
                                child: TextFormField(
                                  controller: TextEditingController(text: routeData['Pickup']),
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
                                      hintText: "PickUp Address",
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    routeData['Pickup'] = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Drop',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(
                                width: 130.w,
                                child: TextFormField(
                                  controller: TextEditingController(text: routeData['Drop']),
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
                                      hintText: "Drop",
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    routeData['Drop'] = value.toUpperCase();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top:2.h),
                                child: SizedBox(
                                  height: 60.h,
                                  width:140.w,
                                  child: FlatButton(
                                    onPressed:()async {
                                      TimeOfDay picked = await showTimePicker(
                                        context: context,
                                        builder: (BuildContext context, Widget child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: Theme.of(context).accentColor,
                                                onPrimary: Theme.of(context).primaryColor,
                                                surface: Theme.of(context).primaryColor,
                                                onSurface: Theme.of(context).secondaryHeaderColor,
                                              ),
                                              dialogBackgroundColor:Theme.of(context).primaryColor,
                                            ),
                                            child: child,
                                          );
                                        },
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if(picked != null){
                                        setState(() {
                                          _pickedTime = picked;
                                          routeData['Time'] = picked.format(context);
                                        });
                                      }

                                    },
                                    child: Center(
                                      child: Text((_pickedTime == null)?"Choose Time":routeData['Time'],style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.w600 ),),
                                    ),
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Fare',
                                style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(
                                width: 130.w,
                                child: TextFormField(
                                  controller: TextEditingController(text: (routeData['Fare'] != null)?routeData['Fare'].toString():null),
                                  keyboardType: TextInputType.number,
                                  decoration: new InputDecoration(
                                      border: new OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(15),
                                        ),
                                      ),
                                      filled: true,
                                      hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                      hintText: "₹",
                                      fillColor: Theme.of(context).cardColor),
                                  onChanged: (value) {
                                    routeData['Fare'] = int.parse(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 50.h,)
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
                                    controller: TextEditingController(text: routeData['Origin']),
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
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Origin'] = value.toUpperCase();
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
                                    controller: TextEditingController(text: routeData['Destination']),
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
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Destination'] = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'PickUp',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    controller: TextEditingController(text: routeData['Pickup']),
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
                                        hintText: "PickUp Address",
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Pickup'] = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Drop',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    controller: TextEditingController(text: routeData['Drop']),
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
                                        hintText: "Drop",
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Drop'] = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                Padding(
                                  padding:  EdgeInsets.only(top:2.h),
                                  child: SizedBox(
                                    height: 60.h,
                                    width:140.w,
                                    child: FlatButton(
                                      onPressed:()async {
                                        TimeOfDay picked = await showTimePicker(
                                          context: context,
                                          builder: (BuildContext context, Widget child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Theme.of(context).accentColor,
                                                  onPrimary: Theme.of(context).primaryColor,
                                                  surface: Theme.of(context).primaryColor,
                                                  onSurface: Theme.of(context).secondaryHeaderColor,
                                                ),
                                                dialogBackgroundColor:Theme.of(context).primaryColor,
                                              ),
                                              child: child,
                                            );
                                          },
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if(picked != null){
                                          setState(() {
                                            _pickedTime = picked;
                                            routeData['Time'] = picked.format(context);
                                          });
                                        }

                                      },
                                      child: Center(
                                        child: Text((_pickedTime == null)?"Choose Time":routeData['Time'],style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.w600 ),),
                                      ),
                                      color: Theme.of(context).cardColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                Padding(
                                  padding:  EdgeInsets.only(top:2.h),
                                  child: SizedBox(
                                    height: 60.h,
                                    width:140.w,
                                    child: FlatButton(
                                      onPressed:(){
                                        pickDateDialog();
                                      },
                                      child: Center(
                                        child: Text((_selectedDate == null)?"Choose Date":routeData['Date'],style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.w600 ),),
                                      ),
                                      color: Theme.of(context).cardColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Fare',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300),
                            ),
                            SizedBox(
                              width: 100.w,
                              child: TextFormField(
                                controller: TextEditingController(text: (routeData['Fare'] != null)?routeData['Fare'].toString():null),
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15),
                                      ),
                                    ),
                                    filled: true,
                                    hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                    hintText: "₹",
                                    fillColor: Theme.of(context).cardColor),
                                onChanged: (value) {
                                  routeData['Fare'] = int.parse(value);
                                },
                              ),
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
                                  width: 100.w,
                                  child: TextFormField(
                                    controller: TextEditingController(text: routeData['Origin']),
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
                                        hintText: "City Name",
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Origin'] = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'PinCode',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 100.w,
                                  child: TextFormField(
                                    controller: TextEditingController(text: routeData['PinCode']),
                                    keyboardType: TextInputType.number,
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(15),
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                        hintText: "PinCode",
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['PinCode'] = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Rate per Km',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300),
                            ),
                            SizedBox(
                              width: 100.w,
                              child: TextFormField(
                                controller: TextEditingController(text: (routeData['Fare'] != null)?routeData['Fare'].toString():null),
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15),
                                      ),
                                    ),
                                    filled: true,
                                    hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                    hintText: "₹",
                                    fillColor: Theme.of(context).cardColor),
                                onChanged: (value) {
                                  routeData['Fare'] = int.parse(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.h,)
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
                                    controller: TextEditingController(text: routeData['Origin']),
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
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Origin'] = value.toUpperCase();
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
                                    controller: TextEditingController(text: routeData['Destination']),
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
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Destination'] = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'PickUp',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    controller: TextEditingController(text: routeData['Pickup']),
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
                                        hintText: "PickUp Address",
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Pickup'] = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Drop',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 130.w,
                                  child: TextFormField(
                                    controller: TextEditingController(text: routeData['Drop']),
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
                                        hintText: "Drop",
                                        fillColor: Theme.of(context).cardColor),
                                    onChanged: (value) {
                                      routeData['Drop'] = value.toUpperCase();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                Padding(
                                  padding:  EdgeInsets.only(top:2.h),
                                  child: SizedBox(
                                    height: 60.h,
                                    width:140.w,
                                    child: FlatButton(
                                      onPressed:()async {
                                        TimeOfDay picked = await showTimePicker(
                                          context: context,
                                          builder: (BuildContext context, Widget child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Theme.of(context).accentColor,
                                                  onPrimary: Theme.of(context).primaryColor,
                                                  surface: Theme.of(context).primaryColor,
                                                  onSurface: Theme.of(context).secondaryHeaderColor,
                                                ),
                                                dialogBackgroundColor:Theme.of(context).primaryColor,
                                              ),
                                              child: child,
                                            );
                                          },
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if(picked != null){
                                          setState(() {
                                            _pickedTime = picked;
                                            routeData['Time'] = picked.format(context);
                                          });
                                        }

                                      },
                                      child: Center(
                                        child: Text((_pickedTime == null)?"Choose Time":routeData['Time'],style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.w600 ),),
                                      ),
                                      color: Theme.of(context).cardColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w300),
                                ),
                                Padding(
                                  padding:  EdgeInsets.only(top:2.h),
                                  child: SizedBox(
                                    height: 60.h,
                                    width:140.w,
                                    child: FlatButton(
                                      onPressed:(){
                                        pickDateDialog();
                                      },
                                      child: Center(
                                        child: Text((_selectedDate == null)?"Choose Date":routeData['Date'],style: TextStyle(color: Colors.black,fontSize: 16.sp,fontWeight: FontWeight.w600 ),),
                                      ),
                                      color: Theme.of(context).cardColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Fare',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300),
                            ),
                            SizedBox(
                              width: 100.w,
                              child: TextFormField(
                                controller: TextEditingController(text: (routeData['Fare'] != null)?routeData['Fare'].toString():null),
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    border: new OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(15),
                                      ),
                                    ),
                                    filled: true,
                                    hintStyle: new TextStyle(color: Theme.of(context).secondaryHeaderColor),
                                    hintText: "₹",
                                    fillColor: Theme.of(context).cardColor),
                                onChanged: (value) {
                                  routeData['Fare'] = int.parse(value);
                                },
                              ),
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
                    uploadData(context);
                  },
                  child: Center(
                    child: Text("Submit",style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w800 ),),
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
