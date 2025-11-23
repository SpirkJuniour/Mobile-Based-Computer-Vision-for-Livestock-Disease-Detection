import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mifugo_care/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/decorated_background.dart';
import '../../widgets/common/glow_card.dart';
import 'profile_menu_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Colors.transparent,
      ),
      body: DecoratedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              GlowCard(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileMenuTile(
                      icon: Icons.language_outlined,
                      title: localizations.language,
                      subtitle: languageProvider.isEnglish 
                          ? localizations.english 
                          : localizations.kiswahili,
                      onTap: () {
                        _showLanguageDialog(context, languageProvider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.selectLanguage),
        content: SegmentedButton<Locale>(
          segments: [
            ButtonSegment(
              value: const Locale('en'),
              label: Text(localizations.english),
              icon: const Icon(Icons.language),
            ),
            ButtonSegment(
              value: const Locale('sw'),
              label: Text(localizations.kiswahili),
              icon: const Icon(Icons.translate),
            ),
          ],
          selected: {languageProvider.locale},
          onSelectionChanged: (selection) {
            final chosen = selection.first;
            languageProvider.setLocale(chosen);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.languageChanged),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      ),
    );
  }
}
