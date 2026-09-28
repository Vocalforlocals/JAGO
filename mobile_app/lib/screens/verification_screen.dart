import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';
import 'application_tracking_screen.dart';
import 'dashboard_screen.dart';

class VerificationScreen extends StatefulWidget {
  final int applicationId;

  const VerificationScreen({Key? key, required this.applicationId}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _currentStepIndex = 0;
  bool _isFinished = false;
  bool _hasRoutedToManualReview = false;

  final List<Map<String, dynamic>> _checks = [
    {
      'name': 'Identity Verification',
      'source': 'UIDAI Central Vault',
      'status': 'verified',
      'message': 'Aadhaar e-KYC authenticated',
    },
    {
      'name': 'ST Status Verification',
      'source': 'State e-District Repository',
      'status': 'verified',
      'message': 'ST Certificate verified',
    },
    {
      'name': 'Academic Record Verification',
      'source': 'APAAR / Academic Bank of Credits',
      'status': 'verified',
      'message': 'B.Tech regular enrollment confirmed',
    },
    {
      'name': 'Institution Verification',
      'source': 'AISHE Directory',
      'status': 'mismatch',
      'message': 'Naming alias mismatch detected (\'Technology\' vs \'Engineering\')',
    },
    {
      'name': 'Income Certificate Verification',
      'source': 'State Revenue / e-District',
      'status': 'verified',
      'message': 'Within permissible scheme ceiling (₹1.80L)',
    },
    {
      'name': 'Domicile Verification',
      'source': 'State Citizen Portal',
      'status': 'verified',
      'message': 'Resident verified (Bihar)',
    },
    {
      'name': 'Scheme Required Documents Check',
      'source': 'DigiLocker Certified Repository',
      'status': 'verified',
      'message': '4 certificates verified via URI tokens',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startStepAnimation();
  }

  void _startStepAnimation() async {
    for (int i = 0; i < _checks.length; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _currentStepIndex = i + 1;
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isFinished = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.runVerificationWorkflow();
  }

  void _handleActionSelected(String actionName) {
    setState(() {
      _hasRoutedToManualReview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Application Verification'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hub_outlined, color: AppTheme.primaryGreen, size: 22),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Source Verification Engine',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      'Verifying information with authorized databases',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Step Progress Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final check = _checks[i];
                final isDone = i < _currentStepIndex;
                final isRunning = i == _currentStepIndex && !_isFinished;
                final isMismatch = check['status'] == 'mismatch' && isDone;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isRunning
                        ? Colors.blue.shade50
                        : (isMismatch ? AppTheme.statusErrorBg : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isRunning
                          ? Colors.blue.shade300
                          : (isMismatch ? Colors.red.shade300 : AppTheme.cardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isRunning) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                        ),
                      ] else if (isDone) ...[
                        Icon(
                          isMismatch ? Icons.warning_amber_rounded : Icons.check_circle,
                          size: 18,
                          color: isMismatch ? AppTheme.statusErrorText : AppTheme.primaryGreen,
                        ),
                      ] else ...[
                        const Icon(Icons.radio_button_unchecked, size: 18, color: Colors.grey),
                      ],
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              check['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isMismatch ? AppTheme.statusErrorText : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              '${check['source']} • ${check['message']}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isMismatch ? AppTheme.statusErrorText.withOpacity(0.8) : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDone)
                        StatusBadge(
                          status: check['status'],
                          customLabel: isMismatch ? '⚠ Mismatch' : '✓ Verified',
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Intentional Discrepancy Mismatch Card
            if (_isFinished && !_hasRoutedToManualReview) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.accentSaffron, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Institution Information Mismatch',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your profile and the institutional record contain different institution names. Your application has NOT been automatically rejected.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.35),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Your Profile: ABC Institute of Technology', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('• Source Record: ABC Institute of Engineering', style: TextStyle(fontSize: 11, color: AppTheme.accentSaffron, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleActionSelected('Review Information'),
                            child: const Text('Review Info', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleActionSelected('Submit Supporting Document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text('Submit Document', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _handleActionSelected('Contact Institution'),
                        child: const Text('Contact Institution Nodal Officer', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Handled & Routed Notification Card
            if (_hasRoutedToManualReview) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Routed to MoTA Manual Review Queue',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your application has been routed to manual review (Case #VR-10245).\n\nA designated officer will review the institutional naming alias and take appropriate action. You will be notified when a decision is made.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApplicationTrackingScreen(appId: widget.applicationId),
                                ),
                              );
                            },
                            child: const Text('Track Application', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('Back to Dashboard', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
