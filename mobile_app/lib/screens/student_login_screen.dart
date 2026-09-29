import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import 'dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StudentLoginScreen — Login + 3-Step Registration Wizard
// ─────────────────────────────────────────────────────────────────────────────

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({Key? key}) : super(key: key);

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Login, 1 = Register

  // ── Login ──────────────────────────────────────────────────────────────────
  final TextEditingController _mobileController =
      TextEditingController(text: '9876543210');
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;

  // ── Registration — 3-step state ────────────────────────────────────────────
  int _regStep = 0; // 0, 1, 2

  // Step 1 — Identity (Aadhaar eKYC)
  final TextEditingController _aadhaarCtrl =
      TextEditingController(text: '2345 6789 9012');
  final TextEditingController _regMobileCtrl =
      TextEditingController(text: '9812345678');
  final TextEditingController _regOtpCtrl = TextEditingController();
  final TextEditingController _nameCtrl =
      TextEditingController(text: 'Pooja Soren');
  final TextEditingController _dobCtrl =
      TextEditingController(text: '14 May 2001');
  bool _aadhaarOtpSent = false;
  bool _identityVerified = false;

  // Step 2 — ST Status
  int _stVerifyMethod = 0; // 0=DigiLocker 1=eDistrict 2=QR
  String _selectedState = 'Jharkhand';
  final TextEditingController _certNoCtrl =
      TextEditingController(text: 'JH/ST/2024/00123');
  final TextEditingController _tribeCtrl =
      TextEditingController(text: 'Santhal');
  bool _stVerified = false;
  String _stVerifiedLabel = '';

  // Step 3 — Academic Profile
  final TextEditingController _collegeCtrl =
      TextEditingController(text: 'National Institute of Technology, Jamshedpur');
  final TextEditingController _courseCtrl =
      TextEditingController(text: 'B.Tech (Computer Science)');
  String _academicYear = '2nd Year (2024–25)';

  // Shared
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal',
  ];

  final List<String> _academicYears = [
    '1st Year (2024–25)',
    '2nd Year (2024–25)',
    '3rd Year (2024–25)',
    '4th Year (2024–25)',
    'Postgraduate – 1st Year',
    'Postgraduate – 2nd Year',
  ];

  // ── Login handlers ─────────────────────────────────────────────────────────

  void _handleSendOtp() {
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit mobile number.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() { _isLoading = false; _otpSent = true; _otpController.text = '123456'; });
      _showSnack('OTP 123456 sent to +91 $mobile (Sandbox)');
    });
  }

  void _handleVerifyOtp() async {
    if (_otpController.text.trim() != '123456') {
      setState(() => _errorMessage = 'Invalid OTP. Demo OTP is 123456.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loginStudent();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToDashboard();
  }

  void _handleDemoLogin() async {
    setState(() => _isLoading = true);
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loginStudent();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToDashboard();
  }

  // ── Registration — Step 1: Aadhaar eKYC ────────────────────────────────────

  void _sendAadhaarOtp() {
    final aadhaar = _aadhaarCtrl.text.replaceAll(' ', '');
    if (aadhaar.length != 12 || int.tryParse(aadhaar) == null) {
      setState(() => _errorMessage = 'Enter a valid 12-digit Aadhaar number.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _aadhaarOtpSent = true;
        _regOtpCtrl.text = '123456';
      });
      _showSnack('Aadhaar OTP sent to Aadhaar-linked mobile (Demo: 123456)');
    });
  }

  void _verifyAadhaarOtp() {
    if (_regOtpCtrl.text.trim() != '123456') {
      setState(() => _errorMessage = 'Invalid OTP. Enter 123456 for sandbox.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _identityVerified = true;
      });
      _showSnack('✅ Identity verified via UIDAI eKYC');
    });
  }

  void _proceedToStep2() {
    if (!_identityVerified) {
      setState(() => _errorMessage = 'Please complete Aadhaar eKYC verification first.');
      return;
    }
    setState(() { _regStep = 1; _errorMessage = null; });
  }

  // ── Registration — Step 2: ST Status ───────────────────────────────────────

  void _verifyViaDiGiLocker() {
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _stVerified = true;
        _stVerifiedLabel = 'DigiLocker — $_selectedState Government';
        _certNoCtrl.text = '$_selectedState/ST/2024/00123'.toUpperCase().replaceAll(' ', '-');
        _tribeCtrl.text = _tribeCtrl.text.isEmpty ? 'Santhal' : _tribeCtrl.text;
      });
      _showSnack('✅ ST Certificate fetched from DigiLocker');
    });
  }

  void _verifyViaEDistrict() {
    if (_certNoCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your ST Certificate number.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _stVerified = true;
        _stVerifiedLabel = 'State e-District API — $_selectedState';
      });
      _showSnack('✅ ST Certificate verified via State e-District API');
    });
  }

  void _verifyViaQR() {
    setState(() { _isLoading = true; _errorMessage = null; });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _stVerified = true;
        _stVerifiedLabel = 'QR Code Scan — Government Registry';
        _certNoCtrl.text = 'QR-$_selectedState-ST-2024-00456'.toUpperCase().replaceAll(' ', '-');
        _tribeCtrl.text = _tribeCtrl.text.isEmpty ? 'Munda' : _tribeCtrl.text;
      });
      _showSnack('✅ ST Certificate QR code scanned & verified');
    });
  }

  void _proceedToStep3() {
    if (!_stVerified) {
      setState(() => _errorMessage = 'Please verify your ST Certificate first.');
      return;
    }
    setState(() { _regStep = 2; _errorMessage = null; });
  }

  // ── Registration — Step 3: Submit ──────────────────────────────────────────

  void _submitRegistration() async {
    if (_collegeCtrl.text.trim().isEmpty || _courseCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please fill institution and course details.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final appState = Provider.of<AppState>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 900));
    await appState.registerStudent(
      fullName: _nameCtrl.text.trim(),
      mobile: _regMobileCtrl.text.trim(),
      aadhaar: _aadhaarCtrl.text.trim(),
      tribe: _tribeCtrl.text.trim(),
      domicile: _selectedState,
      institution: _collegeCtrl.text.trim(),
      course: _courseCtrl.text.trim(),
      stCertificateNo: _certNoCtrl.text.trim().isNotEmpty ? _certNoCtrl.text.trim() : null,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnack('🎉 JAGO Profile created! Pending Institute Nodal Officer approval.');
    _goToDashboard();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.primaryGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTabSwitcher(),
                const SizedBox(height: 16),
                if (_errorMessage != null) _buildErrorBanner(),
                if (_selectedTab == 0) _buildLoginView(),
                if (_selectedTab == 1) _buildRegistrationWizard(),
                const SizedBox(height: 24),
                _buildOfficerNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Tricolor stripe
        Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFFFF671F), // Saffron
              Color(0xFFFFFFFF), // White
              Color(0xFF046A38), // Green
            ]),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/images/logo.png',
            width: 68,
            height: 68,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'JAGO Portal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'National Scholarship Portal • Student Login',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500, letterSpacing: 0.2),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _tabItem('🔑  Existing Login', 0),
          _tabItem('📝  New Registration', 1),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int idx) {
    final isActive = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = idx;
          _errorMessage = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.statusErrorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: AppTheme.statusErrorText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(_errorMessage!,
              style: const TextStyle(fontSize: 11, color: AppTheme.statusErrorText)),
        ),
      ]),
    );
  }

  // ── Login View ─────────────────────────────────────────────────────────────

  Widget _buildLoginView() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _labeledField(
            label: 'Aadhaar-Linked Mobile Number',
            child: TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: _inputDeco(
                hint: 'Enter 10-digit mobile',
                prefix: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text('+91', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_otpSent)
            _fullWidthBtn('Send Verification OTP', _isLoading ? null : _handleSendOtp)
          else ...[
            _labeledField(
              label: 'One-Time Password',
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _inputDeco(hint: '6-digit OTP', counterText: ''),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Sandbox OTP: 123456',
                  style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _fullWidthBtn('Verify & Open Dashboard', _isLoading ? null : _handleVerifyOtp),
          ],
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('OR', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleDemoLogin,
              icon: const Icon(Icons.bolt, color: AppTheme.accentSaffron, size: 18),
              label: const Text('Instant Demo — Rahul Kumar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textDark,
                side: const BorderSide(color: AppTheme.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Registration Wizard ────────────────────────────────────────────────────

  Widget _buildRegistrationWizard() {
    return Column(children: [
      _buildStepProgress(),
      const SizedBox(height: 16),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _regStep == 0
            ? _buildStep1()
            : _regStep == 1
                ? _buildStep2()
                : _buildStep3(),
      ),
    ]);
  }

  Widget _buildStepProgress() {
    const steps = ['Identity\neKYC', 'ST\nStatus', 'Academic\nProfile'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final passed = _regStep > i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: passed ? AppTheme.primaryGreen : Colors.grey.shade300,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone = _regStep > stepIdx;
        final isActive = _regStep == stepIdx;
        return Column(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppTheme.primaryGreen
                  : isActive
                      ? AppTheme.accentSaffron
                      : Colors.grey.shade200,
              border: Border.all(
                color: isActive ? AppTheme.accentSaffron : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${stepIdx + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            steps[stepIdx],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.accentSaffron : Colors.grey.shade500,
            ),
          ),
        ]);
      }),
    );
  }

  // ── Step 1: Aadhaar eKYC Identity ─────────────────────────────────────────

  Widget _buildStep1() {
    return Card(
      key: const ValueKey('step1'),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stepTitle(Icons.fingerprint, 'Step 1 — Identity Verification', 'Aadhaar eKYC (UIDAI Sandbox)'),
          const SizedBox(height: 18),

          _labeledField(
            label: 'Aadhaar Number (12 digits)',
            child: TextField(
              controller: _aadhaarCtrl,
              keyboardType: TextInputType.number,
              enabled: !_identityVerified,
              decoration: _inputDeco(
                hint: 'xxxx xxxx xxxx',
                icon: Icons.credit_card_outlined,
              ),
            ),
          ),
          const SizedBox(height: 10),

          _labeledField(
            label: 'Aadhaar-Linked Mobile Number',
            child: TextField(
              controller: _regMobileCtrl,
              keyboardType: TextInputType.phone,
              enabled: !_identityVerified,
              decoration: _inputDeco(
                hint: '10-digit mobile',
                icon: Icons.phone_android_outlined,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (!_identityVerified) ...[
            if (!_aadhaarOtpSent)
              _fullWidthBtn(
                '📲  Send Aadhaar OTP',
                _isLoading ? null : _sendAadhaarOtp,
                color: const Color(0xFF1565C0),
              )
            else ...[
              _labeledField(
                label: 'Enter OTP received on Aadhaar-linked mobile',
                child: TextField(
                  controller: _regOtpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: _inputDeco(hint: '6-digit OTP', counterText: ''),
                ),
              ),
              const SizedBox(height: 4),
              const Text('Sandbox OTP: 123456',
                  style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _fullWidthBtn(
                '✅  Verify OTP & Confirm Identity',
                _isLoading ? null : _verifyAadhaarOtp,
                color: const Color(0xFF1565C0),
              ),
            ],
          ] else ...[
            _verifiedBadge('✅ Identity Confirmed via UIDAI eKYC', subtitle: 'Aadhaar: ${_aadhaarCtrl.text}'),
            const SizedBox(height: 14),
            _labeledField(
              label: 'Full Name (auto-fetched from UIDAI)',
              child: TextField(controller: _nameCtrl, decoration: _inputDeco(hint: 'Full legal name')),
            ),
            const SizedBox(height: 10),
            _labeledField(
              label: 'Date of Birth (auto-fetched)',
              child: TextField(controller: _dobCtrl, decoration: _inputDeco(hint: 'DD Mon YYYY')),
            ),
            const SizedBox(height: 16),
            _fullWidthBtn('Continue to ST Verification →', _proceedToStep2),
          ],
        ]),
      ),
    );
  }

  // ── Step 2: ST Certificate ─────────────────────────────────────────────────

  Widget _buildStep2() {
    return Card(
      key: const ValueKey('step2'),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stepTitle(Icons.verified_outlined, 'Step 2 — ST Certificate', 'Choose one verification method'),
          const SizedBox(height: 16),

          // State dropdown
          _labeledField(
            label: 'State of Domicile',
            child: DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: _inputDeco(hint: 'Select State', icon: Icons.location_on_outlined),
              items: _indianStates
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: _stVerified ? null : (v) => setState(() => _selectedState = v!),
            ),
          ),
          const SizedBox(height: 14),

          if (!_stVerified) ...[
            // Method picker
            const Text('Verification Method',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            _methodToggle(),
            const SizedBox(height: 14),

            // Per-method UI
            if (_stVerifyMethod == 0) ...[
              _infoBox('📲 Fetch your ST Certificate directly from your DigiLocker account. '
                  'Your certificate will be auto-imported if already stored.'),
              const SizedBox(height: 12),
              _fullWidthBtn(
                '📲  Fetch via DigiLocker',
                _isLoading ? null : _verifyViaDiGiLocker,
                color: const Color(0xFF0F62FE),
              ),
            ],

            if (_stVerifyMethod == 1) ...[
              const SizedBox(height: 4),
              _labeledField(
                label: 'ST Certificate Number',
                child: TextField(
                  controller: _certNoCtrl,
                  decoration: _inputDeco(hint: 'e.g. JH/ST/2024/00123', icon: Icons.numbers_outlined),
                ),
              ),
              const SizedBox(height: 12),
              _fullWidthBtn(
                '🏛️  Verify via State e-District API',
                _isLoading ? null : _verifyViaEDistrict,
                color: const Color(0xFF5D4037),
              ),
            ],

            if (_stVerifyMethod == 2) ...[
              _infoBox('📷 Scan the QR code printed on your physical ST Certificate issued by '
                  'the State Government.'),
              const SizedBox(height: 12),
              _fullWidthBtn(
                '📷  Scan ST Certificate QR Code',
                _isLoading ? null : _verifyViaQR,
                color: const Color(0xFF2E7D32),
              ),
            ],
          ] else ...[
            _verifiedBadge('✅ ST Certificate Verified', subtitle: _stVerifiedLabel),
            const SizedBox(height: 14),
            _labeledField(
              label: 'ST Certificate Number',
              child: TextField(controller: _certNoCtrl, decoration: _inputDeco(hint: 'Certificate number')),
            ),
            const SizedBox(height: 10),
            _labeledField(
              label: 'Tribe / Community',
              child: TextField(controller: _tribeCtrl, decoration: _inputDeco(hint: 'e.g. Santhal, Munda, Gondi')),
            ),
            const SizedBox(height: 16),
            _fullWidthBtn('Continue to Academic Profile →', _proceedToStep3),
          ],
        ]),
      ),
    );
  }

  Widget _methodToggle() {
    const labels = ['📲 DigiLocker', '🏛️ e-District', '📷 QR Code'];
    return Row(
      children: List.generate(labels.length, (i) {
        final isActive = _stVerifyMethod == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _stVerifyMethod = i),
            child: Container(
              margin: EdgeInsets.only(right: i < labels.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryGreen : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? AppTheme.primaryGreen : Colors.grey.shade300,
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Step 3: Academic Profile ───────────────────────────────────────────────

  Widget _buildStep3() {
    return Card(
      key: const ValueKey('step3'),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stepTitle(Icons.school_outlined, 'Step 3 — Academic Profile', 'Your institution details'),
          const SizedBox(height: 18),

          // Summary chip of verified info
          _summaryRow(),
          const SizedBox(height: 16),

          _labeledField(
            label: 'College / Institution Name',
            child: TextField(
              controller: _collegeCtrl,
              decoration: _inputDeco(hint: 'e.g. NIT Jamshedpur', icon: Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 10),

          _labeledField(
            label: 'Course / Degree',
            child: TextField(
              controller: _courseCtrl,
              decoration: _inputDeco(hint: 'e.g. B.Tech Computer Science', icon: Icons.menu_book_outlined),
            ),
          ),
          const SizedBox(height: 10),

          _labeledField(
            label: 'Academic Year',
            child: DropdownButtonFormField<String>(
              value: _academicYear,
              decoration: _inputDeco(hint: 'Select year', icon: Icons.calendar_today_outlined),
              items: _academicYears
                  .map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (v) => setState(() => _academicYear = v!),
            ),
          ),
          const SizedBox(height: 16),

          _approvalFlowInfo(),
          const SizedBox(height: 18),

          _fullWidthBtn(
            '🎉  Create My JAGO Profile',
            _isLoading ? null : _submitRegistration,
          ),
        ]),
      ),
    );
  }

  Widget _summaryRow() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(children: [
        _summaryItem('👤 Name', _nameCtrl.text),
        _summaryItem('🆔 Aadhaar', '${_aadhaarCtrl.text.substring(0, 4)} xxxx xxxx'),
        _summaryItem('🏡 Domicile', _selectedState),
        _summaryItem('🌿 Tribe', _tribeCtrl.text),
      ]),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.textDark))),
      ]),
    );
  }

  Widget _approvalFlowInfo() {
    const steps = [
      ('📤', 'Submit Application', 'You'),
      ('🏫', 'Institute Nodal', '2-3 days'),
      ('🏙️', 'District Officer', '3-5 days'),
      ('🏛️', 'State Nodal', '5-7 days'),
      ('✅', 'Central Final Approval', '7-10 days'),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Final Approval Flow',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF795548))),
        const SizedBox(height: 8),
        ...steps.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Text(s.$1, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.$2,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                Text(s.$3,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.brown.shade400,
                        fontStyle: FontStyle.italic)),
              ]),
            )),
      ]),
    );
  }

  // ── Shared Helpers ─────────────────────────────────────────────────────────

  Widget _stepTitle(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryGreen),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          Text(subtitle,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
        ]),
      ),
    ]);
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      const SizedBox(height: 5),
      child,
    ]);
  }

  InputDecoration _inputDeco({
    required String hint,
    Widget? prefix,
    IconData? icon,
    String? counterText,
  }) {
    return InputDecoration(
      prefixIcon: prefix ??
          (icon != null
              ? Icon(icon, size: 18, color: Colors.grey.shade500)
              : null),
      hintText: hint,
      counterText: counterText,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.cardBorder),
      ),
      isDense: true,
    );
  }

  Widget _fullWidthBtn(String label, VoidCallback? onPressed,
      {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: onPressed == null && _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _verifiedBadge(String text, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF046A38).withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF046A38).withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.verified, color: Color(0xFF046A38), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF046A38))),
            if (subtitle != null)
              Text(subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
          ]),
        ),
      ]),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 11, color: Colors.blue.shade800, height: 1.4)),
    );
  }

  Widget _buildOfficerNote() {
    return Column(children: const [
      Text('Are you a scholarship officer?',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      SizedBox(height: 2),
      Text('Access Admin Portal on Desktop',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
    ]);
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _aadhaarCtrl.dispose();
    _regMobileCtrl.dispose();
    _regOtpCtrl.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _certNoCtrl.dispose();
    _tribeCtrl.dispose();
    _collegeCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }
}
