import 'package:flutter/material.dart';
import 'package:tool_outomate/src/ui/theme/app_theme.dart';

class StatusMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final bool isError;

  const StatusMessage({
    super.key,
    required this.message,
    required this.icon,
    this.color = AppTheme.primaryColor,
    this.isError = false,
  });

  factory StatusMessage.initial() {
    return const StatusMessage(
      message: 'يرجى اختيار مجلد المشروع.',
      icon: Icons.info_outline,
      color: AppTheme.infoColor,
    );
  }

  factory StatusMessage.loaded(String path) {
    return StatusMessage(
      message: 'تم اختيار المشروع: $path',
      icon: Icons.folder_open,
      color: AppTheme.primaryColor,
    );
  }

  factory StatusMessage.integrated(String path) {
    return StatusMessage(
      message: 'تم دمج google_maps_flutter في: $path',
      icon: Icons.check_circle_outline,
      color: AppTheme.successColor,
    );
  }

  factory StatusMessage.configured(String path) {
    return StatusMessage(
      message: 'تم إعداد الـ API Key بنجاح في: $path',
      icon: Icons.key,
      color: AppTheme.successColor,
    );
  }

  factory StatusMessage.error(String message) {
    return StatusMessage(
      message: message,
      icon: Icons.error_outline,
      color: AppTheme.errorColor,
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.arabicTextStyle.copyWith(
                color:
                    isError ? AppTheme.errorColor : AppTheme.textPrimaryColor,
                fontWeight: isError ? FontWeight.bold : FontWeight.normal,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
