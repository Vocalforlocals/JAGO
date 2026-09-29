import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';
import 'documents_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profile = appState.profile;
    final incomeNeedsUpdate = profile.incomeStatus == 'expired';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Verified Profile'),
        backgroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.redAccent),
            label: const Text('Logout', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 2),
                      ),
                      child: const Center(
                        child: Text('👨‍🎓', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Student ID: ${profile.studentId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Overall Completion: ${profile.completionPercentage}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: profile.completionPercentage == 100
                                      ? AppTheme.primaryGreen
                                      : AppTheme.accentSaffron,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 1. Identity Section
            _buildSectionCard(
              title: '1. Identity Verification',
              badgeStatus: profile.identityStatus,
              fields: [
                _buildField('Full Name', profile.fullName),
                _buildField('Date of Birth', profile.dob),
                _buildField('Aadhaar Number', profile.aadhaarMasked),
                _buildField('e-KYC Authority', 'UIDAI Central Vault (Demo / Mock)'),
              ],
            ),

            const SizedBox(height: 12),

            // 2. Tribal Status Section
            _buildSectionCard(
              title: '2. Tribal Category Status',
              badgeStatus: profile.stStatus,
              fields: [
                _buildField('Category', 'Scheduled Tribe (ST)'),
                _buildField('Certificate Number', profile.stCertificateNo),
                _buildField('Issuing State', profile.domicile),
                _buildField('PVTG Status', profile.pvtgStatus),
              ],
            ),

            const SizedBox(height: 12),

            // 3. Education Section
            _buildSectionCard(
              title: '3. Educational Enrollment',
              badgeStatus: profile.academicRecordStatus,
              fields: [
                _buildField('Institution', profile.institution),
                _buildField('Course & Stream', profile.course),
                _buildField('Academic Year', profile.academicYear),
                _buildField('Registry Match', 'APAAR / ABC Academic Bank of Credits'),
              ],
            ),

            const SizedBox(height: 12),

            // 4. Financial Section
            _buildSectionCard(
              title: '4. Financial & Income Information',
              badgeStatus: profile.incomeStatus,
              customBadge: profile.incomeStatus == 'expired' ? '⚠ Expired' : '✓ Verified',
              fields: [
                _buildField('Annual Family Income', '₹${profile.familyIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                _buildField('Income Certificate Date', profile.incomeCertDate),
                _buildField(
                  'Validity Status',
                  incomeNeedsUpdate
                      ? 'Expired (>12 months). Revalidation Required.'
                      : 'Valid for Financial Year 2026-27',
                  isWarning: incomeNeedsUpdate,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 5. Residence Section
            _buildSectionCard(
              title: '5. Residence & Domicile',
              badgeStatus: profile.domicileStatus,
              fields: [
                _buildField('Domicile State', profile.domicile),
                _buildField('Verification Source', 'State e-District Citizen Services'),
              ],
            ),

            const SizedBox(height: 12),

            // 6. Additional Details
            _buildSectionCard(
              title: '6. Additional Classifications',
              badgeStatus: 'not_applicable',
              fields: [
                _buildField('Disability (Divyangjan)', profile.disabilityStatus),
                _buildField('NET / JRF Status', profile.netJrfStatus),
              ],
            ),

            const SizedBox(height: 16),

            // Explanation Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.statusInfoText, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Why do we verify your information?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.statusInfoText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'JAGO validates your information against authorized government repositories (UIDAI, State e-District, AISHE, APAAR) so eligible details can be reused during scholarship applications without repetitive forms.\n\nInformation requires revalidation only when it expires (such as annual income certificates) or when a scheme requests a specialized eligibility check.',
                    style: TextStyle(fontSize: 11, color: AppTheme.statusInfoText, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            if (incomeNeedsUpdate) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                    );
                  },
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Update Income Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentSaffron,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Dashboard'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String badgeStatus,
    String? customBadge,
    required List<Widget> fields,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                StatusBadge(status: badgeStatus, customLabel: customBadge),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.cardBorder, height: 1),
            const SizedBox(height: 10),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isWarning ? AppTheme.accentSaffron : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
