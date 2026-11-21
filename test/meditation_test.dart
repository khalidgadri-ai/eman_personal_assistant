import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eman_life_app/features/health_and_fitness/health_service.dart';
import 'package:eman_life_app/features/meditation/meditation_catalog.dart';
import 'package:eman_life_app/features/meditation/meditation_player.dart';
import 'package:eman_life_app/features/meditation/meditation_session_screen.dart';
import 'package:eman_life_app/features/meditation/meditation_tab.dart';
import 'package:eman_life_app/features/meditation/models/meditation_session.dart';
import 'package:eman_life_app/features/meditation/session_planner.dart';
import 'package:eman_life_app/features/meditation/timeline_cursor.dart';
import 'package:eman_life_app/features/meditation/tone_generator.dart';
import 'package:eman_life_app/features/settings/backup_service.dart';
import 'package:eman_life_app/features/settings/data_reset_service.dart';
import 'package:eman_life_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'helpers/test_storage.dart';
import 'helpers/widget_helpers.dart';

/// مشغّل وهمي: الصوت لا يعمل في الاختبارات، فالاختبار يرسل التقدّم بنفسه.
class FakeMeditationPlayer implements MeditationPlayer {
  final StreamController<MeditationProgress> _controller = StreamController.broadcast();
  SessionPlan? started;
  double? toneVolume;
  int pauses = 0;
  int resumes = 0;
  int stops = 0;
  int lastElapsed = 0;

  @override
  Stream<MeditationProgress> get progress => _controller.stream;

  void emit(int elapsedSec, {bool playing = true, bool finished = false}) {
    final plan = started!;
    lastElapsed = elapsedSec;
    _controller.add(MeditationProgress(
      elapsedSec: elapsedSec,
      totalSec: plan.totalSec,
      phase: plan.phaseAt(elapsedSec),
      playing: playing,
      finished: finished,
    ));
  }

  @override
  Future<void> start(SessionPlan plan, {required double toneVolume}) async {
    started = plan;
    this.toneVolume = toneVolume;
  }

  @override
  Future<void> pause() async => pauses++;

  @override
  Future<void> resume() async => resumes++;

  @override
  Future<void> stop() async {
    stops++;
    if (started != null) emit(lastElapsed, playing: false, finished: true);
  }

  @override
  Future<void> setToneVolume(double volume) async => toneVolume = volume;
}

int _sample(Uint8List wav, int frame, int channel) =>
    ByteData.sublistView(wav).getInt16(44 + frame * 4 + channel * 2, Endian.little);

int _frames(Uint8List wav) => (wav.length - 44) ~/ 4;

int _zeroCrossings(Uint8List wav, int channel) {
  var count = 0;
  var previous = _sample(wav, 0, channel);
  for (var i = 1; i < _frames(wav); i++) {
    final current = _sample(wav, i, channel);
    if ((previous < 0) != (current < 0)) count++;
    previous = current;
  }
  return count;
}

