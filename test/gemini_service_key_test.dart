import 'package:eman_life_app/core/services/database_service.dart';
import 'package:eman_life_app/core/services/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    DatabaseService.resetForTesting();
  });

  test('without a user key there is no model and no fallback key', () async {
    SharedPreferences.setMockInitialValues({});

    final service = await GeminiService.create();

    expect(service.hasKey, isFalse);
    expect(await service.askAssistant('مرحبا'), GeminiService.missingKeyMessage);
  });

  test('a saved user key enables the model', () async {
    SharedPreferences.setMockInitialValues({'gemini_api_key': 'user-key'});

    final service = await GeminiService.create();

    expect(service.hasKey, isTrue);
  });
}
