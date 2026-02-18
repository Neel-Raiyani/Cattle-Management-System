import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/milk_distribution/presentation/screens/distribution_title_screen.dart';
import '../../features/user_management/presentation/screens/user_list_screen.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          _buildHeader(context),

          // Account Section
          _buildSectionTitle('Account'),
          _buildDrawerItem(
            context,
            Icons.home_rounded,
            'Home',
            () => Navigator.pop(context),
          ),
          _buildDrawerItem(context, Icons.lock_rounded, 'Change Password', () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          }),
          _buildDrawerItem(
            context,
            Icons.translate_rounded,
            'Change Language',
            () {
              // TODO: Navigate to Language Selection
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            Icons.privacy_tip_rounded,
            'Privacy Policy',
            () {},
          ),
          _buildDrawerItem(context, Icons.share_rounded, 'Share App', () {}),
          _buildDrawerItem(
            context,
            Icons.power_settings_new_rounded,
            'Logout',
            () async {
              await sl<AuthLocalDataSource>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),

          const Divider(height: 32, thickness: 0.5),

          // Settings Section
          _buildSectionTitle('Settings'),
          _buildDrawerItem(context, Icons.person_rounded, 'User', () {
            Navigator.pop(context); // Close drawer
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserListScreen()),
            );
          }),
          _buildDrawerItem(context, Icons.groups_rounded, 'Cow Group', () {}),
          _buildDrawerItem(
            context,
            Icons.smart_toy_rounded,
            'AI Bull',
            () {},
          ), // Using smart_toy as proxy for AI/Tech icon
          _buildDrawerItem(
            context,
            Icons.pets_rounded,
            'Animal Left From Gaushala',
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.local_shipping_rounded,
            'Distribution Title',
            () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DistributionTitleScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(context, Icons.post_add_rounded, 'My Post', () {}),

          const Divider(height: 32, thickness: 0.5),

          // About Us Section
          _buildSectionTitle('About Us'),
          _buildDrawerItem(
            context,
            Icons.info_outline_rounded,
            'About Developers',
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.business_rounded,
            'About Gaushala',
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.help_outline_rounded,
            'Guidance',
            () {},
          ),
          _buildDrawerItem(context, Icons.feedback_rounded, 'Feedback', () {}),
          _buildDrawerItem(
            context,
            Icons.support_agent_rounded,
            'Contact Us',
            () {},
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: sl<AuthLocalDataSource>().getCurrentUserData(),
      builder: (context, snapshot) {
        final name = snapshot.data?['name'] ?? 'Loading...';
        final mobile = snapshot.data?['mobile'] ?? '';

        return Container(
          padding: const EdgeInsets.only(
            top: 60,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/cowlogo_splash.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Smart Gaushala',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mobile,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage(
                          'assets/images/user_avatar_placeholder.png',
                        ), // Placeholder
                        backgroundColor: Colors.grey,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1), // Icon background
          shape: BoxShape.circle,
        ), // Or just ensure app theme green
        child: Icon(
          icon,
          color: const Color(0xFF7CB342),
          size: 18,
        ), // Olive Green
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
    );
  }
}
