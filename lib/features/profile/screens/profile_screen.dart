import 'package:flutter/material.dart';

import '../../../core/state/app_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/initials_avatar.dart';
import '../../auth/login_screen.dart';
import '../../catalog/data/mock_catalog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final profile = MockCatalog.customer;
    final signedIn = app.signedIn;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPadding,
          8,
          AppDimensions.screenPadding,
          28,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppDecorations.brand,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
            child: Row(
              children: [
                InitialsAvatar(
                  initials: profile.initials,
                  colors: const [Color(0xFF6D28D9), Color(0xFFFF6F61)],
                  size: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signedIn?.fullName ?? profile.fullName,
                        style: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        signedIn == null ? profile.city : signedIn.username,
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Contact',
            children: [
              _InfoRow(icon: Icons.mail_outline_rounded, label: profile.email),
              _InfoRow(icon: Icons.phone_outlined, label: profile.phone),
              _InfoRow(icon: Icons.place_outlined, label: profile.city),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Account',
            children: [
              _ActionTile(
                key: const Key('profile-edit'),
                icon: Icons.person_outline_rounded,
                title: 'Edit profile',
                onTap: () => _unavailable(
                  context,
                  'Profile changes are not part of this preview.',
                ),
              ),
              _ActionTile(
                key: const Key('profile-payments'),
                icon: Icons.credit_card_rounded,
                title: 'Payment methods',
                onTap: () => _unavailable(
                  context,
                  'Payment methods are not part of this preview.',
                ),
              ),
              _ActionTile(
                key: const Key('profile-addresses'),
                icon: Icons.bookmark_outline_rounded,
                title: 'Saved places',
                onTap: () => _unavailable(
                  context,
                  'Saved places are not part of this preview.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Preferences',
            children: [
              SwitchListTile(
                key: const Key('notifications-preview'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                secondary: const Icon(Icons.notifications_none_rounded),
                title: const Text('Appointment reminders'),
                subtitle: const Text(
                  'Preview only. This is not saved after you close the app.',
                ),
                value: app.notificationsPreview,
                onChanged: app.setNotificationsPreview,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'About this preview',
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Text(
                  'Sign in with the customer account from the salon. Payments and live calendars stay on the preview.',
                  style: AppTextStyles.body,
                ),
              ),
              _ActionTile(
                key: Key(signedIn == null ? 'profile-sign-in' : 'profile-sign-out'),
                icon: signedIn == null ? Icons.login_rounded : Icons.logout_rounded,
                title: signedIn == null ? 'Sign in' : 'Sign out',
                onTap: () {
                  if (signedIn == null) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                    );
                    return;
                  }
                  app.signOut();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _unavailable(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Not available yet'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: AppDecorations.surface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(title, style: AppTextStyles.cardTitle),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: AppColors.heading),
      title: Text(title, style: AppTextStyles.body.copyWith(color: AppColors.heading)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.subtitle),
      onTap: onTap,
    );
  }
}
