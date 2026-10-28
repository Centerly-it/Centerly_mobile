import 'package:flutter/material.dart';
import '../../../core/config/preview_mode.dart';
import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/theme/color_manager.dart';
import '../data/update_bootstrap.dart';
import 'update_controller.dart';
import 'update_dialog.dart';

class UpdateGate extends StatefulWidget {
  const UpdateGate({required this.child, this.controller, super.key});
  final Widget child;
  final UpdateController? controller;
  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> with WidgetsBindingObserver {
  UpdateController? _controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _start() async {
    try {
      final controller =
          widget.controller ??
          (PreviewMode.enabled ? null : await createUpdateController());
      if (!mounted) {
        if (widget.controller == null) controller?.dispose();
        return;
      }
      _controller = controller;
      controller?.addListener(_changed);
      await controller?.check();
    } catch (e, stack) {
      AppDiagnostics.current.failure(
        'app.update',
        'UPDATE_CHECK_FAILED',
        stack,
        e,
      );
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller?.resumed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_changed);
    if (widget.controller == null) _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _controller?.visible == true;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: visible,
          child: AbsorbPointer(
            absorbing: visible,
            child: FocusScope(canRequestFocus: !visible, child: widget.child),
          ),
        ),
        if (visible) ...[
          ModalBarrier(
            dismissible: false,
            color: ColorManager.black.withAlpha(120),
          ),
          Center(
            child: SafeArea(
              child: SingleChildScrollView(
                child: UpdateDialog(controller: _controller!),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
