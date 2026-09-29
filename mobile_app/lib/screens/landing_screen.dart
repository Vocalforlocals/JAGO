import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import 'student_login_screen.dart';
import 'dashboard_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isHindi = appState.language == 'hi';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JAGO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Janjatiya Awareness & Guidance for Opportunities',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language Toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => appState.setLanguage('en'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: !isHindi ? AppTheme.primaryGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: !isHindi ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => appState.setLanguage('hi'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHindi ? AppTheme.primaryGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'हिं',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isHindi ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 3, color: const Color(0xFFFF671F))),
              Expanded(child: Container(height: 3, color: Colors.grey.shade300)),
              Expanded(child: Container(height: 3, color: const Color(0xFF046A38))),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

            // App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/logo.png',
                width: 76,
                height: 76,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),

            // Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: Text(
                isHindi
                  ? 'राष्ट्रीय छात्रवृत्ति पोर्टल'
                  : 'National Scholarship Portal',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hero Title
            Text(
              isHindi ? 'जागो (JAGO)' : 'JAGO',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryGreen,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isHindi
                ? 'जनजातीय जागरूकता एवं अवसरों के लिए मार्गदर्शन'
                : 'Janjatiya Awareness & Guidance for Opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                ? 'एक छात्र। एक सत्यापित प्रोफ़ाइल। पाँच छात्रवृत्ति योजनाएँ।'
                : 'One Student. One Verified Profile. Five Scholarship Schemes.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isHindi
                ? 'एक ही एकीकृत अनुभव के माध्यम से जनजातीय छात्रवृत्ति योजनाओं की पात्रता जांचें, आवेदन करें और ट्रैक करें।'
                : 'Access, apply and track eligible Tribal scholarship opportunities through one unified experience.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            // Primary Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isHindi ? 'विद्यार्थी लॉगिन (Student Login)' : 'Student Login',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await appState.loginStudent();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: AppTheme.accentSaffron, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isHindi ? 'त्वरित डेमो देखें (Explore Demo)' : 'Explore Demo (Auto-Login)',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 3 Feature Highlights
            _buildFeatureCard(
              icon: Icons.badge_outlined,
              title: isHindi ? 'एकीकृत प्रोफ़ाइल (Unified Profile)' : 'Unified Profile',
              desc: isHindi
                ? 'पाँचों योजनाओं (Pre, Post, Top Class, National Fellowship, NOS) के लिए एक ही सत्यापित प्रोफ़ाइल।'
                : 'One verified profile for all scholarship schemes.',
              accentColor: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.sync_outlined,
              title: isHindi ? 'पुनः प्रयोज्य सत्यापन (Reusable Verification)' : 'Reusable Verification',
              desc: isHindi
                ? 'एक बार DigiLocker से सत्यापित करें, हर योजना में बिना दोबारा अपलोड किए उपयोग करें।'
                : 'Verify once via DigiLocker. Reuse everywhere without repeated uploads.',
              accentColor: AppTheme.nationalNavy,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.smart_toy_outlined,
              title: isHindi ? 'स्थिति-जागरूक AI (State-Aware JAGO)' : 'State-Aware Chatbot',
              desc: isHindi
                ? 'जागो बॉट आपके आवेदन की वास्तविक स्थिति और नियमों को जानता है।'
                : 'JAGO knows your actual application status and scholarship guidelines.',
              accentColor: AppTheme.accentSaffron,
            ),

            const SizedBox(height: 36),

            // Disclaimer Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                'JAGO — National Unified Scholarship Portal\nGovernment of India',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  ],
),
);
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
