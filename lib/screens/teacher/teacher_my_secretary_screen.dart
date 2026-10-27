import 'package:flutter/material.dart';
import '../../features/secretaries/presentation/teacher_secretaries_page.dart';

/// Legacy navigation delegates to the authenticated secretary-management flow.
class TeacherMySecretaryScreen extends StatelessWidget {
  const TeacherMySecretaryScreen({super.key});

  @override
  Widget build(BuildContext context) => const TeacherSecretariesPage();
}
