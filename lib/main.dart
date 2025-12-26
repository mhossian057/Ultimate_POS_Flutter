import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'helpers/AppTheme.dart';
import 'helpers/routes.dart';
import 'helpers/api_logger.dart';
import 'locale/MyLocalizations.dart';
import 'providers/previous_price_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //orientation setting
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage? appLanguage;

  MyApp({this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguage>(
          create: (_) => appLanguage!,
        ),
        ChangeNotifierProvider<PreviousPriceProvider>(
          create: (_) => PreviousPriceProvider(),
        ),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          routes: Routes.generateRoute(),
          initialRoute: '/splash',
          debugShowCheckedModeBanner: false,
          //Turns on a little "DEBUG" banner in checked mode to indicate that the app is in checked mode.
          theme: AppTheme.getThemeFromThemeMode(1),
          locale: model.appLocal,
          supportedLocales: Config().supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      }),
    );
  }
}