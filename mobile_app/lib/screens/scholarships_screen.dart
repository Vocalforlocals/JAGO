import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/scheme.dart';
import '../widgets/status_badge.dart';
import 'application_prep_screen.dart';

class ScholarshipsScreen extends StatefulWidget {
  const ScholarshipsScreen({Key? key}) : super(key: key);

  @override
  State<ScholarshipsScreen> createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  void _handleRunCheck() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.runEligibilityCheck();
  }

  void _showOneSchemeRuleAlert(SchemeItem scheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.accentSaffron, size: 22),
            SizedBox(width: 8),
            Text('One Scholarship Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Under Ministry of Tribal Affairs regulations, a student can avail only ONE scholarship at any given time.\n\nApplying for Post-Matric Scholarship will be your primary active benefit.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplicationPrepScreen(scheme: scheme),
                ),
              );
            },
            child: const Text('Proceed to Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allSchemes = SchemeItem.allFiveSchemes();
    final eligibilityList = appState.eligibility;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Scholarships'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            const Text(
              'Find and Apply for Scholarships',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'MoTA administers 5 schemes across secondary, higher, research, and overseas education.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),

            const SizedBox(height: 14),

            // Run Eligibility Check Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: appState.isLoading ? null : _handleRunCheck,
                icon: const Icon(Icons.rule, size: 18),
                label: Text(
                  appState.isLoading ? 'Evaluating Eligibility Rules...' : 'Run Eligibility Check',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Eligibility Result Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eligibility Diagnostic Result',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Based on your verified profile (ST, B.Tech, Income ₹1.80L):',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 10),

                  _buildEligibilityRow('Post-Matric Scholarship', 'Eligible', AppTheme.statusSuccessText),
                  _buildEligibilityRow('Top Class Education', 'Potentially Eligible', AppTheme.accentSaffron),
                  _buildEligibilityRow('Pre-Matric Scholarship', 'Not Applicable (Class 9-10 only)', Colors.grey),
                  _buildEligibilityRow('National Fellowship (NFST)', 'Not Eligible (Requires Ph.D)', Colors.grey),
                  _buildEligibilityRow('National Overseas (NOS)', 'Not Applied (Requires Foreign Univ)', Colors.grey),

                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 8),

                  const Text(
                    '• Final decision belongs to the authorized scholarship authority.\n• You can avail only ONE scholarship at a time.',
                    style: TextStyle(fontSize: 10, color: AppTheme.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Available Ministry of Tribal Affairs Schemes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            // 5 Scheme Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allSchemes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final scheme = allSchemes[index];
                final el = eligibilityList.firstWhere(
                  (e) => e.code == scheme.code,
                  orElse: () => SchemeEligibility(
                    schemeId: scheme.id,
                    code: scheme.code,
                    name: scheme.name,
                    eligible: false,
                    statusLabel: 'Not Applicable',
                    statusBadge: 'not_applicable',
                    reason: 'Review details.',
                    actionAllowed: false,
                  ),
                );

                final isPostMatric = scheme.code == 'post_matric';
                final isTopClass = scheme.code == 'top_class';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scheme.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    scheme.level,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(
                              status: el.statusBadge,
                              customLabel: el.statusLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scheme.description,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.currency_rupee, size: 14, color: AppTheme.primaryGreen),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Benefits: ${scheme.benefits}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Action button
                        if (isPostMatric) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showOneSchemeRuleAlert(scheme),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text('Apply Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else if (isTopClass) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Requires Premier Institute designation in AISHE.'),
                                  ),
                                );
                              },
                              child: const Text('Check Requirements', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ] else ...[
                          Text(
                            el.reason,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityRow(String scheme, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(scheme, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
