import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';
import 'coach_quota_text.dart';
import '../../l10n/l10n.dart';

/// من أين فُتحت شاشة الاشتراك: يتغير العنوان، والمزايا هي نفسها (الاشتراك واحد).
enum PaywallFeature { coach, meditation, tools }

/// شاشة الاشتراك الشهري الواحد: «عمّق أكثر» بلا حد وكل جلسات التأمل.
/// يرجع true عندما يصبح الاشتراك فعّالًا (شراء أو استعادة).
class CoachPaywallScreen extends StatefulWidget {
  /// [quotaExhaustedAt]: وقت فتح الشاشة إن كانت المحاولات المجانية قد انتهت، فيُذكر تاريخ
  /// تجددها. بلا قيمة (null) لا يُذكر تاريخ.
  const CoachPaywallScreen({super.key, this.quotaExhaustedAt, this.feature = PaywallFeature.coach});

  final DateTime? quotaExhaustedAt;
  final PaywallFeature feature;

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
        PurchaseStatus.pending => context.l10n.payPending,
        PurchaseStatus.error => context.l10n.payError,
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
        _message = context.l10n.payOpenFailed;
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
      _message = context.l10n.payNoSubscription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.payTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    switch (widget.feature) {
                      PaywallFeature.meditation => Icons.self_improvement_rounded,
                      PaywallFeature.tools => Icons.handyman_rounded,
                      PaywallFeature.coach => Icons.psychology_rounded,
                    },
                    size: 56,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    switch (widget.feature) {
                      PaywallFeature.meditation => context.l10n.payHeadingMeditation,
                      PaywallFeature.tools => context.l10n.payHeadingTools,
                      PaywallFeature.coach => context.l10n.payHeadingCoach,
                    },
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Benefit(context.l10n.payBenefitDeepen),
                  _Benefit(context.l10n.payBenefitMeditation),
                  _Benefit(context.l10n.payBenefitTools),
                  _Benefit(context.l10n.payBenefitControl),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      context.l10n.payFreeNote,
                      style: const TextStyle(color: AppTheme.subTextColor, fontSize: 13, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.feature == PaywallFeature.coach)
                    Text(
                      coachQuotaOfferLine,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                  if (widget.quotaExhaustedAt case final exhaustedAt?)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        coachQuotaRenewalLine(exhaustedAt),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.accentColor, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 16),
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
                                ? context.l10n.payUnavailable
                                : context.l10n.paySubscribe(_product!.price),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                  if (!(_subscription?.canPurchase ?? false))
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        context.l10n.payAndroidOnly,
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
                    child: Text(
                      context.l10n.payRestore,
                      style: TextStyle(color: AppTheme.accentColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.payRenewal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.subTextColor, fontSize: 11, height: 1.6),
                  ),
                ],
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
