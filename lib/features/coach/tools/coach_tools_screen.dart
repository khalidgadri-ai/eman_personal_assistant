import 'package:flutter/material.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/l10n.dart';
import '../coach_paywall_screen.dart';
import 'belief_check_screen.dart';
import 'coach_tool_record.dart';
import 'decision_screen.dart';
import 'emotion_checkin_screen.dart';
import 'habit_change_screen.dart';
import 'inner_voice_screen.dart';
import 'wheel_of_life_screen.dart';

Future<bool> _verifySubscription() async {
  try {
    return await (await SubscriptionService.getInstance()).verify();
  } catch (e) {
    debugPrint('CoachToolsScreen: subscription check failed (${e.runtimeType})');
    return false;
  }
}

Future<bool> _openPaywall(BuildContext context) async {
  final subscribed = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const CoachPaywallScreen(feature: PaywallFeature.tools)),
  );
  return subscribed == true;
}

/// قائمة أدوات المدرب. عجلة الحياة وتسمية المشاعر مجانيتان؛ الأربع الباقية بالاشتراك نفسه
/// (`eman_coach_monthly`). كلها تعمل بلا إنترنت وبلا ذكاء اصطناعي.
class CoachToolsScreen extends StatelessWidget {
  /// المعاملات للاختبارات فقط؛ الأصل هو الاشتراك الحقيقي وشاشته.
  const CoachToolsScreen({
    super.key,
    this.checkSubscription = _verifySubscription,
    this.openPaywall = _openPaywall,
  });

  final Future<bool> Function() checkSubscription;
  final Future<bool> Function(BuildContext context) openPaywall;

  Future<void> _open(BuildContext context, CoachToolKind kind, Widget Function() screen) async {
    if (kind.isPremium && !await checkSubscription()) {
      if (!context.mounted || !await openPaywall(context)) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget tool(CoachToolKind kind, IconData icon, String title, String subtitle, Widget Function() screen) => Card(
          key: ValueKey('tool_${kind.name}'),
          color: AppTheme.cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(icon, color: AppTheme.accentColor, size: 32),
            title: Text(title, style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(color: AppTheme.subTextColor, height: 1.5)),
                if (kind.isPremium)
                  Text(l10n.withSubscription, style: const TextStyle(color: AppTheme.accentColor, fontSize: 11)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.subTextColor),
            onTap: () => _open(context, kind, screen),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coachToolsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.coachToolsIntro, style: const TextStyle(color: AppTheme.subTextColor, height: 1.6)),
          const SizedBox(height: 16),
          tool(CoachToolKind.wheel, Icons.donut_large_rounded, l10n.wheelTitle, l10n.wheelSubtitle,
              () => const WheelOfLifeScreen()),
          tool(CoachToolKind.emotion, Icons.mood_rounded, l10n.emotionTitle, l10n.emotionSubtitle,
              () => const EmotionCheckinScreen()),
          tool(CoachToolKind.belief, Icons.lightbulb_outline_rounded, l10n.beliefTitle, l10n.beliefSubtitle,
              () => const BeliefCheckScreen()),
          tool(CoachToolKind.innerVoice, Icons.record_voice_over_rounded, l10n.innerVoiceTitle, l10n.innerVoiceSubtitle,
              () => const InnerVoiceScreen()),
          tool(CoachToolKind.decision, Icons.call_split_rounded, l10n.decisionTitle, l10n.decisionSubtitle,
              () => const DecisionScreen()),
          tool(CoachToolKind.habit, Icons.event_repeat_rounded, l10n.habitTitle, l10n.habitSubtitle,
              () => const HabitChangeScreen()),
        ],
      ),
    );
  }
}
