import '../domain/group_record.dart';

class GroupBrowseState {
  const GroupBrowseState({
    this.groups = const [],
    this.search = '',
    this.gradeId,
    this.cursor,
    this.loading = false,
    this.retryMore = false,
    this.error,
  });
  final List<GroupRecord> groups;
  final String search;
  final String? gradeId, cursor, error;
  final bool loading, retryMore;
}
