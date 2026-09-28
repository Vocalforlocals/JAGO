"""
Verification Orchestrator for JAGO
Executes multi-level verification pipeline across all authorized government sources.
Handles rule-based matching, detects discrepancies, and seamlessly routes to manual review queue.
"""

import asyncio
from typing import Dict, Any, List
from .mock_gov_integrations import MockGovIntegrations

class VerificationOrchestrator:
    @staticmethod
    async def run_full_verification(application_id: int, student_profile: Any) -> Dict[str, Any]:
        """
        Runs parallel verification checks across all 8 dimensions:
        1. Identity (UIDAI)
        2. ST Status (State e-District)
        3. Academic Record (APAAR)
        4. Institution Check (AISHE) - intentional mismatch
        5. Income Certificate (State Revenue)
        6. Domicile (State e-District)
        7. Scheme Required Documents (DigiLocker)
        8. NET / JRF Qualification (UGC-NTA)
        """

        # Run parallel checks
        results = await asyncio.gather(
            MockGovIntegrations.verify_uidai_identity(student_profile.aadhaar_masked, student_profile.full_name, student_profile.dob),
            MockGovIntegrations.verify_state_caste_certificate(student_profile.st_certificate_no, student_profile.domicile),
            MockGovIntegrations.verify_apaar_academic(student_profile.student_id, student_profile.institution),
            MockGovIntegrations.verify_aishe_institution(student_profile.institution),
            MockGovIntegrations.verify_state_income_certificate(
                student_profile.income_cert_date if student_profile.income_status == "expired" else "10/08/2026",
                student_profile.family_income,
                student_profile.domicile
            ),
            MockGovIntegrations.verify_domicile(student_profile.domicile),
            MockGovIntegrations.verify_net_jrf(student_profile.student_id),
            MockGovIntegrations.verify_disability(student_profile.student_id)
        )

        uidai_res, st_res, academic_res, inst_res, income_res, dom_res, net_res, pwd_res = results

        steps: List[Dict[str, Any]] = [
            {
                "check_name": "Identity Verification",
                "status": uidai_res["status"],
                "source": uidai_res["source"],
                "message": uidai_res["message"],
                "student_record": f"Aadhaar {student_profile.aadhaar_masked} ({student_profile.full_name})",
                "source_record": "UIDAI Central Identity Repository Match"
            },
            {
                "check_name": "ST Status Verification",
                "status": st_res["status"],
                "source": st_res["source"],
                "message": st_res["message"],
                "student_record": f"Certificate #{student_profile.st_certificate_no}",
                "source_record": "State Revenue Department Validated"
            },
            {
                "check_name": "Academic Record Verification",
                "status": academic_res["status"],
                "source": academic_res["source"],
                "message": academic_res["message"],
                "student_record": f"{student_profile.course} - Year {student_profile.academic_year}",
                "source_record": academic_res["current_enrollment"]
            },
            {
                "check_name": "Institution Verification",
                "status": inst_res["status"],  # "mismatch"
                "source": inst_res["source"],
                "message": inst_res["message"],
                "student_record": student_profile.institution,
                "source_record": inst_res.get("source_record", "ABC Institute of Engineering")
            },
            {
                "check_name": "Income Certificate Verification",
                "status": "verified" if student_profile.income_status == "verified" else income_res["status"],
                "source": income_res["source"],
                "message": "Income verified against state revenue database." if student_profile.income_status == "verified" else income_res["message"],
                "student_record": f"Annual Income ₹{student_profile.family_income:,}",
                "source_record": "State Revenue Repository"
            },
            {
                "check_name": "Domicile Verification",
                "status": dom_res["status"],
                "source": dom_res["source"],
                "message": dom_res["message"],
                "student_record": student_profile.domicile,
                "source_record": f"Resident Record - {student_profile.domicile}"
            },
            {
                "check_name": "Scheme Documents Check",
                "status": "verified",
                "source": "DigiLocker Certified Repository (Demo / Mock)",
                "message": "All required scheme documents fetched and verified via DigiLocker.",
                "student_record": "4 Certificates available",
                "source_record": "DigiLocker URI Token Verified"
            },
            {
                "check_name": "NET / JRF Qualification",
                "status": net_res["status"],
                "source": net_res["source"],
                "message": net_res["message"],
                "student_record": "Not Applicable",
                "source_record": "N/A"
            }
        ]

        # Determine overall verification status and routing
        has_mismatch = any(step["status"] == "mismatch" for step in steps)
        has_action_required = any(step["status"] == "action_required" for step in steps)

        if has_mismatch:
            overall_status = "Routed to Manual Review"
            routed_to_review = True
            mismatch_detail = {
                "issue_type": "Institution Information Mismatch",
                "title": "Institution Information Mismatch",
                "message": "Your profile and the institutional record contain different institution names. Your application has NOT been automatically rejected.",
                "student_record": student_profile.institution,
                "source_record": "ABC Institute of Engineering",
                "possible_reasons": [
                    "Student profile may use informal or abbreviated campus name",
                    "Institution AISHE registration might use the parent trust name",
                    "Supporting bonafide or affiliation document will resolve the mismatch"
                ]
            }
        else:
            overall_status = "Verified"
            routed_to_review = False
            mismatch_detail = None

        return {
            "application_id": application_id,
            "overall_status": overall_status,
            "routed_to_review": routed_to_review,
            "mismatch_detail": mismatch_detail,
            "steps": steps
        }
