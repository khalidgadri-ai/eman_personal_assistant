# تكليف للوكيل: إصلاح المنبه والمساعد الذكي في تطبيق إيمان (Flutter)

كتبه المهندس المشرف بتاريخ 2026-11-01 بعد فحص الكود. نفّذ المهام **بالترتيب**، ولا تنتقل لمهمة قبل أن تنجح اختبارات السابقة.

## قواعد ثابتة (لا استثناء)

- اقرأ `CLAUDE.md` في جذر المستودع والتزم به، خصوصًا: النصوص الظاهرة للمستخدم بالعربية والمعرّفات بالإنجليزية، ولا مفتاح API مركزي، ولا طباعة مفاتيح أو أجسام ردود المزوّد في السجلات.
- **لا commit ولا push.** المالك يراجع التعديلات بنفسه أولًا.
- لا تضف `SCHEDULE_EXACT_ALARM` ولا `USE_EXACT_ALARM` ولا أي صلاحية جديدة في `AndroidManifest.xml`.
- لا تغيّر `applicationId` ولا ملفات التوقيع (`android/key.properties` والـ keystore).
- لا تعدّل `pubspec.lock` يدويًا.
- لا تعمل على مجلد `aws_project/`، فهو خارج هذا التكليف.
- بعد كل مهمة شغّل: `flutter analyze` ثم `flutter test`.

## نقطة البداية (فحصها المشرف)

- `flutter analyze`: لا مشاكل.
- `flutter test`: نجح 476، وفشل 2 في `test/budget_screen_test.dart`. السبب مشروح في المهمة 3.
- يوجد عمل كثير غير محفوظ في git منذ آخر commit. لا تلمس ما لا يخص مهامك.

---

## المهمة 1: التذكيرات لا ترن أبدًا (أولوية قصوى)

### السبب (مؤكَّد من كود المكتبة)

1. `NotificationService.locationFor()` في `lib/core/services/notification_service.dart` ينشئ `tz.Location` باسم **`'device'`**.
2. `flutter_local_notifications` (الإصدار 22.2.0) يرسل اسم الموقع كما هو إلى أندرويد (`lib/src/tz_datetime_mapper.dart`: `'timeZoneName': location.name`).
3. كود أندرويد في المكتبة ينفّذ `ZoneId.of(notificationDetails.timeZoneName)` (`FlutterLocalNotificationsPlugin.java`، داخل `zonedScheduleNotification`). الاسم `"device"` ليس معرّف منطقة صالحًا، فيرمي استثناءً.
4. `NotificationService.schedule()` يبتلع الخطأ في `catch` (`debugPrint` فقط)، فلا يُجدول أي تذكير ولا يعرف المستخدم بذلك.
5. الاختبارات الحالية تستبدل `ReminderGateway` بنسخة وهمية، فلم تكشف المشكلة.

### الإصلاح المطلوب

**1-أ (إلزامي):** اجعل اسم الموقع معرّفًا يقبله `java.time.ZoneId.of` كإزاحة ثابتة، مع إبقاء التصميم الحالي (لا تحمّل قاعدة المناطق الزمنية):
- الإزاحة صفر: `'UTC'`.
- غير ذلك: `'UTC'` ثم الإشارة ثم ساعتان ثم `:` ثم دقيقتان. أمثلة: `UTC+03:00`، `UTC-04:00`، `UTC+05:30`، `UTC+05:45`.
- احسبها من `now.timeZoneOffset`، وانتبه للإزاحة السالبة والدقائق غير الصفرية.
- أضف اختبارًا في `test/` يتحقق من الاسم لعدة إزاحات (0، +3، −4، +5:30، +5:45) بالنمط `^UTC([+-]\d{2}:\d{2})?$`، ومن أن الإزاحة نفسها صحيحة.

**1-ب (إلزامي):** لا تجعل الفشل صامتًا:
- اجعل `NotificationService.schedule` ترجع `Future<bool>`: `true` عند النجاح، و`false` عند الاستثناء. واجعل `ReminderGateway.schedule` كذلك.
- اجعل `ReminderService.syncAll` ترجع عدد ما **نجحت** جدولته فعلًا. وحدّث الاختبارات الحالية للخدمة.
- أضف في `NotificationService` دالة تستدعي `areNotificationsEnabled()` من `AndroidFlutterLocalNotificationsPlugin`، وتبتلع الخطأ وترجع `null` إن تعذّر الفحص.
- في الشاشتين اللتين تستدعيان `syncAll(askPermission: true)` (`goals_tasks_screen.dart` و`health_fitness_screen.dart`): بعد أن يضبط المستخدم تذكيرًا بنفسه فقط، إن كانت الإشعارات مطفأة أو فشلت جدولة أي تذكير، أظهر `SnackBar` عربيًا قصيرًا. مثال: «لم يُضبط التذكير. فعّل إشعارات تطبيق إيمان من إعدادات الجوال ثم أعد المحاولة.» استخدم صيغة لا تخاطب جنسًا واحدًا، فاختبار `test/first_run_empty_test.dart` يفحص ذلك.

### للعلم، ولا تغيّره

التذكيرات **غير دقيقة عمدًا** (`inexactAllowWhileIdle`)، فقد تتأخر دقائق. هذا قرار المالك.

---

## المهمة 2: المساعد الذكي «يفكّر» طويلًا ثم يقول «لا يوجد إنترنت»

### السبب (مرجّح بقوة من الكود والتوثيق)

