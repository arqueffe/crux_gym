import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          tooltip: AppLocalizations.of(context).languageSettings,
          onSelected: (Locale locale) {
            localeProvider.setLocale(locale);
          },
          itemBuilder: (BuildContext context) {
            return localeProvider.getSupportedLanguages().entries.map((entry) {
              final locale = entry.key;
              final languageName = entry.value;
              final isSelected = localeProvider.locale == locale;

              return PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.green, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(languageName),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

class LanguageListTile extends StatelessWidget {
  const LanguageListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context).languageSettings),
          subtitle: Text(localeProvider.getLanguageName(localeProvider.locale)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LanguageSelectionDialog(),
            );
          },
        );
      },
    );
  }
}

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).languageSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  localeProvider.getSupportedLanguages().entries.map((entry) {
                final locale = entry.key;
                final languageName = entry.value;
                final isSelected = localeProvider.locale == locale;

                return RadioListTile<Locale>(
                  title: Text(languageName),
                  value: locale,
                  groupValue: localeProvider.locale,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      localeProvider.setLocale(value);
                      Navigator.of(context).pop();
                    }
                  },
                  selected: isSelected,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        );
      },
    );
  }
}
