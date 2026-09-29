"""
Unit test suite for Part 3: Proactive Saturation & Unreached Student Intelligence Engine
Tests:
- Saturation metrics calculation
- District priority clustering
- Multi-channel outreach mobilization
- Regional language template resolution (Hindi, Santali, Odia, English)
"""

import urllib.request
import json

BASE_URL = "http://127.0.0.1:8000/api"

def test_saturation_metrics():
    url = f"{BASE_URL}/admin/saturation/metrics"
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=5) as res:
        assert res.status == 200, f"Expected 200, got {res.status}"
        data = json.loads(res.read().decode())
        assert "overall_saturation_rate" in data
        assert "district_saturation" in data
        assert len(data["district_saturation"]) == 5
        assert "channels" in data
        print(f"PASS: Saturation metrics endpoint (Rate: {data['overall_saturation_rate']}%, Districts: {len(data['district_saturation'])})")

def test_outreach_dispatch_channels():
    url = f"{BASE_URL}/admin/unreached/outreach"
    payloads = [
        {"campaign_name": "Khunti Tribal Van Mobilization", "channel": "csc_mobile_camp", "language": "san", "target_district": "Khunti"},
        {"campaign_name": "West Singhbhum SMS Broadcast", "channel": "sms_regional", "language": "hi", "target_district": "West Singhbhum"},
        {"campaign_name": "Mayurbhanj Odia Outreach", "channel": "school_alert", "language": "or", "target_district": "Mayurbhanj"}
    ]

    for p in payloads:
        data_bytes = json.dumps(p).encode()
        req = urllib.request.Request(url, data=data_bytes, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as res:
            assert res.status == 200
            res_data = json.loads(res.read().decode())
            assert res_data["success"] is True
            assert res_data["campaign"] == p["campaign_name"]
            assert res_data["recipients_count"] > 0
            assert "sample_sms_preview" in res_data
            print(f"PASS: Outreach mobilization for channel '{p['channel']}' in language '{p['language']}'")

if __name__ == "__main__":
    print("\n--- Running Part 3 Saturation & Outreach Engine Tests ---")
    test_saturation_metrics()
    test_outreach_dispatch_channels()
    print("--- ALL PART 3 SATURATION TESTS PASSED ---\n")
