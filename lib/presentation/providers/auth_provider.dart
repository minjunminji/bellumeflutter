import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_service.dart';

// Service provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.authStateChanges.map((state) => state.session?.user);
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth controller
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;
  
  AuthController(this._ref);
  
  SupabaseService get _supabaseService => _ref.read(supabaseServiceProvider);

  Future<void> signIn(String email, String password) async {
    try {
      await _supabaseService.signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _supabaseService.signUp(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _supabaseService.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _supabaseService.isGoogleSignInAvailable();
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  bool get isAuthenticated => _supabaseService.isAuthenticated;
} 