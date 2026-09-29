import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/bottom_nav_bar.dart';
import 'profile_screen.dart';
import 'documents_screen.dart';
import 'scholarships_screen.dart';
import 'payments_screen.dart';
import 'jago_chat_screen.dart';
import 'notifications_screen.dart';
import 'application_tracking_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() => _navIndex = index);
    if (index == 0) return;
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()))
          .then((_) => setState(() => _navIndex = 0));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScholarshipsScreen()))
          .then((_) => setState(() => _navIndex = 0));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const JagoChatScreen()))
          .then((_) => setState(() => _navIndex = 0));
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))
          .then((_) => setState(() => _navIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profile = appState.profile;
    final incomeNeedsUpdate = profile.incomeStatus == 'expired';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'JAGO',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryGreen,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: AppTheme.textDark),
                if (appState.unreadNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentSaffron,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${appState.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.textDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: _onBottomNavTapped,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await appState.refreshAllData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello ${profile.fullName} 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 14, color: AppTheme.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            'ST Status: Verified (${profile.domicile})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Text(
                      profile.studentId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Profile Verification Card (92% completion bar + checklist)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile Verification Readiness',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '${profile.completionPercentage}% Complete',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: profile.completionPercentage == 100
                                  ? AppTheme.primaryGreen
                                  : AppTheme.accentSaffron,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: profile.completionPercentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            profile.completionPercentage == 100
                                ? AppTheme.primaryGreen
                                : AppTheme.accentSaffron,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Verification Checklist
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildCheckItem('Identity', true),
                          _buildCheckItem('ST Status', true),
                          _buildCheckItem('Domicile', true),
                          _buildCheckItem('Academic', true),
                          _buildCheckItem('Institution', true),
                          _buildCheckItem(
                            'Income Certificate',
                            !incomeNeedsUpdate,
                            isWarning: incomeNeedsUpdate,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text(
                            'View Full Profile',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Required Card (if income expired)
              if (incomeNeedsUpdate) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.statusWarningBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.statusWarningText, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Action Required',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.statusWarningText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your income certificate needs revalidation for your selected scholarship application period.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.statusWarningText,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentSaffron,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Update Now', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4 Stat Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryTile(
                    title: 'Eligible Schemes',
                    value: '2',
                    icon: Icons.school_outlined,
                    color: AppTheme.primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScholarshipsScreen()),
                      );
                    },
                  ),
                  _buildSummaryTile(
                    title: 'Active Applications',
                    value: appState.hasSubmittedApplication ? '1' : '0',
                    icon: Icons.assignment_outlined,
                    color: Colors.blue,
                    onTap: () {
                      if (appState.hasSubmittedApplication) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplicationTrackingScreen(appId: appState.application.id),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScholarshipsScreen()),
                        );
                      }
                    },
                  ),
                  _buildSummaryTile(
                    title: 'Pending Actions',
                    value: incomeNeedsUpdate ? '1' : '0',
                    icon: Icons.pending_actions_outlined,
                    color: incomeNeedsUpdate ? AppTheme.accentSaffron : AppTheme.primaryGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                      );
                    },
                  ),
                  _buildSummaryTile(
                    title: 'Disbursements',
                    value: '1',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Links Section
              const Text(
                'Quick Navigation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickLinkButton(
                      label: 'View Schemes',
                      icon: Icons.list_alt,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScholarshipsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickLinkButton(
                      label: 'Check Eligibility',
                      icon: Icons.rule,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScholarshipsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickLinkButton(
                      label: 'Open Wallet',
                      icon: Icons.folder,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Footer Note
              Center(
                child: Text(
                  'Demo data only. Not connected to live production systems.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isDone, {bool isWarning = false}) {
    Color color = isDone ? AppTheme.primaryGreen : (isWarning ? AppTheme.accentSaffron : Colors.grey);
    IconData icon = isDone ? Icons.check_circle : (isWarning ? Icons.error : Icons.radio_button_unchecked);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isWarning ? AppTheme.accentSaffron : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                  ),
                  Icon(icon, size: 18, color: color),
                ],
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinkButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
