import 'package:flutter/material.dart';
import '../theme/values_manager.dart';

/// Explicit keyboard search avoids issuing an RPC for every keystroke.
class ServerSearchField extends StatelessWidget {
  const ServerSearchField({
    required this.label,
    required this.onSubmitted,
    this.maxLength = 200,
    this.showLabel = true,
    super.key,
  });
  final String label;
  final bool showLabel;
  final int maxLength;
  final ValueChanged<String> onSubmitted;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppPadding.p16),
    child: Semantics(
      label: showLabel ? null : label,
      child: TextField(
        maxLength: maxLength,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: showLabel ? label : null,
          prefixIcon: const Icon(Icons.search),
        ),
        onSubmitted: onSubmitted,
      ),
    ),
  );
}
