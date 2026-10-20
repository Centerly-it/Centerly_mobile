import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/teacher_profile.dart';
import '../auth_failure_mapper.dart';
import '../../domain/repo/teacher_auth_repository.dart';

class SupabaseTeacherAuth implements TeacherAuthRepository {
  SupabaseTeacherAuth(this.client, this.clearStorage);
  final SupabaseClient client;
  final Future<void> Function() clearStorage;
  bool _blocked = false;
  int _attempt = 0;
  @override
  Stream<void> get changes =>
      client.auth.onAuthStateChange.asyncMap((event) async {
        if (_blocked && event.session != null) {
          await logout();
        }
      });
  Future<TeacherProfile> _profile({bool retryToken = true}) async {
    final session = client.auth.currentSession;
    if (session == null) throw const TeacherAuthFailure('AUTH_REQUIRED');
    final attempt = _attempt;
    if (session.isExpired) {
      await client.auth.refreshSession().timeout(const Duration(seconds: 15));
    }
    final active = client.auth.currentSession;
    if (active == null || _blocked || attempt != _attempt) {
      throw const TeacherAuthFailure('AUTH_REQUIRED');
    }
    final token = active.accessToken;
    final data = await client
        .rpc('get_current_profile')
        .timeout(const Duration(seconds: 15));
    if (_blocked ||
        attempt != _attempt ||
        client.auth.currentUser?.id != active.user.id) {
      throw const TeacherAuthFailure('AUTH_REQUIRED');
    }
    if (client.auth.currentSession?.accessToken != token) {
      if (retryToken) return _profile(retryToken: false);
      throw const TeacherAuthFailure('AUTH_REQUIRED');
    }
    return TeacherProfile.fromJson(
      Map<String, dynamic>.from(data as Map),
      active.user.id,
    );
  }

  @override
  Future<TeacherProfile?> restore() async {
    if (_blocked || client.auth.currentSession == null) return null;
    try {
      return await _profile();
    } catch (error) {
      throw mapAuthFailure(error);
    }
  }

  @override
  Future<TeacherProfile> login(String email, String password) async {
    _blocked = false;
    final attempt = ++_attempt;
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (_blocked || attempt != _attempt) {
        throw const TeacherAuthFailure('AUTH_REQUIRED');
      }
      return await _profile();
    } catch (error) {
      await logout();
      throw mapAuthFailure(error);
    }
  }

  @override
  Future<void> logout() async {
    _blocked = true;
    ++_attempt;
    try {
      await client.auth
          .signOut(scope: SignOutScope.local)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      /* Local SDK session is removed before the network request. */
    } finally {
      await clearStorage();
    }
  }
}
