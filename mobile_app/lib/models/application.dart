class VerificationStep {
  final String checkName;
  final String status; // 'verified' | 'mismatch' | 'action_required' | 'not_applicable'
  final String source;
  final String message;
  final String? studentRecord;
  final String? sourceRecord;

  VerificationStep({
    required this.checkName,
    required this.status,
    required this.source,
    required this.message,
    this.studentRecord,
    this.sourceRecord,
  });

  factory VerificationStep.fromJson(Map<String, dynamic> json) {
    return VerificationStep(
      checkName: json['check_name'] ?? '',
      status: json['status'] ?? 'verified',
      source: json['source'] ?? '',
      message: json['message'] ?? '',
      studentRecord: json['student_record'],
      sourceRecord: json['source_record'],
    );
  }
}

class TimelineStep {
  final String title;
  final String date;
  final String status; // 'completed' | 'in_progress' | 'pending'

  TimelineStep({
    required this.title,
    required this.date,
    required this.status,
  });
}

class ScholarshipApplication {
  final int id;
  final String appNumber;
  final int schemeId;
  final String schemeName;
  String stage;
  String status;
  final String submissionDate;
  String lastUpdated;
  final String bankAccount;
  final String ifscCode;
  String? deficiencyNotes;
  List<VerificationStep> verificationSteps;
  List<TimelineStep> timeline;

  ScholarshipApplication({
    required this.id,
    required this.appNumber,
    required this.schemeId,
    required this.schemeName,
    required this.stage,
    required this.status,
    required this.submissionDate,
    required this.lastUpdated,
    required this.bankAccount,
    required this.ifscCode,
    this.deficiencyNotes,
    required this.verificationSteps,
    required this.timeline,
  });

  static ScholarshipApplication demoApplication() {
    return ScholarshipApplication(
      id: 1,
      appNumber: 'ST-2026-001245',
      schemeId: 2,
      schemeName: 'Post-Matric Scholarship for ST Students',
      stage: 'Under Verification',
      status: 'Routed to Manual Review',
      submissionDate: '28 Sept 2026',
      lastUpdated: '28 Sept 2026',
      bankAccount: 'XXXXXX1234',
      ifscCode: 'SBIN0001234',
      deficiencyNotes: 'Institutional name alignment check assigned to Officer Queue (Case #VR-10245).',
      verificationSteps: [
        VerificationStep(
          checkName: 'Identity Verification',
          status: 'verified',
          source: 'UIDAI Aadhaar Vault (Demo / Mock)',
          message: 'Aadhaar e-KYC authenticated successfully.',
          studentRecord: 'Aadhaar XXXX-XXXX-1234 (Rahul Kumar)',
          sourceRecord: 'UIDAI Central Identity Repository Match',
        ),
        VerificationStep(
          checkName: 'ST Status Verification',
          status: 'verified',
          source: 'State e-District Portal (Bihar) (Demo / Mock)',
          message: 'ST Certificate verified against State Revenue digital repository.',
          studentRecord: 'Certificate #JH/ST/2022/98432',
          sourceRecord: 'State Revenue Department Validated',
        ),
        VerificationStep(
          checkName: 'Academic Record Verification',
          status: 'verified',
          source: 'APAAR / Academic Bank of Credits (Demo / Mock)',
          message: 'Academic marksheet and semester progression verified.',
          studentRecord: 'B.Tech - Year 2026-27',
          sourceRecord: 'Enrolled - Regular 2026-27',
        ),
        VerificationStep(
          checkName: 'Institution Verification',
          status: 'mismatch',
          source: 'AISHE Institutional Database (Demo / Mock)',
          message: 'AISHE directory listed name differs by suffix (\'ABC Institute of Engineering\' vs \'ABC Institute of Technology\'). Routed for manual verification.',
          studentRecord: 'ABC Institute of Technology',
          sourceRecord: 'ABC Institute of Engineering',
        ),
        VerificationStep(
          checkName: 'Income Certificate Verification',
          status: 'verified',
          source: 'State Revenue / e-District (Demo / Mock)',
          message: 'Income certificate verified within permissible scheme ceiling.',
          studentRecord: 'Annual Income ₹1,80,000',
          sourceRecord: 'State Revenue Repository',
        ),
        VerificationStep(
          checkName: 'Domicile Verification',
          status: 'verified',
          source: 'State e-District (Demo / Mock)',
          message: 'Resident domicile certificate validated.',
          studentRecord: 'Bihar',
          sourceRecord: 'Resident Record - Bihar',
        ),
        VerificationStep(
          checkName: 'Scheme Documents Check',
          status: 'verified',
          source: 'DigiLocker Certified Repository (Demo / Mock)',
          message: 'All 4 required certificates verified via DigiLocker.',
          studentRecord: '4 Available',
          sourceRecord: 'DigiLocker URI Token Verified',
        ),
        VerificationStep(
          checkName: 'NET / JRF Qualification',
          status: 'not_applicable',
          source: 'UGC-NTA National Eligibility Registry (Demo / Mock)',
          message: 'Not applicable for undergraduate degree program.',
          studentRecord: 'N/A',
          sourceRecord: 'N/A',
        ),
      ],
      timeline: [
        TimelineStep(title: 'Application Submitted', date: '28 Sept 2026', status: 'completed'),
        TimelineStep(title: 'Initial Validation', date: '28 Sept 2026', status: 'completed'),
        TimelineStep(title: 'Document Verification', date: '28 Sept 2026', status: 'completed'),
        TimelineStep(title: 'Institution Verification', date: '28 Sept 2026', status: 'completed'),
        TimelineStep(title: 'Application Verified', date: 'In Progress', status: 'in_progress'),
        TimelineStep(title: 'Sanction Order', date: 'Pending', status: 'pending'),
        TimelineStep(title: 'DBT Payment Disbursal', date: 'Pending', status: 'pending'),
      ],
    );
  }
}
