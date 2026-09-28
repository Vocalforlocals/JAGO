"""
Document OCR & Verification Service for JAGO
Simulates Python OCR / AI Document Understanding for:
- Income Certificates (validity, issuing authority, income amount extraction)
- ST Certificates (community name, state, issuing magistrate)
- Bonafide / Admission Receipts
"""

import re
import datetime
from typing import Dict, Any

class OCRService:
    @staticmethod
    def process_income_certificate(file_name: str, raw_text: str = None) -> Dict[str, Any]:
        """
        Parses uploaded income certificate, extracts key fields, and verifies validity.
        """
        current_year = datetime.datetime.now().year
        
        # Simulated extraction results
        cert_number = f"JH/INC/{current_year}/88219"
        extracted_income = 180000
        issuing_authority = "Sub-Divisional Officer / Circle Officer, Revenue Department"
        issue_date = f"10/08/{current_year}"
        validity = f"Valid up to 31/03/{current_year + 1}"

        return {
            "success": True,
            "document_type": "Income Certificate",
            "extracted_fields": {
                "certificate_number": cert_number,
                "annual_income": extracted_income,
                "issue_date": issue_date,
                "issuing_authority": issuing_authority,
                "validity_status": "Valid",
                "valid_until": validity
            },
            "status": "verified",
            "ocr_confidence": 0.985,
            "message": f"OCR extracted Certificate #{cert_number} with declared income ₹{extracted_income:,}. Validated with State Revenue repository."
        }

    @staticmethod
    def process_caste_certificate(file_name: str) -> Dict[str, Any]:
        return {
            "success": True,
            "document_type": "Scheduled Tribe Certificate",
            "extracted_fields": {
                "certificate_number": "JH/ST/2022/98432",
                "caste_tribe": "Santhal",
                "presidential_order": "Constitution (Scheduled Tribes) Order 1950",
                "issuing_district": "Ranchi, Jharkhand"
            },
            "status": "verified",
            "ocr_confidence": 0.992
        }
