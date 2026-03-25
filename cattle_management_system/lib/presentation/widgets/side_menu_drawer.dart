import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/milk_distribution/presentation/screens/distribution_title_screen.dart';
import '../../features/user_management/presentation/screens/user_list_screen.dart';
import '../../features/about_us/presentation/screens/about_developer_screen.dart';
import '../../features/about_us/presentation/screens/about_gaushala_screen.dart';
import '../../features/about_us/presentation/screens/guidance_screen.dart';
import '../../features/about_us/presentation/screens/feedback_screen.dart';
import '../../features/about_us/presentation/screens/contact_us_screen.dart';
import '../../features/settings/presentation/screens/change_language_screen.dart';
import '../../features/cattle/presentation/screens/ai_bull_list_screen.dart';
import '../../features/animal_left/presentation/screens/animal_left_summary_screen.dart';
import '../../features/milk_production/presentation/screens/feed_inventory_screen.dart';
import '../../features/cow_group/presentation/screens/cow_group_screen.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenuDrawer extends StatefulWidget {
  const SideMenuDrawer({super.key});

  @override
  State<SideMenuDrawer> createState() => _SideMenuDrawerState();
}

class _SideMenuDrawerState extends State<SideMenuDrawer> {
  late final Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = sl<AuthRemoteDataSource>().getProfile();
  }

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
          _buildSectionTitle(AppLocalizations.of(context)!.sectionAccount),
          _buildDrawerItem(
            context,
            Icons.home_rounded,
            AppLocalizations.of(context)!.menuHome,
            () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            context,
            Icons.lock_rounded,
            AppLocalizations.of(context)!.menuChangePassword,
            () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.translate_rounded,
            AppLocalizations.of(context)!.menuChangeLanguage,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangeLanguageScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.privacy_tip_rounded,
            AppLocalizations.of(context)!.menuPrivacyPolicy,
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.share_rounded,
            AppLocalizations.of(context)!.menuShareApp,
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.power_settings_new_rounded,
            AppLocalizations.of(context)!.menuLogout,
            () async {
              // Close drawer first
              Navigator.pop(context);

              // Use Repository logout to clear ALL tokens (auth_token, gaushala_id, user_name, etc.)
              // This fixes the issue where the app still thinks it is logged in on the first try.
              await sl<AuthRepository>().logout();

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
          _buildSectionTitle(AppLocalizations.of(context)!.sectionSettings),
          _buildDrawerItem(
            context,
            Icons.person_rounded,
            AppLocalizations.of(context)!.menuUser,
            () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.groups_rounded,
            AppLocalizations.of(context)!.menuCowGroup,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CowGroupScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.smart_toy_rounded,
            AppLocalizations.of(context)!.menuAIBull,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiBullListScreen()),
              );
            },
          ), // Using smart_toy as proxy for AI/Tech icon
          _buildDrawerItem(
            context,
            Icons.pets_rounded,
            AppLocalizations.of(context)!.menuAnimalLeft,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnimalLeftSummaryScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.local_shipping_rounded,
            AppLocalizations.of(context)!.menuDistribution,
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
          _buildDrawerItem(
            context,
            Icons.post_add_rounded,
            AppLocalizations.of(context)!.menuMyPost,
            () {},
          ),
          _buildDrawerItem(
            context,
            Icons.inventory_2_rounded,
            'Feed Inventory',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedInventoryScreen()),
              );
            },
          ),

          const Divider(height: 32, thickness: 0.5),

          // About Us Section
          _buildSectionTitle(AppLocalizations.of(context)!.sectionAboutUs),
          _buildDrawerItem(
            context,
            Icons.info_outline_rounded,
            AppLocalizations.of(context)!.menuAboutDevelopers,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutDeveloperScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.business_rounded,
            AppLocalizations.of(context)!.menuAboutGaushala,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutGaushalaScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.help_outline_rounded,
            AppLocalizations.of(context)!.menuGuidance,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuidanceScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.feedback_rounded,
            AppLocalizations.of(context)!.menuFeedback,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.support_agent_rounded,
            AppLocalizations.of(context)!.menuContactUs,
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // Try to get cached name if API is still loading
        final String cachedName = sl<SharedPreferences>().getString('user_name') ?? 'Smart User';
        final name = snapshot.data?['name'] ?? (snapshot.connectionState == ConnectionState.waiting ? cachedName : 'Smart User');
        final mobile = snapshot.data?['mobileNumber'] ?? snapshot.data?['mobile'] ?? '';
        final profileImageUrl = snapshot.data?['profileImage'] ?? snapshot.data?['photo'];

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
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, color: AppTheme.primaryColor),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (mobile.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            mobile,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl) as ImageProvider
                        : null,
                    backgroundColor: const Color(0xFFF5F6F7),
                    child: (profileImageUrl == null || profileImageUrl.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
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
