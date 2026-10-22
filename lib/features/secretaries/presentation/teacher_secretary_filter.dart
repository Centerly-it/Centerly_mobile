import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/teacher_read_client.dart';
import '../../../core/data/completion_reads.dart';
import '../../../core/data/read_page.dart';
import '../../../core/di/di.dart';
import '../../../core/presentation/paged_read_cubit.dart';
import '../../../core/widgets/paged_read_body.dart';
import '../domain/secretary_record.dart';

class TeacherSecretaryFilter extends StatefulWidget {
  const TeacherSecretaryFilter({
    required this.onChanged,
    this.initialLabel,
    super.key,
  });
  final ValueChanged<String?> onChanged;
  final String? initialLabel;
  @override
  State<TeacherSecretaryFilter> createState() => _TeacherSecretaryFilterState();
}

class _TeacherSecretaryFilterState extends State<TeacherSecretaryFilter> {
  late String? label = widget.initialLabel;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.person_outline),
    label: Text(label ?? 'completion_all_collectors'.tr()),
    onPressed: () async {
      final result = await showDialog<({SecretaryRecord? secretary})>(
        context: context,
        builder: (_) => BlocProvider(
          create: (_) => PagedReadCubit<SecretaryRecord, NoSummary>(
            (_, cursor) => CompletionReads(getIt<TeacherReadClient>()).page(
              TeacherRead.secretaries,
              params: {'p_cursor': cursor, 'p_limit': 30},
              row: SecretaryRecord.fromJson,
              summary: (_) => const NoSummary(),
            ),
            (r) => r.id,
          )..refresh(),
          child: Dialog(
            child: SafeArea(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, (secretary: null)),
                    child: Text('completion_all_collectors'.tr()),
                  ),
                  Expanded(
                    child: PagedReadBody<SecretaryRecord, NoSummary>(
                      item: (context, r) => ListTile(
                        title: Text(r.name),
                        onTap: () => Navigator.pop(context, (secretary: r)),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel_back'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (result != null && mounted) {
        setState(() => label = result.secretary?.name);
        widget.onChanged(result.secretary?.id);
      }
    },
  );
}
