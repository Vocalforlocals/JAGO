import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/status_badge.dart';

class DocumentsScreen extends StatelessWidget {
  final bool isEmbedded;
  const DocumentsScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  void _handleFetchAll(BuildContext context, AppState appState) async {
    final msg = await appState.fetchAllFromDigiLocker();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _handleViewDoc(BuildContext context, AppState appState, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digital Document Preview',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'Document: $title\nIssued by: Competent Authority\nHolder: ${appState.profile.fullName} (${appState.profile.studentId})\nAuthenticated: Cryptographically Verified via Official Registry.',
                style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleUploadDoc(BuildContext context, AppState appState, String docType, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Upload $title', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select document from device storage. OCR will automatically extract certificate number and expiration date.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_upload_outlined, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'sample_certificate_2026.pdf',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final msg = await appState.uploadDocument(docType, title, 'sample_certificate_2026.pdf');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            child: const Text('Upload & Run OCR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final documents = appState.documents;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Document Wallet'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: !isEmbedded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Fetch All from DigiLocker Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleFetchAll(context, appState),
                icon: const Icon(Icons.cloud_download_outlined, size: 18),
                label: const Text('Fetch All from DigiLocker (Mock)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle Info
            const Text(
              'Digital Document Wallet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Certificates verified here are stored once and reused across all scholarship schemes.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),

            const SizedBox(height: 14),

            // 8 Document Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final doc = documents[index];
                final isExpired = doc.status == 'expired';
                final isNotApplicable = doc.status == 'not_applicable';

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
                                doc.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isNotApplicable ? Colors.grey : AppTheme.textDark,
                                ),
                              ),
                            ),
                            StatusBadge(
                              status: doc.status,
                              customLabel: isExpired
                                  ? '⚠ Expired'
                                  : isNotApplicable
                                      ? 'Not Applicable'
                                      : '✓ Verified',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Source: ${doc.source}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isNotApplicable ? Colors.grey.shade400 : AppTheme.textMuted,
                          ),
                        ),
                        if (doc.remarks != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            doc.remarks!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isExpired ? AppTheme.accentSaffron : Colors.grey.shade600,
                              fontStyle: isExpired ? FontStyle.normal : FontStyle.italic,
                              fontWeight: isExpired ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppTheme.cardBorder),
                        const SizedBox(height: 8),

                        // Action Buttons for this card
                        if (isExpired) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleUploadDoc(context, appState, doc.docType, doc.title),
                              icon: const Icon(Icons.upload, size: 14),
                              label: const Text('Upload Updated Certificate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentSaffron,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ] else if (!isNotApplicable) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _handleViewDoc(context, appState, doc.title),
                                icon: const Icon(Icons.visibility_outlined, size: 14),
                                label: const Text('View', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fetched ${doc.title} from DigiLocker (Mock)'),
                                      backgroundColor: AppTheme.primaryGreen,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.refresh, size: 14),
                                label: const Text('Fetch', style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: () => _handleUploadDoc(context, appState, doc.docType, doc.title),
                                icon: const Icon(Icons.upload_file, size: 14),
                                label: const Text('Upload', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            'No documents required for this category.',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Footer
            Center(
              child: Text(
                'DigiLocker & State e-District API Integration • Secure Sandbox',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
