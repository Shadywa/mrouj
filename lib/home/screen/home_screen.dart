import 'package:attendance_app/home/widgets/attendance.dart';
import 'package:attendance_app/home/widgets/notifications.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/home/widgets/profile_header.dart';

class HomeScreen1 extends StatelessWidget {
  const HomeScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileCard(name: 'shady', role: 'مبرمج'),
                    const SizedBox(height: 15),
                    AttendanceScreen(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'آخر الإشعارات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: AbsenceNotificationCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}