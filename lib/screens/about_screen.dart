import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static final Uri _githubUrl = Uri.parse('https://github.com/noa-jou/Veilmi');

  static final Uri _docsUrl = Uri.parse(
    'https://github.com/noa-jou/Veilmi/tree/main/docs',
  );

  // Replace this after choosing a support platform.
  static final Uri _supportUrl = Uri.parse('https://example.com');

  Future<void> _openUrl(BuildContext context, Uri url) async {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutVeilmi)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.shield_outlined, size: 64),
          const SizedBox(height: 12),
          Text(
            'Veilmi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text(l10n.openSource, style: Theme.of(context).textTheme.titleLarge),
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
            icon: const Icon(Icons.description_outlined),
            label: Text(l10n.readDocumentation),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            l10n.supportVeilmi,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(l10n.supportDescription),
          const SizedBox(height: 20),
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
