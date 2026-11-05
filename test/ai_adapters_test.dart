// عقود المحوّلات الثلاثة بلا شبكة حقيقية. الطلبات والردود هنا مبنية يدويًا من المراجع الرسمية
// لكل مزوّد، وليست ملتقطة من استدعاء حي: التحقق الحي يحتاج مفتاح المستخدم نفسه فلا يُطلب منه.
// ("اختبار الاتصال" في شاشة المزوّد هو الفحص الحي.)
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eman_life_app/core/ai/adapters/anthropic_provider.dart';
import 'package:eman_life_app/core/ai/adapters/gemini_provider.dart';
import 'package:eman_life_app/core/ai/adapters/openai_compatible_provider.dart';
import 'package:eman_life_app/core/ai/ai_errors.dart';
import 'package:eman_life_app/core/ai/ai_models.dart';
import 'package:eman_life_app/core/ai/ai_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _key = 'sk-FAKEFAKEFAKEFAKEFAKE1234abcd';

class _Log {
  final List<http.Request> requests = [];
  Map<String, dynamic> bodyOf(int i) => jsonDecode(utf8.decode(requests[i].bodyBytes)) as Map<String, dynamic>;
}

MockClient _client(_Log log, int status, Object body) {
  return MockClient((request) async {
    log.requests.add(request);
    return http.Response.bytes(
      utf8.encode(body is String ? body : jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

MockClient _throwing(Object error) => MockClient((_) async => throw error);

AiProviderConfig _config(AiProviderKind kind, String baseUrl, String model, {AiSupport images = AiSupport.unknown}) {
  return AiProviderConfig(id: 'x', kind: kind, baseUrl: baseUrl, model: model, images: images);
}

final _image = AiImage(Uint8List.fromList([1, 2, 3]), 'image/jpeg');

Future<AiFailure> _failureOf(Future<Object?> Function() action) async {
  try {
    await action();
  } on AiException catch (e) {
    return e.failure;
  }
  fail('expected an AiException');
}

void main() {
  group('OpenAI-compatible', () {
    OpenAiCompatibleProvider provider(_Log log, int status, Object body, {String base = 'https://api.example.com/v1'}) {
      return OpenAiCompatibleProvider(
        _config(AiProviderKind.openAiCompatible, base, 'some-model'),
        _key,
        client: _client(log, status, body),
      );
    }

    Map<String, Object?> okReply(Object content) => {
          'choices': [
            {'message': {'role': 'assistant', 'content': content}, 'finish_reason': 'stop'},
          ],
        };

    test('sends system + user messages to /chat/completions with a bearer key', () async {
      final log = _Log();
      final reply = await provider(log, 200, okReply('أهلًا بك')).send(const AiRequest(
        systemPrompt: 'تعليمات',
        messages: [AiMessage.user('مرحبا')],
      ));

      expect(reply.text, 'أهلًا بك');
      final request = log.requests.single;
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://api.example.com/v1/chat/completions');
      expect(request.headers['Authorization'], 'Bearer $_key');
      final body = log.bodyOf(0);
      expect(body['model'], 'some-model');
      expect(body.containsKey('max_tokens'), isFalse, reason: 'reasoning models reject it');
      expect(body['messages'], [
        {'role': 'system', 'content': 'تعليمات'},
        {'role': 'user', 'content': 'مرحبا'},
      ]);
    });

    test('images go as data-URI image_url parts next to the text', () async {
      final log = _Log();
      await provider(log, 200, okReply('ok')).send(AiRequest(
        messages: [AiMessage.user('ما هذا؟', images: [_image])],
      ));

      final content = (log.bodyOf(0)['messages'] as List).single['content'] as List;
      expect(content[0], {'type': 'text', 'text': 'ما هذا؟'});
      expect(content[1], {
        'type': 'image_url',
        'image_url': {'url': 'data:image/jpeg;base64,AQID'},
      });
    });

    test('keeps the path of the base URL and tolerates a trailing slash', () async {
      final log = _Log();
      await provider(log, 200, okReply('ok'), base: 'https://openrouter.ai/api/v1/')
          .send(const AiRequest(messages: [AiMessage.user('س')]));

      expect(log.requests.single.url.toString(), 'https://openrouter.ai/api/v1/chat/completions');
    });

    test('a reply made of content parts is joined', () async {
      final text = await provider(
        _Log(),
        200,
        okReply([
          {'type': 'text', 'text': 'الجزء الأول'},
          {'type': 'text', 'text': 'الجزء الثاني'},
        ]),
      ).send(const AiRequest(messages: [AiMessage.user('س')]));

      expect(text.text, 'الجزء الأول\nالجزء الثاني');
    });

    test('an empty reply and a content-filter finish are told apart', () async {
      expect(
        await _failureOf(() => provider(_Log(), 200, okReply('   ')).send(const AiRequest(messages: [AiMessage.user('س')]))),
        AiFailure.emptyReply,
      );
      expect(
        await _failureOf(() => provider(_Log(), 200, {
              'choices': [
                {'message': {'content': null}, 'finish_reason': 'content_filter'},
              ],
            }).send(const AiRequest(messages: [AiMessage.user('س')]))),
        AiFailure.blocked,
      );
    });

    test('lists models sorted, and reads image support only when the provider says so', () async {
      final models = await provider(_Log(), 200, {
        'data': [
          {'id': 'zeta'},
          {
            'id': 'alpha-vision',
            'name': 'Alpha Vision',
            'architecture': {'input_modalities': ['text', 'image']},
          },
          {
            'id': 'beta-text',
            'architecture': {'input_modalities': ['text']},
          },
        ],
      }).listModels();

      expect(models.map((m) => m.id), ['alpha-vision', 'beta-text', 'zeta']);
      expect(models[0].label, 'Alpha Vision');
      expect(models[0].supportsImages, AiSupport.yes);
      expect(models[1].supportsImages, AiSupport.no);
      expect(models[2].supportsImages, AiSupport.unknown);
    });
  });

  group('Anthropic', () {
    AnthropicProvider provider(_Log log, int status, Object body) {
      return AnthropicProvider(
        _config(AiProviderKind.anthropic, 'https://api.anthropic.com', 'some-claude'),
        _key,
        client: _client(log, status, body),
      );
    }

    test('posts to /v1/messages with x-api-key, version header, system and a required max_tokens', () async {
      final log = _Log();
      final reply = await provider(log, 200, {
        'content': [
          {'type': 'text', 'text': 'أهلًا'},
          {'type': 'tool_use', 'id': 'x'},
          {'type': 'text', 'text': 'بك'},
        ],
        'stop_reason': 'end_turn',
      }).send(const AiRequest(systemPrompt: 'تعليمات', messages: [AiMessage.user('مرحبا')]));

      expect(reply.text, 'أهلًا\nبك');
      final request = log.requests.single;
      expect(request.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(request.headers['x-api-key'], _key);
      expect(request.headers['anthropic-version'], '2023-06-01');
      expect(request.headers.containsKey('Authorization'), isFalse);
      final body = log.bodyOf(0);
      expect(body['model'], 'some-claude');
      expect(body['max_tokens'], AnthropicProvider.defaultMaxTokens);
      expect(body['system'], 'تعليمات');
    });

    test('an explicit token limit is honoured', () async {
      final log = _Log();
      await provider(log, 200, {
        'content': [
          {'type': 'text', 'text': 'x'},
        ],
      }).send(const AiRequest(messages: [AiMessage.user('س')], maxOutputTokens: 64));

      expect(log.bodyOf(0)['max_tokens'], 64);
    });

    test('images are base64 blocks placed before the text', () async {
      final log = _Log();
      await provider(log, 200, {
        'content': [
          {'type': 'text', 'text': 'x'},
        ],
      }).send(AiRequest(messages: [AiMessage.user('ما هذا؟', images: [_image])]));

      final content = (log.bodyOf(0)['messages'] as List).single['content'] as List;
      expect(content[0], {
        'type': 'image',
        'source': {'type': 'base64', 'media_type': 'image/jpeg', 'data': 'AQID'},
      });
      expect(content[1], {'type': 'text', 'text': 'ما هذا؟'});
    });

    test('a refusal is reported as blocked and an empty content list as an empty reply', () async {
      expect(
        await _failureOf(() => provider(_Log(), 200, {'content': [], 'stop_reason': 'refusal'})
            .send(const AiRequest(messages: [AiMessage.user('س')]))),
        AiFailure.blocked,
      );
      expect(
        await _failureOf(() => provider(_Log(), 200, {'content': []}).send(const AiRequest(messages: [AiMessage.user('س')]))),
        AiFailure.emptyReply,
      );
    });

    test('lists models from /v1/models with the largest page', () async {
      final log = _Log();
      final models = await provider(log, 200, {
        'data': [
          {'id': 'model-a', 'display_name': 'Model A', 'type': 'model'},
          {'id': 'model-b', 'display_name': 'Model B', 'type': 'model'},
        ],
      }).listModels();

      expect(log.requests.single.url.toString(), 'https://api.anthropic.com/v1/models?limit=1000');
      expect(models.map((m) => m.id), ['model-a', 'model-b']);
      expect(models.first.label, 'Model A');
    });
  });

  group('Gemini', () {
    GeminiProvider provider(_Log log, int status, Object body, {String model = 'some-gemini'}) {
      return GeminiProvider(
        _config(AiProviderKind.gemini, 'https://generativelanguage.googleapis.com', model),
        _key,
        client: _client(log, status, body),
      );
    }

    Map<String, Object?> okReply(List<Object?> parts) => {
          'candidates': [
            {
              'content': {'role': 'model', 'parts': parts},
              'finishReason': 'STOP',
            },
          ],
        };

    test('the key travels in a header, never in the URL', () async {
      final log = _Log();
      await provider(log, 200, okReply([{'text': 'أهلًا'}])).send(const AiRequest(messages: [AiMessage.user('مرحبا')]));

      final request = log.requests.single;
      expect(
        request.url.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/some-gemini:generateContent',
      );
      expect(request.headers['x-goog-api-key'], _key);
      expect(request.url.toString(), isNot(contains(_key)));
      expect(request.url.queryParameters, isEmpty);
    });

    test('system instruction, roles and inline images follow the REST reference', () async {
      final log = _Log();
      await provider(log, 200, okReply([{'text': 'ok'}])).send(AiRequest(
        systemPrompt: 'تعليمات',
        messages: [
          const AiMessage.user('سؤال'),
          const AiMessage.assistant('جواب'),
          AiMessage.user('وهذه؟', images: [_image]),
        ],
      ));

      final body = log.bodyOf(0);
      expect(body['systemInstruction'], {
        'parts': [
          {'text': 'تعليمات'},
        ],
      });
      final contents = body['contents'] as List;
      expect(contents.map((c) => c['role']), ['user', 'model', 'user']);
      expect(contents[2]['parts'], [
        {'text': 'وهذه؟'},
        {
          'inlineData': {'mimeType': 'image/jpeg', 'data': 'AQID'},
        },
      ]);
    });

    test('asks for low thinking, so a thinking model answers inside the timeout', () async {
      final log = _Log();
      await provider(log, 200, okReply([{'text': 'ok'}])).send(const AiRequest(messages: [AiMessage.user('س')]));

      // generationConfig.thinkingConfig.thinkingLevel، حسب مرجع REST (ThinkingConfig).
      expect(log.bodyOf(0)['generationConfig'], {
        'thinkingConfig': {'thinkingLevel': 'LOW'},
      });
    });

    test('maxOutputTokens is sent when the caller sets it, and only then', () async {
      final log = _Log();
      await provider(log, 200, okReply([{'text': 'ok'}]))
          .send(const AiRequest(messages: [AiMessage.user('س')], maxOutputTokens: 64));

      expect(log.bodyOf(0)['generationConfig'], {
        'maxOutputTokens': 64,
        'thinkingConfig': {'thinkingLevel': 'LOW'},
      });

      final plain = _Log();
      await provider(plain, 200, okReply([{'text': 'ok'}])).send(const AiRequest(messages: [AiMessage.user('س')]));
      expect((plain.bodyOf(0)['generationConfig'] as Map).containsKey('maxOutputTokens'), isFalse);
    });

    group('a model that rejects the thinking setting', () {
      const thinkingError = {
        'error': {'code': 400, 'message': 'Thinking level is not supported for this model.', 'status': 'INVALID_ARGUMENT'},
      };

      /// يردّ بالقائمة بالترتيب: (الحالة، الجسم) لكل طلب.
      GeminiProvider sequence(_Log log, List<(int, Object)> replies) {
        var i = 0;
        final client = MockClient((request) async {
          log.requests.add(request);
          final (status, body) = replies[i < replies.length ? i++ : replies.length - 1];
          return http.Response.bytes(
            utf8.encode(jsonEncode(body)),
            status,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        return GeminiProvider(
          _config(AiProviderKind.gemini, 'https://generativelanguage.googleapis.com', 'older-model'),
          _key,
          client: client,
        );
      }

      Map<String, Object?> ok(String text) => {
            'candidates': [
              {
                'content': {'role': 'model', 'parts': [{'text': text}]},
                'finishReason': 'STOP',
              },
            ],
          };

      test('is retried once without thinkingConfig and then answers normally', () async {
        final log = _Log();

        final reply = await sequence(log, [(400, thinkingError), (200, ok('تم'))])
            .send(const AiRequest(messages: [AiMessage.user('س')], maxOutputTokens: 64));

        expect(reply.text, 'تم');
        expect(log.requests, hasLength(2));
        expect(log.bodyOf(0)['generationConfig'], {
          'maxOutputTokens': 64,
          'thinkingConfig': {'thinkingLevel': 'LOW'},
        });
        expect(log.bodyOf(1)['generationConfig'], {'maxOutputTokens': 64}, reason: 'same request minus thinking');
        expect(log.bodyOf(1)['contents'], log.bodyOf(0)['contents']);
        expect(log.requests.every((r) => r.headers['x-goog-api-key'] == _key), isTrue);
        expect(log.requests.any((r) => r.url.toString().contains(_key)), isFalse);
      });

      test('the retry carries no generationConfig at all when nothing else was set', () async {
        final log = _Log();

        await sequence(log, [(400, thinkingError), (200, ok('تم'))])
            .send(const AiRequest(messages: [AiMessage.user('س')]));

        expect(log.bodyOf(1).containsKey('generationConfig'), isFalse);
      });

      test('is retried only once: a second rejection is reported, not looped on', () async {
        final log = _Log();

        final failure = await _failureOf(() => sequence(log, [(400, thinkingError)])
            .send(const AiRequest(messages: [AiMessage.user('س')])));

        expect(failure, AiFailure.badRequest);
        expect(log.requests, hasLength(2));
      });

      test('an unrelated 400, or any other status, is never retried', () async {
        for (final (status, body) in <(int, Object)>[
          (400, {'error': {'message': 'Invalid JSON payload received.', 'status': 'INVALID_ARGUMENT'}}),
          (429, {'error': {'message': 'Quota exceeded', 'status': 'RESOURCE_EXHAUSTED'}}),
          (500, {'error': {'message': 'thinking service failed', 'status': 'INTERNAL'}}),
        ]) {
          final log = _Log();

          await _failureOf(() => sequence(log, [(status, body)]).send(const AiRequest(messages: [AiMessage.user('س')])));

          expect(log.requests, hasLength(1), reason: '$status');
        }
      });
    });

    test('a model name given with the models/ prefix is accepted', () async {
      final log = _Log();
      await provider(log, 200, okReply([{'text': 'ok'}]), model: 'models/some-gemini')
          .send(const AiRequest(messages: [AiMessage.user('س')]));

      expect(log.requests.single.url.path, '/v1beta/models/some-gemini:generateContent');
    });

    test('thinking parts and extra fields such as thoughtSignature are ignored', () async {
      final reply = await provider(_Log(), 200, okReply([
        {'text': 'تفكير داخلي', 'thought': true},
        {'text': 'الجواب النهائي', 'thoughtSignature': 'Cg1zaWduYXR1cmU='},
      ])).send(const AiRequest(messages: [AiMessage.user('س')]));

      expect(reply.text, 'الجواب النهائي');
    });

    test('a blocked prompt or a safety finish is reported as blocked', () async {
      expect(
        await _failureOf(() => provider(_Log(), 200, {
              'promptFeedback': {'blockReason': 'SAFETY'},
            }).send(const AiRequest(messages: [AiMessage.user('س')]))),
        AiFailure.blocked,
      );
      expect(
        await _failureOf(() => provider(_Log(), 200, {
              'candidates': [
                {'finishReason': 'SAFETY'},
              ],
            }).send(const AiRequest(messages: [AiMessage.user('س')]))),
        AiFailure.blocked,
      );
    });

    test('lists only models that can generateContent, strips models/, and follows next pages', () async {
      var call = 0;
      final urls = <String>[];
      final client = MockClient((request) async {
        urls.add(request.url.toString());
        call++;
        final body = call == 1
            ? {
                'models': [
                  {'name': 'models/b-model', 'displayName': 'B', 'supportedGenerationMethods': ['generateContent']},
                  {'name': 'models/embed', 'supportedGenerationMethods': ['embedContent']},
                ],
                'nextPageToken': 'page2',
              }
            : {
                'models': [
                  {'name': 'models/a-model', 'supportedGenerationMethods': ['generateContent']},
                ],
              };
        return http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});
      });
      final models = await GeminiProvider(
        _config(AiProviderKind.gemini, 'https://generativelanguage.googleapis.com', 'x'),
        _key,
        client: client,
      ).listModels();

      expect(models.map((m) => m.id), ['a-model', 'b-model']);
      expect(urls.first, contains('pageSize=1000'));
      expect(urls.last, contains('pageToken=page2'));
      expect(urls.any((u) => u.contains(_key)), isFalse);
    });
  });

  group('errors, for every provider', () {
    final builders = <String, AiProvider Function(MockClient)>{
      'openai': (c) => OpenAiCompatibleProvider(
            _config(AiProviderKind.openAiCompatible, 'https://api.example.com/v1', 'm'),
            _key,
            client: c,
          ),
      'anthropic': (c) => AnthropicProvider(
            _config(AiProviderKind.anthropic, 'https://api.anthropic.com', 'm'),
            _key,
            client: c,
          ),
      'gemini': (c) => GeminiProvider(
            _config(AiProviderKind.gemini, 'https://generativelanguage.googleapis.com', 'm'),
            _key,
            client: c,
          ),
    };

    Future<AiFailure> failWith(String provider, int status, Object body, {bool image = false}) {
      final log = _Log();
      return _failureOf(() => builders[provider]!(_client(log, status, body)).send(AiRequest(
            messages: [AiMessage.user('س', images: image ? [_image] : const [])],
          )));
    }

    test('a wrong key is recognised whatever status the provider uses', () async {
      expect(await failWith('openai', 401, {'error': {'message': 'Incorrect API key provided'}}), AiFailure.invalidKey);
      expect(
        await failWith('anthropic', 401, {
          'type': 'error',
          'error': {'type': 'authentication_error', 'message': 'invalid x-api-key'},
        }),
        AiFailure.invalidKey,
      );
      // Gemini يردّ 400 لا 401.
      expect(
        await failWith('gemini', 400, {
          'error': {'code': 400, 'message': 'API key not valid. Please pass a valid API key.', 'status': 'INVALID_ARGUMENT'},
        }),
        AiFailure.invalidKey,
      );
    });

    test('an unknown or retired model suggests refreshing the list', () async {
      expect(await failWith('openai', 404, {'error': {'message': 'The model `x` does not exist'}}), AiFailure.modelNotFound);
      expect(
        await failWith('anthropic', 404, {
          'type': 'error',
          'error': {'type': 'not_found_error', 'message': 'model: x'},
        }),
        AiFailure.modelNotFound,
      );
      expect(
        await failWith('gemini', 404, {
          'error': {'code': 404, 'message': 'models/x is not found for API version v1beta', 'status': 'NOT_FOUND'},
        }),
        AiFailure.modelNotFound,
      );
      expect(
        await failWith('gemini', 400, {
          'error': {'message': 'models/old is no longer available. Please update your code'},
        }),
        AiFailure.modelNotFound,
      );
    });

    test('limits, quota and credit are one message; overload is another', () async {
      expect(await failWith('openai', 429, {'error': {'message': 'Rate limit reached'}}), AiFailure.rateLimited);
      expect(
        await failWith('gemini', 429, {
          'error': {'message': 'You exceeded your current quota', 'status': 'RESOURCE_EXHAUSTED'},
        }),
        AiFailure.rateLimited,
      );
      expect(
        await failWith('anthropic', 400, {
          'type': 'error',
          'error': {'type': 'invalid_request_error', 'message': 'Your credit balance is too low to access the API'},
        }),
        AiFailure.rateLimited,
      );
      expect(
        await failWith('anthropic', 529, {
          'type': 'error',
          'error': {'type': 'overloaded_error', 'message': 'Overloaded'},
        }),
        AiFailure.busy,
      );
      expect(await failWith('openai', 503, '<html>Bad gateway</html>'), AiFailure.busy);
    });

    test('an image refusal is explained, but only when an image was sent', () async {
      const body = {
        'error': {'message': 'Invalid content: image input is not supported by this model'},
      };
      expect(await failWith('openai', 400, body, image: true), AiFailure.imageUnsupported);
      expect(await failWith('openai', 400, body, image: false), AiFailure.badRequest);
    });

    test('a country block and a blocked prompt have their own messages', () async {
      expect(
        await failWith('gemini', 400, {
          'error': {'message': 'User location is not supported for the API use.', 'status': 'FAILED_PRECONDITION'},
        }),
        AiFailure.unsupportedLocation,
      );
      expect(
        await failWith('openai', 400, {'error': {'message': 'Your request was rejected as a result of our safety system'}}),
        AiFailure.blocked,
      );
    });

    test('no connection, a timeout and an unreadable reply never leak raw text', () async {
      for (final name in builders.keys) {
        final byNetwork = await _failureOf(() => builders[name]!(_throwing(const SocketException('Failed host lookup: secret-host')))
            .send(const AiRequest(messages: [AiMessage.user('س')])));
        final byTimeout = await _failureOf(() => builders[name]!(_throwing(TimeoutException('slow')))
            .send(const AiRequest(messages: [AiMessage.user('س')])));
        expect(byNetwork, AiFailure.network, reason: name);
        expect(byTimeout, AiFailure.timeout, reason: '$name: a slow provider is not "no internet"');
      }
      expect(await failWith('openai', 200, 'not json at all'), AiFailure.unknown);
    });

    test('a timeout and a lost connection have different messages for the user', () {
      expect(AiFailure.timeout.message, isNot(AiFailure.network.message));
      expect(aiFriendlyError(TimeoutException('slow')), AiFailure.timeout.message);
      expect(aiFriendlyError(const SocketException('Failed host lookup: secret-host')), AiFailure.network.message);
      expect(isNetworkError(TimeoutException('slow')), isFalse);
      expect(isNetworkError(const SocketException('x')), isTrue);
      expect(aiFriendlyError(TimeoutException('slow')), isNot(contains('slow')));
    });

    test('the chat timeout leaves a thinking model two minutes, model listing stays short', () {
      expect(AiProvider.chatTimeout, const Duration(seconds: 120));
      expect(AiProvider.listTimeout, const Duration(seconds: 20));
    });

    testWidgets('a provider that never answers ends as a timeout only after the chat timeout', (tester) async {
      final never = MockClient((_) => Completer<http.Response>().future);
      final provider = OpenAiCompatibleProvider(
        _config(AiProviderKind.openAiCompatible, 'https://api.example.com/v1', 'm'),
        _key,
        client: never,
      );
      AiFailure? outcome;
      unawaited(_failureOf(() => provider.send(const AiRequest(messages: [AiMessage.user('س')]))).then((f) => outcome = f));

      await tester.pump(AiProvider.chatTimeout - const Duration(seconds: 1));
      expect(outcome, isNull, reason: 'still waiting just before the limit');

      await tester.pump(const Duration(seconds: 2));
      expect(outcome, AiFailure.timeout);
    });

    test('only a 400 that names the thinking setting is flagged as a thinking rejection', () {
      const thinking = '{"error":{"code":400,"message":"Thinking level is not supported for this model.","status":"INVALID_ARGUMENT"}}';
      const other = '{"error":{"code":400,"message":"Invalid JSON payload received.","status":"INVALID_ARGUMENT"}}';

      expect(classifyHttpFailure(400, thinking).rejectedThinking, isTrue);
      expect(classifyHttpFailure(400, other).rejectedThinking, isFalse);
      expect(classifyHttpFailure(500, thinking).rejectedThinking, isFalse);
      expect(classifyHttpFailure(400, thinking).failure, AiFailure.badRequest, reason: 'the message shown is unchanged');
    });

    test('the message shown to the user is the fixed Arabic text, whatever the provider said', () async {
      try {
        await builders['openai']!(_client(_Log(), 401, {'error': {'message': 'secret details sk-LEAK'}}))
            .send(const AiRequest(messages: [AiMessage.user('س')]));
        fail('expected a failure');
      } on AiException catch (e) {
        expect(e.message, AiFailure.invalidKey.message);
        expect(aiFriendlyError(e), isNot(contains('LEAK')));
      }
    });
  });

  group('safety rules every request obeys', () {
    test('an http:// or malformed base URL is refused before anything is sent', () async {
      for (final bad in ['http://api.example.com/v1', 'ftp://x.com', 'https://', 'https://user:pw@x.com/v1', 'https://x.com/v1?key=1', 'مرحبا']) {
        final log = _Log();
        final p = OpenAiCompatibleProvider(
          _config(AiProviderKind.openAiCompatible, bad, 'm'),
          _key,
          client: _client(log, 200, {}),
        );
        expect(
          await _failureOf(() => p.send(const AiRequest(messages: [AiMessage.user('س')]))),
          AiFailure.insecureUrl,
          reason: bad,
        );
        expect(log.requests, isEmpty, reason: 'nothing may be sent to $bad');
      }
    });

    test('a model name with spaces, quotes or path tricks is refused', () async {
      for (final bad in ['', 'a b', '../x', 'm"; drop', 'm\nx', '-leading']) {
        final log = _Log();
        final p = OpenAiCompatibleProvider(
          _config(AiProviderKind.openAiCompatible, 'https://api.example.com/v1', bad),
          _key,
          client: _client(log, 200, {}),
        );
        expect(
          await _failureOf(() => p.send(const AiRequest(messages: [AiMessage.user('س')]))),
          AiFailure.invalidModelName,
          reason: bad,
        );
        expect(log.requests, isEmpty);
      }
    });

    test('requests only go to the host of the chosen provider and the key is in no URL', () async {
      final cases = <(AiProvider, String)>[];
      final logs = <_Log>[];
      AiProvider make(AiProviderKind kind, String base, MockClient Function(_Log) client) {
        final log = _Log();
        logs.add(log);
        final c = _config(kind, base, 'm');
        final mock = client(log);
        return switch (kind) {
          AiProviderKind.openAiCompatible => OpenAiCompatibleProvider(c, _key, client: mock),
          AiProviderKind.anthropic => AnthropicProvider(c, _key, client: mock),
          AiProviderKind.gemini => GeminiProvider(c, _key, client: mock),
        };
      }

      cases
        ..add((make(AiProviderKind.openAiCompatible, 'https://api.example.com/v1', (l) => _client(l, 200, {'choices': [{'message': {'content': 'x'}}], 'data': []})), 'api.example.com'))
        ..add((make(AiProviderKind.anthropic, 'https://api.anthropic.com', (l) => _client(l, 200, {'content': [{'type': 'text', 'text': 'x'}], 'data': []})), 'api.anthropic.com'))
        ..add((make(AiProviderKind.gemini, 'https://generativelanguage.googleapis.com', (l) => _client(l, 200, {'candidates': [{'content': {'parts': [{'text': 'x'}]}}], 'models': []})), 'generativelanguage.googleapis.com'));

      for (var i = 0; i < cases.length; i++) {
        await cases[i].$1.send(const AiRequest(messages: [AiMessage.user('س')]));
        await cases[i].$1.listModels();
        for (final r in logs[i].requests) {
          expect(r.url.host, cases[i].$2);
          expect(r.url.scheme, 'https');
          expect(r.url.toString(), isNot(contains(_key)));
        }
      }
    });

    test('testConnection treats an empty reply as success but surfaces real failures', () async {
      final ok = OpenAiCompatibleProvider(
        _config(AiProviderKind.openAiCompatible, 'https://api.example.com/v1', 'm'),
        _key,
        client: _client(_Log(), 200, {
          'choices': [
            {'message': {'content': ''}, 'finish_reason': 'length'},
          ],
        }),
      );
      await ok.testConnection();

      final bad = OpenAiCompatibleProvider(
        _config(AiProviderKind.openAiCompatible, 'https://api.example.com/v1', 'm'),
        _key,
        client: _client(_Log(), 401, {'error': {'message': 'Incorrect API key'}}),
      );
      expect(await _failureOf(bad.testConnection), AiFailure.invalidKey);
    });
  });

  group('AiProviderConfig', () {
    test('survives a JSON round trip and rejects malformed input', () {
      final config = _config(AiProviderKind.anthropic, 'https://api.anthropic.com', 'm', images: AiSupport.yes);

      final back = AiProviderConfig.fromJson(jsonDecode(jsonEncode(config.toJson())));

      expect(back!.kind, AiProviderKind.anthropic);
      expect(back.model, 'm');
      expect(back.images, AiSupport.yes);
      expect(AiProviderConfig.fromJson({'id': 'x'}), isNull);
      expect(AiProviderConfig.fromJson('nope'), isNull);
      expect(AiProviderConfig.fromJson({...config.toJson(), 'kind': 'martian'}), isNull);
    });
  });
}
