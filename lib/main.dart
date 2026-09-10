import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const settingsService = SettingsService();

  final languageCode = await settingsService.loadLanguageCode();

  runApp(VeilmiApp(initialLocale: Locale(languageCode)));
}

class VeilmiApp extends StatefulWidget {
  const VeilmiApp({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  State<VeilmiApp> createState() => _VeilmiAppState();
}

class _VeilmiAppState extends State<VeilmiApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appTitle;
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(currentLocale: _locale, onLocaleChanged: _changeLocale),
    );
  }
}
