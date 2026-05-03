import 'package:centrally/features/auth/presentation/widgets/step_circle_indicator.dart';
import 'package:flutter/material.dart';
import 'package:centrally/core/res/color_manager.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    for (int index = 0; index < totalSteps; index++) {
      final stepNumber = index + 1;
      final isCompleted = stepNumber < currentStep;
      final isActive = stepNumber == currentStep;

      children.add(
        StepCircleIndicator(
          number: stepNumber,
          isCompleted: isCompleted,
          isActive: isActive,
        ),
      );

      if (index < totalSteps - 1) {
        children.add(
          Expanded(
            child: SizedBox(
              height: 2,
              child: ColoredBox(
                color: isCompleted
                    ? ColorManager.primary
                    : ColorManager.primary.withOpacity(0.2),
              ),
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
