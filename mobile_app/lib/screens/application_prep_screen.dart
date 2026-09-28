import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/scheme.dart';
import '../widgets/status_badge.dart';
import 'application_form_screen.dart';

class ApplicationPrepScreen extends StatefulWidget {
  final SchemeItem scheme;

  const ApplicationPrepScreen({Key? key, required this.scheme}) : super(key: key);

  @override
  State<ApplicationPrepScreen> createState() => _ApplicationPrepScreenState();
}

class _ApplicationPrepScreenState extends State<ApplicationPrepScreen> {
  bool _isRevalidating = false;
  String _revalidationStep = '';

  void _handleUpdateCertificate() async {
    final appState = Provider.of<AppState>(context, listen: false);

    setState(() {
      _isRevalidating = true;
      _revalidationStep = '✓ Submitted for verification';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _revalidationStep = 'Checking authorized record...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _revalidationStep = '✓ Information matched via State Revenue OCR';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await appState.updateIncomeCertificate(
      certNumber: 'JH/INC/2026/88219',
      amount: 180000,
    );

    setState(() {
      _isRevalidating = false;
      _revalidationStep = 'Verification complete. Income information can now be reused.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profile = appState.profile;
    final incomeNeedsUpdate = profile.incomeStatus == 'expired';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Application Preparation — ${widget.scheme.name}'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reusable Info Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Verified Profile Data Found',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'We found information from your verified profile. You don\'t need to enter it again!',
                    style: TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Readiness Checklist
            const Text(
              'Application Readiness',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildReadinessRow('Personal Details', true, 'Identity & Aadhaar matched'),
                    const Divider(height: 12, color: AppTheme.cardBorder),
                    _buildReadinessRow('ST Category Status', true, 'Certificate JH/ST/2022/98432 verified'),
                    const Divider(height: 12, color: AppTheme.cardBorder),
                    _buildReadinessRow('Academic Details', true, 'B.Tech regular enrollment verified'),
                    const Divider(height: 12, color: AppTheme.cardBorder),
                    _buildReadinessRow('Institution AISHE', true, 'ABC Institute of Technology'),
                    const Divider(height: 12, color: AppTheme.cardBorder),
                    _buildReadinessRow(
                      'Income Certificate',
                      !incomeNeedsUpdate,
                      incomeNeedsUpdate ? 'Revalidation required (Expired)' : 'FY 2026-27 Validated',
                      isWarning: incomeNeedsUpdate,
                    ),
                    const Divider(height: 12, color: AppTheme.cardBorder),
                    _buildReadinessRow(
                      'Required Documents',
                      !incomeNeedsUpdate,
                      incomeNeedsUpdate ? '4 Available, 1 Needs Update' : 'All 5 Documents Ready',
                      isWarning: incomeNeedsUpdate,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Warning Card if income needs update
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
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.statusWarningText, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'One item needs attention',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.statusWarningText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Income Certificate\nYour previous certificate is no longer valid for this application period (issued in March 2023).',
                      style: TextStyle(fontSize: 12, color: AppTheme.statusWarningText, height: 1.35),
                    ),
                    const SizedBox(height: 14),

                    if (_isRevalidating || _revalidationStep.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            if (_isRevalidating)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentSaffron),
                              )
                            else
                              const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _revalidationStep,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (incomeNeedsUpdate)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isRevalidating ? null : _handleUpdateCertificate,
                          icon: const Icon(Icons.upload, size: 16),
                          label: const Text('Update Certificate (Simulate Revalidation)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentSaffron,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusSuccessBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.statusSuccessText, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All verified profile prerequisites are 100% ready!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.statusSuccessText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicationFormScreen(scheme: widget.scheme),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continue to Application Form', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessRow(String title, bool isReady, String subtitle, {bool isWarning = false}) {
    return Row(
      children: [
        Icon(
          isReady ? Icons.check_circle : (isWarning ? Icons.error : Icons.radio_button_unchecked),
          size: 18,
          color: isReady ? AppTheme.primaryGreen : (isWarning ? AppTheme.accentSaffron : Colors.grey),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isWarning ? AppTheme.accentSaffron : AppTheme.textMuted,
                  fontWeight: isWarning ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        StatusBadge(
          status: isReady ? 'verified' : (isWarning ? 'expired' : 'pending'),
          customLabel: isReady ? '✓ Ready' : (isWarning ? '⚠ Revalidation' : 'Pending'),
        ),
      ],
    );
  }
}