1. `AiProvider.chatTimeout = 60s` في `lib/core/ai/ai_provider.dart`.
2. عند تجاوز المهلة يُرمى `TimeoutException`، و`isNetworkError()` في `ai_errors.dart` يعدّه خطأ شبكة. فتظهر للمستخدم رسالة `AiFailure.network`: «تعذّر الاتصال بالإنترنت…» مع أن الإنترنت يعمل.
3. الموديل المقترح افتراضيًا `gemini-3.8-flash` (`lib/core/config/ai_config.dart`) موجود في قائمة Google الرسمية. لكنه موديل «تفكير»: صفحة Thinking الرسمية تذكر له المستويات low وmedium وhigh، بلا خيار إيقاف. ومع تعليمات النظام الطويلة قد يتجاوز الرد 60 ثانية.
4. `GeminiProvider.send` لا يرسل `generationConfig` أصلًا، فيتجاهل حتى `maxOutputTokens`. ولهذا قد ينجح زر «اختبار الاتصال» بينما تفشل المحادثة الحقيقية.

### الإصلاح المطلوب

**2-أ (إلزامي): افصل «انتهاء المهلة» عن «لا إنترنت».**
- أضف إلى `AiFailure` قيمة `timeout` برسالة عربية ثابتة، مثل: «تأخّر المزوّد في الرد. حاول مرة أخرى، أو اختر موديلًا أسرع من إعدادات الذكاء الاصطناعي.»
- في `AiProvider._call`: التقط `TimeoutException` أولًا وارمِ `AiException(AiFailure.timeout)`.
- أزل `TimeoutException` من `isNetworkError()`. وفي `aiFriendlyError()` اجعل `TimeoutException` يرجع رسالة `timeout`.
- حدّث وأضف اختبارات: `TimeoutException` يعطي `timeout`، و`SocketException` يعطي `network`.
- السجلات تطبع اسم نوع الفشل فقط كما هي الآن، ولا أي نص من المزوّد.

**2-ب (إلزامي):** ارفع `chatTimeout` إلى 120 ثانية، وأبقِ `listTimeout` كما هو.

**2-ج (إلزامي، بشرط التحقق أولًا): قلّل «التفكير» في Gemini.**
- قبل كتابة أي كود، تحقّق من اسم الحقل بالضبط في مرجع API الرسمي: https://ai.google.dev/api/generate-content (قسما `GenerationConfig` و`ThinkingConfig`). المتوقع `generationConfig.thinkingConfig.thinkingLevel` بقيمة `"low"`، لكن **لا تعتمد على هذا دون تأكيد**. صفحة https://ai.google.dev/gemini-api/docs/thinking توثّق `thinking_level` في واجهة Interactions، لا في `generateContent`.
- أرسل `generationConfig` يحوي مستوى التفكير المنخفض. وأرسل `maxOutputTokens` إن كان `request.maxOutputTokens` غير فارغ.
- إن ردّ المزوّد بـ 400 ورسالته تذكر thinking، فأعد المحاولة **مرة واحدة** بدون `thinkingConfig`. هذا للموديلات التي لا تدعمه.
- حدّث `test/ai_adapters_test.dart` بحيث يثبّت شكل الطلب الجديد، وأضف حالة إعادة المحاولة.

**2-د (اختياري، اسأل المشرف أولًا):** `AiProvider` ينشئ `http.Client()` جديدًا لكل خدمة ولا يغلقه أبدًا. اقترح حلًا ولا تنفّذه.

---

## المهمة 3: اختباران يعتمدان على تاريخ اليوم الحقيقي

`test/budget_screen_test.dart` يثبّت «اليوم» على 2026-10-18 عبر `FinancialScreen(now: ...)`. لكن `ExpenseEntryScreen` (`lib/features/budget/expense_entry_screen.dart`، السطران 34 و56) و`BudgetSummaryScreen` (السطران 31 و56) تستعملان `DateTime.now()` الحقيقي. فبعد انتهاء أكتوبر تقع المصروفات الجديدة خارج دورة الاختبار ويفشل الاختباران:
- «a new expense from the card lowers the remaining amount at once»
- «changing the currency changes the symbol on the card, the form and the monthly screen»

**الإصلاح:** مرّر دالة `now` نفسها من `FinancialScreen` إلى الشاشتين، بمعامل اختياري قيمته الافتراضية `DateTime.now`. لا تغيّر سلوك التطبيق الحقيقي.

---

## المهمة 4: مراجعة عامة (تقرير فقط، بلا تعديل)

بعد نجاح المهام 1 إلى 3، افحص وقدّم **تقريرًا مكتوبًا للمشرف** قبل أي تعديل:

1. كل `catch` يبتلع الخطأ في تدفق يبدأه المستخدم دون أن يخبره بشيء: اذكر الملف والسطر والأثر.
2. أي `debugPrint` أو `print` قد يطبع مفتاحًا أو نص مستخدم أو جسم رد من المزوّد.
3. أي `DateTime.now()` آخر يجعل اختبارًا يعتمد على التاريخ الحقيقي.
4. تكرار حقيقي في `lib/`. لا تذكر نسخ `web_app/`، فهي مكررة عمدًا.
5. بناء release يمرّ: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`. لا ترفعه إلى أي مكان.

---

## تعريف «تم»

- `flutter analyze` بلا مشاكل، و`flutter test` كله ناجح.
- تقرير قصير للمالك والمشرف فيه: الملفات التي تغيّرت ولماذا، ونتيجة الاختبارات، وما **لم** يُختبر على جوال حقيقي.
- لا commit ولا push ولا رفع إلى Google Play.
- لا ترفع رقم الإصدار (`version: 1.0.0+2` في `pubspec.yaml`) إلا بطلب من المالك قبل رفع نسخة اختبار جديدة.
