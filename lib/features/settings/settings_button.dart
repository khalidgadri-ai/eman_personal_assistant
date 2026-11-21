import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import 'settings_screen.dart';

/// أيقونة الإعدادات في شريط كل تبويب.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.settingsTitle,
      icon: const Icon(Icons.settings_rounded, color: AppTheme.accentColor),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
      ),
    );
  }
}
