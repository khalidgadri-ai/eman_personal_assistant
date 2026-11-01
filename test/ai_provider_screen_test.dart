import 'dart:async';

import 'package:eman_life_app/core/ai/ai_errors.dart';
import 'package:eman_life_app/core/ai/ai_models.dart';
import 'package:eman_life_app/core/ai/ai_provider.dart';
import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/config/ai_config.dart';
import 'package:eman_life_app/core/theme/app_theme.dart';
import 'package:eman_life_app/core/widgets/ai_provider_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_storage.dart';

const _secret = 'sk-SECRETSECRETSECRET1234abcd';

class _FakeProvider extends AiProvider {
  _FakeProvider(super.config, super.apiKey, this.behaviour);

  final _Behaviour behaviour;

  @override
  Future<AiReply> send(AiRequest request) async {
    behaviour.requests.add(request);
    behaviour.configs.add(config);
    behaviour.keys.add(apiKey);
    final error = request.hasImages ? behaviour.imageError : behaviour.sendError;
    if (error != null) throw error;
    return const AiReply('تم');
  }

  @override
  Future<List<AiModelInfo>> listModels() async {
    behaviour.configs.add(config);
    behaviour.keys.add(apiKey);
    final error = behaviour.listError;
    if (error != null) throw error;
    return behaviour.models;
  }
}

class _Behaviour {
  Object? sendError;
  Object? imageError;
  Object? listError;
  List<AiModelInfo> models = const [];
  final List<AiRequest> requests = [];
  final List<AiProviderConfig> configs = [];
  final List<String> keys = [];

  AiProvider build(AiProviderConfig config, String key) => _FakeProvider(config, key, this);
}

