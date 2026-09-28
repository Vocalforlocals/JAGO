class SchemeItem {
  final int id;
  final String code;
  final String name;
  final String description;
  final String level;
  final int incomeLimit;
  final String benefits;
  final String portal;
  final String status;

  SchemeItem({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.level,
    required this.incomeLimit,
    required this.benefits,
    required this.portal,
    required this.status,
  });

  factory SchemeItem.fromJson(Map<String, dynamic> json) {
    return SchemeItem(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? '',
      incomeLimit: json['income_limit'] ?? 250000,
      benefits: json['benefits'] ?? '',
      portal: json['portal'] ?? 'NSP',
      status: json['status'] ?? 'open',
    );
  }

  static List<SchemeItem> allFiveSchemes() {
    return [
      SchemeItem(
        id: 1,
        code: 'pre_matric',
        name: 'Pre-Matric Scholarship for ST Students',
        description: 'Financial support for tribal students studying in Classes 9th and 10th to minimize dropouts.',
        level: 'Secondary (Class 9-10)',
        incomeLimit: 250000,
        benefits: 'Day Scholars: ₹3,500/year; Hostellers: ₹7,000/year + disability grant.',
        portal: 'NSP',
        status: 'open',
      ),
      SchemeItem(
        id: 2,
        code: 'post_matric',
        name: 'Post-Matric Scholarship for ST Students',
        description: 'Comprehensive scholarship covering full compulsory course fees and living allowances for post-secondary education.',
        level: 'Higher Education (UG/PG/Diploma)',
        incomeLimit: 250000,
        benefits: '100% compulsory fee reimbursement + up to ₹13,500/year maintenance allowance.',
        portal: 'NSP',
        status: 'open',
      ),
      SchemeItem(
        id: 3,
        code: 'top_class',
        name: 'Top Class Education Scheme for ST Students',
        description: 'Direct grant for meritorious ST students admitted in notified premier institutions (IITs, NITs, IIMs, NLUs).',
        level: 'Premier Institutes (Notified)',
        incomeLimit: 600000,
        benefits: 'Full tuition fee + living allowance ₹3,000/month + books ₹5,000/year + computer grant ₹45,000.',
        portal: 'NSP',
        status: 'open',
      ),
      SchemeItem(
        id: 4,
        code: 'nfst',
        name: 'National Fellowship for Higher Education of ST Students (NFST)',
        description: 'Fellowship for ST scholars pursuing full-time regular Ph.D. and M.Phil degrees.',
        level: 'Research (M.Phil / Ph.D.)',
        incomeLimit: 600000,
        benefits: 'JRF: ₹31,000/month; SRF: ₹35,000/month + annual contingency grants.',
        portal: 'SFMP (Canara Bank)',
        status: 'open',
      ),
      SchemeItem(
        id: 5,
        code: 'nos',
        name: 'National Overseas Scholarship for ST Candidates (NOS)',
        description: 'Financial assistance for meritorious ST students to pursue Master\'s and Ph.D. programs abroad.',
        level: 'Overseas (Foreign Universities <= 500 Rank)',
        incomeLimit: 800000,
        benefits: 'Full international tuition + annual maintenance allowance (USD 15,400 / GBP 9,900) + airfare.',
        portal: 'NOS Standalone Portal',
        status: 'open',
      ),
    ];
  }
}

class SchemeEligibility {
  final int schemeId;
  final String code;
  final String name;
  final bool eligible;
  final String statusLabel; // 'Eligible', 'Potentially Eligible', 'Not Applicable', etc.
  final String statusBadge;
  final String reason;
  final bool actionAllowed;
  final String? requirementsNote;

  SchemeEligibility({
    required this.schemeId,
    required this.code,
    required this.name,
    required this.eligible,
    required this.statusLabel,
    required this.statusBadge,
    required this.reason,
    required this.actionAllowed,
    this.requirementsNote,
  });

  factory SchemeEligibility.fromJson(Map<String, dynamic> json) {
    return SchemeEligibility(
      schemeId: json['scheme_id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      eligible: json['eligible'] ?? false,
      statusLabel: json['status_label'] ?? '',
      statusBadge: json['status_badge'] ?? '',
      reason: json['reason'] ?? '',
      actionAllowed: json['action_allowed'] ?? false,
      requirementsNote: json['requirements_note'],
    );
  }

  static List<SchemeEligibility> defaultEligibility() {
    return [
      SchemeEligibility(
        schemeId: 1,
        code: 'pre_matric',
        name: 'Pre-Matric Scholarship for ST Students',
        eligible: false,
        statusLabel: 'Not Applicable',
        statusBadge: 'not_applicable',
        reason: 'Applicable exclusively for enrolled students in Class 9 and 10.',
        actionAllowed: false,
        requirementsNote: 'Student is currently pursuing higher secondary / undergraduate B.Tech degree.',
      ),
      SchemeEligibility(
        schemeId: 2,
        code: 'post_matric',
        name: 'Post-Matric Scholarship for ST Students',
        eligible: true,
        statusLabel: 'Eligible',
        statusBadge: 'eligible',
        reason: 'Verified ST category student pursuing undergraduate degree (B.Tech) with annual family income (₹1.80L) under ₹2.50L cap.',
        actionAllowed: true,
        requirementsNote: 'One-time income certificate revalidation required.',
      ),
      SchemeEligibility(
        schemeId: 3,
        code: 'top_class',
        name: 'Top Class Education Scheme for ST Students',
        eligible: true,
        statusLabel: 'Potentially Eligible',
        statusBadge: 'potentially_eligible',
        reason: 'Meets academic and income criteria (ceiling ₹6.0L), but requires AISHE premier institution tier validation.',
        actionAllowed: true,
        requirementsNote: 'Institution name matching review will be required.',
      ),
      SchemeEligibility(
        schemeId: 4,
        code: 'nfst',
        name: 'National Fellowship for Higher Education of ST Students (NFST)',
        eligible: false,
        statusLabel: 'Not Eligible',
        statusBadge: 'not_eligible',
        reason: 'Exclusively applicable for candidates pursuing regular full-time Ph.D. or M.Phil degrees.',
        actionAllowed: false,
        requirementsNote: 'Current enrolled course is undergraduate (B.Tech).',
      ),
      SchemeEligibility(
        schemeId: 5,
        code: 'nos',
        name: 'National Overseas Scholarship for ST Candidates (NOS)',
        eligible: false,
        statusLabel: 'Not Applied',
        statusBadge: 'not_applied',
        reason: 'Requires unconditional admission letter from accredited international university (QS rank <= 500).',
        actionAllowed: false,
        requirementsNote: 'Currently studying in domestic Indian institute.',
      ),
    ];
  }
}
