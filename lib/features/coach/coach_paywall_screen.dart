import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';

/// يرجع true عندما يصبح الاشتراك فعّالًا (شراء أو استعادة).
class CoachPaywallScreen extends StatefulWidget {
  const CoachPaywallScreen({super.key});

  @override
  State<CoachPaywallScreen> createState() => _CoachPaywallScreenState();
}

class _CoachPaywallScreenState extends State<CoachPaywallScreen> {
  SubscriptionService? _subscription;
  ProductDetails? _product;
  StreamSubscription<PurchaseStatus>? _events;
  bool _loading = true;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final subscription = await SubscriptionService.getInstance();
    ProductDetails? product;
    try {
      product = await subscription.loadProduct();
    } catch (e) {
      debugPrint('CoachPaywallScreen.loadProduct: $e');
    }
    if (!mounted) return;
    _events = subscription.purchaseEvents.listen(_onPurchaseEvent);
    setState(() {
      _subscription = subscription;
      _product = product;
      _loading = false;
    });
  }

  void _onPurchaseEvent(PurchaseStatus status) {
    if (!mounted) return;
    if (_subscription?.isActive ?? false) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _message = switch (status) {
        PurchaseStatus.pending =>
          'الدفع قيد المعالجة لدى Google Play، وسيُفعَّل الاشتراك تلقائيًا عند اكتماله.',
        PurchaseStatus.error => 'تعذّر إتمام الشراء، حاول مرة أخرى.',
        _ => null,
      };
    });
  }

  Future<void> _subscribe() async {
    final subscription = _subscription;
    final product = _product;
    if (subscription == null || product == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final started = await subscription.buy(product);
      if (!started && mounted) setState(() => _busy = false);
    } catch (e) {
      debugPrint('CoachPaywallScreen.buy: $e');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'تعذّر فتح نافذة الشراء، حاول مرة أخرى.';
      });
    }
  }

  Future<void> _restore() async {
    final subscription = _subscription;
    if (subscription == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final active = await subscription.restore();
    if (!mounted) return;
    if (active) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _message = 'لا يوجد اشتراك فعّال على حساب Google Play هذا.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سؤال المتابعة الذكي')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.psychology_rounded, size: 56, color: AppTheme.accentColor),
                    const SizedBox(height: 12),
                    const Text(
                      'تعمّق أكثر في تأملك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _Benefit('سؤال متابعة واحد مبني على إجابتك أنت، بدل سؤال عام من البنك.'),
                    const _Benefit('نفس قواعد المدرب: أسئلة فقط، بلا نصائح ولا أحكام.'),
                    const _Benefit('أنت تقرر متى تتعمق، لا شيء يحدث تلقائيًا.'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'الأسئلة المحلية وسجل جلساتك وتتبع الميزانية تبقى مجانية بالكامل.\n'
                        'سؤال المتابعة يعمل بمفتاح Gemini الخاص بك (مجاني من Google AI Studio).',
                        style: TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _busy || _product == null ? null : _subscribe,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _product == null
                                  ? 'الاشتراك غير متاح حاليًا'
                                  : 'اشترك الآن — ${_product!.price} شهريًا',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    if (!(_subscription?.canPurchase ?? false))
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'الاشتراك متاح في نسخة Android المثبتة من Google Play.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.subTextColor, fontSize: 12),
                        ),
                      ),
                    if (_message case final message?)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : _restore,
                      child: const Text(
                        'استعادة المشتريات',
                        style: TextStyle(color: AppTheme.accentColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يتجدد الاشتراك تلقائيًا كل شهر بنفس السعر حتى تلغيه. يمكنك الإلغاء في أي وقت '
                      'من Google Play ← الدفعات والاشتراكات ← الاشتراكات.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.subTextColor, fontSize: 11, height: 1.6),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 20, color: AppTheme.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppTheme.textColor, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
