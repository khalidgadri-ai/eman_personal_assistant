import 'package:eman_life_app/core/ai/ai_errors.dart';
import 'package:eman_life_app/core/ai/ai_models.dart';
import 'package:eman_life_app/core/ai/ai_provider.dart';
import 'package:eman_life_app/core/ai/ai_settings_service.dart';
import 'package:eman_life_app/core/config/ai_config.dart';
import 'package:eman_life_app/core/services/database_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _secret = 'sk-SECRETSECRETSECRET1234abcd';

void main() {
  void freshInstall({Map<String, Object> prefs = const {}, Map<String, String> secure = const {}}) {
    SharedPreferences.setMockInitialValues({...prefs});
    FlutterSecureStorage.setMockInitialValues({...secure});
    DatabaseService.resetForTesting();
    AiSettingsService.resetForTesting();
  }

  setUp(freshInstall);

  test('a fresh install has no provider and no key', () async {
    final settings = await AiSettingsService.getInstance();

    expect(settings.selected, isNull);
    expect(settings.selectedId, isNull);
    expect(await settings.hasKey('gemini'), isFalse);
  });

  test('the chosen provider and its model survive an app restart', () async {
    var settings = await AiSettingsService.getInstance();
    await settings.save(settings.configFor('openai').copyWith(model: 'my-model', images: AiSupport.no));

    AiSettingsService.resetForTesting();
    settings = await AiSettingsService.getInstance();

    expect(settings.selectedId, 'openai');
    expect(settings.selected!.model, 'my-model');
    expect(settings.selected!.images, AiSupport.no);
    expect(settings.selected!.baseUrl, 'https://api.openai.com/v1');
  });

  test('a provider that was never configured shows its preset defaults, with no model name invented', () async {
    final settings = await AiSettingsService.getInstance();

    final openai = settings.configFor('openai');
    expect(openai.model, isEmpty, reason: 'model names are the user\'s to type or fetch');
    expect(settings.configFor('gemini').model, AIConfig.modelName, reason: 'only a starting suggestion');
    expect(settings.configFor('anthropic').kind, AiProviderKind.anthropic);
  });

  test('each provider has its own key', () async {
    final settings = await AiSettingsService.getInstance();

    await settings.saveKey('openai', 'sk-OPENAI0000000000');
    await settings.saveKey('anthropic', 'sk-ANTHROPIC0000000');

    expect(await settings.readKey('openai'), 'sk-OPENAI0000000000');
    expect(await settings.readKey('anthropic'), 'sk-ANTHROPIC0000000');
    expect(await settings.hasKey('gemini'), isFalse);

    await settings.deleteKey('openai');
    expect(await settings.hasKey('openai'), isFalse);
    expect(await settings.hasKey('anthropic'), isTrue);
  });

  test('a key is trimmed, and saving a blank key deletes it', () async {
    final settings = await AiSettingsService.getInstance();

    await settings.saveKey('openai', '  $_secret  ');
    expect(await settings.readKey('openai'), _secret);

    await settings.saveKey('openai', '   ');
    expect(await settings.hasKey('openai'), isFalse);
  });

  test('the preview shows only the last four characters', () async {
    final settings = await AiSettingsService.getInstance();
    await settings.saveKey('openai', _secret);
    await settings.saveKey('groq', 'short');

    expect(await settings.keyPreview('openai'), '••••abcd');
    expect(await settings.keyPreview('groq'), '••••');
    expect(await settings.keyPreview('xai'), isEmpty);
  });

  test('keys live only in secure storage, never in SharedPreferences', () async {
    final settings = await AiSettingsService.getInstance();
    await settings.save(settings.configFor('openai').copyWith(model: 'm'));
    await settings.saveKey('openai', _secret);

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      expect('${prefs.get(key)}', isNot(contains(_secret)), reason: 'found in pref $key');
    }
    expect(await const FlutterSecureStorage().read(key: 'ai_key_openai'), _secret);
  });

  test('saving an insecure address or a bad model name is refused and nothing is stored', () async {
    final settings = await AiSettingsService.getInstance();

    Future<AiFailure> failureOf(AiProviderConfig config) async {
      try {
        await settings.save(config);
      } on AiException catch (e) {
        return e.failure;
      }
      fail('expected a failure');
    }

    expect(
      await failureOf(settings.configFor('custom').copyWith(baseUrl: 'http://192.168.1.5:11434/v1', model: 'm')),
      AiFailure.insecureUrl,
    );
    expect(await failureOf(settings.configFor('openai').copyWith(model: 'a b')), AiFailure.invalidModelName);
    expect(settings.selected, isNull);
  });

  test('a corrupted or foreign stored config is ignored instead of crashing the app', () async {
    freshInstall(prefs: {'ai_config': '{not json'});
    expect((await AiSettingsService.getInstance()).selected, isNull);

    freshInstall(prefs: {
      'ai_config': '{"selected":"martian","providers":{"martian":{"id":"martian","kind":"gemini","baseUrl":"https://x.com","model":"m"}}}',
    });
    final settings = await AiSettingsService.getInstance();
    expect(settings.selected, isNull);
    expect(settings.selectedId, isNull);
  });

  group('the old key that used to sit in SharedPreferences', () {
    const legacy = 'AIzaSyLEGACYLEGACYLEGACYLEGACY1234';

    test('moves once to secure storage, becomes the Gemini provider, and is wiped from prefs', () async {
      freshInstall(prefs: {'gemini_api_key': legacy, 'daily_tasks': '[]'});

      final settings = await AiSettingsService.getInstance();

      expect(await settings.readKey('gemini'), legacy);
      expect(settings.selectedId, 'gemini');
      expect(settings.selected!.model, AIConfig.modelName);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('gemini_api_key'), isFalse, reason: 'it must not stay in the auto-backed-up file');
      expect(prefs.getString('daily_tasks'), '[]', reason: 'other data untouched');
    });

    test('does not override a provider or key the user already set up', () async {
      freshInstall(prefs: {'gemini_api_key': legacy});
      SharedPreferences.setMockInitialValues({
        'gemini_api_key': legacy,
        'ai_config':
            '{"selected":"openai","providers":{"openai":{"id":"openai","kind":"openAiCompatible","baseUrl":"https://api.openai.com/v1","model":"m","images":"unknown"}}}',
      });
      FlutterSecureStorage.setMockInitialValues({'ai_key_gemini': 'AIzaSyNEWER00000000000'});
      DatabaseService.resetForTesting();
      AiSettingsService.resetForTesting();

      final settings = await AiSettingsService.getInstance();

      expect(settings.selectedId, 'openai', reason: 'the user\'s choice stands');
      expect(await settings.readKey('gemini'), 'AIzaSyNEWER00000000000');
      expect((await SharedPreferences.getInstance()).containsKey('gemini_api_key'), isFalse);
    });

    test('a blank old key changes nothing', () async {
      freshInstall(prefs: {'gemini_api_key': '   '});

      final settings = await AiSettingsService.getInstance();

      expect(settings.selected, isNull);
      expect(await settings.hasKey('gemini'), isFalse);
    });
  });
}
