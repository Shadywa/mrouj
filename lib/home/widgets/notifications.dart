import 'package:flutter/material.dart';

class AbsenceNotificationCard extends StatelessWidget {
  const AbsenceNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // مهم لجعل النص من اليمين لليسار
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان العلوي مع الجرس
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      " اشعار",
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
              SizedBox(height: 12),
              // عنوان الإشعار
              const Text(
                "تحذير: تم تسجيل عقوبة غياب",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              // التفاصيل
              const Text(
                "تم تسجيل عقوبة غياب لك من تاريخ 02-05-2025 إلى تاريخ 03-05-2025. السبب: مخالف للنظام",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6F6F6F), // رمادي متوسط
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
