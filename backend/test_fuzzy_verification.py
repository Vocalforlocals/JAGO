"""
Unit test suite for Part 2: Fuzzy Mismatch Engine & Verification Pipeline
Tests:
- Levenshtein distance calculations
- Token set similarity & abbreviation expansions
- Tolerance tiers and zero-rejection policy enforcement
- Verification orchestrator discrepancy payload generation
"""

import asyncio
import sys
from app.services.fuzzy_matcher import FuzzyMatcher
from app.services.verification_orchestrator import VerificationOrchestrator

class DummyStudentProfile:
    def __init__(self):
        self.student_id = "STU2026-JH-001"
        self.full_name = "Rahul Kumar"
        self.aadhaar_masked = "XXXX-XXXX-4819"
        self.dob = "15/07/2004"
        self.domicile = "Jharkhand"
        self.st_certificate_no = "JH-ST-2022-88412"
        self.family_income = 180000
        self.income_status = "verified"
        self.income_cert_date = "15/06/2026"
        self.institution = "ABC Institute of Technology"
        self.course = "B.Tech Computer Science & Engineering"
        self.academic_year = "3rd Year"

def test_fuzzy_matcher_abbreviations():
    # Test abbreviation expansions
    exp = FuzzyMatcher.expand_abbreviations("BIT Sindri")
    assert "birsa institute of technology" in exp, f"Failed expansion: {exp}"
    print("PASS: Abbreviation expansion (BIT -> Birsa Institute of Technology)")

def test_fuzzy_matcher_identical():
    # Test identical match
    res = FuzzyMatcher.match_institution("Indian Institute of Technology Delhi", "Indian Institute of Technology Delhi")
    assert res["similarity_percentage"] == 100
    assert res["status"] == "verified"
    assert res["requires_review"] is False
    assert res["auto_rejected"] is False
    print("PASS: Exact match institution validation (100% similarity)")

def test_fuzzy_matcher_tolerance_tier():
    # Test acceptable tolerance tier (e.g. Technology vs Engineering suffix)
    res = FuzzyMatcher.match_institution("ABC Institute of Technology", "ABC Institute of Engineering")
    assert 50 <= res["similarity_percentage"] <= 85
    assert res["status"] == "mismatch"
    assert res["requires_review"] is True
    assert res["auto_rejected"] is False
    print(f"PASS: Tolerance variance routing ({res['similarity_percentage']}% similarity, zero rejection)")

def test_fuzzy_name_matching():
    # Test student name matching across registry
    res = FuzzyMatcher.match_student_name("Rahul Kumar", "Rahul Kumar Santhal")
    assert res["auto_rejected"] is False
    print(f"PASS: Student name tolerance matching ({res['similarity_percentage']}%)")

def test_verification_orchestrator():
    profile = DummyStudentProfile()
    result = asyncio.run(VerificationOrchestrator.run_full_verification(application_id=1, student_profile=profile))

    assert result["application_id"] == 1
    assert result["routed_to_review"] is True
    assert result["overall_status"] == "Routed to Manual Review"
    assert result["mismatch_detail"] is not None
    assert result["mismatch_detail"]["auto_rejected"] is False
    assert len(result["steps"]) == 8
    print("PASS: 8-stage Verification Orchestrator execution with zero-rejection routing")

if __name__ == "__main__":
    print("\n--- Running Part 2 Fuzzy Mismatch Engine Tests ---")
    test_fuzzy_matcher_abbreviations()
    test_fuzzy_matcher_identical()
    test_fuzzy_matcher_tolerance_tier()
    test_fuzzy_name_matching()
    test_verification_orchestrator()
    print("--- ALL 5 FUZZY VERIFICATION TESTS PASSED ---\n")
