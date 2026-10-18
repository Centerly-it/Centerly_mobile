import 'package:centrally/core/constants/strings_manager.dart';
import 'package:centrally/core/theme/color_manager.dart';
import 'package:centrally/core/theme/style_manager.dart';
import 'package:centrally/core/theme/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// QR code display widget — renders a visual QR pattern using CustomPaint.
/// No external qr_flutter dependency needed.
///
/// Shows:
/// - A QR code canvas (deterministic pixel grid based on the value string)
/// - A student ID badge below
/// - A hint label
class AppQrWidget extends StatelessWidget {
  const AppQrWidget({
    required this.value,
    super.key,
    this.size = AppSize.s120,
    this.showIdBadge = true,
    this.hint,
  });

  final String value;
  final double size;
  final bool showIdBadge;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hint != null) ...[
          Text(
            hint!,
            style: AppTextStyles.labelSmall.copyWith(
              color: ColorManager.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSize.s8),
        ],
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(AppPadding.p8),
          decoration: BoxDecoration(
            color: ColorManager.white,
            border: Border.all(color: ColorManager.divider),
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: CustomPaint(painter: _QrPainter(value: value)),
        ),
        if (showIdBadge) ...[
          const SizedBox(height: AppSize.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p16,
              vertical: AppPadding.p8,
            ),
            decoration: BoxDecoration(
              color: ColorManager.grey200,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Text(
              StringsManager.profileQrId.tr(namedArgs: {'id': value}),
              style: AppTextStyles.labelSmall,
            ),
          ),
        ],
      ],
    );
  }
}

/// Deterministic QR-like pixel grid painter.
/// Generates a consistent visual pattern from the [value] string hash.
class _QrPainter extends CustomPainter {
  _QrPainter({required this.value});

  final String value;

  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 11;
    final cellSize = size.width / gridSize;
    final paint = Paint()..color = ColorManager.textPrimary;
    final bgPaint = Paint()..color = ColorManager.white;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Deterministic cell fill from string hash
    final code = value.codeUnits.fold<int>(0, (acc, c) => acc ^ (c * 17 + acc));
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (_isFinder(row, col, gridSize) || _isCell(row, col, code)) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize + 1,
              row * cellSize + 1,
              cellSize - 1,
              cellSize - 1,
            ),
            paint,
          );
        }
      }
    }
  }

  bool _isFinder(int row, int col, int size) {
    // Top-left, top-right, bottom-left finder squares (simplified)
    final tl = row < 3 && col < 3;
    final tr = row < 3 && col >= size - 3;
    final bl = row >= size - 3 && col < 3;
    return tl || tr || bl;
  }

  bool _isCell(int row, int col, int seed) {
    final idx = row * 11 + col;
    final hash = (seed ^ (idx * 31 + row * 7 + col * 13)) & 0xFF;
    return hash > 128;
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.value != value;
}
