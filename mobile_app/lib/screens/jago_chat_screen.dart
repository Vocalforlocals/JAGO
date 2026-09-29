import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import 'documents_screen.dart';

class JagoChatScreen extends StatefulWidget {
  final bool isEmbedded;
  const JagoChatScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  State<JagoChatScreen> createState() => _JagoChatScreenState();
}

class _JagoChatScreenState extends State<JagoChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _speakingIndex;
  late AnimationController _waveController;

  final List<String> _quickChips = [
    'Check Status',
    'Check Eligibility',
    'Required Documents',
    'Payment Status',
    'How to Apply',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String query) async {
    if (query.trim().isEmpty) return;
    _textController.clear();

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.sendChatMessage(query);

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _speakMessage(int index, String text, bool isHindi) {
    setState(() {
      _speakingIndex = (_speakingIndex == index) ? null : index;
    });

    if (_speakingIndex != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isHindi ? 'ऑडियो प्लेबैक चालू है (हिंदी आवाज़)...' : 'Playing AI Voice Response (Audio narration)...',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );

      // Auto-reset speaking state after simulated audio duration
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted && _speakingIndex == index) {
          setState(() {
            _speakingIndex = null;
          });
        }
      });
    }
  }

  void _showVoiceInputDialog(bool isHindi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isHindi ? '🎙️ बोलकर पूछें (Voice Assistant)' : '🎙️ Speak Your Query (Voice Assistant)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isHindi 
                      ? 'हिंदी अथवा अंग्रेज़ी में अपनी छात्रवृत्ति संबंधी प्रश्न बोलें' 
                      : 'Speak in Hindi or English regarding scholarships, documents, or status',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Animated Pulsing Mic Wave
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Container(
                        width: 84 + (_waveController.value * 12),
                        height: 84 + (_waveController.value * 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen.withOpacity(0.12 + (_waveController.value * 0.08)),
                        ),
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGreen,
                            ),
                            child: const Icon(Icons.mic, color: Colors.white, size: 32),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHindi ? 'सुन रहा है... (Listening)' : 'Listening for audio query...',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 20),

                  // Quick Voice Prompts
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isHindi ? 'त्वरित आवाज़ विकल्प (Tap to simulate speech):' : 'Common Voice Queries (Tap to speak):',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildVoicePromptChip(
                        isHindi ? 'मेरी छात्रवृत्ति का स्टेटस क्या है?' : 'What is my scholarship status?',
                        ctx,
                      ),
                      _buildVoicePromptChip(
                        isHindi ? 'आय प्रमाण पत्र कैसे नवीनीकरण करें?' : 'How to renew expired income certificate?',
                        ctx,
                      ),
                      _buildVoicePromptChip(
                        isHindi ? 'मैं किस योजना के लिए पात्र हूँ?' : 'Am I eligible for Post-Matric scholarship?',
                        ctx,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVoicePromptChip(String text, BuildContext modalContext) {
    return InkWell(
      onTap: () {
        Navigator.pop(modalContext);
        _sendMessage(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_up_outlined, size: 14, color: AppTheme.primaryGreen),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final messages = appState.chatMessages;
    final isHindi = appState.language == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isEmbedded,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('JAGO AI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                  isHindi ? 'छात्रवृत्ति व दस्तावेज़ सहायक' : 'Scholarship & Document Assistant',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: AppTheme.primaryGreen, size: 20),
            tooltip: isHindi ? 'आवाज़ से पूछें' : 'Voice Assistant',
            onPressed: () => _showVoiceInputDialog(isHindi),
          ),
          TextButton(
            onPressed: () {
              appState.setLanguage(isHindi ? 'en' : 'hi');
            },
            child: Text(
              isHindi ? 'हिं ➔ EN' : 'EN ➔ हिं',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Notice Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isHindi 
                      ? 'आवाज़ एवं टेक्स्ट दोनों मोड सक्रिय। सटीक नियमों एवं प्रोफाइल पर आधारित उत्तर।' 
                      : 'Voice & Multimodal mode active. Answers grounded in official rules & your profile.',
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Quick Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _quickChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_quickChips[index]),
                  labelStyle: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.08),
                  side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () => _sendMessage(_quickChips[index]),
                );
              },
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isBot = msg.sender == 'bot';
                final isSpeakingThis = _speakingIndex == index;

                // Check if message discusses document diagnostics
                final hasDocDiagnosis = isBot && (
                  msg.text.contains('Income Certificate') || 
                  msg.text.contains('आय प्रमाण पत्र') ||
                  msg.text.contains('DigiLocker') ||
                  msg.text.contains('डिजीलॉकर')
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBot) ...[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBot ? Colors.white : AppTheme.primaryGreen,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isBot ? 0 : 12),
                              bottomRight: Radius.circular(isBot ? 12 : 0),
                            ),
                            border: Border.all(
                              color: isBot ? AppTheme.cardBorder : Colors.transparent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bot Message Header with Audio Speak Button
                              if (isBot)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('JAGO AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                                    InkWell(
                                      onTap: () => _speakMessage(index, msg.text, isHindi),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSpeakingThis ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isSpeakingThis ? Icons.graphic_eq : Icons.volume_up,
                                              size: 13,
                                              color: isSpeakingThis ? AppTheme.primaryGreen : Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              isSpeakingThis ? 'Speaking...' : 'Listen',
                                              style: TextStyle(
                                                fontSize: 9, 
                                                fontWeight: FontWeight.bold,
                                                color: isSpeakingThis ? AppTheme.primaryGreen : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (isBot) const SizedBox(height: 6),

                              Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isBot ? AppTheme.textDark : Colors.white,
                                  height: 1.4,
                                ),
                              ),

                              // Interactive Document Action Card
                              if (hasDocDiagnosis) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.folder_shared, size: 16, color: Colors.amber.shade800),
                                          const SizedBox(width: 6),
                                          Text(
                                            isHindi ? 'कार्रवाई: दस्तावेज़ वॉलेट में अद्यतन करें' : 'Action: Update in DigiLocker Vault',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isHindi 
                                          ? 'अपना नया आय प्रमाण पत्र सीधे डिजीलॉकर से सिंक करें अथवा डिजिटल कॉपी अपलोड करें।' 
                                          : 'Sync your renewed certificate directly via DigiLocker or view your verified vault.',
                                        style: TextStyle(fontSize: 10, color: Colors.amber.shade900),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                isHindi ? 'दस्तावेज़ वॉलेट खोलें' : 'Open DigiLocker Vault',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  msg.timestamp,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isBot ? Colors.grey.shade400 : Colors.white70,
                                  ),
                                ),
                              ),
                              if (isBot && msg.options != null && msg.options!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: msg.options!.map((opt) {
                                    return InkWell(
                                      onTap: () {
                                        if (opt == "Open DigiLocker Vault" || opt == "Open Document Wallet") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const DocumentsScreen()),
                                          );
                                        } else {
                                          _sendMessage(opt);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                                        ),
                                        child: Text(
                                          opt,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (!isBot) const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              children: [
                // Voice Input Microphone Button
                IconButton(
                  icon: const Icon(Icons.mic, color: AppTheme.primaryGreen),
                  tooltip: isHindi ? 'बोलकर प्रश्न पूछें' : 'Speak to JAGO AI',
                  onPressed: () => _showVoiceInputDialog(isHindi),
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: isHindi ? 'प्रश्न लिखें या माइक दबाएं...' : 'Type or tap mic to speak...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryGreen),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
