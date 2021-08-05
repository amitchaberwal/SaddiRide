import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil_init.dart';
import 'package:saddiride/Pages/Login/Splash.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent
  ));
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(392, 835),
        allowFontScaling: false,
        builder: () => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.grey[50],
            scaffoldBackgroundColor: Colors.grey[100],
            accentColor: Colors.orange[800],
            secondaryHeaderColor: Colors.grey[900],
            cardColor: Colors.grey[200],
            textTheme:TextTheme(
              bodyText1: TextStyle(color: Colors.grey[900],fontSize: 20,letterSpacing: 1.0),
            ),
          ),
          home: Splash(),
        )
    );
  }
}
