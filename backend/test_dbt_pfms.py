"""
Unit test suite for Part 6: Transparent DBT & PFMS Settlement Orchestration
Tests:
- /api/student/payments with PFMS settlement details in history
- /api/student/payments/receipt/{id} digital sanction receipts
- 422/404 validation on non-integer receipt ID
"""

import urllib.request
import urllib.error
import json

BASE_URL = "http://127.0.0.1:8000/api"

def test_payments_and_receipt():
    # 1. Login as student to get JWT token
    login_data = json.dumps({"mobile": "9876543210", "otp": "123456"}).encode("utf-8")
    login_req = urllib.request.Request(
        f"{BASE_URL}/auth/verify-otp",
        data=login_data,
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(login_req, timeout=5) as res:
        assert res.status == 200
        token_info = json.loads(res.read().decode())
        token = token_info["access_token"]
        print("PASS: Student authenticated successfully")

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    # 2. Test /student/payments
    payments_req = urllib.request.Request(f"{BASE_URL}/student/payments", headers=headers)
    with urllib.request.urlopen(payments_req, timeout=5) as res:
        assert res.status == 200
        payment_summary = json.loads(res.read().decode())
        assert "history" in payment_summary, "Missing history list in payment summary"
        history = payment_summary["history"]
        print(f"PASS: Fetched payment summary with {len(history)} payment records")
        assert len(history) > 0, "No payment history returned"
        
        first = history[0]
        assert "sanction_number" in first, "Missing sanction_number"
        assert "utr_number" in first, "Missing utr_number"
        assert "pfms_status" in first, "Missing pfms_status"
        print(f"PASS: First payment verified: ID={first['id']}, Sanction={first['sanction_number']}, PFMS={first['pfms_status']}, UTR={first['utr_number']}")

    # 3. Test /student/payments/receipt/{id}
    receipt_req = urllib.request.Request(f"{BASE_URL}/student/payments/receipt/{first['id']}", headers=headers)
    with urllib.request.urlopen(receipt_req, timeout=5) as res:
        assert res.status == 200
        receipt = json.loads(res.read().decode())
        assert "sanction_number" in receipt
        assert "utr_number" in receipt
        assert "pfms_status" in receipt
        assert "digital_stamp" in receipt
        assert "aadhaar_seeding_status" in receipt
        print(f"PASS: Sanction Receipt verified for ID {first['id']}: Receipt={receipt['receipt_number']}, Stamp='{receipt['digital_stamp'][:40]}...'")

    # 4. Test invalid receipt ID type validation (string returns 422)
    bad_req = urllib.request.Request(f"{BASE_URL}/student/payments/receipt/invalid-id", headers=headers)
    try:
        urllib.request.urlopen(bad_req, timeout=5)
        assert False, "Expected HTTPError 422"
    except urllib.error.HTTPError as e:
        assert e.code == 422
        print("PASS: 422 validation correctly handled for non-integer receipt ID")

    print("\nALL DBT & PFMS ENDPOINTS VERIFIED 100% SUCCESSFULLY!")

if __name__ == "__main__":
    test_payments_and_receipt()
