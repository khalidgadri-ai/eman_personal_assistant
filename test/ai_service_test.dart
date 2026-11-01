import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eman_life_app/core/ai/ai_errors.dart';
import 'package:eman_life_app/core/ai/ai_models.dart';
import 'package:eman_life_app/core/ai/ai_provider.dart';
import 'package:eman_life_app/core/ai/ai_service.dart';
import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/config/ai_config.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fakeKey = 'AIzaSyFAKEFAKEFAKEFAKEFAKEFAKE1234abcd';

class _FakeProvider extends AiProvider {
  _FakeProvider(this.handler, {AiProviderConfig? config})
      : super(
          config ??
              const AiProviderConfig(
                id: 'fake',
                kind: AiProviderKind.openAiCompatible,
                baseUrl: 'https://fake.example.com',
                model: 'm',
              ),
          'key',
        );

  final FutureOr<AiReply> Function(AiRequest request) handler;
  final List<AiRequest> sent = [];

  @override
  Future<AiReply> send(AiRequest request) async {
    sent.add(request);
    return handler(request);
  }

  @override
  Future<List<AiModelInfo>> listModels() async => const [];
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    DatabaseService.resetForTesting();
    AiSettingsService.resetForTesting();
  });

  Future<void> configure({AiSupport images = AiSupport.unknown, String key = _fakeKey}) async {
    final settings = await AiSettingsService.getInstance();
    await settings.save(settings.configFor('openai').copyWith(model: 'some-model', images: images));
    await settings.saveKey('openai', key);
  }

  test('without a provider and key there is nothing to call and no fallback key', () async {
    final service = await AiService.create();

    expect(service.isConfigured, isFalse);
    expect(await service.askAssistant('مرحبا'), AiService.missingKeyMessage);
    expect(
      await service.analyzeImage(imageBytes: Uint8List(1), mimeType: 'image/jpeg', prompt: 'س'),
      AiService.missingKeyMessage,
    );
  });

  test('a chosen provider with a saved key is built with that exact config and key', () async {
    await configure();
    AiProviderConfig? builtWith;
    String? usedKey;

    final service = await AiService.create(builder: (config, key) {
      builtWith = config;
      usedKey = key;
      return _FakeProvider((_) => const AiReply('أهلًا بك'));
    });

    expect(service.isConfigured, isTrue);
    expect(builtWith!.id, 'openai');
    expect(builtWith!.model, 'some-model');
    expect(usedKey, _fakeKey);
    expect(await service.askAssistant('مرحبا'), 'أهلًا بك');
  });

  test('a provider without a key is not configured, even if chosen', () async {
    await configure(key: '');

    final service = await AiService.create();

    expect(service.isConfigured, isFalse);
  });

  test('the system prompt is sent with every request, and a request-level one wins', () async {
    final fake = _FakeProvider((_) => const AiReply('ok'));
    final service = AiService.withProvider(fake, systemPrompt: 'تعليمات عامة');

    await service.askAssistant('س');
    await service.sendRaw(const AiRequest(systemPrompt: 'تعليمات خاصة', messages: [AiMessage.user('س')]));

    expect(fake.sent[0].systemPrompt, 'تعليمات عامة');
    expect(fake.sent[1].systemPrompt, 'تعليمات خاصة');
  });

  test('provider failures become fixed Arabic messages, never raw text', () async {
    Future<String> askWith(Object error) {
      final service = AiService.withProvider(_FakeProvider((_) => throw error));
      return service.askAssistant('مرحبا');
    }

    expect(await askWith(const AiException(AiFailure.modelNotFound, statusCode: 404)), AiFailure.modelNotFound.message);
    expect(await askWith(const SocketException('Failed host lookup: secret-host')), AiFailure.network.message);
    expect(await askWith(TimeoutException('slow')), AiFailure.network.message);
    final unknown = await askWith(StateError('internal secret detail'));
    expect(unknown, AiFailure.unknown.message);
    expect(unknown, isNot(contains('secret')));
  });

  test('a blank reply shows the no-reply message instead of an empty bubble', () async {
    final service = AiService.withProvider(_FakeProvider((_) => const AiReply('   ')));

    expect(await service.askAssistant('س'), AiService.emptyReplyMessage);
  });

  group('images', () {
    test('a model marked as not supporting images is never sent one, and the user is told', () async {
      final fake = _FakeProvider((_) => const AiReply('ok'));
      final service = AiService.withProvider(fake, images: AiSupport.no);

      final reply = await service.analyzeImage(imageBytes: Uint8List(3), mimeType: 'image/jpeg', prompt: 'حلّل');

      expect(reply, AiFailure.imageUnsupported.message);
      expect(fake.sent, isEmpty);
    });

    test('unknown or yes is allowed and the image reaches the provider', () async {
      for (final support in [AiSupport.unknown, AiSupport.yes]) {
        final fake = _FakeProvider((_) => const AiReply('تحليل'));
        final service = AiService.withProvider(fake, images: support);

        final reply = await service.analyzeImage(
          imageBytes: Uint8List.fromList([1, 2, 3]),
          mimeType: 'image/jpeg',
          prompt: 'حلّل',
        );

        expect(reply, 'تحليل', reason: '$support');
        final image = fake.sent.single.messages.single.images.single;
        expect(image.mimeType, 'image/jpeg');
        expect(image.bytes, [1, 2, 3]);
      }
    });

    test('an empty image reply uses the image-specific message', () async {
      final service = AiService.withProvider(_FakeProvider((_) => const AiReply('')));

      final reply = await service.analyzeImage(imageBytes: Uint8List(1), mimeType: 'image/jpeg', prompt: 'س');

      expect(reply, AiService.emptyImageReplyMessage);
    });

    test('exercise and medication analyses ask for their own things in Arabic', () async {
      final fake = _FakeProvider((_) => const AiReply('x'));
      final service = AiService.withProvider(fake);

      await service.analyzeExerciseImage(Uint8List(1));
      await service.analyzeMedicationLabel(Uint8List(1));

      expect(fake.sent[0].messages.single.text, contains('التمرين'));
      expect(fake.sent[1].messages.single.text, contains('الدواء'));
    });
  });

  test('capability prompts carry the user input', () async {
    final fake = _FakeProvider((_) => const AiReply('x'));
    final service = AiService.withProvider(fake);

    await service.suggestRecipes(['دجاج', 'أرز']);
    await service.parseVoiceNoteToTasks('اشتري الحليب غدًا');
    await service.suggestBudgetLimits(
      income: 5000,
      fixedTotal: 2000,
      savings: 500,
      available: 2500,
      currencyName: 'ريال سعودي',
    );

    expect(fake.sent[0].messages.single.text, contains('دجاج, أرز'));
    expect(fake.sent[1].messages.single.text, contains('اشتري الحليب غدًا'));
    final budgetPrompt = fake.sent[2].messages.single.text;
    expect(budgetPrompt, allOf(contains('5000'), contains('2000'), contains('500'), contains('2500')));
    expect(budgetPrompt, contains('ريال سعودي'));
  });

  group('the saved key (resetModel stays the public way to activate AI)', () {
    test('resetModel with no provider chosen activates Gemini and trims the key', () async {
      final service = await AiService.create();

      await service.resetModel('  $_fakeKey  ');

      final settings = await AiSettingsService.getInstance();
      expect(settings.selectedId, 'gemini');
      expect(await settings.readKey('gemini'), _fakeKey);
      expect(service.isConfigured, isTrue);
    });

    test('resetModel updates the key of the provider already chosen', () async {
      await configure(key: 'old-key-0000000000');
      final service = await AiService.create();

      await service.resetModel('new-key-0000000000');

      final settings = await AiSettingsService.getInstance();
      expect(settings.selectedId, 'openai');
      expect(await settings.readKey('openai'), 'new-key-0000000000');
      expect(await settings.hasKey('gemini'), isFalse);
    });

    test('a blank key turns the service off', () async {
      await configure();
      final service = await AiService.create();
      expect(service.isConfigured, isTrue);

      await service.resetModel('   ');

      expect(service.isConfigured, isFalse);
      expect(await service.askAssistant('مرحبا'), AiService.missingKeyMessage);
    });

    test('the preview shows only the last four characters', () async {
      await configure();
      final service = await AiService.create();

      final preview = await service.getActiveKeyPreview();

      expect(preview, '••••abcd');
      expect(preview, isNot(contains('AIza')));
    });
  });

  group('model name rules for Gemini', () {
    test('the starting suggestion is the current stable model, not a retired one', () {
      expect(AIConfig.modelName, 'gemini-3.8-flash');
      expect(AIConfig.modelName, isNot(startsWith('gemini-2.0')));
      expect(AIConfig.modelName, isNot(startsWith('gemini-1.5')));
    });

    test('is written in exactly one file under lib/', () {
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => RegExp(r'gemini-\d').hasMatch(f.readAsStringSync()))
          .map((f) => f.path.replaceAll('\\', '/'))
          .toList();

      expect(hits, ['lib/core/config/ai_config.dart']);
    });

    test('the deprecated SDK is gone from the code and from pubspec', () {
      final importers = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains("package:google_generative_ai"))
          .map((f) => f.path)
          .toList();

      expect(importers, isEmpty);
      expect(File('pubspec.yaml').readAsStringSync(), isNot(contains('google_generative_ai')));
    });
  });
}
