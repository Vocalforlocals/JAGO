class StudentProfile {
  final String studentId;
  final String fullName;
  final String dob;
  final String aadhaarMasked;
  final String identityStatus;
  final String stCertificateNo;
  final String stStatus;
  final String pvtgStatus;
  final String institution;
  final String course;
  final String academicYear;
  final String academicRecordStatus;
  final String institutionStatus;
  final int familyIncome;
  final String incomeStatus; // 'expired' | 'verified' | 'pending'
  final String incomeCertDate;
  final String domicile;
  final String domicileStatus;
  final String disabilityStatus;
  final String netJrfStatus;
  final int completionPercentage;

  StudentProfile({
    required this.studentId,
    required this.fullName,
    required this.dob,
    required this.aadhaarMasked,
    required this.identityStatus,
    required this.stCertificateNo,
    required this.stStatus,
    required this.pvtgStatus,
    required this.institution,
    required this.course,
    required this.academicYear,
    required this.academicRecordStatus,
    required this.institutionStatus,
    required this.familyIncome,
    required this.incomeStatus,
    required this.incomeCertDate,
    required this.domicile,
    required this.domicileStatus,
    required this.disabilityStatus,
    required this.netJrfStatus,
    required this.completionPercentage,
  });

  factory StudentProfile.initialDemo() {
    return StudentProfile(
      studentId: 'ST2026-001',
      fullName: 'Rahul Kumar',
      dob: '12/04/2005',
      aadhaarMasked: 'XXXX-XXXX-1234',
      identityStatus: 'verified',
      stCertificateNo: 'JH/ST/2022/98432',
      stStatus: 'verified',
      pvtgStatus: 'Not Applicable',
      institution: 'ABC Institute of Technology',
      course: 'B.Tech (Computer Science)',
      academicYear: '2026-27',
      academicRecordStatus: 'verified',
      institutionStatus: 'verified',
      familyIncome: 180000,
      incomeStatus: 'expired',
      incomeCertDate: '15/03/2023',
      domicile: 'Bihar',
      domicileStatus: 'verified',
      disabilityStatus: 'Not Applicable',
      netJrfStatus: 'Not Applicable',
      completionPercentage: 92,
    );
  }

  StudentProfile copyWith({
    String? studentId,
    String? fullName,
    String? aadhaarMasked,
    String? institution,
    String? course,
    String? domicile,
    int? familyIncome,
    String? incomeStatus,
    String? incomeCertDate,
    int? completionPercentage,
  }) {
    return StudentProfile(
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      dob: dob,
      aadhaarMasked: aadhaarMasked ?? this.aadhaarMasked,
      identityStatus: identityStatus,
      stCertificateNo: stCertificateNo,
      stStatus: stStatus,
      pvtgStatus: pvtgStatus,
      institution: institution ?? this.institution,
      course: course ?? this.course,
      academicYear: academicYear,
      academicRecordStatus: academicRecordStatus,
      institutionStatus: institutionStatus,
      familyIncome: familyIncome ?? this.familyIncome,
      incomeStatus: incomeStatus ?? this.incomeStatus,
      incomeCertDate: incomeCertDate ?? this.incomeCertDate,
      domicile: domicile ?? this.domicile,
      domicileStatus: domicileStatus,
      disabilityStatus: disabilityStatus,
      netJrfStatus: netJrfStatus,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentId: json['student_id'] ?? 'ST2026-001',
      fullName: json['full_name'] ?? 'Rahul Kumar',
      dob: json['dob'] ?? '12/04/2005',
      aadhaarMasked: json['aadhaar_masked'] ?? 'XXXX-XXXX-1234',
      identityStatus: json['identity_status'] ?? 'verified',
      stCertificateNo: json['st_certificate_no'] ?? 'JH/ST/2022/98432',
      stStatus: json['st_status'] ?? 'verified',
      pvtgStatus: json['pvtg_status'] ?? 'Not Applicable',
      institution: json['institution'] ?? 'ABC Institute of Technology',
      course: json['course'] ?? 'B.Tech',
      academicYear: json['academic_year'] ?? '2026-27',
      academicRecordStatus: json['academic_record_status'] ?? 'verified',
      institutionStatus: json['institution_status'] ?? 'verified',
      familyIncome: json['family_income'] ?? 180000,
      incomeStatus: json['income_status'] ?? 'expired',
      incomeCertDate: json['income_cert_date'] ?? '15/03/2023',
      domicile: json['domicile'] ?? 'Bihar',
      domicileStatus: json['domicile_status'] ?? 'verified',
      disabilityStatus: json['disability_status'] ?? 'Not Applicable',
      netJrfStatus: json['net_jrf_status'] ?? 'Not Applicable',
      completionPercentage: json['completion_percentage'] ?? 92,
    );
  }
}
