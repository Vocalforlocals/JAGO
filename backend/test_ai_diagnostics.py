"""
Unit test suite for Part 4: JAGO AI Assistant Multilingual & Document Diagnostics
Tests:
- Step-by-step renewal roadmap for expired certificates
- Hindi & English localized responses
- Document diagnosis metadata & vault redirection options
"""

from app.services.jago_ai import JagoAIService

class DummyStudentProfile:
    def __init__(self, income_status="expired"):
        self.student_id = "STU2026-JH-001"
        self.full_name = "Rahul Kumar"
        self.aadhaar_masked = "XXXX-XXXX-4819"
        self.dob = "15/07/2004"
        self.domicile = "Jharkhand"
        self.st_certificate_no = "JH-ST-2022-88412"
        self.family_income = 180000
        self.income_status = income_status
        self.income_cert_date = "10/05/2023"
        self.institution = "ABC Institute of Technology"
        self.course = "B.Tech Computer Science"

def test_document_diagnostic_english():
    profile = DummyStudentProfile(income_status="expired")
    res = JagoAIService.generate_response(
        query="My income certificate is expired, how to renew it?",
        student_profile=profile,
        language="en"
    )
    assert "4-Step Renewal Pathway" in res["text"] or "State Portal" in res["text"]
    assert "DigiLocker" in res["text"]
    assert "Open DigiLocker Vault" in res["options"] or "Update Income Certificate" in res["options"]
    print("PASS: English Document Diagnostic Explainer (4-Step Renewal Roadmap)")

def test_document_diagnostic_hindi():
    profile = DummyStudentProfile(income_status="expired")
    res = JagoAIService.generate_response(
        query="आय प्रमाण पत्र कैसे नवीनीकरण करें?",
        student_profile=profile,
        language="hi"
    )
    assert "नवीनीकरण" in res["text"]
    assert "डिजीलॉकर" in res["text"]
    print("PASS: Hindi Document Diagnostic Explainer (4-Step Renewal Pathway in Hindi)")

def test_voice_prompt_query():
    profile = DummyStudentProfile(income_status="verified")
    res = JagoAIService.generate_response(
        query="meri scholarship ka status kya hai",
        student_profile=profile,
        language="hi"
    )
    assert len(res["text"]) > 20
    assert len(res["options"]) > 0
    print("PASS: Voice prompt query handling (Hinglish/Hindi query resolution)")

if __name__ == "__main__":
    print("\n--- Running Part 4 JAGO AI Diagnostics Tests ---")
    test_document_diagnostic_english()
    test_document_diagnostic_hindi()
    test_voice_prompt_query()
    print("--- ALL PART 4 AI DIAGNOSTICS TESTS PASSED ---\n")
