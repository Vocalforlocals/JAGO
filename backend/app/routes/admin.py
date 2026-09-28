from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import (
    User, Application, ReviewCase, Notification, UnreachedStudent
)
from ..schemas import (
    AdminDashboardStats, ReviewCaseResponse, ReviewActionRequest,
    UnreachedStudentResponse, OutreachRequest
)

router = APIRouter(prefix="/api/admin", tags=["Admin Portal"])

@router.get("/stats", response_model=AdminDashboardStats)
def get_admin_stats(db: Session = Depends(get_db)):
    review_count = db.query(ReviewCase).filter(ReviewCase.status == "Pending").count()
    app_count = db.query(Application).count()

    return AdminDashboardStats(
        total_registered=12450,
        verified_st=11230,
        applications_submitted=9870 + app_count,
        under_verification=2340,
        manual_review_required=312 + review_count,
        sanctioned=7218,
        payments_completed_crores=18.4,
        potentially_unreached=300,
        common_deficiencies={
            "Income Certificate": 480,
            "Domicile Certificate": 210,
            "Academic Marksheet": 150
        }
    )

@router.get("/reviews", response_model=List[ReviewCaseResponse])
def get_review_queue(
    filter_type: Optional[str] = Query("all"),
    db: Session = Depends(get_db)
):
    query = db.query(ReviewCase)
    
    if filter_type == "pending":
        query = query.filter(ReviewCase.status == "Pending")
    elif filter_type == "high_priority":
        query = query.filter(ReviewCase.priority == "High")
    elif filter_type == "institution_mismatch":
        query = query.filter(ReviewCase.issue_type.ilike("%institution%"))
    elif filter_type == "income_mismatch":
        query = query.filter(ReviewCase.issue_type.ilike("%income%"))
    elif filter_type == "resolved":
        query = query.filter(ReviewCase.status == "Resolved")

    cases = query.order_by(ReviewCase.id.asc()).all()
    results = []
    for c in cases:
        results.append(ReviewCaseResponse(
            id=c.id,
            case_number=c.case_number,
            application_id=c.application_id,
            student_name=c.student_name,
            issue_type=c.issue_type,
            priority=c.priority,
            status=c.status,
            student_data=c.student_data,
            authorized_data=c.authorized_data,
            possible_reasons=c.possible_reasons,
            resolution_notes=c.resolution_notes,
            created_at=c.created_at.strftime("%d %b %Y") if c.created_at else "28 Sept 2026"
        ))
    return results

@router.get("/reviews/{case_id}", response_model=ReviewCaseResponse)
def get_review_case(case_id: str, db: Session = Depends(get_db)):
    if case_id.isdigit():
        case = db.query(ReviewCase).filter(
            (ReviewCase.case_number == case_id) | (ReviewCase.id == int(case_id))
        ).first()
    else:
        case = db.query(ReviewCase).filter(ReviewCase.case_number == case_id).first()

    if not case:
        raise HTTPException(status_code=404, detail="Review case not found.")
    
    return ReviewCaseResponse(
        id=case.id,
        case_number=case.case_number,
        application_id=case.application_id,
        student_name=case.student_name,
        issue_type=case.issue_type,
        priority=case.priority,
        status=case.status,
        student_data=case.student_data,
        authorized_data=case.authorized_data,
        possible_reasons=case.possible_reasons,
        resolution_notes=case.resolution_notes,
        created_at=case.created_at.strftime("%d %b %Y") if case.created_at else "28 Sept 2026"
    )

