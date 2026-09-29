class PaymentRecord {
  final int id;
  final String schemeName;
  final int sanctionedAmount;
  final int receivedAmount;
  final int pendingAmount;
  final String installment;
  final String date;
  final String status;
  final String mode;
  final String bankAccount;
  final String sanctionNumber;
  final String utrNumber;
  final String pfmsStatus;

  PaymentRecord({
    required this.id,
    required this.schemeName,
    required this.sanctionedAmount,
    required this.receivedAmount,
    required this.pendingAmount,
    required this.installment,
    required this.date,
    required this.status,
    required this.mode,
    required this.bankAccount,
    this.sanctionNumber = 'SAN-2026-ST-7721',
    this.utrNumber = 'UTR98412894124',
    this.pfmsStatus = 'Settled via NPCI Aadhaar Payment Bridge',
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? 0,
      schemeName: json['scheme_name'] ?? '',
      sanctionedAmount: json['sanctioned_amount'] ?? 0,
      receivedAmount: json['received_amount'] ?? 0,
      pendingAmount: json['pending_amount'] ?? 0,
      installment: json['installment'] ?? '1st Installment',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Payment Credited',
      mode: json['mode'] ?? 'DBT',
      bankAccount: json['bank_account'] ?? '****1234',
      sanctionNumber: json['sanction_number'] ?? 'SAN-2026-ST-7721',
      utrNumber: json['utr_number'] ?? 'UTR98412894124',
      pfmsStatus: json['pfms_status'] ?? 'Settled via NPCI Aadhaar Payment Bridge',
    );
  }

  static List<PaymentRecord> defaultHistory() {
    return [
      PaymentRecord(
        id: 1,
        schemeName: 'Post-Matric Scholarship for ST Students',
        sanctionedAmount: 18000,
        receivedAmount: 9000,
        pendingAmount: 9000,
        installment: '1st Installment',
        date: '28 Sept 2026',
        status: 'Payment Credited',
        mode: 'DBT (Direct Benefit Transfer)',
        bankAccount: '****1234',
        sanctionNumber: 'SAN-2026-ST-7721',
        utrNumber: 'UTR98412894124',
        pfmsStatus: 'Settled via NPCI Aadhaar Payment Bridge',
      ),
      PaymentRecord(
        id: 2,
        schemeName: 'Top Class Education Scheme',
        sanctionedAmount: 0,
        receivedAmount: 0,
        pendingAmount: 0,
        installment: 'N/A',
        date: '—',
        status: 'Not Applied',
        mode: '—',
        bankAccount: '—',
        sanctionNumber: '—',
        utrNumber: '—',
        pfmsStatus: 'Not Disbursed',
      ),
    ];
  }
}
