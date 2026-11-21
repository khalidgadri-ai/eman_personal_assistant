import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/nice_axis_step.dart';
import 'models/social_app.dart';
import 'usage_service.dart';
import '../../l10n/l10n.dart';

// اسم التطبيق كما يظهر في قائمة إعدادات Android (android:label في AndroidManifest.xml).
const String _androidAppLabel = 'إيمان';

String _formatMinutes(AppLocalizations l10n, int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return l10n.minutesShort(rest);
  if (rest == 0) return l10n.hoursShort(hours);
  return l10n.hoursMinutesShort(hours, rest);
}

class UsageAwarenessScreen extends StatefulWidget {
  const UsageAwarenessScreen({super.key});

  @override
  State<UsageAwarenessScreen> createState() => _UsageAwarenessScreenState();
}

class _UsageAwarenessScreenState extends State<UsageAwarenessScreen> with WidgetsBindingObserver {
  UsageService? _service;
  bool _loading = true;
  bool _hasPermission = false;
  bool _readFailed = false;
  List<SocialAppUsage> _usage = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // الرجوع من إعدادات Android بعد تفعيل الصلاحية.
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    if (!UsageService.isSupported) return;
    final service = _service ?? await UsageService.getInstance();
    var allowed = false;
    var usage = const <SocialAppUsage>[];
    var failed = false;
    try {
      allowed = await service.hasPermission();
      if (allowed) usage = await service.getDailyUsageByApp();
    } catch (e) {
      debugPrint('UsageAwarenessScreen: $e');
      failed = true;
    }
    if (!mounted) return;
    setState(() {
      _service = service;
      _hasPermission = allowed;
      _usage = usage;
      _readFailed = failed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.awarenessTooltip),
        actions: [
          if (_hasPermission)
            IconButton(
              tooltip: context.l10n.refresh,
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentColor),
              onPressed: _load,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!UsageService.isSupported) {
      return _CenteredNote(context.l10n.usageAndroidOnly);
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_readFailed) {
      return _CenteredNote(context.l10n.usageReadFailed);
    }
    if (!_hasPermission) {
      return _PermissionGuide(
        onOpenSettings: () => _service?.openPermissionSettings(),
        onDecline: () => Navigator.of(context).pop(),
      );
    }
    return _buildUsage();
  }

  Widget _buildUsage() {
    final total = totalMinutes(_usage);
    final rows = _usage.where((u) => u.minutes > 0).toList()
      ..sort((a, b) => b.minutes.compareTo(a.minutes));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          context.l10n.usageToday,
          style: TextStyle(color: AppTheme.subTextColor, fontSize: 13),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            _formatMinutes(context.l10n, total),
            style: const TextStyle(color: AppTheme.textColor, fontSize: 48, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        if (total == 0)
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              context.l10n.usageNone,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subTextColor),
            ),
          )
        else ...[
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.usageBreakdown,
                  style: TextStyle(color: AppTheme.textColor, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(height: 220, child: _buildChart()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (final row in rows)
                  ListTile(
                    title: Text(row.app.nameFor(context.appLang), style: const TextStyle(color: AppTheme.textColor)),
                    subtitle: Text(
                      context.l10n.usageShare((row.minutes / total * 100).round()),
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                    ),
                    trailing: Text(
                      _formatMinutes(context.l10n, row.minutes),
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          context.l10n.usageSource,
          style: TextStyle(color: AppTheme.subTextColor, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildChart() {
    // fl_chart يرسم من اليسار لليمين دائمًا، فنعكس الترتيب في العربية ليبدأ القارئ من اليمين.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final order = rtl ? socialApps.reversed.toList() : socialApps;
    final lang = context.appLang;
    final minutesById = {for (final u in _usage) u.app.id: u.minutes};
    final values = [for (final app in order) (minutesById[app.id] ?? 0).toDouble()];
    final maxValue = values.reduce(math.max);
    final step = niceAxisStep(maxValue / 4);
    final maxY = step * (maxValue / step).ceil();
    const axisStyle = TextStyle(color: AppTheme.subTextColor, fontSize: 11);
    final valueAxis = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        interval: step,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          child: Text(value.toInt().toString(), style: axisStyle),
        ),
      ),
    );
    const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          for (var i = 0; i < order.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 20,
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppTheme.surfaceColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(bottom: BorderSide(color: AppTheme.surfaceColor)),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // محور القيم على جهة نهاية القراءة: يمين في العربية، يسار في الإنجليزية.
          leftTitles: rtl ? hidden : valueAxis,
          rightTitles: rtl ? valueAxis : hidden,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(order[value.toInt()].nameFor(lang), style: axisStyle),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surfaceColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${order[group.x].nameFor(lang)}\n${_formatMinutes(context.l10n, rod.toY.toInt())}',
              const TextStyle(color: AppTheme.textColor, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenteredNote extends StatelessWidget {
  const _CenteredNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.subTextColor, height: 1.6),
        ),
      ),
    );
  }
}

/// إفصاح واضح قبل إرسال المستخدم لإعدادات Android، مع خيار الرفض (متطلب Google Play).
class _PermissionGuide extends StatelessWidget {
  const _PermissionGuide({required this.onOpenSettings, required this.onDecline});

  final VoidCallback onOpenSettings;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final appNames = socialApps.map((a) => a.nameFor(context.appLang)).join(context.l10n.listSeparator);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.usageHowTitle,
          style: TextStyle(color: AppTheme.textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            context.l10n.usageHowBody(appNames),
            style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.8),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.usageEnableTitle,
          style: TextStyle(color: AppTheme.textColor, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _Step(1, Icons.settings_rounded, context.l10n.usageStep1),
        _Step(2, Icons.search_rounded, context.l10n.usageStep2(_androidAppLabel)),
        _Step(3, Icons.toggle_on_rounded, context.l10n.usageStep3),
        _Step(4, Icons.keyboard_return_rounded, context.l10n.usageStep4),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onOpenSettings,
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          label: Text(context.l10n.openSettings, style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onDecline,
          child: Text(context.l10n.notNow, style: TextStyle(color: AppTheme.subTextColor)),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.icon, this.text);

  final int number;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.surfaceColor,
            child: Text('$number', style: const TextStyle(color: AppTheme.textColor, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: AppTheme.accentColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppTheme.textColor, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