@router.post("/reviews/{case_id}/action")
def review_action(case_id: str, req: ReviewActionRequest, db: Session = Depends(get_db)):
    if case_id.isdigit():
        case = db.query(ReviewCase).filter(
            (ReviewCase.case_number == case_id) | (ReviewCase.id == int(case_id))
        ).first()
    else:
        case = db.query(ReviewCase).filter(ReviewCase.case_number == case_id).first()

    if not case:
        raise HTTPException(status_code=404, detail="Review case not found.")
    
    # Look up the student linked to this case's application (or fall back to first student)
    student = None
    if case.application_id:
        app_for_student = db.query(Application).filter(Application.id == case.application_id).first()
        if app_for_student:
            student = db.query(User).filter(User.id == app_for_student.student_id).first()
    if not student:
        student = db.query(User).filter(User.role == "student").first()

    if req.action == "approve":
        case.status = "Resolved"
        case.resolution_notes = req.notes or "Officer verified AISHE affiliation alias. Approved."

        if case.application_id:
            app = db.query(Application).filter(Application.id == case.application_id).first()
            if app:
                app.stage = "Application Verified"
                app.status = "Verified by MoTA Officer"
                app.deficiency_notes = None

        if student:
            notif = Notification(
                user_id=student.id,
                title="Verification Case Approved",
                message=f"Case #{case.case_number} has been approved by the MoTA Review Officer. Your application has moved to 'Application Verified'.",
                date="Today",
                is_read=False,
                type="success"
            )
            db.add(notif)

        message = "Verification Case Approved. Application status updated to Verified."

    elif req.action == "request_correction":
        case.status = "Under Review"
        case.resolution_notes = req.notes or "Correction requested by officer."

        if student:
            notif = Notification(
                user_id=student.id,
                title="Clarification Requested by Officer",
                message=f"Case #{case.case_number}: The officer requested clarification: {req.notes}",
                date="Today",
                is_read=False,
                type="action_required"
            )
            db.add(notif)

        message = "Correction requested. Student notified via dashboard."

    elif req.action == "reject":
        case.status = "Rejected"
        case.resolution_notes = req.notes or "Application rejected due to unverified documentation."

        if case.application_id:
            app = db.query(Application).filter(Application.id == case.application_id).first()
            if app:
                app.stage = "Rejected"
                app.status = "Rejected by Verification Officer"
                app.deficiency_notes = req.notes

        if student:
            notif = Notification(
                user_id=student.id,
                title="Application Rejected with Reason",
                message=f"Your application was not approved: {req.notes}",
                date="Today",
                is_read=False,
                type="warning"
            )
            db.add(notif)

        message = "Application rejected. Student notified."

    else:
        raise HTTPException(status_code=400, detail="Invalid review action.")

    db.commit()
    return {
        "success": True,
        "case_number": case.case_number,
        "new_status": case.status,
        "message": message
    }

@router.get("/unreached", response_model=List[UnreachedStudentResponse])
def get_unreached_students(db: Session = Depends(get_db)):
    students = db.query(UnreachedStudent).all()
    return students

@router.post("/unreached/outreach")
def trigger_outreach(req: OutreachRequest, db: Session = Depends(get_db)):
    count = db.query(UnreachedStudent).count() or 300
    return {
        "success": True,
        "message": f"Outreach SMS & Mobile Notifications dispatched to {count} identified students via CDAC Meghdoot Gateway (Demo / Mock)",
        "recipients_count": count,
        "campaign": req.campaign_name
    }

@router.get("/verification-layer")
def get_verification_layer_sources():
    sources = [
        {"name": "DigiLocker", "type": "Digital Documents Repository", "status": "connected", "badge": "🟢 Connected (Demo / Mock)", "latency": "140ms"},
        {"name": "AISHE", "type": "Higher Education Institutions Database", "status": "future", "badge": "🟡 Future Integration Layer", "latency": "Mocked"},
        {"name": "UDISE+", "type": "School Education Data (Classes 1-12)", "status": "future", "badge": "🟡 Future Integration Layer", "latency": "Mocked"},
        {"name": "APAAR", "type": "Academic Bank of Credits / One Nation One Student ID", "status": "future", "badge": "🟡 Future Integration Layer", "latency": "Mocked"},
        {"name": "UIDAI", "type": "Aadhaar e-KYC Identity Verification", "status": "future", "badge": "🟡 Future Integration Layer", "latency": "Mocked"},
        {"name": "State e-District", "type": "Revenue Portals (ST, Domicile, Income)", "status": "future", "badge": "🟡 Future Integration Layer", "latency": "Mocked"},
        {"name": "UGC-NTA", "type": "NET/JRF National Registry", "status": "future", "badge": "🟡 Future Integration Layer", "latency": "Mocked"}
    ]

    verification_entries = [
        {"dimension": "Identity Verification", "status": "verified", "badge": "✅ Verified (Demo / Mock)", "source": "UIDAI / DigiLocker"},
        {"dimension": "ST/PVTG Status", "status": "verified", "badge": "✅ Verified (Demo / Mock)", "source": "State e-District (Jharkhand)"},
        {"dimension": "Academic Records", "status": "pending", "badge": "⏳ Pending (Demo / Mock)", "source": "APAAR / ABC"},
        {"dimension": "Institution Details", "status": "verified", "badge": "✅ Verified (Demo / Mock)", "source": "AISHE Directory"},
        {"dimension": "NET/JRF Qualification", "status": "not_applicable", "badge": "⚪ Not Applicable", "source": "UGC-NTA"},
        {"dimension": "Disability Certificate", "status": "not_applicable", "badge": "⚪ Not Applicable", "source": "UDID Portal"},
        {"dimension": "Income Certificate", "status": "action_required", "badge": "⚠️ Action Required (Expired)", "source": "State Revenue Portal"},
        {"dimension": "Domicile Certificate", "status": "verified", "badge": "✅ Verified (Demo / Mock)", "source": "State e-District"}
    ]

    return {
        "sources": sources,
        "verification_entries": verification_entries
    }
