class SocialApp {
  final String id;
  final String arabicName;
  final String englishName;
  final List<String> packages;

  const SocialApp({required this.id, required this.arabicName, required this.englishName, required this.packages});

  String nameFor(String lang) => lang == 'ar' ? arabicName : englishName;
}

/// يجب أن تطابق أسماء الحزم هنا قائمة `<queries>` في android/app/src/main/AndroidManifest.xml.
const List<SocialApp> socialApps = [
  SocialApp(id: 'whatsapp', arabicName: 'واتساب', englishName: 'WhatsApp', packages: ['com.whatsapp', 'com.whatsapp.w4b']),
  SocialApp(id: 'instagram', arabicName: 'انستقرام', englishName: 'Instagram', packages: ['com.instagram.android']),
  SocialApp(id: 'x', arabicName: 'X (تويتر)', englishName: 'X (Twitter)', packages: ['com.twitter.android']),
  SocialApp(
    id: 'tiktok',
    arabicName: 'تيك توك',
    englishName: 'TikTok',
    packages: ['com.zhiliaoapp.musically', 'com.ss.android.ugc.trill'],
  ),
  SocialApp(id: 'snapchat', arabicName: 'سناب شات', englishName: 'Snapchat', packages: ['com.snapchat.android']),
];

class SocialAppUsage {
  final SocialApp app;
  final int minutes;

  const SocialAppUsage(this.app, this.minutes);
}
