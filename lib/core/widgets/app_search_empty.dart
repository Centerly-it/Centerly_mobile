import 'package:flutter/material.dart';
import '../theme/style_manager.dart';
import '../theme/values_manager.dart';

/// Shared search illustration and geometry for student-related empty results.
class AppSearchEmpty extends StatelessWidget {
  const AppSearchEmpty({required this.title, super.key});
  final String title;
  static const imagePath = 'assets/figma/sessions/9578e.png';
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AspectRatio(
        aspectRatio: 290 / 216,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
      const SizedBox(height: AppSize.s16),
      Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium,
      ),
    ],
  );
}
