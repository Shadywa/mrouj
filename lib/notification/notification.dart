import 'package:attendance_app/home/widgets/profile_header.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl, 
        child: Scaffold(
          backgroundColor: Colors.grey[50],
         
          body: Padding(
            padding: const EdgeInsets.symmetric( vertical: 8),
            child: Column(
              children: [
                ProfileCard(
                  name: 'شادي',
                  role: 'مبرمج',
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                            'الإشعارات',
                            style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                            ),
                          ),
                ),
                              SizedBox(height: 16),
        
                _notificationCard(),
                const SizedBox(height: 6),
                _notificationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notificationCard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة التنبيه
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D4F), // أحمر
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "هام" + العنوان
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF4D4F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'هام',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'تحذير! تم تسجيل عقوبة غياب',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'تم تسجيل عقوبة غياب لك من تاريخ 2025-05-02 إلى تاريخ 2025-05-03. السبب: مخالفة للنظام',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'منذ 7 ساعات تقريباً',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
