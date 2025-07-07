import 'dart:developer';

import 'package:attendance_app/home/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class MyPermissionsPage extends StatefulWidget {
  final String? role;
  final String? name;
  const MyPermissionsPage({super.key, this.role, this.name});

  @override
  State<MyPermissionsPage> createState() => _MyPermissionsPageState();
}

class _MyPermissionsPageState extends State<MyPermissionsPage> {
  List permissions = [];
  bool isLoading = true;

  final dio = Dio();
  final cloudFunctionUrl = 'https://us-central1-eljudymarket.cloudfunctions.net/getMyPermissions';

  Future<void> fetchPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await prefs.getString('uid');
    log('Fetching permissions for user ID: $uid');

    try {
      final response = await dio.get(cloudFunctionUrl, queryParameters: {'userId': uid});
      setState(() {
        log('Permissions fetched successfully: ${response.data}');
        permissions = response.data['permissions'];
        isLoading = false;
      });
    } catch (e) {
        log('Error submitting permission request: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ فشل في تحميل الأذونات')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
             backgroundColor: Colors.grey[100],

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : permissions.isEmpty
              ? const Center(child: Text("لا توجد أذونات بعد", style: TextStyle(fontSize: 16)))
              : Column(
                children: [
                        const SizedBox(height: 20),
                       ProfileCard(name: widget.name,role: widget.role,),
                       const SizedBox(height: 10),
                       Expanded(
                         child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          itemCount: permissions.length,
                          itemBuilder: (context, index) {
                            final item = permissions[index];
                            Color statusColor;
                            String statusText = item['status'] ?? '';
                            switch (statusText) {
                              case 'approved':
                                statusColor = Colors.green;
                                statusText = 'مقبول';
                                break;
                              case 'pending':
                                statusColor = Colors.orange;
                                statusText = 'قيد المراجعة';
                                break;
                              case 'rejected':
                                statusColor = Colors.red;
                                statusText = 'مرفوض';
                                break;
                              default:
                                statusColor = Colors.grey;
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: statusColor.withOpacity(0.18), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        // دائرة بها أيقونة نوع الإذن
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: statusColor.withOpacity(0.13),
                                          child: Icon(Icons.assignment_turned_in, color: statusColor, size: 26),
                                        ),
                                        const SizedBox(width: 12),
                                        // نوع الإذن أو الغياب
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Badge نوع الطلب الرئيسي
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: (item['mainType'] == 'غياب'
                                                            ? Colors.red
                                                            : Colors.indigo)
                                                        .withOpacity(0.13),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    item['mainType'] ?? '',
                                                    style: TextStyle(
                                                      color: item['mainType'] == 'غياب'
                                                          ? Colors.red
                                                          : Colors.indigo,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // نوع الاستئذان أو كلمة "غياب"
                                                Text(
                                                  item['mainType'] == 'استئذان'
                                                      ? (item['type'] ?? '')
                                                      : 'غياب',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        // Badge حالة الإذن
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.13),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                statusColor == Colors.green
                                                    ? Icons.check_circle
                                                    : statusColor == Colors.orange
                                                        ? Icons.hourglass_top
                                                        : Icons.cancel,
                                                color: statusColor,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                statusText,
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 0, thickness: 1, color: Color(0xfff3f3f3)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        // التاريخ
                                        Column(
                                          children: [
                                            Icon(Icons.calendar_today, size: 20, color: Colors.indigo.shade300),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatDate(item['date']),
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 18),
                                        // المدة
                                        Column(
                                          children: [
                                            Icon(Icons.access_time, size: 20, color: Colors.indigo.shade300),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['hours'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 18),
                                        // السبب
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Icon(Icons.edit_note, size: 20, color: Colors.indigo.shade300),
                                              const SizedBox(height: 4),
                                              Text(
                                                item['reason'] ?? '',
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                       ),
                ]   ),
    );
  }
}
