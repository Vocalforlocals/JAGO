from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt
from passlib.context import CryptContext

from ..database import get_db
from ..models import User, StudentProfile
from ..schemas import OTPRequest, OTPVerifyRequest, OfficerLoginRequest, Token, RegisterRequest
from ..config import SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES, DEMO_OTP

router = APIRouter(prefix="/api/auth", tags=["Authentication"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@router.post("/send-otp")
def send_otp(req: OTPRequest):
    mobile = req.mobile.strip()
    if len(mobile.replace("+91", "").replace(" ", "").replace("-", "")) < 10:
        raise HTTPException(status_code=400, detail="Invalid mobile number. Please enter a valid 10-digit number.")
    return {
        "success": True,
        "message": f"OTP successfully dispatched to {mobile} (Demo / Mock)",
        "demo_otp": DEMO_OTP
    }

def init_student_defaults(db: Session, user_id: int, full_name: str, state: str = "Jharkhand", st_cert_no: str = None, aadhaar_masked: str = None):
    """Seed initial wallet documents and welcome alert for new student accounts."""
    existing_docs = db.query(Document).filter(Document.user_id == user_id).count()
    if existing_docs == 0:
        docs = [
            Document(
                user_id=user_id,
                doc_type="st_cert",
                title="ST Certificate",
                status="verified",
                source="DigiLocker / State e-District",
                issue_date="12/08/2023",
                remarks=f"Certificate {st_cert_no or 'JH/ST/2024/00123'} verified."
            ),
            Document(
                user_id=user_id,
                doc_type="income_cert",
                title="Income Certificate",
                status="expired",
                source="State e-District",
                issue_date="15/03/2023",
                expiry_date="31/03/2024",
                remarks="Validity expired (>12 months). Revalidation recommended."
            ),
            Document(
                user_id=user_id,
                doc_type="domicile_cert",
                title="Domicile Certificate",
                status="verified",
                source="DigiLocker",
                issue_date="10/05/2023",
                remarks=f"Resident of {state}."
            ),
            Document(
                user_id=user_id,
                doc_type="marksheet",
                title="Academic Marksheet",
                status="verified",
                source="DigiLocker / APAAR",
                issue_date="20/06/2026",
                remarks="Higher Secondary record verified."
            ),
            Document(
                user_id=user_id,
                doc_type="bonafide_cert",
                title="Bonafide Certificate",
                status="verified",
                source="Institution Portal / AISHE",
                issue_date="05/08/2026",
                remarks="Regular full-time enrollment."
            ),
            Document(
                user_id=user_id,
                doc_type="identity_doc",
                title="Identity Document (Aadhaar)",
                status="verified",
                source="UIDAI eKYC",
                issue_date="01/01/2021",
                remarks=f"Aadhaar {aadhaar_masked or 'XXXX-XXXX-1234'} verified."
            ),
        ]
        db.add_all(docs)

    existing_notifs = db.query(Notification).filter(Notification.user_id == user_id).count()
    if existing_notifs == 0:
        welcome_notif = Notification(
            user_id=user_id,
            title="Welcome to JAGO",
            message=f"Welcome {full_name}! Your student profile has been initialized. Complete your documentation to apply for pre-approved scholarships.",
            date="Today",
            is_read=False,
            type="info"
        )
        db.add(welcome_notif)
    db.commit()


@router.post("/verify-otp", response_model=Token)
def verify_otp(req: OTPVerifyRequest, db: Session = Depends(get_db)):
    if req.otp != DEMO_OTP and req.otp != "123456":
        raise HTTPException(status_code=400, detail="Invalid OTP. For demonstration, use '123456'.")

    mobile_clean = req.mobile.strip().replace("+91", "").replace(" ", "").replace("-", "")

    # Check for demo student mobile
    if mobile_clean == "9876543210":
        user = db.query(User).filter(User.username == "rahul_kumar").first()
        if not user:
            user = db.query(User).filter(User.role == "student").first()
    else:
        user = db.query(User).filter(User.mobile == mobile_clean, User.role == "student").first()

    # If user not found, create new user and basic profile
    if not user:
        import random
        username = f"student_{mobile_clean}"
        user = User(
            username=username,
            mobile=mobile_clean,
            email=f"{username}@example.com",
            role="student",
            is_active=True
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        last4 = mobile_clean[-4:] if len(mobile_clean) >= 4 else "5678"
        aadhaar_masked = f"XXXX-XXXX-{last4}"
        student_id = f"ST2026-{random.randint(100, 999)}"
        profile = StudentProfile(
            user_id=user.id,
            student_id=student_id,
            full_name=f"Student {last4}",
            aadhaar_masked=aadhaar_masked,
            identity_status="verified",
            st_certificate_no=f"JH/ST/2024/{random.randint(10000, 99999)}",
            st_status="verified",
            pvtg_status="Not Applicable",
            institution="National Institute of Technology, Jamshedpur",
            course="B.Tech (Computer Science)",
            academic_year="2026-27",
            academic_record_status="verified",
            institution_status="verified",
            family_income=180000,
            income_status="expired",
            income_cert_date="15/03/2023",
            domicile="Jharkhand",
            domicile_status="verified",
            disability_status="Not Applicable",
            net_jrf_status="Not Applicable",
            completion_percentage=72
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)

        init_student_defaults(
            db=db,
            user_id=user.id,
            full_name=profile.full_name,
            state="Jharkhand",
            st_cert_no=profile.st_certificate_no,
            aadhaar_masked=aadhaar_masked
        )

    full_name = user.profile.full_name if (user.profile and user.profile.full_name) else "Student"
    access_token = create_access_token(data={"sub": user.username, "role": user.role, "user_id": user.id})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id,
        "role": user.role,
        "username": user.username,
        "full_name": full_name
    }

@router.post("/demo-student-login", response_model=Token)
def demo_student_login(db: Session = Depends(get_db)):
    user = db.query(User).filter(User.role == "student").first()
    if not user:
        raise HTTPException(status_code=404, detail="Demo student profile not initialized.")
    access_token = create_access_token(data={"sub": user.username, "role": user.role, "user_id": user.id})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.id,
        "role": user.role,
        "username": user.username,
        "full_name": "Rahul Kumar"
    }

@router.post("/officer-login", response_model=Token)
def officer_login(req: OfficerLoginRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    if email == "officer@mota.gov.in" and req.password == "demo123":
        user = db.query(User).filter(User.role == "officer").first()
        if not user:
            user = User(
                username="mota_officer",
                email="officer@mota.gov.in",
                role="officer",
                is_active=True
            )
            db.add(user)
            db.commit()
            db.refresh(user)

        access_token = create_access_token(data={"sub": user.username, "role": user.role, "user_id": user.id})
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": user.id,
            "role": user.role,
            "username": user.username,
            "full_name": "Dr. Ananya Sharma (MoTA Review Officer)"
        }
    
    raise HTTPException(status_code=401, detail="Invalid officer credentials. Use officer@mota.gov.in / demo123")

@router.post("/register", response_model=Token)
def register_student(req: RegisterRequest, db: Session = Depends(get_db)):
    """
    3-Step Registration Endpoint — Called after Aadhaar eKYC + ST certificate verification.
    Creates a new User and StudentProfile in the database.
    """
    # Sanitize mobile for username
    mobile_clean = req.mobile.strip().replace("+91", "").replace(" ", "").replace("-", "")
    username = f"student_{mobile_clean}"

    # Check if user already exists
    existing = db.query(User).filter(User.mobile == mobile_clean).first()
    if existing:
        # Return existing user token
        access_token = create_access_token(data={"sub": existing.username, "role": existing.role, "user_id": existing.id})
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": existing.id,
            "role": existing.role,
            "username": existing.username,
            "full_name": req.full_name
        }

    # Create new User
    new_user = User(
        username=username,
        mobile=mobile_clean,
        role="student",
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Create StudentProfile
    import random
    student_id = f"ST2026-{random.randint(100, 999)}"
    profile = StudentProfile(
        user_id=new_user.id,
        student_id=student_id,
        full_name=req.full_name,
        aadhaar_masked=req.aadhaar_masked,
        identity_status="verified",
        st_certificate_no=req.st_certificate_no or f"{req.domicile[:2].upper()}/ST/2024/00001",
        st_status="verified",
        pvtg_status="Not Applicable",
        institution=req.institution,
        course=req.course,
        academic_year="2026-27",
        academic_record_status="pending",
        institution_status="pending",
        family_income=180000,
        income_status="pending",
        income_cert_date="",
        domicile=req.domicile,
        domicile_status="verified",
        disability_status="Not Applicable",
        net_jrf_status="Not Applicable",
        completion_percentage=72
    )
    db.add(profile)
    db.commit()

    init_student_defaults(
        db=db,
        user_id=new_user.id,
        full_name=req.full_name,
        state=req.domicile,
        st_cert_no=profile.st_certificate_no,
        aadhaar_masked=req.aadhaar_masked
    )

    access_token = create_access_token(data={"sub": new_user.username, "role": new_user.role, "user_id": new_user.id})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": new_user.id,
        "role": new_user.role,
        "username": new_user.username,
        "full_name": req.full_name
    }

