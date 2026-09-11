import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // These are the external webpages this app can open.
  // They are saved as Uri objects so the app can open them in a browser or external app.
  static final Uri _githubUrl = Uri.parse('https://github.com/noa-jou/Veilmi');

  static final Uri _docsUrl = Uri.parse('https://noa-jou.github.io/Veilmi/');

  static final Uri _privacyPolicyUrl = Uri.parse(
    'https://noa-jou.github.io/Veilmi/privacy-policy/',
  );

  static final Uri _supportUrl = Uri.parse('https://buymeacoffee.com/noajou');

  // Open a link outside the app.
  // If the link cannot open, show a small snack bar message instead of crashing.
  Future<void> _openUrl(BuildContext context, Uri url) async {
    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

      if (!opened && context.mounted) {
        _showOpenLinkError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showOpenLinkError(context);
      }
    }
  }

  // This method shows a small popup message when a link fails to open.
  // In beginner terms: if the browser cannot open the page, the app tells the user politely.
  void _showOpenLinkError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // This screen is like an information page for the app.
    // It tells the user where to find:
    // - the source code
    // - the documentation
    // - the privacy policy
    // - support options
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutVeilmi)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),

          // App icon in the middle of the page.
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon/veilmi_icon_small.png',
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // App name text.
          Text(
            'Veilmi',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 32),

          // This section explains where the project code and docs live.
          // The user can open the GitHub repository or the documentation website from here.
          Text(l10n.openSource, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(l10n.openSourceDescription),
          const SizedBox(height: 12),
          Text(l10n.docsDescription),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () => _openUrl(context, _githubUrl),
            icon: const Icon(Icons.code),
            label: Text(l10n.viewOnGitHub),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _openUrl(context, _docsUrl),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(l10n.readDocumentation),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // This section is about privacy.
          // It gives the user a direct way to read the privacy policy.
          Text(l10n.privacy, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(l10n.privacyDescription),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () => _openUrl(context, _privacyPolicyUrl),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: Text(l10n.privacyPolicy),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // This last section is for support.
          // The app gives the user a simple button to support the project if they want to.
          Text(l10n.supportVeilmi, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(l10n.supportDescription),
          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () => _openUrl(context, _supportUrl),
            icon: const Icon(Icons.favorite_outline),
            label: Text(l10n.supportVeilmi),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
