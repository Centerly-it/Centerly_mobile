/// In-memory preview actions; never forwards requests to a server.
dynamic previewMutation(
  String rpc,
  Map<String, dynamic> p,
  Map<String, dynamic> data,
  String now,
) {
  switch (rpc) {
    case 'save_teacher_note':
      data['note'] = {
        'note': {'content': p['p_content'], 'updated_at': now},
        'synced_at': now,
      };
      return null;
    case 'mark_notification_read':
      for (final row in data['notifications']['rows']) {
        if (row['id'] == p['p_id']) row['read_at'] = now;
      }
      data['notifications']['unread_count'] =
          (data['notifications']['rows'] as List)
              .where((r) => r['read_at'] == null)
              .length;
      return null;
    case 'request_secretary_removal':
      for (final row in data['secretaries']['rows']) {
        if (row['id'] == p['p_secretary_id']) {
          row['removal_request'] = {
            'id': '70000000-0000-0000-0000-000000000001',
            'status': 'pending',
            'requested_at': now,
            'handled_at': null,
          };
        }
      }
      return null;
    default:
      throw StateError('Unsupported local preview operation: $rpc');
  }
}
