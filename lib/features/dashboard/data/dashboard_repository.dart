import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  const DashboardRepository(this.client);
  final SupabaseClient client;
  Future<Map<String, dynamic>> load() async {
    // Cairo date defaults on the server; device timezone/clock does not decide it.
    final data = await client
        .rpc('get_teacher_dashboard')
        .timeout(const Duration(seconds: 15));
    return Map<String, dynamic>.from(data as Map);
  }
}
