import '../../../core/api/teacher_read_client.dart';
import '../../../core/errors/backend_failure.dart';

class NotificationPayment {
  const NotificationPayment(this.invoiceId, this.actor);
  final String invoiceId;
  final String? actor;
}

class NotificationPaymentRepository {
  const NotificationPaymentRepository(this.api);
  final TeacherReadClient api;
  Future<NotificationPayment> load(String id) async {
    if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(id)) {
      throw const BackendFailure('VALIDATION_ERROR');
    }
    final guard = api.sessionGuard();
    final teacher = api.client.auth.currentUser?.id;
    if (teacher == null) throw const BackendFailure('AUTH_REQUIRED');
    try {
      final payment = await api.client
          .from('payments')
          .select('invoice_id,collected_by')
          .eq('id', id)
          .eq('teacher_id', teacher)
          .maybeSingle()
          .timeout(const Duration(seconds: 20));
      guard();
      if (payment == null) throw const BackendFailure('NOT_FOUND');
      final actor = await api.client
          .from('secretaries')
          .select('name')
          .eq('id', payment['collected_by'])
          .eq('teacher_id', teacher)
          .maybeSingle()
          .timeout(const Duration(seconds: 20));
      guard();
      return NotificationPayment(
        payment['invoice_id'] as String,
        actor?['name'] as String?,
      );
    } on BackendFailure {
      rethrow;
    } catch (_) {
      guard();
      throw const BackendFailure('SERVICE_UNAVAILABLE');
    }
  }
}