final AppLocalizations _ar = lookupAppLocalizations(const Locale('ar'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sessionsJson = File('assets/meditation/sessions.json').readAsStringSync();
  final sessions = MeditationCatalog.parse(sessionsJson);
  MeditationSession byId(String id) => sessions.firstWhere((s) => s.id == id);

  group('the tone generator', () {
    test('writes a valid 16-bit stereo 44.1kHz WAV of the right length', () {
      final wav = ToneGenerator.binauralGamma();
      final header = ByteData.sublistView(wav);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
      expect(header.getUint16(20, Endian.little), 1, reason: 'PCM');
      expect(header.getUint16(22, Endian.little), 2);
      expect(header.getUint32(24, Endian.little), 44100);
      expect(header.getUint16(34, Endian.little), 16);
      expect(header.getUint32(40, Endian.little), ToneGenerator.loopSeconds * 44100 * 4);
      expect(wav.length, 44 + ToneGenerator.loopSeconds * 44100 * 4);
    });

    test('stays quiet: no sample above the tone level', () {
      for (final wav in [ToneGenerator.binauralGamma(), ToneGenerator.isochronicGamma()]) {
        var peak = 0;
        for (var i = 0; i < _frames(wav); i += 7) {
          peak = [peak, _sample(wav, i, 0).abs(), _sample(wav, i, 1).abs()].reduce((a, b) => a > b ? a : b);
        }
        expect(peak, greaterThan(0));
        expect(peak, lessThanOrEqualTo((ToneGenerator.toneAmplitude * 32767).round() + 1));
      }
    });

    test('loops without a click: the end joins the start smoothly', () {
      for (final wav in [ToneGenerator.binauralGamma(), ToneGenerator.isochronicGamma(), ToneGenerator.silence()]) {
        final last = _frames(wav) - 1;
        for (final channel in [0, 1]) {
          // الانتقال من آخر عيّنة إلى أول عيّنة لا يقفز أكثر من خطوة عادية بين عيّنتين متجاورتين.
          final joinStep = (_sample(wav, 0, channel) - _sample(wav, last, channel)).abs();
          final normalStep = (_sample(wav, 1, channel) - _sample(wav, 0, channel)).abs();
          expect(joinStep, lessThanOrEqualTo(normalStep + 2), reason: 'channel $channel');
        }
      }
    });

    test('the binaural channels differ by 40 Hz', () {
      final wav = ToneGenerator.binauralGamma();
      final seconds = ToneGenerator.loopSeconds;
      final leftHz = _zeroCrossings(wav, 0) / 2 / seconds;
      final rightHz = _zeroCrossings(wav, 1) / 2 / seconds;
      expect(leftHz, closeTo(200, 0.5));
      expect(rightHz, closeTo(240, 0.5));
      expect(rightHz - leftHz, closeTo(40, 0.5));
    });

    test('the isochronic tone is the same in both channels', () {
      final wav = ToneGenerator.isochronicGamma();
      for (var i = 0; i < _frames(wav); i += 997) {
        expect(_sample(wav, i, 0), _sample(wav, i, 1));
      }
    });

    test('the bell rings for about 4 seconds and fades out', () {
      final wav = ToneGenerator.bell();
      expect(_frames(wav), 4 * 44100);
      double energy(int from, int to) {
        var sum = 0.0;
        for (var i = from; i < to; i++) {
          final s = _sample(wav, i, 0);
          sum += s * s;
        }
        return sum;
      }

      final half = 44100 ~/ 2;
      expect(energy(_frames(wav) - half, _frames(wav)), lessThan(energy(0, half) * 0.1));
    });
  });

  group('sessions.json', () {
    test('every session is valid and none was skipped', () {
      expect(sessions, hasLength(6));
      expect(sessions.map((s) => s.id).toSet(), hasLength(6));
    });

    test('has the sessions and tiers the owner decided', () {
      expect(byId('silent_timer').kind, MeditationKind.silent);
      expect(byId('gamma_listening').kind, MeditationKind.gamma);
      expect(byId('move_and_still').kind, MeditationKind.active);
      for (final id in ['silent_timer', 'gamma_listening', 'calm_breathing']) {
        expect(byId(id).tier, MeditationTier.free, reason: id);
      }
      for (final id in ['body_scan', 'present_moment', 'move_and_still']) {
        expect(byId(id).tier, MeditationTier.premium, reason: id);
      }
      expect(byId('calm_breathing').durations, [5, 10]);
      expect(byId('body_scan').durations, [10, 15]);
      expect(byId('present_moment').durations, [10, 20]);
      expect(byId('move_and_still').durations, [20]);
      expect(byId('move_and_still').phases, hasLength(5));
    });

    test('a bad session is skipped and the others still load', () {
      final list = [
        {
          'id': 'x',
          'title': 't',
          'kind': 'guided',
          'tier': 'free',
          'durations': [5],
          'phases': [
            {'id': 'p', 'title': 't', 'durationSec': 100},
          ],
        },
        ...(jsonDecode(sessionsJson) as List),
      ];
      final parsed = MeditationCatalog.parse(jsonEncode(list));
      expect(parsed.map((s) => s.id), isNot(contains('x')), reason: '100 s is not 5 minutes');
      expect(parsed, hasLength(6));
    });

    test('rejects an unknown background and a cue outside its phase', () {
      expect(
        () => MeditationPhase.fromJson({'id': 'p', 'title': 't', 'durationSec': 60, 'background': 'loud'}),
        throwsFormatException,
      );
      expect(
        () => MeditationPhase.fromJson({
          'id': 'p',
          'title': 't',
          'durationSec': 60,
          'cues': [
            {'atSec': 61, 'clip': 'a'},
          ],
        }),
        throwsFormatException,
      );
    });

    test('a guided session with a missing recording is hidden, the active one is not', () {
      final none = MeditationCatalog.available(sessions, const {});
      expect(none.map((s) => s.id), unorderedEquals(['silent_timer', 'gamma_listening', 'move_and_still']));

      final allClips = {for (final s in sessions) ...s.clipAssets};
      expect(MeditationCatalog.available(sessions, allClips), hasLength(6));

      final oneMissing = allClips.difference({MeditationSession.clipAsset('body_scan', 'body_scan_03')});
      expect(MeditationCatalog.available(sessions, oneMissing).map((s) => s.id), isNot(contains('body_scan')));
    });

    test('every recording folder is listed as an asset in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final session in sessions.where((s) => s.clipAssets.isNotEmpty)) {
        expect(pubspec, contains('- assets/meditation/voice/${session.id}/'), reason: session.id);
      }
    });
  });

  group('the planner', () {
    test('every session and duration fills the time exactly, with bells at the start, end and between phases', () {
      for (final session in sessions) {
        for (final minutes in session.durations) {
          final plan = planSession(session, minutes: minutes);
          expect(plan.totalSec, minutes * 60);
          expect(plan.phases.first.startSec, 0);
          expect(plan.phases.last.endSec, plan.totalSec);
          for (var i = 1; i < plan.phases.length; i++) {
            expect(plan.phases[i].startSec, plan.phases[i - 1].endSec);
          }
          expect(plan.bells, [0, for (final p in plan.phases.skip(1)) p.startSec, plan.totalSec]);
          for (final cue in plan.cues) {
            final phase = plan.phases.firstWhere((p) => p.phase.id == cue.phaseId);
            expect(cue.atSec, inInclusiveRange(phase.startSec, phase.endSec), reason: cue.asset);
          }
        }
      }
    });

    test('longer durations stretch the phases in proportion', () {
      final plan = planSession(byId('calm_breathing'), minutes: 10);
      expect(plan.phases.map((p) => p.lengthSec), [120, 360, 120]);
      expect(plan.bells, [0, 120, 480, 600]);
    });

    test('a cue counted from the end lands that many seconds before the phase ends', () {
      final plan = planSession(byId('calm_breathing'), minutes: 10);
      final last = plan.cues.firstWhere((c) => c.asset.endsWith('breathing_06.m4a'));
      expect(last.atSec, 600 - 20);
      final second = plan.cues.firstWhere((c) => c.asset.endsWith('breathing_02.m4a'));
      expect(second.atSec, 30);
    });

    test('the chosen background replaces the phases\' own', () {
      final timer = byId('silent_timer');
      expect(planSession(timer, minutes: 20).usesGamma, isFalse);
      expect(planSession(timer, minutes: 20, background: ToneBackground.gammaIsochronic).usesGamma, isTrue);
      expect(() => planSession(timer, minutes: 7), throwsArgumentError);
    });

    test('the cursor hands out each event once, in order, bell before voice at the same second', () {
      final cursor = TimelineCursor(planSession(byId('calm_breathing'), minutes: 5));
      final first = cursor.advanceTo(0);
      expect(first.map((e) => e.runtimeType), [PhaseStartEvent, BellEvent, CueEvent]);
      expect(cursor.advanceTo(0), isEmpty);
      final upToMinute = cursor.advanceTo(60);
      expect(
        upToMinute.whereType<CueEvent>().map((e) => e.cue.asset.split('/').last),
        ['breathing_02.m4a', 'breathing_03.m4a'],
      );
      expect(upToMinute.whereType<PhaseStartEvent>().single.phase.phase.id, 'counted_breath');
      expect(upToMinute.whereType<BellEvent>().single.atSec, 60);
      final rest = cursor.advanceTo(10000);
      expect(rest.last, isA<SessionEndEvent>());
      expect(cursor.finished, isTrue);
    });
  });

  group('content rules', () {
    final banned = [
      'يعالج', 'علاج', 'يشفي', 'شفاء', 'الذاكرة', 'الزهايمر', 'القلق المرضي', 'الاكتئاب', //
      'alzheimer', 'cure', 'therapy',
      'أوشو', 'اوشو', 'osho', 'kundalini', 'كونداليني', 'nadabrahma', 'nataraj', 'dynamic meditation',
    ];
    final files = [
      File('assets/meditation/sessions.json'),
      File('docs/meditation_recording_script.md'),
      File('lib/features/coach/coach_paywall_screen.dart'),
      ...Directory('lib/features/meditation').listSync(recursive: true).whereType<File>(),
      // نصوص الشاشات صارت في ملفات اللغات.
      File('lib/l10n/app_ar.arb'),
      File('lib/l10n/app_en.arb'),
    ];

    test('no health claim and no other app\'s meditation names in any meditation text', () {
      for (final file in files) {
        final text = file.readAsStringSync().toLowerCase();
        for (final word in banned) {
          expect(text.contains(word.toLowerCase()), isFalse, reason: '"$word" in ${file.path}');
        }
      }
    });

    test('every voice file in the app is a clip some session uses, in that session\'s folder', () {
      final used = {for (final s in sessions) ...s.clipAssets, for (final s in sessions) ...s.clipAssetsFor('en')};
      final files = Directory('assets/meditation/voice')
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.replaceAll('\\', '/'))
          .where((p) => !p.endsWith('.gitkeep'))
          .toList();

      expect(files, isNotEmpty);
      for (final path in files) {
        expect(used, contains(path), reason: '$path is not a clip any session uses');
      }
    });

    test('every session with a guide voice has all its clips in the app, so none is hidden', () {
      for (final session in sessions.where((s) => s.clipAssets.isNotEmpty)) {
        for (final clip in session.clipAssets) {
          expect(File(clip).existsSync(), isTrue, reason: '${session.id}: $clip is missing');
        }
      }
      final onDisk = Directory('assets/meditation/voice')
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.replaceAll('\\', '/'))
          .toSet();
      expect(MeditationCatalog.available(sessions, onDisk).map((s) => s.id), sessions.map((s) => s.id));
    });

    test('the English script has every clip, and English voice files go to their own folder', () {
      final script = File('docs/meditation_recording_script_en.md').readAsStringSync();
      for (final session in sessions) {
        for (final phase in session.phases) {
          for (final cue in phase.cues) {
            expect(script, contains('${cue.clip}.m4a'), reason: cue.clip);
          }
        }
      }
      expect(MeditationSession.clipAsset('calm_breathing', 'breathing_01', lang: 'en'),
          'assets/meditation/voice/en/calm_breathing/breathing_01.m4a');
      expect(MeditationSession.clipAsset('calm_breathing', 'breathing_01'),
          'assets/meditation/voice/calm_breathing/breathing_01.m4a');
    });

    test('every session and phase has English text', () {
      for (final session in sessions) {
        expect(session.titleEn, isNotEmpty, reason: session.id);
        expect(session.descriptionEn, isNotEmpty, reason: session.id);
        expect(session.titleFor('en'), isNot(session.title));
        expect(session.titleFor('ar'), session.title);
        for (final phase in session.phases) {
          expect(phase.titleEn, isNotEmpty, reason: '${session.id}/${phase.id}');
          if (phase.instruction.isNotEmpty) {
            expect(phase.instructionEn, isNotEmpty, reason: '${session.id}/${phase.id}');
          }
        }
      }
    });

    test('in English a guided session waits for its English voice; the plan uses that folder', () {
      final arabicOnly = {for (final s in sessions) ...s.clipAssets};
      final inEnglish = MeditationCatalog.available(sessions, arabicOnly, lang: 'en');
      expect(inEnglish.where((s) => s.kind == MeditationKind.guided), isEmpty);
      expect(inEnglish.any((s) => s.kind == MeditationKind.active), isTrue, reason: 'bells and text still work');

      final plan = planSession(byId('calm_breathing'), minutes: 5, lang: 'en');
      expect(plan.cues.first.asset, startsWith('assets/meditation/voice/en/'));
      expect(plan.lang, 'en');
    });

    test('the recording script has every clip the sessions use', () {
      final script = File('docs/meditation_recording_script.md').readAsStringSync();
      for (final session in sessions) {
        for (final phase in session.phases) {
          for (final cue in phase.cues) {
            expect(script, contains('${cue.clip}.m4a'), reason: cue.clip);
          }
        }
      }
    });
  });

  group('the meditation tab', () {
    late TestStorage storage;
    late FakeMeditationPlayer player;
    var paywallOpened = 0;
    var subscriber = false;
    var paywallBuys = false;

    setUp(() async {
      storage = await TestStorage.inMemory();
      player = FakeMeditationPlayer();
      paywallOpened = 0;
      subscriber = false;
      paywallBuys = false;
    });
    tearDown(() => storage.dispose());

    Future<void> openTab(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpScreen(
        tester,
        Scaffold(
          body: MeditationTab(
            playerBuilder: () => player,
            loadSessions: () async => sessions,
            loadAssets: () async => {for (final s in sessions) ...s.clipAssets},
            checkSubscription: () async => subscriber,
            openPaywall: (_) async {
              paywallOpened++;
              return paywallBuys;
            },
          ),
        ),
      );
    }

    Future<void> startSession(WidgetTester tester, String title) async {
      await tester.tap(find.text(title));
      await settle(tester);
      await tester.tap(find.text('ابدأ الجلسة'));
      await settle(tester);
    }

    testWidgets('shows every session, marks the paid ones and the week\'s minutes', (tester) async {
      await openTab(tester);
      for (final session in sessions) {
        expect(find.text(session.title), findsOneWidget);
      }
      expect(find.text('مع الاشتراك'), findsNWidgets(3));
      expect(find.text('دقائق التأمل في آخر 7 أيام: 0'), findsOneWidget);
    });

    testWidgets('a free session starts without the paywall', (tester) async {
      await openTab(tester);
      await startSession(tester, 'تنفّس هادئ');

      expect(paywallOpened, 0);
      expect(find.byType(MeditationSessionScreen), findsOneWidget);
      expect(player.started!.session.id, 'calm_breathing');
      expect(player.toneVolume, defaultToneVolume);
    });

    testWidgets('a session with a guide voice says the voice is AI-generated', (tester) async {
      await openTab(tester);
      await tester.tap(find.text('تنفّس هادئ'));
      await settle(tester);

      expect(find.text(_ar.meditationAiVoiceNotice), findsOneWidget);
    });

    testWidgets('a session without a guide voice does not mention one', (tester) async {
      await openTab(tester);
      await tester.tap(find.text('مؤقت صامت بأجراس'));
      await settle(tester);

      expect(find.text('ابدأ الجلسة'), findsOneWidget);
      expect(find.text(_ar.meditationAiVoiceNotice), findsNothing);
    });

    testWidgets('a paid session opens the paywall and stops there if nothing is bought', (tester) async {
      await openTab(tester);
      await tester.tap(find.text('مسح الجسد'));
      await settle(tester);

      expect(paywallOpened, 1);
      expect(find.text('ابدأ الجلسة'), findsNothing);
      expect(player.started, isNull);
    });

    testWidgets('a paid session continues after buying', (tester) async {
      paywallBuys = true;
      await openTab(tester);
      await startSession(tester, 'مسح الجسد');

      expect(paywallOpened, 1);
      expect(player.started!.session.id, 'body_scan');
    });

    testWidgets('a subscriber opens paid sessions without the paywall', (tester) async {
      subscriber = true;
      await openTab(tester);
      await startSession(tester, 'الحضور في اللحظة');

      expect(paywallOpened, 0);
      expect(player.started!.session.id, 'present_moment');
    });

    testWidgets('the gamma safety note shows once, before the first gamma session', (tester) async {
      await openTab(tester);
      await startSession(tester, 'موجات جاما 40 هرتز');
      expect(find.text('ملاحظة قبل البدء'), findsOneWidget);
      expect(player.started, isNull);
      await tester.tap(find.text('فهمت، ابدأ'));
      await settle(tester);
      expect(player.started!.usesGamma, isTrue);

      // المرة الثانية: بلا ملاحظة.
      await player.stop();
      await settle(tester);
      await tester.tap(find.text('رجوع'));
      await settle(tester);
      player.started = null;
      await startSession(tester, 'موجات جاما 40 هرتز');
      expect(find.text('ملاحظة قبل البدء'), findsNothing);
      expect(player.started, isNotNull);
    });

    testWidgets('the active session shows its own safety note', (tester) async {
      subscriber = true;
      await openTab(tester);
      await startSession(tester, 'حركة ثم سكون');
      expect(find.textContaining('الحركة بلطف'), findsOneWidget);
    });

    testWidgets('a finished session is logged and the week\'s minutes go up', (tester) async {
      await openTab(tester);
      await startSession(tester, 'مؤقت صامت بأجراس');
      expect(find.text('ملاحظة قبل البدء'), findsNothing, reason: 'no gamma by default');

      player.emit(120);
      await settle(tester);
      expect(find.text('03:00'), findsOneWidget, reason: '5 minutes minus 2');

      player.emit(300, playing: false, finished: true);
      await settle(tester);
      expect(find.text('انتهت الجلسة'), findsOneWidget);

      final health = await tester.runAsync(HealthService.getInstance);
      expect(health!.meditationMinutesSince(DateTime(2000)), 5);

      await tester.tap(find.text('رجوع'));
      await settle(tester);
      expect(find.text('دقائق التأمل في آخر 7 أيام: 5'), findsOneWidget);
    });

    testWidgets('ending early after a minute keeps the minutes; under a minute keeps nothing', (tester) async {
      await openTab(tester);
      await startSession(tester, 'مؤقت صامت بأجراس');
      player.emit(45);
      await settle(tester);
      await tester.tap(find.text('إنهاء'));
      await settle(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'إنهاء'));
      await settle(tester);
      expect(player.stops, greaterThanOrEqualTo(1));
      final health = await tester.runAsync(HealthService.getInstance);
      expect(health!.meditationCount(), 0);
    });
  });

  group('the session screen', () {
    late TestStorage storage;
    setUp(() async => storage = await TestStorage.inMemory());
    tearDown(() => storage.dispose());

    testWidgets('pause, resume and the gamma volume slider reach the player', (tester) async {
      final player = FakeMeditationPlayer();
      final plan = planSession(byId('gamma_listening'), minutes: 5, background: ToneBackground.gammaIsochronic);
      await pumpScreen(tester, MeditationSessionScreen(plan: plan, player: player));

      player.emit(10);
      await settle(tester);
      await tester.tap(find.text('إيقاف مؤقت'));
      await tester.pump();
      expect(player.pauses, 1);

      player.emit(10, playing: false);
      await settle(tester);
      await tester.tap(find.text('متابعة'));
      await tester.pump();
      expect(player.resumes, 1);

      expect(find.text('مستوى نغمة جاما'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(-300, 0));
      await tester.pump();
      expect(player.toneVolume, isNot(defaultToneVolume));
    });

    testWidgets('the active session shows the phase instruction in large text', (tester) async {
      final player = FakeMeditationPlayer();
      final plan = planSession(byId('move_and_still'), minutes: 20);
      await pumpScreen(tester, MeditationSessionScreen(plan: plan, player: player));
      player.emit(200);
      await settle(tester);

      final instruction = byId('move_and_still').phases[1].instruction;
      final text = tester.widget<Text>(find.text(instruction));
      expect(text.style!.fontSize, greaterThanOrEqualTo(24));
      expect(find.text('حركة بإيقاع'), findsOneWidget);
    });
  });

  group('the log', () {
    late TestStorage storage;
    setUp(() => storage = TestStorage.create());
    tearDown(() => storage.dispose());

    test('is kept in the encrypted health box, which is backed up and erased with the rest', () async {
      final health = await HealthService.getInstance();
      await health.logMeditation(sessionId: 'calm_breathing', minutes: 10, at: DateTime(2026, 11, 10));
      await health.logMeditation(sessionId: 'silent_timer', minutes: 0);
      await health.logMeditation(sessionId: 'silent_timer', minutes: 500, at: DateTime(2026, 11, 12));

      expect(health.meditationCount(), 2, reason: 'zero minutes are not logged');
      expect(health.meditationMinutesSince(DateTime(2026, 11, 11)), HealthService.maxMeditationMinutes);
      expect(health.meditationMinutesSince(DateTime(2026, 11, 1)), 10 + HealthService.maxMeditationMinutes);

      final stored = Hive.box('health_enc').values.whereType<Map>().where((r) => r['kind'] == 'meditation');
      expect(stored, hasLength(2));
      expect(BackupService.boxNames, contains('health'));
      expect(DataResetService.userBoxes, contains('health_enc'));
    });
  });
}
