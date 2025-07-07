import 'package:attendance_app/admin/requests.dart';
import 'package:attendance_app/auth/attendance/attend.dart';
import 'package:attendance_app/auth/attendance/generateQr.dart';
import 'package:attendance_app/permissions/my_permitions.dart';
import 'package:attendance_app/permissions/request.dart';
import 'package:attendance_app/permissions/request_absence.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/home/widgets/profile_header.dart';

class attendpage extends StatefulWidget {
  const attendpage({super.key});

  @override
  State<attendpage> createState() => _attendpageState();
}

class _attendpageState extends State<attendpage> {
  String? name;
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
      role = prefs.getString('role');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
    
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileCard(name: name, role: role),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildHomeButton('تسجيل الحضور', Icons.qr_code_scanner, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRAttendancePage(),
                          ),
                        );
                      }),
                      _buildHomeButton('طلب إذن', Icons.edit_note, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: RequestPermissionPage()),
                          ),
                        );
                      }),
                    
                      _buildHomeButton('طلب غياب', Icons.event_busy, () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: RequestAbsencePage()),
                          ),
                        );
                      }),
                      _buildHomeButton('أذوناتي', Icons.history, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyPermissionsPage(),
                          ),
                        );
                      }),
                      role == 'team_leader' ?   _buildHomeButton('طلباتي ', Icons.list_alt, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamLeaderApprovalPage(),
                          ),
                        );
                      }) :SizedBox(),
                  
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4), // تقليل البادينج
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10), // تقليل حجم دائرة الأيقونة
              child: Icon(icon, size: 24, color: Colors.blue.shade700), // تقليل حجم الأيقونة
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13, // تقليل حجم الخط
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
