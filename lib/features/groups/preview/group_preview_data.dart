import 'package:easy_localization/easy_localization.dart';

class GroupPreviewData {
  GroupPreviewData({
    required this.id,
    required this.grade,
    required this.letter,
    required this.students,
    required this.hour,
    required this.weekdays,
  });
  final int id, grade, students, hour;
  final String letter;
  final List<int> weekdays;
  final List<GroupPreviewNote> notes = [];
  String get name => 'group_design_name'.tr(args: [letter.tr()]);
  String get gradeName => 'group_design_grade_$grade'.tr();
  String get studentName => 'group_design_student'.tr();
  String get days => weekdays
      .map(
        (d) =>
            'day_${['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][d]}'
                .tr(),
      )
      .join(' - ');
  static List<GroupPreviewData> fixtures() => [
    GroupPreviewData(
      id: 1,
      grade: 1,
      letter: 'group_design_a',
      students: 44,
      hour: 9,
      weekdays: [4, 2],
    ),
    GroupPreviewData(
      id: 2,
      grade: 1,
      letter: 'group_design_b',
      students: 25,
      hour: 13,
      weekdays: [6, 3],
    ),
    GroupPreviewData(
      id: 3,
      grade: 2,
      letter: 'group_design_a',
      students: 44,
      hour: 17,
      weekdays: [4, 2],
    ),
  ];
}

class GroupPreviewNote {
  const GroupPreviewNote(this.text, this.createdAt);
  final String text;
  final DateTime createdAt;
}
