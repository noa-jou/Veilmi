import 'package:flutter/material.dart';

// App-specific imports.
// These files contain the localization logic, the main home screen,
// and the settings service that loads saved preferences.
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'settings/settings_service.dart';

// This is the app entry point.
// Flutter starts here when the app launches.
Future<void> main() async {
  // This makes sure Flutter is fully initialized before we run the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Create the settings service and load the saved language from storage.
  const settingsService = SettingsService();

  final languageCode = await settingsService.loadLanguageCode();

  // Start the app and pass the saved locale so the UI can use it.
  runApp(VeilmiApp(initialLocale: Locale(languageCode)));
}

// A StatefulWidget is used when the widget needs to change over time.
// In this app, the locale can change, so the app state must be tracked.
class VeilmiApp extends StatefulWidget {
  const VeilmiApp({super.key, required this.initialLocale});

  // The language value this app should start with.
  final Locale initialLocale;

  @override
  State<VeilmiApp> createState() => _VeilmiAppState();
}

// This is the state class for VeilmiApp.
// It stores the current locale and updates it when the user changes language.
class _VeilmiAppState extends State<VeilmiApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    // When the widget is first created, use the locale that was loaded earlier.
    _locale = widget.initialLocale;
  }

  // This method updates the current locale and tells Flutter to rebuild the UI.
  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root of a Material Design app.
    // It contains the app theme, localization settings, and the first screen.
    return MaterialApp(
      // Current language for the app.
      locale: _locale,

      // This gives the app title using the localization file.
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appTitle;
      },

      // Hide the debug banner in the top-right corner during development.
      debugShowCheckedModeBanner: false,

      // App theme configuration.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Localization setup for supported languages.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // The main screen shown when the app starts.
      // It also receives the current locale and a function to change it.
      home: HomeScreen(currentLocale: _locale, onLocaleChanged: _changeLocale),
    );
  }
}
