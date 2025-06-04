import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_decorations.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add top padding for status bar
            SizedBox(height: MediaQuery.of(context).padding.top + 8),
            
            // Profile title - now aligned with body content
            Text(
              'Profile',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Profile Header
            Container(
              padding: AppSpacing.cardPadding,
              decoration: AppDecorations.cardDecoration,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user?.email?.split('@')[0] ?? 'User',
                    style: AppTextStyles.heading2,
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Account Section
            _buildSection(
              title: 'Account',
              items: [
                _buildListItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: user?.email ?? 'Not available',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your account security',
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // App Settings Section
            _buildSection(
              title: 'App Settings',
              items: [
                _buildListItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Customize your notification preferences',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Sign Out Button
            Container(
              padding: AppSpacing.cardPadding,
              decoration: AppDecorations.cardDecoration,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'Sign Out',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      final confirmed = await _showSignOutDialog(context);
                      if (confirmed == true) {
                        final authController = ref.read(authControllerProvider);
                        await authController.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // App Version
            Text(
              'Bellume v1.0.0',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.body,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
} 