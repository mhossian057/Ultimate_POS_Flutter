import 'package:flutter/material.dart';

import '../helpers/AppTheme.dart';
import '../helpers/SizeConfig.dart';
import '../helpers/style.dart' as style;
import '../locale/MyLocalizations.dart';

Widget posBottomBar(page, context, [call]) {
  ThemeData themeData = AppTheme.getThemeFromThemeMode(1);
  return Material(
    elevation: 12,
    shadowColor: themeData.colorScheme.primary.withOpacity(0.3),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeData.colorScheme.surface,
            themeData.colorScheme.surface.withOpacity(0.95),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: themeData.colorScheme.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      height: MySize.size72,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          bottomBarMenu(
              context,
              '/home',
              AppLocalizations.of(context).translate('home'),
              page == "home",
              Icons.home,
              true),
          bottomBarMenu(
              context,
              '/products',
              AppLocalizations.of(context).translate('products'),
              page == "products",
              Icons.shop_two,
              true),
          bottomBarMenu(
              context,
              '/sale',
              AppLocalizations.of(context).translate('sales'),
              page == "sale",
              Icons.list,
              true),
        ],
      ),
    ),
  );
}

Widget bottomBarMenu(context, route, name, isSelected, icon,
    [replace, arguments]) {
  replace = (replace == null) ? false : replace;
  ThemeData themeData = Theme.of(context);
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(25.0),
      onTap: () {
        if (replace)
          Navigator.pushReplacementNamed(context, route, arguments: arguments);
        else
          Navigator.pushNamed(context, route, arguments: arguments);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    themeData.colorScheme.primary,
                    themeData.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeData.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? themeData.colorScheme.onPrimary
                  : themeData.colorScheme.onSurface.withOpacity(0.6),
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Text(
                name,
                style: AppTheme.getTextStyle(
                  themeData.textTheme.bodyMedium,
                  color: themeData.colorScheme.onPrimary,
                  fontWeight: 600,
                ),
              ),
            ]
          ],
        ),
      ),
    ),
  );
}

Widget cartBottomBar(route, name, context, [nextArguments]) {
  ThemeData themeData = AppTheme.getThemeFromThemeMode(1);
  //TODO: add some shadows.
  return Material(
    child: Container(
      color: themeData.colorScheme.onPrimary,
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          bottomBarMenu(context, route, name, true, Icons.arrow_forward, false,
              nextArguments),
        ],
      ),
    ),
  );
}

//syncAlert
syncing(time, context) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(),
        Container(
            margin: EdgeInsets.only(left: 5),
            child: Text("Sync in progress...")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      Future.delayed(Duration(seconds: time), () {
        Navigator.of(context).pop(true);
      });
      return alert;
    },
  );
}
