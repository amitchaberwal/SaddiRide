import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';
import 'package:saddiride/Pages/Booking.dart';
import 'package:saddiride/Pages/CurrentRide.dart';
import 'package:saddiride/Pages/Home.dart';
import 'package:saddiride/Pages/UpdatePage.dart';
import 'package:saddiride/Pages/UserPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    Home(),
    Bookings(),
    BookedRide(),
    UserPage(),
  ];

  @override
  void initState() {
    super.initState();
    checkVersion();
  }
  checkVersion()async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    DocumentSnapshot aData = await FirebaseFirestore.instance.collection('Admin').doc('AdminData').get();
    if(buildNumber >= aData.data()['MinUserBuildNumber']){
      print(buildNumber);
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          UpdateApp()), (Route<dynamic> route) => false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 25,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text('Home',style: TextStyle(fontSize: 10.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w400),),
            activeIcon: Icon(
              Icons.home,
              size: 35,
              color: Theme.of(context).accentColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              size: 25,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text('Booking History',style: TextStyle(fontSize: 10.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w400),),
            activeIcon: Icon(
              Icons.timelapse_outlined,
              size: 35,
              color: Theme.of(context).accentColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.directions_car_outlined,
              size: 25,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            title: Text('Booking',style: TextStyle(fontSize: 10.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w400),),
            activeIcon: Icon(
              Icons.directions_car_rounded,
              size: 35,
              color: Theme.of(context).accentColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline_outlined,
              color: Theme.of(context).secondaryHeaderColor,
              size: 25,
            ),
            title: Text('Profile',style: TextStyle(fontSize: 10.sp,color: Theme.of(context).secondaryHeaderColor,fontWeight: FontWeight.w400),),
            activeIcon: Icon(
              Icons.person,
              color: Theme.of(context).accentColor,
              size: 35,
            ),
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
