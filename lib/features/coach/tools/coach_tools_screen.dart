import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/l10n.dart';
import 'emotion_checkin_screen.dart';
import 'wheel_of_life_screen.dart';

/// قائمة أدوات المدرب. الأداتان هنا مجانيتان وتعملان بلا إنترنت وبلا ذكاء اصطناعي.
class CoachToolsScreen extends StatelessWidget {
  const CoachToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget tool(IconData icon, String title, String subtitle, Widget Function() screen) => Card(
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(icon, color: AppTheme.accentColor, size: 32),
            title: Text(title, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.subTextColor, height: 1.5)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.subTextColor),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen())),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coachToolsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.coachToolsIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
          const SizedBox(height: 16),
          tool(Icons.donut_large_rounded, l10n.wheelTitle, l10n.wheelSubtitle, () => const WheelOfLifeScreen()),
          tool(Icons.mood_rounded, l10n.emotionTitle, l10n.emotionSubtitle, () => const EmotionCheckinScreen()),
        ],
      ),
    );
  }
}
