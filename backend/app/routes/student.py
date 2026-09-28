import datetime
from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import (
    User, StudentProfile, Document, Scheme, Application,
    VerificationRecord, ReviewCase, Payment, Notification
)
from ..schemas import (
    ProfileResponse, IncomeUpdateRequest, DocumentResponse,
    DocumentUploadRequest, SchemeResponse, EligibilityCheckResult,
    SchemeEligibilityItem, ApplicationCreateRequest, ApplicationResponse,
    PaymentSummaryResponse, NotificationResponse, ChatRequest, ChatMessage
)
from ..services.mock_gov_integrations import MockGovIntegrations
from ..services.verification_orchestrator import VerificationOrchestrator
from ..services.ocr_service import OCRService
from ..services.jago_ai import JagoAIService

router = APIRouter(prefix="/api/student", tags=["Student App"])

def get_demo_student(db: Session) -> User:
    student = db.query(User).filter(User.role == "student").first()
    if not student:
        raise HTTPException(status_code=404, detail="Student user not found in database.")
    return student

# 1. Profile
@router.get("/profile", response_model=ProfileResponse)
def get_profile(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile record missing.")
    return profile

@router.post("/profile/update-income", response_model=ProfileResponse)
def update_income(req: IncomeUpdateRequest, db: Session = Depends(get_db)):
    student = get_demo_student(db)
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile record missing.")
    
    # Process simulated OCR
    ocr_result = OCRService.process_income_certificate(req.certificate_number)

    # Update profile
    profile.income_status = "verified"
    profile.family_income = req.annual_income or 180000
    profile.income_cert_date = req.issue_date or "10/08/2026"
    profile.completion_percentage = 100

    # Also update Document in wallet
    doc = db.query(Document).filter(
        Document.user_id == student.id,
        Document.doc_type == "income_cert"
    ).first()
    if doc:
        doc.status = "verified"
        doc.issue_date = profile.income_cert_date
        doc.remarks = "Verified via State Revenue e-District & OCR match."

    # Add notification
    notif = Notification(
        user_id=student.id,
        title="Income Certificate Revalidated",
        message="Your Income Certificate for FY 2026-27 was successfully verified via State Revenue repository and OCR cross-check.",
        date="Just now",
        is_read=False,
        type="success"
    )
    db.add(notif)
    db.commit()
    db.refresh(profile)
    return profile

# 2. Documents
@router.get("/documents", response_model=List[DocumentResponse])
def get_documents(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    docs = db.query(Document).filter(Document.user_id == student.id).all()
    return docs

@router.post("/documents/fetch-all-digilocker")
async def fetch_all_digilocker(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    fetched_docs = await MockGovIntegrations.fetch_digilocker_documents(student.username)
    
    for item in fetched_docs:
        doc = db.query(Document).filter(
            Document.user_id == student.id,
            Document.doc_type == item["doc_type"]
        ).first()
        if doc:
            if item["doc_type"] != "income_cert" or doc.status == "verified":
                doc.status = item["status"]
            doc.source = item["source"]

    db.commit()
    return {
        "success": True,
        "message": "Fetched 5 authorized documents from DigiLocker (Demo / Mock)",
        "count": 5
    }

@router.post("/documents/upload")
def upload_document(req: DocumentUploadRequest, db: Session = Depends(get_db)):
    student = get_demo_student(db)
    doc = db.query(Document).filter(
        Document.user_id == student.id,
        Document.doc_type == req.doc_type
    ).first()

    if not doc:
        doc = Document(
            user_id=student.id,
            doc_type=req.doc_type,
            title=req.title,
            status="verified",
            source="Manual Upload + OCR Verification (Demo / Mock)"
        )
        db.add(doc)
    else:
        doc.status = "verified"
        doc.source = "Manual Upload + OCR Verification (Demo / Mock)"
        doc.remarks = f"Document '{req.file_name}' validated."

    # If updating income certificate, update profile too
    if req.doc_type == "income_cert":
        profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()
        if profile:
            profile.income_status = "verified"
            profile.completion_percentage = 100

    db.commit()
    return {
        "success": True,
        "message": f"Document '{req.title}' uploaded and verified successfully (Demo / Mock)",
        "doc_type": req.doc_type,
        "status": "verified"
    }

# 3. Schemes & Eligibility Engine
@router.get("/schemes", response_model=List[SchemeResponse])
def get_schemes(db: Session = Depends(get_db)):
    schemes = db.query(Scheme).all()
    return schemes

@router.get("/eligibility", response_model=EligibilityCheckResult)
def run_eligibility_check(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()

    schemes_data = [
        SchemeEligibilityItem(
            scheme_id=1,
            code="pre_matric",
            name="Pre-Matric Scholarship for ST Students",
            eligible=False,
            status_label="Not Applicable",
            status_badge="not_applicable",
            reason="Applicable exclusively for enrolled students in Class 9 and 10 in secondary schools.",
            action_allowed=False,
            requirements_note="Student is currently pursuing higher secondary/undergraduate education (B.Tech)."
        ),
        SchemeEligibilityItem(
            scheme_id=2,
            code="post_matric",
            name="Post-Matric Scholarship for ST Students",
            eligible=True,
            status_label="Eligible",
            status_badge="eligible",
            reason="Verified ST category student pursuing recognized undergraduate degree (B.Tech) with annual family income (₹1.80L) under the ₹2.50L cap.",
            action_allowed=True,
            requirements_note="One-time income certificate revalidation required before submission."
        ),
        SchemeEligibilityItem(
            scheme_id=3,
            code="top_class",
            name="Top Class Education Scheme for ST Students",
            eligible=True,
            status_label="Potentially Eligible",
            status_badge="potentially_eligible",
            reason="Meets academic and income criteria (ceiling ₹6.0L), but requires AISHE premier institution tier validation.",
            action_allowed=True,
            requirements_note="Institution name matching review will be required."
        ),
        SchemeEligibilityItem(
            scheme_id=4,
            code="nfst",
            name="National Fellowship for Higher Education of ST Students (NFST)",
            eligible=False,
            status_label="Not Eligible",
            status_badge="not_eligible",
            reason="Exclusively applicable for candidates pursuing regular full-time Ph.D. or M.Phil degrees.",
            action_allowed=False,
            requirements_note="Current enrolled course is B.Tech (Undergraduate)."
        ),
        SchemeEligibilityItem(
            scheme_id=5,
            code="nos",
            name="National Overseas Scholarship for ST Candidates (NOS)",
            eligible=False,
            status_label="Not Applied",
            status_badge="not_applied",
            reason="Requires unconditional admission letter from accredited international university (QS/THE rank <= 500).",
            action_allowed=False,
            requirements_note="Currently studying in domestic Indian institute."
        )
    ]

    return EligibilityCheckResult(
        student_name=profile.full_name if profile else "Rahul Kumar",
        st_status=profile.st_status if profile else "verified",
        family_income=profile.family_income if profile else 180000,
        schemes=schemes_data
    )

# 4. Applications
@router.post("/applications")
def create_application(req: ApplicationCreateRequest, db: Session = Depends(get_db)):
    student = get_demo_student(db)
    scheme = db.query(Scheme).filter(Scheme.id == req.scheme_id).first()
    if not scheme:
        scheme_name = "Post-Matric Scholarship for ST Students"
    else:
        scheme_name = scheme.name

    # Check if application already exists
    existing = db.query(Application).filter(
        Application.student_id == student.id,
        Application.scheme_id == req.scheme_id
    ).first()

    if existing:
        return {
            "success": True,
            "application_id": existing.id,
            "app_number": existing.app_number,
            "message": "Existing application retrieved."
        }

    import uuid as _uuid
    from datetime import datetime as _dt
    unique_suffix = _uuid.uuid4().hex[:6].upper()
    app_number = f"ST-{_dt.now().strftime('%Y')}-{unique_suffix}"
    now_str = _dt.now().strftime("%d %b %Y")
    app = Application(
        app_number=app_number,
        student_id=student.id,
        scheme_id=req.scheme_id,
        scheme_name=scheme_name,
        stage="Application Submitted",
        status="Under Government Verification",
        submission_date=now_str,
        last_updated=now_str,
        bank_account=req.bank_account or "XXXXXX1234",
        ifsc_code=req.ifsc_code or "SBIN0001234",
        declarations_accepted=req.declaration,
        deficiency_notes="Income certificate revalidation pending officer verification."
    )
    db.add(app)
    db.commit()
    db.refresh(app)

    # Add notification
    notif = Notification(
        user_id=student.id,
        title="Application Submitted Successfully",
        message=f"Application #{app_number} for {scheme_name} has been submitted and queued for verification.",
        date="Today",
        is_read=False,
        type="info"
    )
    db.add(notif)
    db.commit()

    return {
        "success": True,
        "application_id": app.id,
        "app_number": app.app_number,
        "submission_date": app.submission_date,
        "message": "Application submitted successfully."
    }

@router.get("/applications")
def list_applications(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    apps = db.query(Application).filter(Application.student_id == student.id).all()
    result = []
    for a in apps:
        result.append({
            "id": a.id,
            "app_number": a.app_number,
            "scheme_id": a.scheme_id,
            "scheme_name": a.scheme_name,
            "stage": a.stage,
            "status": a.status,
            "submission_date": a.submission_date,
            "last_updated": a.last_updated,
            "bank_account": a.bank_account,
            "ifsc_code": a.ifsc_code,
            "deficiency_notes": a.deficiency_notes
        })
    return result

@router.get("/applications/{id}")
def get_application_detail(id: int, db: Session = Depends(get_db)):
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found.")
    
    sub_date = app.submission_date or datetime.datetime.now().strftime("%d %b %Y")
    timeline = [
        {"title": "Application Submitted", "date": sub_date, "status": "completed"},
        {"title": "Initial Validation", "date": sub_date, "status": "completed"},
        {"title": "Document Verification", "date": sub_date, "status": "completed"},
        {"title": "Institution Verification", "date": sub_date, "status": "completed"},
        {"title": "Application Verified", "date": "In Progress", "status": "in_progress"},
        {"title": "Sanction Order", "date": "Pending", "status": "pending"},
        {"title": "DBT Payment Disbursal", "date": "Pending", "status": "pending"}
    ]

    records = db.query(VerificationRecord).filter(VerificationRecord.application_id == id).all()
    steps = []
    for r in records:
        steps.append({
            "check_name": r.check_name,
            "status": r.status,
            "source": r.source,
            "message": r.message,
            "student_record": r.student_record,
            "source_record": r.source_record
        })

    return {
        "id": app.id,
        "app_number": app.app_number,
        "scheme_id": app.scheme_id,
        "scheme_name": app.scheme_name,
        "stage": app.stage,
        "status": app.status,
        "submission_date": app.submission_date,
        "last_updated": app.last_updated,
        "bank_account": app.bank_account,
        "ifsc_code": app.ifsc_code,
        "deficiency_notes": app.deficiency_notes,
        "timeline": timeline,
        "verification_steps": steps
    }

@router.post("/applications/{id}/run-verification")
async def run_application_verification(id: int, db: Session = Depends(get_db)):
    student = get_demo_student(db)
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()
    app = db.query(Application).filter(Application.id == id).first()
    if not app:
        raise HTTPException(status_code=404, detail="Application not found.")

    # Execute orchestrator
    result = await VerificationOrchestrator.run_full_verification(id, profile)

    # Save verification records
    db.query(VerificationRecord).filter(VerificationRecord.application_id == id).delete()
    for s in result["steps"]:
        vr = VerificationRecord(
            application_id=id,
            check_name=s["check_name"],
            status=s["status"],
            source=s["source"],
            message=s["message"],
            student_record=s.get("student_record"),
            source_record=s.get("source_record")
        )
        db.add(vr)

    # Handle mismatch case
    if result["routed_to_review"]:
        app.stage = "Under Government Verification"
        app.status = "Routed to MoTA Manual Review Queue"
        app.last_updated = datetime.datetime.now().strftime("%d %b %Y")

        # Check or create ReviewCase in admin queue
        case_no = "VR-10245"
        existing_case = db.query(ReviewCase).filter(ReviewCase.case_number == case_no).first()
        if not existing_case:
            rc = ReviewCase(
                case_number=case_no,
                application_id=app.id,
                student_name=profile.full_name,
                issue_type="Institution mismatch",
                priority="High",
                status="Pending",
                student_data={"institution": profile.institution},
                authorized_data={"institution": "ABC Institute of Engineering"},
                possible_reasons=[
                    "Student profile may use informal or abbreviated campus name",
                    "Institution record may need correction or alias addition",
                    "Supporting bonafide document will resolve the mismatch"
                ],
                resolution_notes="Awaiting officer verification of AISHE code affiliation."
            )
            db.add(rc)

        notif = Notification(
            user_id=student.id,
            title="Application Moved to Government Verification",
            message="Your application has been routed to the MoTA Manual Review Queue for institution record alignment. No action is required from your side.",
            date="Today",
            is_read=False,
            type="info"
        )
        db.add(notif)

    db.commit()
    return result

# 5. Payments
@router.get("/payments", response_model=PaymentSummaryResponse)
def get_payments(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    payments = db.query(Payment).filter(Payment.student_id == student.id).all()
    
    total_sanctioned = sum(p.sanctioned_amount for p in payments) or 18000
    total_received = sum(p.received_amount for p in payments) or 9000
    pending_amount = sum(p.pending_amount for p in payments) or 9000

    history = []
    for p in payments:
        history.append({
            "id": p.id,
            "scheme_name": p.scheme_name,
            "sanctioned_amount": p.sanctioned_amount,
            "received_amount": p.received_amount,
            "pending_amount": p.pending_amount,
            "installment": p.installment,
            "date": p.date,
            "status": p.status,
            "mode": p.mode,
            "bank_account": p.bank_account
        })

    if not history:
        # Default fallback payment record for demo
        history = [
            {
                "id": 1,
                "scheme_name": "Post-Matric Scholarship for ST Students",
                "sanctioned_amount": 18000,
                "received_amount": 9000,
                "pending_amount": 9000,
                "installment": "1st Installment",
                "date": datetime.datetime.now().strftime("%d %b %Y"),
                "status": "Payment Credited",
                "mode": "DBT (Direct Benefit Transfer)",
                "bank_account": "****1234"
            }
        ]

    return PaymentSummaryResponse(
        total_sanctioned=total_sanctioned,
        total_received=total_received,
        pending_amount=pending_amount,
        history=history
    )

# 6. Notifications
@router.get("/notifications", response_model=List[NotificationResponse])
def get_notifications(db: Session = Depends(get_db)):
    student = get_demo_student(db)
    notifs = db.query(Notification).filter(Notification.user_id == student.id).order_by(Notification.id.desc()).all()
    return notifs

@router.post("/notifications/{id}/read")
def mark_notification_read(id: int, db: Session = Depends(get_db)):
    notif = db.query(Notification).filter(Notification.id == id).first()
    if notif:
        notif.is_read = True
        db.commit()
    return {"success": True, "id": id}

# 7. JAGO Chatbot
@router.post("/jago-chat")
def jago_chat(req: ChatRequest, db: Session = Depends(get_db)):
    student = get_demo_student(db)
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == student.id).first()
    apps = db.query(Application).filter(Application.student_id == student.id).all()

    response = JagoAIService.generate_response(
        query=req.message,
        student_profile=profile,
        applications=apps,
        language=req.language
    )

    return {
        "reply": response["text"],
        "options": response["options"],
        "language": req.language
    }
