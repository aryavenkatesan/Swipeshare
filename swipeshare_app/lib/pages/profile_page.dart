import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/profile/profile_page_actions.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text("Profile", style: textTheme.displayLarge),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 20),

            // --- Settings Section ---
            Text("Settings", style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  label: "Notifications",
                  onTap: () =>
                      ProfilePageActions.navigateToNotifications(context),
                ),
                _SettingsTile(
                  icon: Icons.password_rounded,
                  label: "Change Password",
                  onTap: () =>
                      ProfilePageActions.navigateToChangePassword(context),
                ),
                _SettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Update Payment Options",
                  onTap: () =>
                      ProfilePageActions.navigateToUpdatePayment(context),
                ),
                _SettingsTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: "Share Feedback",
                  onTap: () => ProfilePageActions.navigateToFeedback(context),
                  showDivider: false,
                ),
              ],
            ),

             const SizedBox(height: 28),

            // --- Replay Tutorial Section ---
            Text("Replay Tutorial", style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                _SettingsTile(
                  icon: Icons.play_arrow_outlined,
                  label: "Swipeology 101",
                  onTap: () => ProfilePageActions.navigateToTutorial(context),
                  showDivider: false,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // --- Danger Zone Section ---
            Text("Danger Zone", style: textTheme.titleMedium),
            const SizedBox(height: 12),
            _SectionCard(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: "Sign Out",
                  onTap: () => ProfilePageActions.signOut(context),
                ),
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  label: "Delete Account",
                  onTap: () =>
                      ProfilePageActions.navigateToDeleteAccount(context),
                  showDivider: false,
                ),
              ],
            ),


            const SizedBox(height: 32),

            // --- Legal Links ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => ProfilePageActions.launchPrivacyPolicy(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    textStyle: const TextStyle(fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Privacy Policy"),
                ),
                const Text(
                  "·",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => ProfilePageActions.launchTermsOfService(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    textStyle: const TextStyle(fontSize: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Terms & Conditions"),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- Footer ---
            const Center(
              child: Text(
                "Swipeshare 2026",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- Rounded bordered card that wraps a section ---
class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD0D0D0), width: 1.2),
      ),
      child: Column(children: children),
    );
  }
}

// --- Individual clickable row inside a section card ---
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          highlightColor: const Color(0xFF4F6FE8).withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: const Color(0xFF5C4DB7)),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
