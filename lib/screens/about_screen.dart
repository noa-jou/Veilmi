import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

// This screen shows the app's information page.
// It explains what the project is, where to find the source code,
// and how users can support the project.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // These are the external links the app can open.
  // They are stored as Uri objects so they can be launched with the browser.
  static final Uri _githubUrl = Uri.parse('https://github.com/noa-jou/Veilmi');

  static final Uri _docsUrl = Uri.parse(
    'https://github.com/noa-jou/Veilmi/tree/main/docs',
  );

  // This is the link for support/donations.
  static final Uri _supportUrl = Uri.parse('https://buymeacoffee.com/noajou');

  // This helper method opens a URL in the device's default browser.
  // If opening fails, it shows a snackbar message to tell the user.
  Future<void> _openUrl(BuildContext context, Uri url) async {
    // Try to open the URL using the external app/browser.
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    // If it failed to open, show a message to the user.
    if (!opened && context.mounted) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the localized strings for this screen.
    final l10n = AppLocalizations.of(context)!;

    // Scaffold is the basic screen structure in Flutter.
    // It gives us an AppBar and a body area.
    return Scaffold(
      // Top bar of the screen.
      appBar: AppBar(title: Text(l10n.aboutVeilmi)),

      // ListView lets us stack widgets vertically with scrolling.
      // This screen is mostly a vertical list of information and buttons.
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),

          // App icon near the top.
          const Icon(Icons.shield_outlined, size: 64),
          const SizedBox(height: 12),

          // Main app name in the center.
          Text(
            'Veilmi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 32),

          // Section for open-source information.
          Text(l10n.openSource, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(l10n.openSourceDescription),
          const SizedBox(height: 12),
          Text(l10n.docsDescription),
          const SizedBox(height: 20),

          // A button to open the GitHub repo.
          OutlinedButton.icon(
            onPressed: () => _openUrl(context, _githubUrl),
            icon: const Icon(Icons.code),
            label: Text(l10n.viewOnGitHub),
          ),
          const SizedBox(height: 12),

          // A button to open the docs page.
          OutlinedButton.icon(
            onPressed: () => _openUrl(context, _docsUrl),
            icon: const Icon(Icons.description_outlined),
            label: Text(l10n.readDocumentation),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Section for support and donations.
          Text(
            l10n.supportVeilmi,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(l10n.supportDescription),
          const SizedBox(height: 20),

          // Button to open the support link.
          FilledButton.icon(
            onPressed: () => _openUrl(context, _supportUrl),
            icon: const Icon(Icons.favorite_outline),
            label: Text(l10n.supportVeilmi),
          ),
        ],
      ),
    );
  }
}
