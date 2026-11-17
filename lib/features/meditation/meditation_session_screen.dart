import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../health_and_fitness/health_service.dart';
import 'meditation_player.dart';
import 'models/meditation_session.dart';
import 'session_planner.dart';

/// شاشة الجلسة الجارية: المرحلة الحالية، والوقت المتبقي، وإيقاف مؤقت وإنهاء، وشريط جاما.
/// الصوت يستمر والشاشة مطفأة (الخدمة تعمل في المقدمة)، والتحكم متاح أيضًا من الإشعار.
class MeditationSessionScreen extends StatefulWidget {
  const MeditationSessionScreen({super.key, required this.plan, required this.player});

  final SessionPlan plan;
  final MeditationPlayer player;

  @override
  State<MeditationSessionScreen> createState() => _MeditationSessionScreenState();
}

class _MeditationSessionScreenState extends State<MeditationSessionScreen> {
  StreamSubscription<MeditationProgress>? _subscription;
  MeditationProgress? _progress;
  double _toneVolume = defaultToneVolume;
  bool _finished = false;
  bool _logged = false;
  String? _error;

  SessionPlan get _plan => widget.plan;

  @override
  void initState() {
    super.initState();
    _subscription = widget.player.progress.listen(_onProgress);
    _start();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (!_finished) {
      // خرج من الشاشة بلا «إنهاء» (مثلًا أُغلق التطبيق): تُنهى الجلسة وتُسجَّل دقائقها.
      unawaited(widget.player.stop());
      unawaited(_log(_progress?.elapsedSec ?? 0));
    }
    super.dispose();
  }

  Future<void> _start() async {
    try {
      await widget.player.start(_plan, toneVolume: _toneVolume);
    } catch (e) {
      debugPrint('MeditationSessionScreen: could not start (${e.runtimeType})');
      if (mounted) setState(() => _error = 'تعذّر تشغيل الصوت. حاول مرة أخرى.');
    }
  }

  void _onProgress(MeditationProgress progress) {
    if (!mounted || _finished) return;
    setState(() => _progress = progress);
    if (progress.finished) {
      setState(() => _finished = true);
      unawaited(_log(progress.elapsedSec));
    }
  }

  /// جلسة اكتملت أو استمرت دقيقة على الأقل تُحفظ في سجل التأمل.
  Future<void> _log(int elapsedSec) async {
    if (_logged || elapsedSec < 60) return;
    _logged = true;
    try {
      final health = await HealthService.getInstance();
      await health.logMeditation(sessionId: _plan.session.id, minutes: elapsedSec ~/ 60);
    } catch (e) {
      debugPrint('MeditationSessionScreen: could not log (${e.runtimeType})');
    }
  }

  Future<void> _togglePause() async {
    if (_progress?.playing ?? true) {
      await widget.player.pause();
    } else {
      await widget.player.resume();
    }
  }

  Future<void> _end() => widget.player.stop();

  Future<bool> _confirmLeave() async {
    if (_finished || _error != null) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('إنهاء الجلسة؟', style: TextStyle(color: AppTheme.textColor)),
          content: const Text(
            'تُحفظ الدقائق التي مضت إن كانت دقيقة أو أكثر.',
            style: TextStyle(color: AppTheme.subTextColor, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('متابعة الجلسة', style: TextStyle(color: AppTheme.subTextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('إنهاء', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (leave == true) await _end();
    return leave == true;
  }

  static String _clock(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final phase = progress?.phase ?? _plan.phases.first;
    final isActive = _plan.session.kind == MeditationKind.active;
    return PopScope(
      canPop: _finished || _error != null,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave() && mounted) navigator.pop();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text(_plan.session.title)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _finished ? _buildFinished() : _buildRunning(progress, phase, isActive),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRunning(MeditationProgress? progress, PlannedPhase phase, bool isActive) {
    final remaining = progress?.remainingSec ?? _plan.totalSec;
    final elapsed = progress?.elapsedSec ?? 0;
    final playing = progress?.playing ?? true;
    final instruction = phase.phase.instruction;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'المرحلة ${_plan.phases.indexOf(phase) + 1} من ${_plan.phases.length}',
                  style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  phase.phase.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: isActive ? 34 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (instruction.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? AppTheme.textColor : AppTheme.subTextColor,
                      fontSize: isActive ? 24 : 16,
                      height: 1.6,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  _clock(remaining),
                  style: const TextStyle(color: AppTheme.accentColor, fontSize: 56, fontWeight: FontWeight.w300),
                ),
                const Text('الوقت المتبقي', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _plan.totalSec == 0 ? 0 : elapsed / _plan.totalSec,
                  backgroundColor: AppTheme.surfaceColor,
                  color: AppTheme.accentColor,
                ),
                if (_plan.usesGamma) ...[
                  const SizedBox(height: 24),
                  const Text('مستوى نغمة جاما', style: TextStyle(color: AppTheme.subTextColor, fontSize: 13)),
                  Slider(
                    value: _toneVolume,
                    label: '${(_toneVolume * 100).round()}%',
                    divisions: 20,
                    activeColor: AppTheme.accentColor,
                    onChanged: (v) {
                      setState(() => _toneVolume = v);
                      unawaited(widget.player.setToneVolume(v));
                    },
                  ),
                ],
                if (_error case final error?)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(error, style: const TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                onPressed: _error == null ? _confirmLeaveAndPop : null,
                child: const Text('إنهاء'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(0, 52),
                ),
                onPressed: _error == null ? _togglePause : null,
                icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white),
                label: Text(playing ? 'إيقاف مؤقت' : 'متابعة', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmLeaveAndPop() async {
    final navigator = Navigator.of(context);
    if (await _confirmLeave() && mounted) navigator.pop();
  }

  Widget _buildFinished() {
    final minutes = (_progress?.elapsedSec ?? 0) ~/ 60;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.spa_rounded, size: 72, color: AppTheme.accentColor),
        const SizedBox(height: 16),
        const Text(
          'انتهت الجلسة',
          style: TextStyle(color: AppTheme.textColor, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          minutes >= 1 ? 'دقائق هذه الجلسة: $minutes' : 'الجلسات الأقصر من دقيقة لا تُحفظ في السجل.',
          style: const TextStyle(color: AppTheme.subTextColor, fontSize: 15),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: const Size(160, 52)),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('رجوع', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
