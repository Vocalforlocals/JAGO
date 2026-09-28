import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

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
            const Text(
              'Direct Benefit Transfer (DBT)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 2),
            const Text(
              'Scholarship funds are credited via Public Financial Management System (PFMS) and APB directly to your Aadhaar-seeded bank account.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),

            const SizedBox(height: 16),

            // 3 Summary Cards
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

            const SizedBox(height: 20),

            const Text(
              'Disbursement History',
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

                        _buildHistoryRow('Sanctioned Amount', '₹${payment.sanctionedAmount}'),
                        _buildHistoryRow('Received Amount', '₹${payment.receivedAmount} (${payment.installment})'),
                        _buildHistoryRow('Pending Balance', '₹${payment.pendingAmount}'),
                        _buildHistoryRow('Disbursement Date', payment.date),
                        _buildHistoryRow('Transfer Channel', payment.mode),
                        _buildHistoryRow('Credited Bank A/C', payment.bankAccount),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'All amounts are demo values. No real financial transactions occurred.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
