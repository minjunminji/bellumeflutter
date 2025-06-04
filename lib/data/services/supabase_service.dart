import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/measurement_result.dart';
import '../models/facial_metrics_hive.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Authentication
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign In
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available (has proper configuration)
      if (!await _isGoogleSignInAvailable()) {
        throw Exception('Google Sign-In is not configured. Please set up OAuth credentials or use email/password sign-in.');
      }

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Check if Google Sign-In is properly configured
  Future<bool> _isGoogleSignInAvailable() async {
    try {
      // Try to initialize Google Sign-In to check if it's configured
      await _googleSignIn.isSignedIn();
      return true;
    } catch (e) {
      // If it fails, Google Sign-In is not properly configured
      return false;
    }
  }

  // Check if Google Sign-In is available for UI purposes
  Future<bool> isGoogleSignInAvailable() async {
    return await _isGoogleSignInAvailable();
  }

  Future<void> signOut() async {
    try {
      // Sign out from both Supabase and Google
      await _client.auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Auth state stream
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  // Data storage
  Future<void> saveMeasurements(List<MeasurementResult> measurements) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final measurementData = measurements.map((m) => {
        ...m.toJson(),
        'user_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();

      await _client.from('measurements').insert(measurementData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FacialMetrics>> getMeasurementHistory() async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('facial_metrics')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map<FacialMetrics>((data) => FacialMetrics.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Save facial metrics
  Future<void> saveFacialMetrics(FacialMetrics metrics) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final data = {
        ...metrics.toJson(),
        'user_id': user.id,
      };

      await _client.from('facial_metrics').insert(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('profiles')
          .upsert({
            'id': user.id,
            ...profileData,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => getCurrentUser() != null;
} 