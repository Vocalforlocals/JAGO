"""
Mock Government Integrations Layer for JAGO
All simulated integrations clearly labeled with 'Demo / Mock'
Connected data sources:
- DigiLocker
- AISHE (All India Survey on Higher Education)
- UDISE+ (Unified District Information System for Education Plus)
- APAAR (Automated Permanent Academic Account Registry)
- UIDAI (Unique Identification Authority of India)
- State e-District (Jharkhand / Bihar / Odisha Revenue Portals)
- UGC-NTA (National Testing Agency)
- NSP / SFMP / NOS
"""

import asyncio
from typing import Dict, Any
from .fuzzy_matcher import FuzzyMatcher

class MockGovIntegrations:
    @staticmethod
    async def verify_uidai_identity(aadhaar_number: str, name: str, dob: str) -> Dict[str, Any]:
        await asyncio.sleep(0.3)
        return {
            "source": "UIDAI Aadhaar Vault (Demo / Mock)",
            "status": "verified",
            "matched_name": name,
            "matched_dob": dob,
            "ekyc_auth_code": "UIDAI-AUTH-2026-99321",
            "message": "Aadhaar e-KYC authenticated successfully."
        }

    @staticmethod
    async def verify_state_caste_certificate(cert_no: str, state: str) -> Dict[str, Any]:
        await asyncio.sleep(0.3)
        return {
            "source": f"State e-District Portal ({state}) (Demo / Mock)",
            "status": "verified",
            "community": "Scheduled Tribe (ST)",
            "sub_tribe": "Santhal / Oraon",
            "cert_validity": "Permanent / Lifetime",
            "message": "ST Certificate verified against State Revenue digital repository."
        }

    @staticmethod
    async def verify_apaar_academic(student_id: str, institution: str) -> Dict[str, Any]:
        await asyncio.sleep(0.3)
        return {
            "source": "APAAR / DigiLocker Academic Bank of Credits (Demo / Mock)",
            "status": "verified",
            "current_enrollment": "Enrolled - Regular 2026-27",
            "aggregate_gpa": "8.4 / 10",
            "message": "Academic marksheet and semester progression verified."
        }

    @staticmethod
    async def verify_aishe_institution(institution_name: str) -> Dict[str, Any]:
        await asyncio.sleep(0.4)
        source_official_name = "ABC Institute of Engineering"
        match_info = FuzzyMatcher.match_institution(institution_name, source_official_name)
        
        return {
            "source": "AISHE - Higher Education Database (Demo / Mock)",
            "status": match_info["status"],
            "student_record": institution_name,
            "source_record": source_official_name,
            "aishe_code": "C-49210",
            "similarity_percentage": match_info["similarity_percentage"],
            "tier": match_info["tier"],
            "message": f"AISHE alignment evaluated ({match_info['similarity_percentage']}% similarity). {match_info['action_desc']}",
            "match_details": match_info
        }

    @staticmethod
    async def verify_state_income_certificate(cert_date: str, annual_income: int, state: str) -> Dict[str, Any]:
        await asyncio.sleep(0.3)
        # If certificate date is older than 1 year (e.g. 2023), flag as expired
        if "2023" in cert_date or "expired" in cert_date.lower():
            return {
                "source": f"State Revenue / e-District ({state}) (Demo / Mock)",
                "status": "action_required",
                "income_amount": annual_income,
                "validity": "Expired",
                "message": "Financial year income certificate validity exceeded 12 months. Fresh revalidation certificate required."
            }
        return {
            "source": f"State Revenue / e-District ({state}) (Demo / Mock)",
            "status": "verified",
            "income_amount": annual_income,
            "validity": "Valid for FY 2026-27",
            "message": "Income certificate verified within permissible scheme ceiling."
        }

    @staticmethod
    async def verify_domicile(state: str) -> Dict[str, Any]:
        await asyncio.sleep(0.2)
        return {
            "source": f"State e-District ({state}) (Demo / Mock)",
            "status": "verified",
            "domicile_state": state,
            "message": "Resident domicile certificate validated via digital public service portal."
        }

    @staticmethod
    async def verify_net_jrf(candidate_id: str) -> Dict[str, Any]:
        await asyncio.sleep(0.2)
        return {
            "source": "UGC-NTA National Eligibility Registry (Demo / Mock)",
            "status": "not_applicable",
            "message": "Only required for PhD/M.Phil National Fellowship (NFST) schemes."
        }

    @staticmethod
    async def verify_disability(student_id: str) -> Dict[str, Any]:
        await asyncio.sleep(0.2)
        return {
            "source": "UDID Portal - Ministry of Social Justice (Demo / Mock)",
            "status": "not_applicable",
            "message": "Candidate does not claim Divyangjan quota."
        }

    @staticmethod
    async def fetch_digilocker_documents(student_id: str):
        await asyncio.sleep(0.5)
        return [
            {"doc_type": "st_cert", "title": "ST Certificate", "status": "verified", "source": "DigiLocker / State e-District (Mock)"},
            {"doc_type": "income_cert", "title": "Income Certificate", "status": "expired", "source": "DigiLocker / State e-District (Mock)"},
            {"doc_type": "domicile_cert", "title": "Domicile Certificate", "status": "verified", "source": "DigiLocker (Mock)"},
            {"doc_type": "marksheet", "title": "Academic Marksheet", "status": "verified", "source": "DigiLocker / APAAR (Mock)"},
            {"doc_type": "bonafide_cert", "title": "Bonafide Certificate", "status": "verified", "source": "DigiLocker / AISHE (Mock)"},
            {"doc_type": "disability_cert", "title": "Disability Certificate", "status": "not_applicable", "source": "UDID (Mock)"},
            {"doc_type": "identity_doc", "title": "Identity Document (Aadhaar)", "status": "verified", "source": "DigiLocker / UIDAI (Mock)"},
            {"doc_type": "institution_cert", "title": "Institution Certificate", "status": "verified", "source": "DigiLocker / AISHE (Mock)"},
        ]
