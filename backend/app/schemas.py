from typing import List, Optional, Any, Dict
from pydantic import BaseModel, Field

# --- Auth ---
class OTPRequest(BaseModel):
    mobile: str

class OTPVerifyRequest(BaseModel):
    mobile: str
    otp: str

class OfficerLoginRequest(BaseModel):
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    role: str
    username: str
    full_name: Optional[str] = None

class RegisterRequest(BaseModel):
    full_name: str
    mobile: str
    aadhaar_masked: str
    tribe: str
    domicile: str
    institution: str
    course: str
    st_certificate_no: Optional[str] = None

# --- Profile ---
class ProfileResponse(BaseModel):
    id: int
    student_id: str
    full_name: str
    dob: str
    aadhaar_masked: str
    identity_status: str
    st_certificate_no: str
    st_status: str
    pvtg_status: str
    institution: str
    course: str
    academic_year: str
    academic_record_status: str
    institution_status: str
    family_income: int
    income_status: str
    income_cert_date: str
    domicile: str
    domicile_status: str
    disability_status: str
    net_jrf_status: str
    completion_percentage: int

    class Config:
        from_attributes = True

class IncomeUpdateRequest(BaseModel):
    certificate_number: str
    annual_income: Optional[int] = 180000
    issuing_authority: Optional[str] = "Sub-Divisional Officer, Revenue Dept"
    issue_date: Optional[str] = None
    document_base64: Optional[str] = None

# --- Documents ---
class DocumentResponse(BaseModel):
    id: int
    doc_type: str
    title: str
    status: str
    source: str
    file_url: Optional[str] = None
    issue_date: Optional[str] = None
    expiry_date: Optional[str] = None
    remarks: Optional[str] = None

    class Config:
        from_attributes = True

class DocumentUploadRequest(BaseModel):
    doc_type: str
    title: str
    file_name: str
    document_content: Optional[str] = None

# --- Schemes & Eligibility ---
class SchemeResponse(BaseModel):
    id: int
    code: str
    name: str
    description: str
    level: Optional[str] = None
    income_limit: Optional[int] = None
    benefits: str
    portal: str
    status: str

    class Config:
        from_attributes = True

class SchemeEligibilityItem(BaseModel):
    scheme_id: int
    code: str
    name: str
    eligible: bool
    status_label: str  # "Eligible", "Potentially Eligible", "Not Applicable", "Not Eligible", "Not Applied"
    status_badge: str  # "eligible", "potentially_eligible", "not_applicable", "not_eligible"
    reason: str
    action_allowed: bool
    requirements_note: Optional[str] = None

class EligibilityCheckResult(BaseModel):
    student_name: str
    st_status: str
    family_income: int
    schemes: List[SchemeEligibilityItem]
    one_scheme_rule_note: str = "As per official guidelines, a student can avail only ONE scholarship at a time."
    disclaimer: str = "Verified Rules Engine. Final sanctioning decision rests with the authorized scholarship authority."

# --- Applications ---
class ApplicationCreateRequest(BaseModel):
    scheme_id: int
    bank_account: str
    ifsc_code: str
    declaration: bool

class VerificationStepItem(BaseModel):
    check_name: str
    status: str  # "verified", "mismatch", "action_required", "not_applicable"
    source: str
    message: str
    student_record: Optional[str] = None
    source_record: Optional[str] = None

class ApplicationResponse(BaseModel):
    id: int
    app_number: str
    scheme_id: int
    scheme_name: str
    stage: str
    status: str
    submission_date: str
    last_updated: str
    bank_account: str
    ifsc_code: str
    deficiency_notes: Optional[str] = None
    timeline: List[Dict[str, Any]]
    verification_steps: List[VerificationStepItem]

    class Config:
        from_attributes = True

# --- Reviews ---
class ReviewCaseResponse(BaseModel):
    id: int
    case_number: str
    application_id: Optional[int]
    student_name: str
    issue_type: str
    priority: str
    status: str
    student_data: Optional[Dict[str, Any]]
    authorized_data: Optional[Dict[str, Any]]
    possible_reasons: Optional[List[str]]
    resolution_notes: Optional[str]
    created_at: str

    class Config:
        from_attributes = True

class ReviewActionRequest(BaseModel):
    action: str  # "approve", "request_correction", "reject"
    notes: Optional[str] = None
    correction_field: Optional[str] = None

# --- Payments ---
class PaymentItem(BaseModel):
    id: int
    scheme_name: str
    sanctioned_amount: int
    received_amount: int
    pending_amount: int
    installment: str
    date: str
    status: str
    mode: str
    bank_account: str
    sanction_number: Optional[str] = "SAN-2026-ST-7721"
    utr_number: Optional[str] = "UTR98412894124"
    pfms_status: Optional[str] = "Settled via NPCI Aadhaar Payment Bridge"

class PaymentSummaryResponse(BaseModel):
    total_sanctioned: int
    total_received: int
    pending_amount: int
    history: List[PaymentItem]

# --- Notifications ---
class NotificationResponse(BaseModel):
    id: int
    title: str
    message: str
    date: str
    is_read: bool
    type: str

    class Config:
        from_attributes = True

# --- Admin Stats ---
class AdminDashboardStats(BaseModel):
    total_registered: int
    verified_st: int
    applications_submitted: int
    under_verification: int
    manual_review_required: int
    sanctioned: int
    payments_completed_crores: float
    potentially_unreached: int
    common_deficiencies: Dict[str, int]

# --- Unreached Students ---
class UnreachedStudentResponse(BaseModel):
    id: int
    name: str
    grade_class: str
    state: str
    district: str
    udise_apaar_id: str
    status: str
    enrolled_benefit: str
    contact_number: str
    source_portal: str

    class Config:
        from_attributes = True

class OutreachRequest(BaseModel):
    student_ids: Optional[List[int]] = None
    campaign_name: str = "National Scholarship Saturation & Direct Outreach Drive"
    channel: Optional[str] = "sms_regional"  # sms_regional, csc_mobile_camp, school_alert
    target_district: Optional[str] = "All Districts"
    language: Optional[str] = "hi"  # hi, san, or, en

# --- JAGO Chatbot ---
class ChatMessage(BaseModel):
    sender: str  # "user" or "bot"
    text: str
    timestamp: Optional[str] = None
    options: Optional[List[str]] = None

class ChatRequest(BaseModel):
    message: str
    language: str = "en"  # "en" or "hi"
    context_user_id: Optional[int] = None
