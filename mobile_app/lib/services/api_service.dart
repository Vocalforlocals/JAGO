import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/profile.dart';
import '../models/document.dart';
import '../models/scheme.dart';
import '../models/payment.dart';
import '../models/notification_item.dart';

class ApiService {
  // Configured for FastAPI backend (supports localhost and mobile phone over LAN)
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      return 'http://$host:8000/api';
    }
    return 'http://10.177.59.42:8000/api';
  }

  // --- Auth ---
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService sendOtp error: $e');
    }
    return {
      'success': true,
      'message': 'OTP dispatched (Demo / Mock)',
      'demo_otp': '123456',
    };
  }

  static Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile, 'otp': otp}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService verifyOtp error: $e');
    }
    return {
      'access_token': 'mock_student_jwt_token',
      'role': 'student',
      'username': 'rahul_kumar',
      'full_name': 'Rahul Kumar',
    };
  }

  static Future<Map<String, dynamic>> demoStudentLogin() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/auth/demo-student-login'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService demoStudentLogin error: $e');
    }
    return {
      'access_token': 'mock_student_jwt_token',
      'role': 'student',
      'username': 'rahul_kumar',
      'full_name': 'Rahul Kumar',
    };
  }

  static Future<Map<String, dynamic>> registerStudent({
    required String fullName,
    required String mobile,
    required String aadhaarMasked,
    required String tribe,
    required String domicile,
    required String institution,
    required String course,
    String? stCertificateNo,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'mobile': mobile,
          'aadhaar_masked': aadhaarMasked,
          'tribe': tribe,
          'domicile': domicile,
          'institution': institution,
          'course': course,
          'st_certificate_no': stCertificateNo,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService registerStudent error: $e');
    }
    // Fallback mock
    return {
      'access_token': 'mock_new_student_token',
      'role': 'student',
      'username': 'student_new',
      'full_name': fullName,
    };
  }

  // --- Profile ---
  static Future<StudentProfile> fetchProfile() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/student/profile'));
      if (res.statusCode == 200) {
        return StudentProfile.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('ApiService fetchProfile error: $e');
    }
    return StudentProfile.initialDemo();
  }

  static Future<StudentProfile> updateIncomeCertificate({
    required String certNumber,
    required int annualIncome,
    String? issueDate,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/student/profile/update-income'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'certificate_number': certNumber,
          'annual_income': annualIncome,
          'issuing_authority': 'Sub-Divisional Officer, Revenue Dept',
          'issue_date': issueDate ?? '10/08/2026',
        }),
      );
      if (res.statusCode == 200) {
        return StudentProfile.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint('ApiService updateIncomeCertificate error: $e');
    }
    return StudentProfile.initialDemo().copyWith(
      incomeStatus: 'verified',
      incomeCertDate: issueDate ?? '10/08/2026',
      completionPercentage: 100,
    );
  }

  // --- Documents ---
  static Future<List<DocumentItem>> fetchDocuments() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/student/documents'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((d) => DocumentItem.fromJson(d)).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchDocuments error: $e');
    }
    return DocumentItem.defaultWallet();
  }

  static Future<Map<String, dynamic>> fetchAllFromDigiLocker() async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/student/documents/fetch-all-digilocker'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService fetchAllFromDigiLocker error: $e');
    }
    return {
      'success': true,
      'message': 'Fetched 5 documents from DigiLocker (Demo / Mock)',
      'count': 5,
    };
  }

  static Future<Map<String, dynamic>> uploadDocument(String docType, String title, String fileName) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/student/documents/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doc_type': docType,
          'title': title,
          'file_name': fileName,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService uploadDocument error: $e');
    }
    return {
      'success': true,
      'message': 'Document uploaded and verified (Mock)',
      'status': 'verified',
    };
  }

  // --- Schemes & Eligibility ---
  static Future<List<SchemeEligibility>> checkEligibility() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/student/eligibility'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        final List schemes = data['schemes'] ?? [];
        return schemes.map((s) => SchemeEligibility.fromJson(s)).toList();
      }
    } catch (e) {
      debugPrint('ApiService checkEligibility error: $e');
    }
    return SchemeEligibility.defaultEligibility();
  }

  // --- Applications ---
  static Future<Map<String, dynamic>> createApplication({
    required int schemeId,
    required String bankAccount,
    required String ifscCode,
    required bool declaration,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/student/applications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'scheme_id': schemeId,
          'bank_account': bankAccount,
          'ifsc_code': ifscCode,
          'declaration': declaration,
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService createApplication error: $e');
    }
    return {
      'success': true,
      'application_id': 1,
      'app_number': 'ST-2026-001245',
      'submission_date': '28 Sept 2026',
    };
  }

  static Future<Map<String, dynamic>> runVerification(int applicationId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/student/applications/$applicationId/run-verification'),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService runVerification error: $e');
    }
    return {
      'application_id': applicationId,
      'overall_status': 'Routed to Manual Review',
      'routed_to_review': true,
      'mismatch_detail': {
        'title': 'Institution Information Mismatch',
        'message': 'Your profile and institutional record contain different institution names.',
        'student_record': 'ABC Institute of Technology',
        'source_record': 'ABC Institute of Engineering',
      },
    };
  }

  // --- Payments & Notifications ---
  static Future<List<PaymentRecord>> fetchPayments() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/student/payments'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        final List history = data['history'] ?? [];
        return history.map((p) => PaymentRecord.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchPayments error: $e');
    }
    return PaymentRecord.defaultHistory();
  }

  static Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/student/notifications'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((n) => NotificationItem.fromJson(n)).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchNotifications error: $e');
    }
    return NotificationItem.defaultNotifications();
  }

  static Future<void> markNotificationRead(int notifId) async {
    try {
      await http.post(Uri.parse('$baseUrl/student/notifications/$notifId/read'));
    } catch (e) {
      debugPrint('ApiService markNotificationRead error: $e');
    }
  }

  // --- JAGO Chatbot ---
  static Future<Map<String, dynamic>> chatWithJago(String query, {String language = 'en'}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/student/jago-chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': query, 'language': language}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService chatWithJago error: $e');
    }

    final isHindi = (language == 'hi');
    if (query.toLowerCase().contains('status')) {
      return {
        'reply': isHindi
            ? 'आपके आवेदन संख्या ST-2026-001245 (Post-Matric) की स्थिति: सरकारी अधिकारी द्वारा समीक्षा जारी है।'
            : 'Your application ST-2026-001245 is currently Under Government Verification. It has been routed to the Manual Review queue for institutional alias verification.',
        'options': ['Check Payments', 'Required Documents', 'Help'],
      };
    }
    return {
      'reply': isHindi
          ? 'मैं आधिकारिक छात्रवृत्ति नियमों और आपकी प्रोफ़ाइल स्थिति के आधार पर सहायता करता हूँ।'
          : 'I am JAGO, your scholarship assistant. How can I help you today?',
      'options': ['Check Status', 'Check Eligibility', 'Required Documents', 'Payment Status', 'How to Apply'],
    };
  }
}
