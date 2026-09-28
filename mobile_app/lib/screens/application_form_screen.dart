import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/scheme.dart';
import 'verification_screen.dart';

class ApplicationFormScreen extends StatefulWidget {
  final SchemeItem scheme;

  const ApplicationFormScreen({Key? key, required this.scheme}) : super(key: key);

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final TextEditingController _bankAccountController = TextEditingController(text: '38920194821');
  final TextEditingController _ifscController = TextEditingController(text: 'SBIN0001234');
  bool _declarationChecked = true;
  bool _submitting = false;

  void _showReviewModal() {
    if (!_declarationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the declaration before submitting.'),
          backgroundColor: AppTheme.accentSaffron,
        ),
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final profile = appState.profile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Application Summary & Audit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: AppTheme.cardBorder),
            const SizedBox(height: 8),

            // Reused information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sync, color: AppTheme.primaryGreen, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Information Reused from Verified Profile:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Full Name: ${profile.fullName}\n• ST Certificate: ${profile.stCertificateNo}\n• Domicile: ${profile.domicile}\n• Institution: ${profile.institution}\n• Course: ${profile.course}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Revalidated information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security_update_good, color: Colors.blue, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Information Revalidated for FY 2026-27:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Income Certificate: Validated (₹${profile.familyIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})\n• Aadhaar-Seeded Bank A/C: ${_bankAccountController.text} (${_ifscController.text})',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      _handleFinalSubmit();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    child: const Text('Confirm & Submit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _handleFinalSubmit() async {
    setState(() => _submitting = true);
    final appState = Provider.of<AppState>(context, listen: false);

    await appState.submitApplication(
      schemeId: widget.scheme.id,
      bankAccount: _bankAccountController.text.trim(),
      ifscCode: _ifscController.text.trim(),
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 24),
            SizedBox(width: 8),
            Text('Application Submitted', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your application has been registered on the unified MoTA platform.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Application ID: ${appState.application.appNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Submission Date: ${appState.application.submissionDate}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 2),
                  const Text('Status: Verification Pipeline Triggered', style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VerificationScreen(
                    applicationId: appState.application.id,
                  ),
                ),
              );
            },
            child: const Text('Track Live Verification'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profile = appState.profile;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Application Form — ${widget.scheme.name}'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verified profile fields are pre-filled and locked to prevent tamper and repetitive entry.',
                      style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pre-filled Read-Only Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pre-filled Verified Information',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField('Full Name', profile.fullName),
                    _buildReadOnlyField('Category', 'Scheduled Tribe (ST)'),
                    _buildReadOnlyField('Domicile', profile.domicile),
                    _buildReadOnlyField('Enrolled Institution', profile.institution),
                    _buildReadOnlyField('Course', profile.course),
                    _buildReadOnlyField('Academic Year', profile.academicYear),
                    _buildReadOnlyField('Annual Family Income', '₹${profile.familyIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Editable DBT Banking Details Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DBT Bank Account Details',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scholarship disbursements are transferred via Aadhaar Payment Bridge (APB) directly to your bank account.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _bankAccountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Bank Account Number',
                        labelStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _ifscController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'IFSC Code',
                        labelStyle: const TextStyle(fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Declaration Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _declarationChecked,
                  onChanged: (val) => setState(() => _declarationChecked = val ?? false),
                  activeColor: AppTheme.primaryGreen,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I hereby declare that all details are accurate, and I agree to avail only one scholarship benefit in accordance with MoTA policies.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.35),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Review Application Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _showReviewModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _submitting ? 'Submitting Application...' : 'Review & Submit Application',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
