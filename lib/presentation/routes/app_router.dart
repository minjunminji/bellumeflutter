import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/main/dashboard_screen.dart';
import '../screens/main/chat_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/scan/camera_capture_screen.dart';
import '../screens/scan/front_capture_screen.dart';
import '../screens/scan/right_profile_capture_screen.dart';
import '../screens/scan/left_profile_capture_screen.dart';
import '../screens/scan/photo_approval_screen.dart';
import '../screens/scan/processing_screen.dart';
import '../screens/scan/results_intro_screen.dart';
import '../screens/scan/measurement_detail_screen.dart';
import '../screens/scan/results_summary_screen.dart';
import '../screens/scan/improvement_plan_screen.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      // If not authenticated and not on auth screens, redirect to login
      if (!isAuthenticated && 
          !state.matchedLocation.startsWith('/login') && 
          !state.matchedLocation.startsWith('/register')) {
        return '/login';
      }

      // If authenticated and on auth screens, redirect to dashboard
      if (isAuthenticated && 
          (state.matchedLocation.startsWith('/login') || 
           state.matchedLocation.startsWith('/register'))) {
        return '/main';
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Route (with internal tab navigation)
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      
      // Legacy routes for backward compatibility
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) => '/main',
      ),
      GoRoute(
        path: '/chat',
        redirect: (context, state) => '/main',
      ),
      GoRoute(
        path: '/profile',
        redirect: (context, state) => '/main',
      ),

      // Scan Flow Routes (Modal)
      GoRoute(
        path: '/scan',
        builder: (context, state) => const CameraCaptureScreen(),
        routes: [
          GoRoute(
            path: 'front',
            builder: (context, state) => const FrontCaptureScreen(),
          ),
          GoRoute(
            path: 'right',
            builder: (context, state) => const RightProfileCaptureScreen(),
          ),
          GoRoute(
            path: 'left',
            builder: (context, state) => const LeftProfileCaptureScreen(),
          ),
          GoRoute(
            path: 'approval',
            builder: (context, state) => const PhotoApprovalScreen(),
          ),
          GoRoute(
            path: 'processing',
            builder: (context, state) => const ProcessingScreen(),
          ),
          GoRoute(
            path: 'results-intro',
            builder: (context, state) => const ResultsIntroScreen(),
          ),
          GoRoute(
            path: 'measurement-detail',
            builder: (context, state) => const MeasurementDetailScreen(),
          ),
          GoRoute(
            path: 'results-summary',
            builder: (context, state) => const ResultsSummaryScreen(),
          ),
          GoRoute(
            path: 'improvement-plan',
            builder: (context, state) => const ImprovementPlanScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}); 