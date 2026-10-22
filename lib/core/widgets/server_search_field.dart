import 'package:flutter/material.dart';
import '../theme/values_manager.dart';

/// Explicit keyboard search avoids issuing an RPC for every keystroke.
class ServerSearchField extends StatelessWidget {
  const ServerSearchField({
    required this.label,
    required this.onSubmitted,
    this.maxLength = 200,
    super.key,
  });
  final String label;
  final int maxLength;
  final ValueChanged<String> onSubmitted;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppPadding.p16),
    child: TextField(
      maxLength: maxLength,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.search),
      ),
      onSubmitted: onSubmitted,
    ),
  );
}
