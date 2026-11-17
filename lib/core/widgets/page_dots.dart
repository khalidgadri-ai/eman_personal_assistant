import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// نقاط الصفحات في الشاشات المتتالية (الترحيب والجولة). الصفحة الحالية نقطة عريضة.
/// زخرفة فقط: رقم الصفحة يُكتب نصًا ظاهرًا عند الحاجة ليقرأه قارئ الشاشة.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.page, required this.count});

  final int page;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == page ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == page ? AppTheme.accentColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
