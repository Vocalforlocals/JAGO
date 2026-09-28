import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const StatusBadge({
    Key? key,
    required this.status,
    this.customLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'verified':
      case 'completed':
      case 'resolved':
      case 'eligible':
        bg = AppTheme.statusSuccessBg;
        text = AppTheme.statusSuccessText;
        label = customLabel ?? '✓ Verified';
        icon = Icons.check_circle_outline;
        break;
      case 'expired':
      case 'action_required':
      case 'potentially_eligible':
      case 'in_progress':
      case 'pending':
        bg = AppTheme.statusWarningBg;
        text = AppTheme.statusWarningText;
        label = customLabel ?? (status == 'expired' ? '⚠ Expired' : '⚠ Action Required');
        icon = Icons.warning_amber_rounded;
        break;
      case 'mismatch':
      case 'rejected':
      case 'not_eligible':
        bg = AppTheme.statusErrorBg;
        text = AppTheme.statusErrorText;
        label = customLabel ?? '⚠ Mismatch';
        icon = Icons.error_outline;
        break;
      case 'not_applicable':
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        label = customLabel ?? 'Not Applicable';
        icon = Icons.remove_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
