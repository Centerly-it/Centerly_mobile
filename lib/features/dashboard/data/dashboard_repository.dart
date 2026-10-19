import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';
import '../domain/dashboard_summary.dart';

class DashboardRepository {
  const DashboardRepository(this.api);
  final TeacherReadClient api;
  Future<DashboardSummary> load({bool refresh = false, String? date}) async {
    // Cairo date defaults on the server; device timezone/clock does not decide it.
    final data = await api.read(
      TeacherRead.dashboard,
      refresh: refresh,
      params: date == null ? null : {'p_date': date},
    );
    try {
      return DashboardSummary.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
