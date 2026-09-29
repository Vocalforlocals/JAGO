import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

class JagoChatScreen extends StatefulWidget {
  const JagoChatScreen({Key? key}) : super(key: key);

  @override
  State<JagoChatScreen> createState() => _JagoChatScreenState();
}

class _JagoChatScreenState extends State<JagoChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickChips = [
    'Check Status',
    'Check Eligibility',
    'Required Documents',
    'Payment Status',
    'How to Apply',
  ];

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
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final messages = appState.chatMessages;
    final isHindi = appState.language == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
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
                  isHindi ? 'छात्रवृत्ति सहायक' : 'Scholarship Assistant',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
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
                const Icon(Icons.verified_user, size: 14, color: AppTheme.nationalNavy),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isHindi
                      ? 'जागो आधिकारिक छात्रवृत्ति नियमों के आधार पर उत्तर देता है।'
                      : 'JAGO answers strictly from official scholarship guidelines.',
                    style: const TextStyle(fontSize: 10, color: AppTheme.nationalNavy, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Quick Action Chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _quickChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final chip = _quickChips[i];
                return ActionChip(
                  label: Text(chip, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () => _sendMessage(chip),
                );
              },
            ),
          ),

          const Divider(height: 1, color: AppTheme.cardBorder),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (ctx, index) {
                final msg = messages[index];
                final isBot = msg.sender == 'bot';

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
                              Text(
                                msg.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isBot ? AppTheme.textDark : Colors.white,
                                  height: 1.4,
                                ),
                              ),
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
                                      onTap: () => _sendMessage(opt),
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
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: isHindi ? 'अपना प्रश्न यहाँ लिखें...' : 'Ask JAGO a question...',
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
