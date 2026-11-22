# الإصدار 1.0.0+6

الحزمة: `build/app/outputs/bundle/release/app-release.aab` (موقّعة بمفتاح الرفع، versionCode 6، targetSdk 36، minSdk 24).
ملفات الرموز لقراءة أعطال هذه النسخة: `%USERPROFILE%\eman_symbols\1.0.0+6`.

تحل محل 1.0.0+5 التي بُنيت ولم تُرفع. الجديد بعدها:
- **إصلاح Gemini:** النسخ حتى 1.0.0+4 كانت تحفظ `gemini-3.8-flash`، وهو مزدحم بمفتاح مجاني، فيرد المساعد «خدمة المزوّد مشغولة» أو «تأخّر المزوّد». عند أول تشغيل لهذه النسخة يُستبدل مرة واحدة بالموديل الأخف (`AIConfig.modelName`)، ولا يُمس أي موديل آخر كتبه المستخدم.
- ثلاثة مجالات جديدة للمدرب (150 سؤالًا باللغتين)، وإصلاح عملة تبويب الميزانية قبل إعداد الخطة.
- زر «تواصل معنا» ظاهر الآن ويفتح البريد على عنوان الدعم.

لا شيء جديد يخرج من الجهاز: زر «تواصل معنا» يفتح تطبيق البريد في جوال المستخدم فقط (مذكور في `docs/play_data_safety.md`). لا تغيير في الأذونات.

## ملاحظات الإصدار (حد Google Play: 500 حرف لكل لغة؛ العربية 368 والإنجليزية 432)

النسخة 5 لم تُرفع، فهذه الملاحظات تجمع ما فيها وما أُضيف بعدها.

```
<ar>
جديد في هذا التحديث:
• إصلاح المساعد الذكي مع Gemini: موديل أخف وأسرع يُختار تلقائيًا، ومحاولة ثانية حين يزدحم المزوّد.
• التطبيق بالعربية والإنجليزية، ويتبع لغة الجوال.
• أدوات جديدة في المدرب: عجلة الحياة وتسمية المشاعر مجانًا، وأربع أدوات بالاشتراك.
• ثلاثة مجالات جديدة للمدرب: العلاقات، والعمل، والحياة الرقمية.
• عملات أكثر في الميزانية.
• زر «تواصل معنا» للدعم.
</ar>
<en-US>
What's new:
• Fixed the AI assistant with Gemini: a lighter, faster model is chosen for you, and a busy provider is retried once.
• The app is now in Arabic and English, following your phone's language.
• New coach tools: wheel of life and naming feelings for free, plus four with the subscription.
• Three new coach areas: relationships, work, and digital life.
• More currencies in the budget.
• A "Contact us" button for support.
</en-US>
```

## وصف المتجر بالإنجليزية (مسودة)

حدود Google Play: الاسم 30 حرفًا، والوصف القصير 80، والوصف الكامل 4000.

**الاسم:**
```
Eman: Life Assistant
```

**الوصف القصير:**
```
Tasks, health, kitchen, budget and a life coach in one private app.
```

**الوصف الكامل:**
```
Eman brings the everyday parts of life into one calm, private app: your tasks and goals, health and care routine, kitchen and pantry, budget, and a life coach that asks good questions.

YOUR DATA STAYS ON YOUR PHONE
There is no account and no server. Your entries are stored on your device, and the sensitive ones are encrypted. You can save an encrypted backup file to move to a new phone.

GOALS & TASKS
• Daily tasks with optional reminders
• A goal ladder from yearly to weekly goals
• A Quran reading tracker

HEALTH & FITNESS
• Exercise cards with sets, reps and a workout log
• Medicines and a daily care routine with reminders
• Meditation: a silent timer with bells and 40 Hz gamma listening (the guided sessions are in Arabic for now)

KITCHEN & HOME
• Recipes with ingredients that scale with servings
• Pantry and home supplies, a shopping list and a laundry schedule
• Move what ran out to the shopping list in one tap

BUDGET
• Enter your income, payday and fixed expenses, and see what is left for the cycle and for each day
• Category limits with warnings, and a monthly chart
• Manual entry only: no bank linking

LIFE COACH
• 450 reflection questions in nine areas, including relationships, work and digital life, with no advice and no judgement
• Coach tools: wheel of life and naming feelings (free); belief check, inner voice, deciding between two options and changing a habit (with the subscription)
• If something you write suggests a crisis, the coach shows how to reach your local emergency number and a free helpline directory

AI FEATURES WITH YOUR OWN KEY
Recipe ideas, exercise photo analysis, reading a medicine box, budget suggestions and coach follow-up questions work with your own key from Google Gemini, Anthropic Claude or any OpenAI-compatible service. The key is stored only on your device and sent only to the provider you choose.

SUBSCRIPTION
One monthly subscription unlocks unlimited coach follow-up questions, the premium meditation sessions, and four coach tools. Everything else is free.

Eman is a self-reflection and organization tool. It is not a medical device and does not replace a doctor, a pharmacist or a licensed therapist.
```

## ما يفعله المالك في Play Console

1. رفع `app-release.aab` في إصدار جديد بالقناة المناسبة، ولصق ملاحظات الإصدار أعلاه.
2. في «التواجد في المتجر» ← «تفاصيل المتجر»: التأكد أن بريد التواصل هو نفسه بريد زر «تواصل معنا».
3. (مستحسن) إضافة وصف المتجر بالإنجليزية من «التواجد في المتجر» ← «الترجمات».
4. تحديث وصف اشتراك `eman_coach_monthly` إن كان يعدّد ما يفتحه، بإضافة أدوات المدرب الأربع.
5. صوت المرشد الإنجليزي لم يُولَّد بعد: الجلسات المرشدة تبقى مخفية بالإنجليزية حتى يُولَّد (`docs/meditation_recording_script_en.md`)، وهذا لا يمنع الإصدار.
