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

@router.post("/verify-otp", response_model=Token)
def verify_otp(req: OTPVerifyRequest, db: Session = Depends(get_db)):
    if req.otp != DEMO_OTP and req.otp != "123456":
        raise HTTPException(status_code=400, detail="Invalid OTP. For demonstration, use '123456'.")
    
    # Locate or create student
    user = db.query(User).filter(User.role == "student").first()
    if not user:
        user = User(
            username="rahul_kumar",
            mobile=req.mobile,
            email="rahul.st@example.com",
            role="student",
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
        "full_name": "Rahul Kumar"
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

    access_token = create_access_token(data={"sub": new_user.username, "role": new_user.role, "user_id": new_user.id})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": new_user.id,
        "role": new_user.role,
        "username": new_user.username,
        "full_name": req.full_name
    }

