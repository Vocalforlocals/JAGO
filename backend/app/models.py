import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, JSON, Float
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, index=True, nullable=False)
    mobile = Column(String(20), unique=True, index=True, nullable=True)
    email = Column(String(150), unique=True, index=True, nullable=True)
    role = Column(String(20), default="student")  # "student" or "officer"
    password_hash = Column(String(255), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    profile = relationship("StudentProfile", back_populates="user", uselist=False)
    documents = relationship("Document", back_populates="user")
    notifications = relationship("Notification", back_populates="user")


class StudentProfile(Base):
    __tablename__ = "student_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    student_id = Column(String(50), default="ST2026-001")
    full_name = Column(String(150), default="Rahul Kumar")
    dob = Column(String(20), default="12/04/2005")
    aadhaar_masked = Column(String(30), default="XXXX-XXXX-1234")
    identity_status = Column(String(30), default="verified")  # verified, pending, mismatch
    
    # Tribal Status
    st_certificate_no = Column(String(100), default="JH/ST/2022/98432")
    st_status = Column(String(30), default="verified")
    pvtg_status = Column(String(50), default="Not Applicable")
    
    # Education
    institution = Column(String(200), default="ABC Institute of Technology")
    course = Column(String(100), default="B.Tech")
    academic_year = Column(String(50), default="2026-27")
    academic_record_status = Column(String(30), default="verified")
    institution_status = Column(String(30), default="verified")
    
    # Financial
    family_income = Column(Integer, default=180000)
    income_status = Column(String(30), default="expired")  # "expired", "verified", "pending"
    income_cert_date = Column(String(50), default="15/03/2023")
    
    # Residence
    domicile = Column(String(100), default="Bihar")
    domicile_status = Column(String(30), default="verified")
    
    # Additional
    disability_status = Column(String(50), default="Not Applicable")
    net_jrf_status = Column(String(50), default="Not Applicable")
    completion_percentage = Column(Integer, default=92)

    user = relationship("User", back_populates="profile")


class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    doc_type = Column(String(50), nullable=False)  # st_cert, income_cert, domicile_cert, marksheet, etc.
    title = Column(String(150), nullable=False)
    status = Column(String(30), default="verified")  # verified, expired, not_applicable, pending
    source = Column(String(100), default="DigiLocker (Mock)")
    file_url = Column(String(255), default="/mock/docs/sample.pdf")
    issue_date = Column(String(30), nullable=True)
    expiry_date = Column(String(30), nullable=True)
    remarks = Column(Text, nullable=True)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    user = relationship("User", back_populates="documents")


class Scheme(Base):
    __tablename__ = "schemes"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, index=True)  # pre_matric, post_matric, top_class, nfst, nos
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    level = Column(String(100))  # School, Higher Secondary, Graduate, Masters/PhD, Overseas
    income_limit = Column(Integer, nullable=True)
    benefits = Column(Text, nullable=False)
    portal = Column(String(50), default="NSP")  # NSP, SFMP, NOS Portal
    status = Column(String(30), default="open")  # open, closed, upcoming


class Application(Base):
    __tablename__ = "applications"

    id = Column(Integer, primary_key=True, index=True)
    app_number = Column(String(50), unique=True, index=True)  # ST-2026-001245
    student_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    scheme_id = Column(Integer, ForeignKey("schemes.id"), nullable=False)
    scheme_name = Column(String(200), nullable=False)
    stage = Column(String(100), default="Application Submitted")  # Application Submitted, Document Verification, Institution Verification, Under Government Verification, Sanctioned, Disbursed, Rejected
    status = Column(String(50), default="Under Government Verification")
    submission_date = Column(String(50), default="28 Sept 2026")
    last_updated = Column(String(50), default="28 Sept 2026")
    bank_account = Column(String(50), default="XXXXXX1234")
    ifsc_code = Column(String(30), default="SBIN0001234")
    declarations_accepted = Column(Boolean, default=True)
    deficiency_notes = Column(Text, nullable=True)

    scheme = relationship("Scheme")
    student = relationship("User")
    verification_records = relationship("VerificationRecord", back_populates="application")
    review_cases = relationship("ReviewCase", back_populates="application")


class VerificationRecord(Base):
    __tablename__ = "verification_records"

    id = Column(Integer, primary_key=True, index=True)
    application_id = Column(Integer, ForeignKey("applications.id"), nullable=False)
    check_name = Column(String(100), nullable=False)  # Identity, ST Status, Academic, Institution, Income, Domicile, etc.
    status = Column(String(30), nullable=False)  # verified, mismatch, action_required, not_applicable
    source = Column(String(100), nullable=False)  # UIDAI, State e-District, AISHE, DigiLocker, etc.
    message = Column(Text, nullable=False)
    source_record = Column(String(255), nullable=True)
    student_record = Column(String(255), nullable=True)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)

    application = relationship("Application", back_populates="verification_records")


class ReviewCase(Base):
    __tablename__ = "review_cases"

    id = Column(Integer, primary_key=True, index=True)
    case_number = Column(String(50), unique=True, index=True)  # VR-10245
    application_id = Column(Integer, ForeignKey("applications.id"), nullable=True)
    student_name = Column(String(150), nullable=False)
    issue_type = Column(String(100), nullable=False)  # Institution mismatch, Income mismatch, Domicile mismatch
    priority = Column(String(30), default="High")  # High, Medium, Low
    status = Column(String(30), default="Pending")  # Pending, Under Review, Resolved, Rejected
    student_data = Column(JSON, nullable=True)  # {"institution": "ABC Institute of Technology"}
    authorized_data = Column(JSON, nullable=True)  # {"institution": "ABC Institute of Engineering"}
    possible_reasons = Column(JSON, nullable=True)
    resolution_notes = Column(Text, nullable=True)
    officer_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    application = relationship("Application", back_populates="review_cases")


class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    application_id = Column(Integer, ForeignKey("applications.id"), nullable=True)
    student_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    scheme_name = Column(String(200), nullable=False)
    sanctioned_amount = Column(Integer, default=18000)
    received_amount = Column(Integer, default=9000)
    pending_amount = Column(Integer, default=9000)
    installment = Column(String(50), default="1st Installment")
    date = Column(String(50), default="28 Sept 2026")
    status = Column(String(50), default="Payment Credited")
    mode = Column(String(50), default="DBT (Direct Benefit Transfer)")
    bank_account = Column(String(50), default="****1234")


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)
    date = Column(String(50), default="Today")
    is_read = Column(Boolean, default=False)
    type = Column(String(50), default="info")  # info, warning, success, action_required
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", back_populates="notifications")


class UnreachedStudent(Base):
    __tablename__ = "unreached_students"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    grade_class = Column(String(100), nullable=False)
    state = Column(String(100), nullable=False)
    district = Column(String(100), default="Ranchi")
    udise_apaar_id = Column(String(100), unique=True, nullable=False)
    status = Column(String(50), default="Potentially Unreached")
    enrolled_benefit = Column(String(100), default="None")
    contact_number = Column(String(30), default="+91 98765 43210")
    source_portal = Column(String(100), default="UDISE+ / APAAR Match")
