import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateApp extends StatelessWidget {
  const UpdateApp({ key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: new AppBar(
        title: Text(
          'Update',
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        //toolbarHeight: 60,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          width: 300.w,
          height: 300.h,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.only(top:50.h),
                child: Center(
                  child: Text(
                    'App Out-Of-Date',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 60.h),
                child: Center(
                  child: Text(
                    'Please Update the App to enjoy seamless and bug free experience.',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 150.w,
                    height: 50.h,
                    child: FlatButton(
                      onPressed:()async{
                        PackageInfo packageInfo = await PackageInfo.fromPlatform();
                        String pName = packageInfo.packageName;
                        String url = 'https://play.google.com/store/apps/details?id=' + pName;
                        if (await canLaunch(url))
                        await launch(url);
                        else
                        throw "Could not launch $url";
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'Update',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
