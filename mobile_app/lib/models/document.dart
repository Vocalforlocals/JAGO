class DocumentItem {
  final int id;
  final String docType;
  final String title;
  String status; // 'verified' | 'expired' | 'not_applicable' | 'pending'
  String source;
  final String? issueDate;
  final String? expiryDate;
  final String? remarks;

  DocumentItem({
    required this.id,
    required this.docType,
    required this.title,
    required this.status,
    required this.source,
    this.issueDate,
    this.expiryDate,
    this.remarks,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] ?? 0,
      docType: json['doc_type'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'verified',
      source: json['source'] ?? 'DigiLocker (Mock)',
      issueDate: json['issue_date'],
      expiryDate: json['expiry_date'],
      remarks: json['remarks'],
    );
  }

  static List<DocumentItem> defaultWallet() {
    return [
      DocumentItem(
        id: 1,
        docType: 'st_cert',
        title: 'ST Certificate',
        status: 'verified',
        source: 'DigiLocker / State e-District (Mock)',
        issueDate: '12/08/2022',
        remarks: 'Permanent validity issued by Circle Officer, Ranchi.',
      ),
      DocumentItem(
        id: 2,
        docType: 'income_cert',
        title: 'Income Certificate',
        status: 'expired',
        source: 'State e-District (Mock)',
        issueDate: '15/03/2023',
        expiryDate: '31/03/2024',
        remarks: 'Validity expired (>12 months). Fresh certificate required.',
      ),
      DocumentItem(
        id: 3,
        docType: 'domicile_cert',
        title: 'Domicile Certificate',
        status: 'verified',
        source: 'DigiLocker (Mock)',
        issueDate: '10/05/2022',
        remarks: 'Permanent resident of Bihar.',
      ),
      DocumentItem(
        id: 4,
        docType: 'marksheet',
        title: 'Academic Marksheet',
        status: 'verified',
        source: 'DigiLocker / APAAR (Mock)',
        issueDate: '20/06/2026',
        remarks: 'Class 12 / Higher Secondary score: 86.4%.',
      ),
      DocumentItem(
        id: 5,
        docType: 'bonafide_cert',
        title: 'Bonafide Certificate',
        status: 'verified',
        source: 'Institution Portal / AISHE (Mock)',
        issueDate: '05/08/2026',
        remarks: 'Regular full-time B.Tech student enrollment.',
      ),
      DocumentItem(
        id: 6,
        docType: 'disability_cert',
        title: 'Disability Certificate',
        status: 'not_applicable',
        source: 'UDID (Mock)',
        remarks: 'Not Applicable for general ST category.',
      ),
      DocumentItem(
        id: 7,
        docType: 'identity_doc',
        title: 'Identity Document (Aadhaar)',
        status: 'verified',
        source: 'DigiLocker / UIDAI (Mock)',
        issueDate: '01/01/2020',
        remarks: 'Aadhaar e-KYC authenticated.',
      ),
      DocumentItem(
        id: 8,
        docType: 'institution_cert',
        title: 'Institution Certificate',
        status: 'verified',
        source: 'AISHE Directory (Mock)',
        issueDate: '01/07/2026',
        remarks: 'AISHE Code: C-49210.',
      ),
    ];
  }
}
