import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:saddiridedriver/Pages/AccountPage.dart';
import 'package:saddiridedriver/Pages/BookingHistory.dart';
import 'package:saddiridedriver/Pages/Bookings.dart';
import 'package:saddiridedriver/Pages/Home.dart';
import 'package:saddiridedriver/Pages/Login/LoginPageA.dart';
import 'package:saddiridedriver/Pages/Payments.dart';
import 'package:saddiridedriver/Pages/UpdatePage.dart';
import 'package:saddiridedriver/Pages/Vehicle/Vehicle.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  int _selectedIndex = 0;
  int _selectedIndexA = 0;

  List<Widget> _widgetOptions = <Widget>[
    Home(),
    AccountPage(),
    MyVehicles(),
    Bookings(),
    BookingHistory(),
    Payments()
  ];
  List<String> _widgetBar = <String>[
    'Home',
    'Account',
    'My Vehicles',
    'Bookings',
    'Booking History',
    'Payment Settlement'
  ];

  Future<String> shareProduct(String productID) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://saddiridedriver.page.link',
      link: Uri.parse('https://saddiridedriver.page.link/user?id=$productID'),
      androidParameters: AndroidParameters(
        packageName: 'com.v4tech.saddiridedriver',
        fallbackUrl: Uri.parse('www.google.com'),
      ),
      iosParameters: IosParameters(
        bundleId: 'com.v4tech.saddiridedriver',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;

    final Uri dynamicUrl = await parameters.buildUrl();
    String content = 'Download and install Saddi Ride Driver App and Signup Using my link\n' + shortUrl.toString();
    Share.share(content,subject: 'Download Saddi Ride Driver');
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<void> logout() async {
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
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkVersion();
  }
  checkVersion()async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);
    DocumentSnapshot aData = await FirebaseFirestore.instance.collection('Admin').doc('AdminData').get();
    if(buildNumber >= aData.data()['MinDriverBuildNumber']){
      print(buildNumber);
    }
    else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          UpdateApp()), (Route<dynamic> route) => false);
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget drawerHeader = SizedBox(
      child: Column(
        children: [
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('Driver').doc(FirebaseAuth.instance.currentUser.phoneNumber).collection('Account').doc('Profile').get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> mdata) {
              if (mdata.hasData) {
                return Column(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: mdata.data['ProfileImage'],
                        placeholder: (context, url) =>
                            Center(child: Image.asset("images/Ripple2.gif",height: 100.h,)),
                        fit: BoxFit.cover,
                        width: 120.w,
                        height: 120.h,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      mdata.data['Name'],
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp),
                    )
                  ],
                );
              } else {
                return Center(child: Image.asset("images/DualBall.gif",height: 100));
              }
            },
          ),
          Padding(
            padding:  EdgeInsets.fromLTRB(0, 4.h, 0, 0),
            child: Text(
              FirebaseAuth.instance.currentUser.phoneNumber,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          _widgetBar.elementAt(_selectedIndexA),
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: 25.r,
            color: Theme.of(context).accentColor, //20
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
        elevation: 0,
        //toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,

      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).primaryColor,
          child: ListView(
            children: [
              Padding(
                padding:  EdgeInsets.fromLTRB(10.w, 30.h, 10.w, 15.h),
                child: drawerHeader,
              ),
              Divider(
                thickness: 1.h,
                color: Theme.of(context).accentColor,
                indent: 15.w,
                endIndent: 30.w,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                    _selectedIndexA = 0;

                  });
                  _scaffoldKey.currentState.openEndDrawer();

                },
                child: ListTile(
                  title: Text('Home',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).accentColor, //20
                  ),
                ),
              ),
              InkWell(
                onTap: () => {
                setState(() {
                _selectedIndex = 1;
                _selectedIndexA = 1;
                _scaffoldKey.currentState.openEndDrawer();
                })
                },
                child: ListTile(
                  title: Text('Account',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.account_circle,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: () => {
                  setState(() {
                    _selectedIndex = 2;
                    _selectedIndexA = 2;
                    _scaffoldKey.currentState.openEndDrawer();

                  })

                },
                child: ListTile(
                  title: Text('My Vehicle',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.directions_car,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: () => {
                  setState(() {
                    _selectedIndex = 3;
                    _selectedIndexA = 3;
                    _scaffoldKey.currentState.openEndDrawer();
                  })
                },
                child: ListTile(
                  title: Text('Bookings',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.event_note,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: () => {
                  setState(() {
                    _selectedIndex = 4;
                    _selectedIndexA = 4;
                    _scaffoldKey.currentState.openEndDrawer();
                  })
                },
                child: ListTile(
                  title: Text('Booking History',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.history,
                      color: Theme.of(context).accentColor),
                ),
              ),
              InkWell(
                onTap: () => {
                  setState(() {
                    _selectedIndex = 5;
                    _selectedIndexA = 5;
                    _scaffoldKey.currentState.openEndDrawer();
                  })
                },
                child: ListTile(
                  title: Text('Payment',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(Icons.payment,
                      color: Theme.of(context).accentColor),
                ),
              ),

              Divider(
                thickness: 1.h,
                color: Theme.of(context).accentColor,
                indent: 15.w,
                endIndent: 30.w,
              ),
              InkWell(
                onTap: ()
                {
                  shareProduct(FirebaseAuth.instance.currentUser.phoneNumber);
                },
                child: ListTile(
                  title: Text('Share App',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(
                    Icons.share,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              InkWell(
                onTap: logout,
                child: ListTile(
                  title: Text('Sign Out',
                      style: Theme.of(context).textTheme.bodyText1),
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
