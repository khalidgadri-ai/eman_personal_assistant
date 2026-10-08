class SocialApp {
  final String id;
  final String arabicName;
  final List<String> packages;

  const SocialApp({required this.id, required this.arabicName, required this.packages});
}

/// يجب أن تطابق أسماء الحزم هنا قائمة `<queries>` في android/app/src/main/AndroidManifest.xml.
const List<SocialApp> socialApps = [
  SocialApp(id: 'whatsapp', arabicName: 'واتساب', packages: ['com.whatsapp', 'com.whatsapp.w4b']),
  SocialApp(id: 'instagram', arabicName: 'انستقرام', packages: ['com.instagram.android']),
  SocialApp(id: 'x', arabicName: 'X (تويتر)', packages: ['com.twitter.android']),
  SocialApp(
    id: 'tiktok',
    arabicName: 'تيك توك',
    packages: ['com.zhiliaoapp.musically', 'com.ss.android.ugc.trill'],
  ),
  SocialApp(id: 'snapchat', arabicName: 'سناب شات', packages: ['com.snapchat.android']),
];

class SocialAppUsage {
  final SocialApp app;
  final int minutes;

  const SocialAppUsage(this.app, this.minutes);
}
