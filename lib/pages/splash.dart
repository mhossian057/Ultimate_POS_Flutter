import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/otherHelpers.dart';
import '../locale/MyLocalizations.dart';
import '../pages/login.dart';

// ignore: must_be_immutable
class Splash extends StatelessWidget {
  static int themeType = 1;
  ThemeData themeData = AppTheme.getThemeFromThemeMode(themeType);
  CustomAppTheme customAppTheme = AppTheme.getCustomAppTheme(themeType);

  @override
  Widget build(BuildContext context) {
    MySize().init(context);

    return Scaffold(
      body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Image.asset(
                'assets/images/splash_screen.png',
                fit: BoxFit.fill,
                height: MySize.screenHeight! * 0.75,
                width: MySize.screenWidth,
              ),
      SizedBox(height: MySize.size20),
      Text(AppLocalizations.of(context).translate('welcome'),
          style: AppTheme.getTextStyle(themeData.textTheme.headlineLarge,
              color: themeData.colorScheme.onSurface)),
      SizedBox(height: MySize.size20),
      ElevatedButton.icon(
        onPressed: () async {
          await Helper().requestAppPermission();
          SharedPreferences prefs =
          await SharedPreferences.getInstance();
          if (prefs.getInt('userId') != null) {
            USERID = prefs.getInt('userId');
            Config.userId = USERID;
            Helper().jobScheduler();
            //Take to home page
            Navigator.of(context).pushReplacementNamed('/home');
          } else
            Navigator.of(context).pushReplacementNamed('/login');
        },
        icon: Icon(Icons.navigate_next,
            color: themeData.colorScheme.primary),
        label: Text(AppLocalizations.of(context).translate('login'),
            style: AppTheme.getTextStyle(themeData.textTheme.bodyLarge,
                color: themeData.colorScheme.primary, fontWeight: 600)),
        style: ElevatedButton.styleFrom(
            backgroundColor: themeData.colorScheme.onPrimary,
            shadowColor: themeData.colorScheme.primary),
      ),
      Visibility(
        visible: Config().showRegister,
        child: Padding(
          padding: EdgeInsets.all(MySize.size10!),
          child: GestureDetector(
            child: Text(
                AppLocalizations.of(context).translate('register'),
                style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyLarge,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600)),
            onTap: () async {
              await launch('${Config.baseUrl}business/register');
            },
          ),
        ),
      )
      ],
    ),
    ),
    );
  }
}
