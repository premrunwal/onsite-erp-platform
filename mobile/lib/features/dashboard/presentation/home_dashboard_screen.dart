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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Materials'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Approvals'),
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metro Tower Site 04'),
            Text('Apex Infra Construction Ltd', style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Punch CTA Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.primaryOrangeDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Self Punch Attendance',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI Liveness + Geofence Verified',
                          style: TextStyle(color: Color(0xDEFFFFFF), fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PunchAttendanceScreen()),
                            );
                          },
                          icon: const Icon(Icons.camera_front, color: AppTheme.primaryOrange),
                          label: const Text('PUNCH IN WITH FACE', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.face_retouching_natural_rounded, size: 72, color: Colors.white24),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's Stats Cards
            const Text('Daily Site Snapshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('36 / 40', 'Workers Present', Icons.groups, AppTheme.statusSuccess),
                const SizedBox(width: 12),
                _buildStatCard('₹45,000', 'Pending Approvals', Icons.account_balance_wallet, AppTheme.statusWarning),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions Grid
            const Text('Quick ERP Modules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildModuleTile(
                  context,
                  icon: Icons.assignment_outlined,
                  label: 'Add DPR',
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DPREntryScreen())),
                ),
                _buildModuleTile(
                  context,
                  icon: Icons.people_outline,
                  label: 'Squad Punch',
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForemanBulkPunchScreen())),
                ),
                _buildModuleTile(
                  context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Material Stock',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialsDashboardScreen())),
                ),
                _buildModuleTile(
                  context,
                  icon: Icons.payments_outlined,
                  label: 'Approvals',
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalsScreen())),
                ),
                _buildModuleTile(
                  context,
                  icon: Icons.chat_outlined,
                  label: 'Site Chat',
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectChatScreen())),
                ),
                _buildModuleTile(
                  context,
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Export DPR',
                  color: Colors.red,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DPREntryScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              radius: 20,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