void main() {
  late TestStorage storage;
  late _Behaviour behaviour;

  setUp(() async {
    storage = await TestStorage.inMemory();
    behaviour = _Behaviour();
  });
  tearDown(() => storage.dispose());

  Future<void> openScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => AiProviderScreen(providerBuilder: behaviour.build)),
                ),
                child: const Text('افتح'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('افتح'));
    await tester.pumpAndSettle();
  }

  TextField field(WidgetTester tester, int index) => tester.widget<TextField>(find.byType(TextField).at(index));

  Future<void> pickProvider(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('opens on Gemini with the suggested model, a locked address and the key link', (tester) async {
    await openScreen(tester);

    expect(find.text('Google Gemini'), findsOneWidget);
    expect(field(tester, 0).controller!.text, 'https://generativelanguage.googleapis.com');
    expect(field(tester, 0).readOnly, isTrue, reason: 'a typo must not send the key to another host');
    expect(field(tester, 1).controller!.text, AIConfig.modelName);
    expect(find.text('https://aistudio.google.com/app/apikey'), findsOneWidget);
    expect(field(tester, 2).obscureText, isTrue, reason: 'the key is hidden by default');
  });

  testWidgets('switching provider loads that provider, with no model name invented for it', (tester) async {
    await openScreen(tester);

    await pickProvider(tester, 'OpenAI (ChatGPT)');

    expect(field(tester, 0).controller!.text, 'https://api.openai.com/v1');
    expect(field(tester, 1).controller!.text, isEmpty);
    expect(find.text('https://platform.openai.com/api-keys'), findsOneWidget);
  });

  testWidgets('only the custom provider lets the address be edited, and http:// is refused', (tester) async {
    await openScreen(tester);
    await pickProvider(tester, 'مخصص (متوافق مع OpenAI)');
    expect(field(tester, 0).readOnly, isFalse);

    await tester.enterText(find.byType(TextField).at(0), 'http://192.168.1.5:11434/v1');
    await tester.enterText(find.byType(TextField).at(1), 'llama');
    await tester.enterText(find.byType(TextField).at(2), _secret);
    await tapText(tester, 'حفظ وتفعيل');

    expect(find.text(AiFailure.insecureUrl.message), findsOneWidget);
    final settings = await AiSettingsService.getInstance();
    expect(settings.selected, isNull, reason: 'nothing saved');
    expect(await settings.hasKey('custom'), isFalse);
  });

  testWidgets('saving stores the provider, model and key (in secure storage) and closes the screen', (tester) async {
    await openScreen(tester);
    await pickProvider(tester, 'OpenAI (ChatGPT)');

    await tester.enterText(find.byType(TextField).at(1), 'my-model');
    await tester.enterText(find.byType(TextField).at(2), '  $_secret  ');
    await tapText(tester, 'حفظ وتفعيل');

    expect(find.byType(AiProviderScreen), findsNothing, reason: 'back to the previous screen');
    final settings = await AiSettingsService.getInstance();
    expect(settings.selectedId, 'openai');
    expect(settings.selected!.model, 'my-model');
    expect(await settings.readKey('openai'), _secret);
    expect(await const FlutterSecureStorage().read(key: 'ai_key_openai'), _secret);
  });

  testWidgets('saving with no key anywhere says a key is needed, and saves nothing', (tester) async {
    await openScreen(tester);
    await pickProvider(tester, 'OpenAI (ChatGPT)');
    await tester.enterText(find.byType(TextField).at(1), 'my-model');

    await tapText(tester, 'حفظ وتفعيل');

    expect(find.text(AiFailure.missingKey.message), findsOneWidget);
    expect((await AiSettingsService.getInstance()).selected, isNull);
  });

  testWidgets('a bad model name is explained before anything is sent', (tester) async {
    await openScreen(tester);
    await pickProvider(tester, 'OpenAI (ChatGPT)');
    await tester.enterText(find.byType(TextField).at(1), 'two words');
    await tester.enterText(find.byType(TextField).at(2), _secret);

    await tapText(tester, 'اختبار الاتصال');

    expect(find.text(AiFailure.invalidModelName.message), findsOneWidget);
    expect(behaviour.requests, isEmpty);
  });

  testWidgets('a saved key is never shown, only its last four characters, and can be deleted', (tester) async {
    final settings = await AiSettingsService.getInstance();
    await settings.save(settings.configFor('gemini'));
    await settings.saveKey('gemini', _secret);

    await openScreen(tester);

    expect(find.textContaining('••••abcd'), findsOneWidget);
    expect(find.textContaining('SECRET'), findsNothing);

    await tapText(tester, 'حذف المفتاح المحفوظ');

    expect(await settings.hasKey('gemini'), isFalse);
    expect(find.textContaining('••••abcd'), findsNothing);
    expect(find.text('حُذف المفتاح من هذا الجهاز.'), findsOneWidget);
  });

  testWidgets('each provider keeps its own key when switching back and forth', (tester) async {
    final settings = await AiSettingsService.getInstance();
    await settings.saveKey('gemini', 'AIzaGEMINIKEY00001111');
    await settings.saveKey('openai', 'sk-OPENAIKEY000002222');

    await openScreen(tester);
    expect(find.textContaining('••••1111'), findsOneWidget);

    await pickProvider(tester, 'OpenAI (ChatGPT)');
    expect(find.textContaining('••••2222'), findsOneWidget);
    expect(find.textContaining('••••1111'), findsNothing);
  });

  group('test connection', () {
    testWidgets('success says the model answers, and uses the typed key without saving it', (tester) async {
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(1), 'my-model');
      await tester.enterText(find.byType(TextField).at(2), _secret);

      await tapText(tester, 'اختبار الاتصال');

      expect(find.text('الاتصال سليم والموديل يرد.'), findsOneWidget);
      expect(behaviour.keys.single, _secret);
      expect(behaviour.configs.single.model, 'my-model');
      expect(await (await AiSettingsService.getInstance()).hasKey('openai'), isFalse, reason: 'testing is not saving');
    });

    testWidgets('failures show the fixed Arabic message, never what the provider said', (tester) async {
      behaviour.sendError = const AiException(AiFailure.invalidKey, statusCode: 401);
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(1), 'my-model');
      await tester.enterText(find.byType(TextField).at(2), _secret);

      await tapText(tester, 'اختبار الاتصال');

      expect(find.text(AiFailure.invalidKey.message), findsOneWidget);
      expect(find.textContaining('401'), findsNothing);
    });

    testWidgets('no key at all asks for one instead of calling the provider', (tester) async {
      await openScreen(tester);

      await tapText(tester, 'اختبار الاتصال');

      expect(find.text(AiFailure.missingKey.message), findsOneWidget);
      expect(behaviour.requests, isEmpty);
    });

    testWidgets('a network failure is reported as no connection', (tester) async {
      behaviour.sendError = TimeoutException('slow');
      await openScreen(tester);
      await tester.enterText(find.byType(TextField).at(2), _secret);

      await tapText(tester, 'اختبار الاتصال');

      expect(find.text(AiFailure.network.message), findsOneWidget);
    });
  });

  group('fetching models', () {
    testWidgets('lists the provider\'s models, filters them by search, and fills the name', (tester) async {
      behaviour.models = const [
        AiModelInfo(id: 'alpha-vision', supportsImages: AiSupport.yes),
        AiModelInfo(id: 'beta-text', supportsImages: AiSupport.no),
        AiModelInfo(id: 'gamma'),
      ];
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(2), _secret);

      await tapText(tester, 'جلب الموديلات المتاحة');
      expect(find.text('alpha-vision'), findsOneWidget);
      expect(find.text('gamma'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '').last, 'vision');
      await tester.pumpAndSettle();
      expect(find.text('gamma'), findsNothing);

      await tester.tap(find.text('alpha-vision'));
      await tester.pumpAndSettle();

      expect(field(tester, 1).controller!.text, 'alpha-vision');
      expect(find.text('نعم'), findsOneWidget);
      expect(
        tester.widget<SegmentedButton<AiSupport>>(find.byType(SegmentedButton<AiSupport>)).selected,
        {AiSupport.yes},
        reason: 'image support is read from the provider when it says so',
      );
    });

    testWidgets('works before any model is chosen, and a wrong key is explained', (tester) async {
      behaviour.listError = const AiException(AiFailure.invalidKey, statusCode: 401);
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(2), _secret);

      await tapText(tester, 'جلب الموديلات المتاحة');

      expect(find.text(AiFailure.invalidKey.message), findsOneWidget);
    });
  });

  group('image support', () {
    SegmentedButton<AiSupport> segmented(WidgetTester tester) =>
        tester.widget<SegmentedButton<AiSupport>>(find.byType(SegmentedButton<AiSupport>));

    testWidgets('the automatic test marks the model as supporting images when it accepts one', (tester) async {
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(1), 'my-model');
      await tester.enterText(find.byType(TextField).at(2), _secret);
      expect(segmented(tester).selected, {AiSupport.unknown});

      await tapText(tester, 'اختبار دعم الصور تلقائيًا');

      expect(segmented(tester).selected, {AiSupport.yes});
      expect(behaviour.requests.single.hasImages, isTrue);
    });

    testWidgets('a refusal marks it as not supporting images', (tester) async {
      behaviour.imageError = const AiException(AiFailure.imageUnsupported, statusCode: 400);
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(1), 'my-model');
      await tester.enterText(find.byType(TextField).at(2), _secret);

      await tapText(tester, 'اختبار دعم الصور تلقائيًا');

      expect(segmented(tester).selected, {AiSupport.no});
      expect(find.textContaining('لا يدعم الصور'), findsWidgets);
    });

    testWidgets('the choice is saved with the provider', (tester) async {
      await openScreen(tester);
      await pickProvider(tester, 'OpenAI (ChatGPT)');
      await tester.enterText(find.byType(TextField).at(1), 'my-model');
      await tester.enterText(find.byType(TextField).at(2), _secret);
      await tapText(tester, 'لا');

      await tapText(tester, 'حفظ وتفعيل');

      expect((await AiSettingsService.getInstance()).selected!.images, AiSupport.no);
    });
  });
}
