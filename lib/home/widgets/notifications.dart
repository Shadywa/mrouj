import 'package:flutter/material.dart';
import 'package:attendance_app/notification/data/model.dart';

class NotificationCardHome extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCardHome({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      "إشعار",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.notifications_none, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _buildTitle(notification),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notification.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6F6F6F),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _buildTitle(NotificationModel notification) {
    if (notification.type.contains("work"))
      return "تنبيه: تعليق جديد على العمل";
    if (notification.type.contains("attachment"))
      return "تنبيه: عميل  جديد مضاف";
    if (notification.type.contains("account_comment"))
      return "تنبيه: تعليق جديد من الحسايات";
    if (notification.type.contains("customer")) return "تنبيه بخصوص عميل";
    return "إشعار جديد";
  }
}
