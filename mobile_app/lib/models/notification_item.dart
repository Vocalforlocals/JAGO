class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String date;
  bool isRead;
  final String type; // 'info' | 'warning' | 'success' | 'action_required'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    required this.type,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      date: json['date'] ?? 'Today',
      isRead: json['is_read'] ?? false,
      type: json['type'] ?? 'info',
    );
  }

  static List<NotificationItem> defaultNotifications() {
    return [
      NotificationItem(
        id: 1,
        title: 'Application moved to Verification',
        message: 'Your Post-Matric Scholarship application has been routed to the Manual Review queue for institutional record alignment.',
        date: '12 Sep 2026',
        isRead: false,
        type: 'info',
      ),
      NotificationItem(
        id: 2,
        title: 'Income Certificate requires attention',
        message: 'Your previously submitted income certificate validity has expired (>12 months). Please revalidate for current cycle.',
        date: '12 Sep 2026',
        isRead: false,
        type: 'warning',
      ),
      NotificationItem(
        id: 3,
        title: 'Document Verification completed',
        message: 'Aadhaar, ST Certificate, and Academic Marksheet verified successfully via DigiLocker.',
        date: '10 Aug 2026',
        isRead: true,
        type: 'success',
      ),
      NotificationItem(
        id: 4,
        title: 'College Verification completed',
        message: 'Bonafide enrollment verified by ABC Institute nodal desk.',
        date: '05 Aug 2026',
        isRead: true,
        type: 'success',
      ),
      NotificationItem(
        id: 5,
        title: 'Application Submitted successfully',
        message: 'Your student profile and draft scholarship form have been registered on JAGO unified layer.',
        date: '01 Aug 2026',
        isRead: true,
        type: 'info',
      ),
    ];
  }
}
