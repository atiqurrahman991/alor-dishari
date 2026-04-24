import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart'; // To access global `supabase` client.

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _checkCurrentUser();
    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = AsyncValue.data(session?.user);
    });
  }

  void _checkCurrentUser() {
    final session = supabase.auth.currentSession;
    state = AsyncValue.data(session?.user);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      // State updated by listener
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred.', st);
      rethrow;
    }
  }

  Future<void> signUp({
    required String name,
    required String mobile,
    required String nid,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      final user = response.user;
      
      if (user != null) {
        // Create the member profile
        await supabase.from('members').insert({
          'auth_id': user.id,
          'name': name,
          'mobile': mobile,
          'nid': nid,
          'category': 'General', // Default category
          'role': 'member',
          'status': 'pending'  // New users are pending by default
        });
      }
    } on AuthException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    // We don't set state to loading here to not block the whole screen
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
