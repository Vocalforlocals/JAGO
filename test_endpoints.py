import urllib.request
import urllib.error
import json
import sys

BASE_URL = "http://127.0.0.1:8000/api"

endpoints = [
    ("GET", "/health", None),
    ("GET", "/student/profile", None),
    ("GET", "/student/documents", None),
    ("GET", "/student/eligibility", None),
    ("GET", "/student/applications", None),
    ("GET", "/student/payments", None),
    ("GET", "/student/notifications", None),
    ("POST", "/student/jago-chat", {"message": "What is the status of my application?", "language": "en"}),
    ("GET", "/admin/stats", None),
    ("GET", "/admin/reviews", None),
    ("GET", "/admin/reviews/VR-10245", None),
    ("GET", "/admin/unreached", None),
    ("GET", "/admin/verification-layer", None),
    ("POST", "/auth/officer-login", {"email": "officer@mota.gov.in", "password": "demo123"}),
    ("POST", "/auth/register", {
        "full_name": "Birsa Munda",
        "mobile": "9812345678",
        "aadhaar_masked": "XXXX-XXXX-9012",
        "tribe": "Munda",
        "domicile": "Jharkhand",
        "institution": "Birsa Institute of Technology",
        "course": "B.Tech Mining",
        "st_certificate_no": "JH/ST/2024/99123"
    }),
]

passed = 0
failed = 0

for method, path, body in endpoints:
    url = BASE_URL + path
    headers = {"Content-Type": "application/json"} if body else {}
    data = json.dumps(body).encode("utf-8") if body else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=5) as res:
            res_data = json.loads(res.read().decode("utf-8"))
            print(f"PASS [{method}] {path} -> {res.status}")
            passed += 1
    except Exception as e:
        print(f"FAIL [{method}] {path} -> {e}")
        failed += 1

print(f"\nSummary: {passed} passed, {failed} failed.")
if failed > 0:
    sys.exit(1)
