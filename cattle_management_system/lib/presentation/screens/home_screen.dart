import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/localized_ui.dart';
import '../widgets/side_menu_drawer.dart';
import '../../features/dashboard/presentation/widgets/gaushala_tab.dart';
import '../../features/gaugram/presentation/widgets/gaugram_tab.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Gaushala, 1: GauGram
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final result = await sl<AuthRepository>().getUserName();
    result.fold((failure) => null, (name) {
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5), // Light Grey bg
      drawer: const SideMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            _buildToggle(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  GaushalaTab(),
                  GauGramTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Drawer Icon
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sort,
                color: Colors.black87,
              ), // Hamburger-ish
            ),
          ),
          const SizedBox(width: 12),

          // Welcome Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.ui.welcomeBack,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              Text(
                _userName, // Dynamic
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Actions
          _buildActionIcon(Icons.search),
          const SizedBox(width: 8),
          _buildActionIcon(Icons.qr_code_scanner), // QR/Grid icon
          const SizedBox(width: 8),
          _buildActionIcon(
            Icons.notifications_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFA4C639),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? const Color(0xFFA4C639)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  context.ui.gaushala,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? const Color(0xFFA4C639)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  context.ui.gauGram,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
