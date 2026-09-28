import datetime
from sqlalchemy.orm import Session
from .database import engine, Base, SessionLocal
from .models import (
    User, StudentProfile, Document, Scheme, Application,
    ReviewCase, Payment, Notification, UnreachedStudent
)

def seed_database():
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()

    try:
        # Check if already seeded
        if db.query(User).filter(User.username == "rahul_kumar").first():
            return

        # 1. Users
        student_user = User(
            username="rahul_kumar",
            mobile="+91 98765 43210",
            email="rahul.kumar@example.com",
            role="student",
            is_active=True
        )
        officer_user = User(
            username="officer_mota",
            mobile="+91 91234 56789",
            email="officer@mota.gov.in",
            role="officer",
            is_active=True
        )
        db.add_all([student_user, officer_user])
        db.commit()
        db.refresh(student_user)
        db.refresh(officer_user)

        # 2. Student Profile (Rahul Kumar)
        profile = StudentProfile(
            user_id=student_user.id,
            student_id="ST2026-001",
            full_name="Rahul Kumar",
            dob="12/04/2005",
            aadhaar_masked="XXXX-XXXX-1234",
            identity_status="verified",
            st_certificate_no="JH/ST/2022/98432",
            st_status="verified",
            pvtg_status="Not Applicable",
            institution="ABC Institute of Technology",
            course="B.Tech (Computer Science & Engineering)",
            academic_year="2026-27",
            academic_record_status="verified",
            institution_status="verified",
            family_income=180000,
            income_status="expired",
            income_cert_date="15/03/2023",
            domicile="Bihar",
            domicile_status="verified",
            disability_status="Not Applicable",
            net_jrf_status="Not Applicable",
            completion_percentage=92
        )
        db.add(profile)

        # 3. 8 Documents in Wallet
        docs = [
            Document(
                user_id=student_user.id,
                doc_type="st_cert",
                title="ST Certificate",
                status="verified",
                source="DigiLocker / State e-District (Mock)",
                issue_date="12/08/2022",
                remarks="Permanent validity issued by Circle Officer, Ranchi."
            ),
            Document(
                user_id=student_user.id,
                doc_type="income_cert",
                title="Income Certificate",
                status="expired",
                source="State e-District (Mock)",
                issue_date="15/03/2023",
                expiry_date="31/03/2024",
                remarks="Validity expired (>12 months). Fresh certificate required."
            ),
            Document(
                user_id=student_user.id,
                doc_type="domicile_cert",
                title="Domicile Certificate",
                status="verified",
                source="DigiLocker (Mock)",
                issue_date="10/05/2022",
                remarks="Resident of Bihar."
            ),
            Document(
                user_id=student_user.id,
                doc_type="marksheet",
                title="Academic Marksheet",
                status="verified",
                source="DigiLocker / APAAR (Mock)",
                issue_date="20/06/2026",
                remarks="Class 12 / Higher Secondary score: 86.4%."
            ),
            Document(
                user_id=student_user.id,
                doc_type="bonafide_cert",
                title="Bonafide Certificate",
                status="verified",
                source="Institution Portal / AISHE (Mock)",
                issue_date="05/08/2026",
                remarks="Regular full-time B.Tech student enrollment."
            ),
            Document(
                user_id=student_user.id,
                doc_type="disability_cert",
                title="Disability Certificate",
                status="not_applicable",
                source="UDID (Mock)",
                remarks="Not Applicable."
            ),
            Document(
                user_id=student_user.id,
                doc_type="identity_doc",
                title="Identity Document (Aadhaar)",
                status="verified",
                source="DigiLocker / UIDAI (Mock)",
                issue_date="01/01/2020",
                remarks="Aadhaar authenticated via e-KYC."
            ),
            Document(
                user_id=student_user.id,
                doc_type="institution_cert",
                title="Institution Certificate",
                status="verified",
                source="AISHE Repository (Mock)",
                issue_date="01/07/2026",
                remarks="AISHE Code: C-49210."
            ),
        ]
        db.add_all(docs)

        # 4. 5 MoTA Schemes
        schemes = [
            Scheme(
                code="pre_matric",
                name="Pre-Matric Scholarship for ST Students",
                description="Financial support to ST students studying in Classes 9th and 10th to minimize dropouts.",
                level="Secondary (Class 9-10)",
                income_limit=250000,
                benefits="Day Scholars: ₹3,500/year; Hostellers: ₹7,000/year + disability grant.",
                portal="NSP",
                status="open"
            ),
            Scheme(
                code="post_matric",
                name="Post-Matric Scholarship for ST Students",
                description="Comprehensive scholarship covering full course fees and maintenance for post-matriculation courses.",
                level="Higher Education (UG/PG/Diploma)",
                income_limit=250000,
                benefits="100% compulsory non-refundable fees reimbursement + up to ₹13,500/year maintenance allowance.",
                portal="NSP",
                status="open"
            ),
            Scheme(
                code="top_class",
                name="Top Class Education Scheme for ST Students",
                description="Encourages meritorious ST students pursuing studies in notified premier institutes like IITs, NITs, IIMs, and NLUs.",
                level="Premier Institutes (Notified)",
                income_limit=600000,
                benefits="Full tuition fee + living allowance ₹3,000/month + books ₹5,000/year + computer grant ₹45,000.",
                portal="NSP",
                status="open"
            ),
            Scheme(
                code="nfst",
                name="National Fellowship for Higher Education of ST Students (NFST)",
                description="Fellowship for ST scholars pursuing full-time Ph.D. and M.Phil degrees in recognized universities.",
                level="Research (M.Phil / Ph.D.)",
                income_limit=600000,
                benefits="JRF: ₹31,000/month; SRF: ₹35,000/month + contingency grants up to ₹25,000/year.",
                portal="SFMP (Canara Bank)",
                status="open"
            ),
            Scheme(
                code="nos",
                name="National Overseas Scholarship for ST Candidates (NOS)",
                description="Financial assistance for meritorious ST students to pursue Master's, Ph.D., and Post-Doc programs abroad.",
                level="Overseas (Foreign Universities <= 500 Rank)",
                income_limit=800000,
                benefits="Full international tuition + annual maintenance allowance (USD 15,400 / GBP 9,900) + airfare.",
                portal="NOS Standalone Portal",
                status="open"
            )
        ]
        db.add_all(schemes)

        # 5. Initial Review Cases in Admin Queue
        cases = [
            ReviewCase(
                case_number="VR-10245",
                student_name="Rahul Kumar",
                issue_type="Institution mismatch",
                priority="High",
                status="Pending",
                student_data={"institution": "ABC Institute of Technology"},
                authorized_data={"institution": "ABC Institute of Engineering"},
                possible_reasons=[
                    "Student profile may be outdated or use informal campus name",
                    "Institution AISHE record may list parent trust or engineering campus",
                    "Supporting bonafide certificate can resolve the naming mismatch"
                ],
                resolution_notes="Pending officer check of AISHE Code C-49210."
            ),
            ReviewCase(
                case_number="VR-10246",
                student_name="Priya Kumari",
                issue_type="Income mismatch",
                priority="Medium",
                status="Under Review",
                student_data={"income": "₹1,40,000 (Declared)"},
                authorized_data={"income": "₹2,10,000 (State Revenue IT Return)"},
                possible_reasons=[
                    "Difference between gross agricultural income and total taxable income",
                    "Tehsildar certificate differs from automated IT data match"
                ],
                resolution_notes="Reviewing agricultural land certificate."
            ),
            ReviewCase(
                case_number="VR-10247",
                student_name="Amit Kumar",
                issue_type="Domicile mismatch",
                priority="Low",
                status="Resolved",
                student_data={"domicile": "Jharkhand (Bokaro)"},
                authorized_data={"domicile": "Jharkhand (Bokaro Steel City)"},
                possible_reasons=[
                    "Municipal boundary postal alias"
                ],
                resolution_notes="Officer verified Bokaro municipal record. Case resolved."
            )
        ]
        db.add_all(cases)

        # 6. Unreached Students
        unreached = [
            UnreachedStudent(
                name="Ravi Kumar",
                grade_class="Class 9",
                state="Bihar",
                district="Gaya",
                udise_apaar_id="UDISE-BR-2026-90112",
                status="Potentially Unreached",
                enrolled_benefit="None",
                contact_number="+91 94321 00001",
                source_portal="UDISE+ / APAAR Match"
            ),
            UnreachedStudent(
                name="Sunita Devi",
                grade_class="Class 11",
                state="Jharkhand",
                district="Khunti",
                udise_apaar_id="UDISE-JH-2026-88123",
                status="Potentially Unreached",
                enrolled_benefit="None",
                contact_number="+91 94321 00002",
                source_portal="UDISE+ / APAAR Match"
            ),
            UnreachedStudent(
                name="Mohan Oraon",
                grade_class="B.Tech Year 2",
                state="Odisha",
                district="Mayurbhanj",
                udise_apaar_id="APAAR-OD-2026-77341",
                status="Potentially Unreached",
                enrolled_benefit="None",
                contact_number="+91 94321 00003",
                source_portal="AISHE / APAAR Match"
            ),
            UnreachedStudent(
                name="Lakshmi Munda",
                grade_class="Class 10",
                state="Jharkhand",
                district="Ranchi",
                udise_apaar_id="UDISE-JH-2026-44219",
                status="Potentially Unreached",
                enrolled_benefit="None",
                contact_number="+91 94321 00004",
                source_portal="UDISE+ Match"
            ),
            UnreachedStudent(
                name="Arjun Santal",
                grade_class="M.Phil",
                state="West Bengal",
                district="Purulia",
                udise_apaar_id="APAAR-WB-2026-33901",
                status="Potentially Unreached",
                enrolled_benefit="None",
                contact_number="+91 94321 00005",
                source_portal="AISHE / OTR Match"
            )
        ]
        db.add_all(unreached)

        # 7. Initial Student Notifications
        notifications = [
            Notification(
                user_id=student_user.id,
                title="Application moved to Government Verification",
                message="Your Post-Matric Scholarship application has been routed to the MoTA Manual Review queue for institutional record alignment.",
                date="12 Sep 2026",
                is_read=False,
                type="info"
            ),
            Notification(
                user_id=student_user.id,
                title="Income Certificate requires attention",
                message="Your previously submitted income certificate validity has expired (>12 months). Please revalidate for current cycle.",
                date="12 Sep 2026",
                is_read=False,
                type="warning"
            ),
            Notification(
                user_id=student_user.id,
                title="Document Verification completed",
                message="Aadhaar, ST Certificate, and Academic Marksheet verified successfully via DigiLocker.",
                date="10 Aug 2026",
                is_read=True,
                type="success"
            ),
            Notification(
                user_id=student_user.id,
                title="College Verification completed",
                message="Bonafide enrollment verified by ABC Institute nodal desk.",
                date="05 Aug 2026",
                is_read=True,
                type="success"
            ),
            Notification(
                user_id=student_user.id,
                title="Application Submitted successfully",
                message="Your student profile and draft scholarship form have been registered on JAGO unified layer.",
                date="01 Aug 2026",
                is_read=True,
                type="info"
            )
        ]
        db.add_all(notifications)

        # 8. Demo Payment
        payment = Payment(
            student_id=student_user.id,
            scheme_name="Post-Matric Scholarship for ST Students",
            sanctioned_amount=18000,
            received_amount=9000,
            pending_amount=9000,
            installment="1st Installment",
            date="28 Sept 2026",
            status="Payment Credited",
            mode="DBT (Direct Benefit Transfer)",
            bank_account="****1234"
        )
        db.add(payment)

        db.commit()
        print("JAGO database seeded successfully with Rahul Kumar and MoTA demo records.")
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
