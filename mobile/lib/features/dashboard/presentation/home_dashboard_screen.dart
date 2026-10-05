import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../attendance/presentation/punch_attendance_screen.dart';
import '../../attendance/presentation/foreman_bulk_punch_screen.dart';
import '../../dpr/presentation/dpr_entry_screen.dart';
import '../../materials/presentation/materials_dashboard_screen.dart';
import '../../financials/presentation/approvals_screen.dart';
import '../../chat/presentation/project_chat_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentTab = 0;

  final List<Widget> _pages = [
    const _HomeMainTab(),
    const ForemanBulkPunchScreen(),
    const MaterialsDashboardScreen(),
    const ProjectChatScreen(),
    const ApprovalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: const Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded, color: AppTheme.primaryOrange),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge_rounded, color: AppTheme.primaryOrange),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryOrange),
            label: 'Materials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryOrange),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryOrange),
            label: 'Approvals',
          ),
        ],
      ),
    );
  }
}

class _HomeMainTab extends StatelessWidget {
  const _HomeMainTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.slateNavyDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Metro Tower Site 04', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Apex Infra Construction Ltd', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scanning Desktop Web QR Login...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exact Onsite Hero Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.primaryOrangeDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('AI BIOMETRIC VERIFIED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Punch Attendance Now',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Face Liveness + GPS Geofence threshold',
                        style: TextStyle(color: Color(0xDEFFFFFF), fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PunchAttendanceScreen()),
                          );
                        },
                        icon: const Icon(Icons.camera_front_rounded, color: AppTheme.primaryOrange),
                        label: const Text(
                          'PUNCH IN WITH FACE',
                          style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                  const Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(Icons.face_retouching_natural_rounded, size: 90, color: Colors.white24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Snapshot Stats
            const Text('Daily Site Snapshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slateNavyDark)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildOnsiteStatCard('36 / 40', 'Workers Present', Icons.groups_rounded, AppTheme.statusSuccess),
                const SizedBox(width: 12),
                _buildOnsiteStatCard('₹45,000', 'Pending Approvals', Icons.account_balance_wallet_rounded, AppTheme.statusWarning),
              ],
            ),
            const SizedBox(height: 24),

            // Onsite Feature Modules Grid (Matching Onsite 14.9.8 Layout)
            const Text('Onsite ERP Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.slateNavyDark)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildOnsiteTile(
                  context,
                  icon: Icons.assignment_rounded,
                  label: 'Add DPR',
                  color: const Color(0xFF2563EB),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DPREntryScreen())),
                ),
                _buildOnsiteTile(
                  context,
                  icon: Icons.people_alt_rounded,
                  label: 'Squad Punch',
                  color: const Color(0xFF9333EA),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForemanBulkPunchScreen())),
                ),
                _buildOnsiteTile(
                  context,
                  icon: Icons.inventory_2_rounded,
                  label: 'Material Stock',
                  color: AppTheme.primaryOrange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialsDashboardScreen())),
                ),
                _buildOnsiteTile(
                  context,
                  icon: Icons.payments_rounded,
                  label: 'Approvals',
                  color: const Color(0xFF16A34A),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsScreen())),
                ),
                _buildOnsiteTile(
                  context,
                  icon: Icons.chat_rounded,
                  label: 'Site Channels',
                  color: const Color(0xFF0D9488),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectChatScreen())),
                ),
                _buildOnsiteTile(
                  context,
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Export DPR',
                  color: const Color(0xFFDC2626),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DPREntryScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnsiteStatCard(String title, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              radius: 20,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.slateNavyDark)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnsiteTile(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              radius: 22,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.slateNavyDark)),
          ],
        ),
      ),
    );
  }
}
