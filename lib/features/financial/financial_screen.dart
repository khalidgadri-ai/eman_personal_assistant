import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ai_key_setup_screen.dart';
import '../budget/budget_summary_screen.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  final TextEditingController _salaryController = TextEditingController(text: '10000');
  final TextEditingController _expensesController = TextEditingController(text: '3500');
  final TextEditingController _savingsController = TextEditingController(text: '2000');
  bool _isGeneratingAdvice = false;

  final List<Map<String, dynamic>> _budgets = [
    {'title': 'الفواتير والالتزامات الثابتة', 'amount': '3,500 ر.س', 'percentage': 0.85, 'color': Colors.redAccent},
    {'title': 'الادخار والاستثمار', 'amount': '2,000 ر.س', 'percentage': 0.65, 'color': Colors.greenAccent},
    {'title': 'ميزانية التسوق والشراء', 'amount': '1,500 ر.س', 'percentage': 0.50, 'color': Colors.blueAccent},
    {'title': 'التعليم والسفر والاشتراكات', 'amount': '1,000 ر.س', 'percentage': 0.40, 'color': Colors.amberAccent},
  ];

  @override
  void dispose() {
    _salaryController.dispose();
    _expensesController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  /// ✅ يطلب توصيات ميزانية ذكية من Gemini بناءً على القيم المدخلة
  Future<void> _getBudgetAdvice() async {
    final salary = double.tryParse(_salaryController.text.replaceAll(',', '').trim());
    final expenses = double.tryParse(_expensesController.text.replaceAll(',', '').trim());
    final savings = double.tryParse(_savingsController.text.replaceAll(',', '').trim());

    if (salary == null || expenses == null || savings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ يرجى إدخال أرقام صحيحة في جميع الحقول'), backgroundColor: Colors.orange),
      );
      return;
    }

    final gemini = await requireGeminiService(context);
    if (gemini == null || !mounted) return;

    setState(() => _isGeneratingAdvice = true);

    final result = await gemini.getBudgetAdvice(
      salary: salary,
      fixedExpenses: expenses,
      savingsGoal: savings,
    );

    setState(() => _isGeneratingAdvice = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Text('تقرير الميزانية الذكية 💡', style: TextStyle(color: AppTheme.textColor, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(result, style: const TextStyle(color: AppTheme.subTextColor, fontSize: 14, height: 1.7)),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 المحفظة المالية والميزانية'),
        actions: [
          IconButton(
            tooltip: 'مصاريفي الشهرية',
            icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.accentColor),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BudgetSummaryScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ بطاقة إدخال البيانات المالية التفاعلية
          Card(
            color: AppTheme.surfaceColor,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: AppTheme.accentColor),
                      SizedBox(width: 8),
                      Text('بياناتي المالية الشهرية', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFinancialField(
                    controller: _salaryController,
                    label: '💼 الراتب الشهري (ر.س)',
                    icon: Icons.payments_rounded,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildFinancialField(
                    controller: _expensesController,
                    label: '📋 الالتزامات الثابتة (ر.س)',
                    icon: Icons.receipt_long_rounded,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildFinancialField(
                    controller: _savingsController,
                    label: '🏦 هدف الادخار الشهري (ر.س)',
                    icon: Icons.savings_rounded,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _isGeneratingAdvice
                        ? const Column(
                            children: [
                              CircularProgressIndicator(color: AppTheme.accentColor),
                              SizedBox(height: 8),
                              Text('جارٍ تحليل ميزانيتك...', style: TextStyle(color: AppTheme.subTextColor, fontSize: 12)),
                            ],
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: _getBudgetAdvice,
                            icon: const Icon(Icons.auto_awesome, color: Colors.white),
                            label: const Text('احصل على توصيات الميزانية 💡', style: TextStyle(color: Colors.white)),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ملخص الميزانية الإجمالية
          Card(
            color: AppTheme.surfaceColor,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('إجمالي الميزانية الشهرية', style: TextStyle(color: AppTheme.subTextColor, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${_salaryController.text} ر.س',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                  ),
                ],
              ),
            ),
          ),

          const Text('توزيع المصاريف والالتزامات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textColor)),
          const SizedBox(height: 12),
          ..._budgets.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['title'], style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                      Text(item['amount'], style: TextStyle(color: item['color'], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: item['percentage'],
                    backgroundColor: AppTheme.surfaceColor,
                    color: item['color'],
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFinancialField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppTheme.textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.subTextColor, fontSize: 13),
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true,
        fillColor: AppTheme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
