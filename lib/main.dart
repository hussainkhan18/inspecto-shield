import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/LanguageTranslate/l10n.dart';
import 'package:hash_mufattish/Providers/checklist_Provider.dart';
import 'package:hash_mufattish/Providers/edit_Profile_Provider.dart';
import 'package:hash_mufattish/Providers/local_Provider.dart';
import 'package:hash_mufattish/Screens/my_record.dart';
import 'package:hash_mufattish/Screens/new_inspection.dart';
import 'package:hash_mufattish/Screens/splashscreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<ChecklistProvider>(
            create: (_) => ChecklistProvider()),
        ChangeNotifierProvider<EditProfileProvider>(
            create: (_) => EditProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Set the status bar color and brightness
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff0DC5B9),
      statusBarIconBrightness:
          Brightness.dark, // Set the status bar icons to dark for visibility
      statusBarBrightness: Brightness.light,
    ));
    final provider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
        locale: provider.locale,
        supportedLocales: L10n.all,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (deviceLocale != null &&
                deviceLocale.languageCode == locale.languageCode) {
              return deviceLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen());
  }
}
