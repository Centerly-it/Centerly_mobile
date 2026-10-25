import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/workspace_app_bar.dart';
import 'widgets/teacher_bottom_navigation.dart';
import 'workspace_panels.dart';
import 'workspace_selection.dart';

class TeacherWorkspace extends StatefulWidget {
  const TeacherWorkspace({super.key});
  @override
  State<TeacherWorkspace> createState() => _TeacherWorkspaceState();
}

class _TeacherWorkspaceState extends State<TeacherWorkspace> {
  late int _index;
  final _panels = <int, Widget>{};
  @override
  void initState() {
    super.initState();
    _index = WorkspaceSelection.restore();
    _panels[_index] = workspacePanel(_index);
  }

  void _select(int index) {
    setState(() {
      _index = index;
      _panels.putIfAbsent(index, () => workspacePanel(index));
    });
    unawaited(WorkspaceSelection.save(index));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: WorkspaceAppBar(height: WorkspaceAppBar.heightFor(context)),
    body: SafeArea(
      top: false,
      child: IndexedStack(
        index: _index,
        children: List.generate(
          5,
          (i) => TickerMode(
            enabled: i == _index,
            child: _panels[i] ?? const SizedBox.shrink(),
          ),
        ),
      ),
    ),
    bottomNavigationBar: TeacherBottomNavigation(
      index: _index,
      onSelected: _select,
    ),
  );
}
