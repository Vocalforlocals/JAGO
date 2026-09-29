import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/document.dart';
import '../models/scheme.dart';
import '../models/application.dart';
import '../models/payment.dart';
import '../models/notification_item.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _language = 'en'; // 'en' | 'hi'
  bool _isLoading = false;

  StudentProfile _profile = StudentProfile.initialDemo();
  List<DocumentItem> _documents = DocumentItem.defaultWallet();
  List<SchemeEligibility> _eligibility = SchemeEligibility.defaultEligibility();
  ScholarshipApplication _application = ScholarshipApplication.demoApplication();
  bool _hasSubmittedApplication = false;
  List<PaymentRecord> _payments = PaymentRecord.defaultHistory();
  List<NotificationItem> _notifications = NotificationItem.defaultNotifications();
  List<ChatMessage> _chatMessages = ChatMessage.initialConversation();

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get language => _language;
  bool get isLoading => _isLoading;
  StudentProfile get profile => _profile;
  List<DocumentItem> get documents => _documents;
  List<SchemeEligibility> get eligibility => _eligibility;
  ScholarshipApplication get application => _application;
  bool get hasSubmittedApplication => _hasSubmittedApplication;
  List<PaymentRecord> get payments => _payments;
  List<NotificationItem> get notifications => _notifications;
  List<ChatMessage> get chatMessages => _chatMessages;

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  AppState() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final token = await ApiService.getToken();
      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
        await _loadStudentData();
      }
    } catch (e) {
      debugPrint('AppState init error: $e');
    }
  }

  Future<void> _loadStudentData() async {
    try {
      _profile = await ApiService.fetchProfile();
      _documents = await ApiService.fetchDocuments();
      _eligibility = await ApiService.checkEligibility();
      _payments = await ApiService.fetchPayments();
      _notifications = await ApiService.fetchNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('AppState _loadStudentData error: $e');
    }
  }

  Future<void> refreshAllData() async {
    _isLoading = true;
    notifyListeners();
    await _loadStudentData();
    _isLoading = false;
    notifyListeners();
  }


  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Future<bool> loginStudent({String? mobile, String? otp}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (mobile != null && otp != null) {
        final res = await ApiService.verifyOtp(mobile, otp);
        if (res['access_token'] != null) {
          _isLoggedIn = true;
          await _loadStudentData();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        final res = await ApiService.demoStudentLogin();
        if (res['access_token'] != null) {
          _isLoggedIn = true;
          await _loadStudentData();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('AppState loginStudent error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> registerStudent({
    required String fullName,
    required String mobile,
    required String aadhaar,
    required String tribe,
    required String domicile,
    required String institution,
    required String course,
    String? stCertificateNo,
  }) async {
    _isLoading = true;
    notifyListeners();

    final last4 = aadhaar.replaceAll(' ', '').length >= 4
        ? aadhaar.replaceAll(' ', '').substring(aadhaar.replaceAll(' ', '').length - 4)
        : '5678';
    final aadhaarMasked = 'XXXX-XXXX-$last4';

    // Call real backend register endpoint
    await ApiService.registerStudent(
      fullName: fullName,
      mobile: mobile,
      aadhaarMasked: aadhaarMasked,
      tribe: tribe,
      domicile: domicile,
      institution: institution,
      course: course,
      stCertificateNo: stCertificateNo,
    );

    _isLoggedIn = true;
    await _loadStudentData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _isLoggedIn = false;
    _profile = StudentProfile.initialDemo();
    _documents = DocumentItem.defaultWallet();
    _eligibility = SchemeEligibility.defaultEligibility();
    _application = ScholarshipApplication.demoApplication();
    _hasSubmittedApplication = false;
    _payments = PaymentRecord.defaultHistory();
    _notifications = NotificationItem.defaultNotifications();
    _chatMessages = ChatMessage.initialConversation();
    notifyListeners();
  }

  Future<void> updateIncomeCertificate({required String certNumber, required int amount}) async {
    _isLoading = true;
    notifyListeners();

    _profile = await ApiService.updateIncomeCertificate(
      certNumber: certNumber,
      annualIncome: amount,
    );

    // Refresh documents and notifications
    _documents = await ApiService.fetchDocuments();
    _notifications = await ApiService.fetchNotifications();

    _isLoading = false;
    notifyListeners();
  }

  Future<String> fetchAllFromDigiLocker() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.fetchAllFromDigiLocker();
    _documents = await ApiService.fetchDocuments();

    _isLoading = false;
    notifyListeners();
    return res['message'] ?? 'Documents updated from DigiLocker';
  }

  Future<String> uploadDocument(String docType, String title, String fileName) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.uploadDocument(docType, title, fileName);
    _documents = await ApiService.fetchDocuments();
    _profile = await ApiService.fetchProfile();

    _isLoading = false;
    notifyListeners();
    return res['message'] ?? 'Document uploaded successfully';
  }

  Future<void> runEligibilityCheck() async {
    _isLoading = true;
    notifyListeners();

    _eligibility = await ApiService.checkEligibility();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitApplication({
    required int schemeId,
    required String bankAccount,
    required String ifscCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.createApplication(
      schemeId: schemeId,
      bankAccount: bankAccount,
      ifscCode: ifscCode,
      declaration: true,
    );

    _hasSubmittedApplication = true;
    if (res['application_id'] != null) {
      _application = _application.copyWith(
        id: res['application_id'] is int ? res['application_id'] : 1,
        appNumber: res['app_number'] ?? _application.appNumber,
        submissionDate: res['submission_date'] ?? 'Today',
      );
    }

    _notifications = await ApiService.fetchNotifications();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> runVerificationWorkflow() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.runVerification(_application.id);

    _application.stage = 'Under Verification';
    _application.status = res['overall_status'] ?? 'Routed to Manual Review';

    _notifications = await ApiService.fetchNotifications();

    _isLoading = false;
    notifyListeners();
  }

  void markNotificationRead(int id) {
    for (var n in _notifications) {
      if (n.id == id) {
        n.isRead = true;
      }
    }
    ApiService.markNotificationRead(id);
    notifyListeners();
  }

  Future<void> sendChatMessage(String query) async {
    final now = TimeOfDay.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    _chatMessages.add(ChatMessage(
      sender: 'user',
      text: query,
      timestamp: timeStr,
    ));
    notifyListeners();

    final botRes = await ApiService.chatWithJago(query, language: _language);

    _chatMessages.add(ChatMessage(
      sender: 'bot',
      text: botRes['reply'] ?? '',
      timestamp: timeStr,
      options: (botRes['options'] as List?)?.map((e) => e.toString()).toList(),
    ));
    notifyListeners();
  }
}
