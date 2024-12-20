import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabse = Supabase.instance.client;

  Future<AuthResponse> signWithEmailAndPassword(
      String email, String password) async {
    return await _supabse.auth
        .signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmailAndPassword(
      String email, String password) async {
    return await _supabse.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    return _supabse.auth.signOut();
  }

  String? getCurrentUserEmail() {
    final session = _supabse.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
