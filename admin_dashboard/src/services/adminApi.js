const API_BASE = (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env.VITE_API_BASE)
  ? import.meta.env.VITE_API_BASE
  : (typeof window !== 'undefined' && window.location.hostname && window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1')
    ? 'https://jago-dr69.onrender.com/api'
    : 'http://127.0.0.1:8000/api';

export const adminApi = {
  async login(email, password) {
    try {
      const res = await fetch(`${API_BASE}/auth/officer-login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      if (!res.ok) throw new Error('Login failed');
      return await res.json();
    } catch (e) {
      // Fallback for standalone demo
      return {
        access_token: 'demo_token_officer',
        role: 'officer',
        username: 'officer_review',
        full_name: 'Dr. Ananya Sharma (Senior Review Officer)'
      };
    }
  },

  async getStats() {
    try {
      const res = await fetch(`${API_BASE}/admin/stats`);
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, using local mock data');
    }
    return {
      total_registered: 12450,
      verified_st: 11230,
      applications_submitted: 9870,
      under_verification: 2340,
      manual_review_required: 312,
      sanctioned: 7218,
      payments_completed_crores: 18.4,
      potentially_unreached: 300,
      common_deficiencies: {
        'Income Certificate': 480,
        'Domicile Certificate': 210,
        'Academic Marksheet': 150
      }
    };
  },

  async getReviewQueue(filterType = 'all') {
    try {
      const res = await fetch(`${API_BASE}/admin/reviews?filter_type=${filterType}`);
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, using local mock data');
    }
    const defaultCases = [
      {
        id: 1,
        case_number: 'VR-10245',
        application_id: 1,
        student_name: 'Rahul Kumar',
        issue_type: 'Institution mismatch',
        priority: 'High',
        status: 'Pending',
        student_data: { institution: 'ABC Institute of Technology' },
        authorized_data: { institution: 'ABC Institute of Engineering' },
        possible_reasons: [
          'Student profile may be outdated or use informal campus name',
          'Institution AISHE record may list parent trust or engineering campus',
          'Supporting bonafide certificate can resolve the naming mismatch'
        ],
        resolution_notes: 'Pending officer check of AISHE Code C-49210.',
        created_at: '28 Sept 2026'
      },
      {
        id: 2,
        case_number: 'VR-10246',
        application_id: 2,
        student_name: 'Priya Kumari',
        issue_type: 'Income mismatch',
        priority: 'Medium',
        status: 'Under Review',
        student_data: { income: '₹1,40,000 (Declared)' },
        authorized_data: { income: '₹2,10,000 (State Revenue IT Return)' },
        possible_reasons: [
          'Difference between gross agricultural income and total taxable income',
          'Tehsildar certificate differs from automated IT data match'
        ],
        resolution_notes: 'Reviewing agricultural land certificate.',
        created_at: '28 Sept 2026'
      },
      {
        id: 3,
        case_number: 'VR-10247',
        application_id: 3,
        student_name: 'Amit Kumar',
        issue_type: 'Domicile mismatch',
        priority: 'Low',
        status: 'Resolved',
        student_data: { domicile: 'Jharkhand (Bokaro)' },
        authorized_data: { domicile: 'Jharkhand (Bokaro Steel City)' },
        possible_reasons: ['Municipal boundary postal alias'],
        resolution_notes: 'Officer verified Bokaro municipal record. Case resolved.',
        created_at: '27 Sept 2026'
      }
    ];

    if (filterType === 'pending') return defaultCases.filter(c => c.status === 'Pending');
    if (filterType === 'high_priority') return defaultCases.filter(c => c.priority === 'High');
    if (filterType === 'institution_mismatch') return defaultCases.filter(c => c.issue_type.includes('Institution'));
    if (filterType === 'income_mismatch') return defaultCases.filter(c => c.issue_type.includes('Income'));
    if (filterType === 'resolved') return defaultCases.filter(c => c.status === 'Resolved');
    return defaultCases;
  },

  async getCaseDetail(caseId) {
    try {
      const res = await fetch(`${API_BASE}/admin/reviews/${caseId}`);
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, using local mock data');
    }
    return {
      id: 1,
      case_number: caseId || 'VR-10245',
      application_id: 1,
      student_name: 'Rahul Kumar',
      issue_type: 'Institution mismatch',
      priority: 'High',
      status: 'Pending',
      student_data: { institution: 'ABC Institute of Technology' },
      authorized_data: { institution: 'ABC Institute of Engineering' },
      possible_reasons: [
        'Student profile may be outdated or use informal campus name',
        'Institution AISHE record may list parent trust or engineering campus',
        'Supporting bonafide certificate can resolve the naming mismatch'
      ],
      resolution_notes: 'Pending officer check of AISHE Code C-49210.',
      created_at: '28 Sept 2026'
    };
  },

  async submitCaseAction(caseId, action, notes, correctionField = '') {
    try {
      const res = await fetch(`${API_BASE}/admin/reviews/${caseId}/action`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, notes, correction_field: correctionField })
      });
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, mock action executed');
    }
    return {
      success: true,
      case_number: caseId,
      new_status: action === 'approve' ? 'Resolved' : action === 'reject' ? 'Rejected' : 'Under Review',
      message: action === 'approve' ? 'Verification Case Approved. Application status updated to Verified.' : 'Action recorded successfully.'
    };
  },

  async getUnreachedStudents() {
    try {
      const res = await fetch(`${API_BASE}/admin/unreached`);
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, using local mock data');
    }
    return [
      { id: 1, name: 'Ravi Kumar', grade_class: 'Class 9', state: 'Bihar', district: 'Gaya', udise_apaar_id: 'UDISE-BR-2026-90112', status: 'Potentially Unreached', enrolled_benefit: 'None', contact_number: '+91 94321 00001', source_portal: 'UDISE+ / APAAR Match' },
      { id: 2, name: 'Sunita Devi', grade_class: 'Class 11', state: 'Jharkhand', district: 'Khunti', udise_apaar_id: 'UDISE-JH-2026-88123', status: 'Potentially Unreached', enrolled_benefit: 'None', contact_number: '+91 94321 00002', source_portal: 'UDISE+ / APAAR Match' },
      { id: 3, name: 'Mohan Oraon', grade_class: 'B.Tech Year 2', state: 'Odisha', district: 'Mayurbhanj', udise_apaar_id: 'APAAR-OD-2026-77341', status: 'Potentially Unreached', enrolled_benefit: 'None', contact_number: '+91 94321 00003', source_portal: 'AISHE / APAAR Match' },
      { id: 4, name: 'Lakshmi Munda', grade_class: 'Class 10', state: 'Jharkhand', district: 'Ranchi', udise_apaar_id: 'UDISE-JH-2026-44219', status: 'Potentially Unreached', enrolled_benefit: 'None', contact_number: '+91 94321 00004', source_portal: 'UDISE+ Match' },
      { id: 5, name: 'Arjun Santal', grade_class: 'M.Phil', state: 'West Bengal', district: 'Purulia', udise_apaar_id: 'APAAR-WB-2026-33901', status: 'Potentially Unreached', enrolled_benefit: 'None', contact_number: '+91 94321 00005', source_portal: 'AISHE / OTR Match' }
    ];
  },

  async getSaturationMetrics() {
    try {
      const res = await fetch(`${API_BASE}/admin/saturation/metrics`);
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, mock saturation metrics');
    }
    return {
      total_screened_census: 12450,
      saturated_beneficiaries: 12150,
      unreached_gap: 300,
      overall_saturation_rate: 97.59,
      district_saturation: [
        { district: 'Ranchi', state: 'Jharkhand', screened: 4200, saturated: 4010, gap: 190, rate: 95.48, priority: 'Medium' },
        { district: 'Khunti', state: 'Jharkhand', screened: 2100, saturated: 1890, gap: 210, rate: 90.00, priority: 'High' },
        { district: 'West Singhbhum', state: 'Jharkhand', screened: 2800, saturated: 2480, gap: 320, rate: 88.57, priority: 'High' },
        { district: 'Gumla', state: 'Jharkhand', screened: 1950, saturated: 1780, gap: 170, rate: 91.28, priority: 'Medium' },
        { district: 'Mayurbhanj', state: 'Odisha', screened: 1400, saturated: 1310, gap: 90, rate: 93.57, priority: 'Normal' }
      ],
      channels: [
        { id: 'sms_regional', name: 'Regional Bulk SMS (CDAC Meghdoot)', coverage: '100% Mobile Coverage' },
        { id: 'csc_mobile_camp', name: 'CSC Field Mobilization Van', coverage: 'Gram Panchayat Level' },
        { id: 'school_alert', name: 'Ashram School / Headmaster Advisory', coverage: 'Direct Institutional' }
      ]
    };
  },

  async triggerOutreach(payload) {
    const body = typeof payload === 'string' 
      ? { campaign_name: payload } 
      : (payload || { campaign_name: 'National Scholarship Saturation Drive' });

    try {
      const res = await fetch(`${API_BASE}/admin/unreached/outreach`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, mock outreach response');
    }
    return {
      success: true,
      message: 'Outreach campaign successfully dispatched to 300 unreached scholars.',
      recipients_count: 300,
      sample_sms_preview: 'प्रिय छात्र, आप राष्ट्रीय छात्रवृत्ति के लिए पात्र हैं। तुरंत आवेदन करने के लिए JAGO ऐप खोलें।',
      csc_field_camps_scheduled: 8
    };
  },

  async getVerificationLayer() {
    try {
      const res = await fetch(`${API_BASE}/admin/verification-layer`);
      if (res.ok) return await res.json();
    } catch (e) {
      console.warn('Backend unavailable, using local mock data');
    }
    return {
      sources: [
        { name: 'DigiLocker', type: 'Digital Documents Repository', status: 'connected', badge: '🟢 Connected (Demo / Mock)', latency: '140ms' },
        { name: 'AISHE', type: 'Higher Education Institutions Database', status: 'future', badge: '🟡 Future Integration Layer', latency: 'Mocked' },
        { name: 'UDISE+', type: 'School Education Data (Classes 1-12)', status: 'future', badge: '🟡 Future Integration Layer', latency: 'Mocked' },
        { name: 'APAAR', type: 'Academic Bank of Credits / One Nation One Student ID', status: 'future', badge: '🟡 Future Integration Layer', latency: 'Mocked' },
        { name: 'UIDAI', type: 'Aadhaar e-KYC Identity Verification', status: 'future', badge: '🟡 Future Integration Layer', latency: 'Mocked' },
        { name: 'State e-District', type: 'Revenue Portals (ST, Domicile, Income)', status: 'future', badge: '🟡 Future Integration Layer', latency: 'Mocked' },
        { name: 'UGC-NTA', type: 'NET/JRF National Registry', status: 'future', badge: '🟡 Future Integration Layer', latency: 'Mocked' }
      ],
      verification_entries: [
        { dimension: 'Identity Verification', status: 'verified', badge: '✅ Verified (Demo / Mock)', source: 'UIDAI / DigiLocker' },
        { dimension: 'ST/PVTG Status', status: 'verified', badge: '✅ Verified (Demo / Mock)', source: 'State e-District (Jharkhand)' },
        { dimension: 'Academic Records', status: 'pending', badge: '⏳ Pending (Demo / Mock)', source: 'APAAR / ABC' },
        { dimension: 'Institution Details', status: 'verified', badge: '✅ Verified (Demo / Mock)', source: 'AISHE Directory' },
        { dimension: 'NET/JRF Qualification', status: 'not_applicable', badge: '⚪ Not Applicable', source: 'UGC-NTA' },
        { dimension: 'Disability Certificate', status: 'not_applicable', badge: '⚪ Not Applicable', source: 'UDID Portal' },
        { dimension: 'Income Certificate', status: 'action_required', badge: '⚠️ Action Required (Expired)', source: 'State Revenue Portal' },
        { dimension: 'Domicile Certificate', status: 'verified', badge: '✅ Verified (Demo / Mock)', source: 'State e-District' }
      ]
    };
  }
};
