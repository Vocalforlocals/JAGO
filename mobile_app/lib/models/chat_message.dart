class ChatMessage {
  final String sender; // 'user' | 'bot'
  final String text;
  final String timestamp;
  final List<String>? options;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.options,
  });

  static List<ChatMessage> initialConversation() {
    return [
      ChatMessage(
        sender: 'bot',
        text: 'Hello Rahul! I am JAGO, your dedicated scholarship assistant for the Ministry of Tribal Affairs. How can I assist you today?',
        timestamp: '10:00 AM',
        options: ['Check Status', 'Check Eligibility', 'Required Documents', 'Payment Status', 'How to Apply'],
      ),
      ChatMessage(
        sender: 'user',
        text: 'What is the current status of my application?',
        timestamp: '10:01 AM',
      ),
      ChatMessage(
        sender: 'bot',
        text: 'Your application ST-2026-001245 for Post-Matric Scholarship is currently Under Government Verification. It has been routed to the MoTA Manual Review queue for institution alias validation. No action is required from your side!',
        timestamp: '10:01 AM',
        options: ['Check Payments', 'Required Documents', 'Help'],
      ),
      ChatMessage(
        sender: 'user',
        text: 'Why does my income certificate need revalidation?',
        timestamp: '10:02 AM',
      ),
      ChatMessage(
        sender: 'bot',
        text: 'As per Ministry guidelines, income certificates are valid for 12 months. Your previous certificate from March 2023 has expired. Revalidating it for FY 2026-27 allows instant reuse across all eligible schemes.',
        timestamp: '10:02 AM',
        options: ['Open Document Wallet', 'View Schemes'],
      ),
    ];
  }
}
