import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  void _showReceiptDialog(BuildContext context, dynamic payment) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('🏛️', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'JAGO — PFMS Settlement Receipt',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              Text(
                                'Public Financial Management System',
                                style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppTheme.cardBorder),
                  const SizedBox(height: 14),

                  _buildReceiptRow('Sanction Number', payment.sanctionNumber),
                  _buildReceiptRow('Transaction UTR', payment.utrNumber),
                  _buildReceiptRow('Disbursal Date', payment.date),
                  _buildReceiptRow('Scheme Name', payment.schemeName),
                  _buildReceiptRow('Installment', payment.installment),
                  _buildReceiptRow('Credited Bank', 'State Bank of India'),
                  _buildReceiptRow('Account Number', payment.bankAccount),
                  _buildReceiptRow('Aadhaar APB Status', 'Active & Seeded'),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppTheme.cardBorder),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount Credited:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      Text(
                        '₹${payment.receivedAmount}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '✓ Digitally Certified by PFMS & APB',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Direct Benefit Transfer acknowledged by destination bank. No intermediary deduction.',
                          style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final payments = appState.payments;

    final totalSanctioned = payments.fold<int>(0, (sum, p) => sum + p.sanctionedAmount);
    final totalReceived = payments.fold<int>(0, (sum, p) => sum + p.receivedAmount);
    final pendingAmount = payments.fold<int>(0, (sum, p) => sum + p.pendingAmount);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Payments & DBT'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aadhaar Seeding Header Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Aadhaar-Seeded Bank Account Active',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'State Bank of India (****1234) • Mapped via NPCI Aadhaar Payment Bridge',
                          style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Direct Benefit Transfer (DBT)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 2),
            const Text(
              'Scholarship funds are credited via Public Financial Management System (PFMS) directly to your verified account.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),

            const SizedBox(height: 16),

            // 3 Summary Metric Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    'Sanctioned',
                    '₹${totalSanctioned.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    'Received',
                    '₹${totalReceived.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    'Pending',
                    '₹${pendingAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    AppTheme.accentSaffron,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'PFMS Disbursement Lifecycle',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final payment = payments[index];
                final isCredited = payment.status == 'Payment Credited';

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
                                payment.schemeName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            StatusBadge(
                              status: isCredited ? 'verified' : 'not_applicable',
                              customLabel: payment.status,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppTheme.cardBorder),
                        const SizedBox(height: 10),

                        _buildHistoryRow('Sanction Number', payment.sanctionNumber),
                        _buildHistoryRow('Received Amount', '₹${payment.receivedAmount} (${payment.installment})'),
                        _buildHistoryRow('Pending Balance', '₹${payment.pendingAmount}'),
                        _buildHistoryRow('Disbursement Date', payment.date),
                        _buildHistoryRow('Transaction UTR', payment.utrNumber),
                        _buildHistoryRow('PFMS Clearance', payment.pfmsStatus),

                        const SizedBox(height: 12),

                        // 4-Stage PFMS Progress Indicator
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Settlement Tracking:',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildTimelineNode('Sanctioned', true),
                                  _buildTimelineLine(true),
                                  _buildTimelineNode('Treasury', true),
                                  _buildTimelineLine(true),
                                  _buildTimelineNode('NPCI APB', true),
                                  _buildTimelineLine(isCredited),
                                  _buildTimelineNode('Bank Credit', isCredited),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Action Buttons: Digital Receipt
                        if (isCredited)
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => _showReceiptDialog(context, payment),
                              icon: const Icon(Icons.receipt_long, size: 14, color: AppTheme.primaryGreen),
                              label: const Text(
                                'View Digital Sanction Receipt',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryGreen),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'Direct Benefit Transfer authenticated by Ministry of Finance PFMS Gateway (Demo / Mock)',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode(String label, bool isDone) {
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: isDone ? AppTheme.primaryGreen : Colors.grey.shade400,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppTheme.textDark : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppTheme.primaryGreen : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 12),
      ),
    );
  }

  Widget _buildMetricBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
