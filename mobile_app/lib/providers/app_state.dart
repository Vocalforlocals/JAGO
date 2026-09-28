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
    // Initial fetch from backend if running
    try {
      _profile = await ApiService.fetchProfile();
      _documents = await ApiService.fetchDocuments();
      _eligibility = await ApiService.checkEligibility();
      _payments = await ApiService.fetchPayments();
      _notifications = await ApiService.fetchNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('AppState init error: $e');
    }
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Future<void> loginStudent() async {
    _isLoading = true;
    notifyListeners();
    await ApiService.demoStudentLogin();
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
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

    // Update local profile for immediate UI display
    _profile = _profile.copyWith(
      fullName: fullName,
      studentId: 'ST2026-${(100 + (DateTime.now().millisecondsSinceEpoch % 899))}',
      aadhaarMasked: aadhaarMasked,
      domicile: domicile,
      institution: institution,
      course: course,
      completionPercentage: 72,
    );

    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
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

    // Update document in list
    for (var doc in _documents) {
      if (doc.docType == 'income_cert') {
        doc.status = 'verified';
      }
    }

    _notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Income Certificate Revalidated',
        message: 'Your Income Certificate for FY 2026-27 was successfully verified via State Revenue repository and OCR cross-check.',
        date: 'Just now',
        isRead: false,
        type: 'success',
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<String> fetchAllFromDigiLocker() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.fetchAllFromDigiLocker();

    for (var doc in _documents) {
      if (doc.docType != 'disability_cert') {
        if (doc.docType != 'income_cert' || _profile.incomeStatus == 'verified') {
          doc.status = 'verified';
        }
      }
    }

    _isLoading = false;
    notifyListeners();
    return res['message'] ?? 'Fetched 5 documents from DigiLocker (Mock)';
  }

  Future<String> uploadDocument(String docType, String title, String fileName) async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiService.uploadDocument(docType, title, fileName);

    for (var doc in _documents) {
      if (doc.docType == docType) {
        doc.status = 'verified';
      }
    }

    if (docType == 'income_cert') {
      _profile = _profile.copyWith(
        incomeStatus: 'verified',
        completionPercentage: 100,
      );
    }

    _isLoading = false;
    notifyListeners();
    return res['message'] ?? 'Document uploaded and verified (Mock)';
  }

  Future<void> runEligibilityCheck() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));
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

    await ApiService.createApplication(
      schemeId: schemeId,
      bankAccount: bankAccount,
      ifscCode: ifscCode,
      declaration: true,
    );

    _hasSubmittedApplication = true;
    _application = ScholarshipApplication.demoApplication();

    _notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Application Submitted successfully',
        message: 'Your Post-Matric Scholarship application (ST-2026-001245) has been registered and scheduled for verification.',
        date: 'Today',
        isRead: false,
        type: 'info',
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> runVerificationWorkflow() async {
    _isLoading = true;
    notifyListeners();

    await ApiService.runVerification(_application.id);

    _application.stage = 'Under Government Verification';
    _application.status = 'Routed to MoTA Manual Review';

    _notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Application Moved to Government Verification',
        message: 'Institution alias discrepancy detected. Your application has been routed to the MoTA Manual Review Queue (Case #VR-10245).',
        date: 'Today',
        isRead: false,
        type: 'info',
      ),
    );

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
