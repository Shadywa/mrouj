import 'dart:developer';

import 'package:attendance_app/botton_navigate/bottom_nav.dart';
import 'package:attendance_app/home/main_screen.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String role = 'موظف';
  String department = 'تقنية المعلومات';
  String shift = 'نهاري';

  bool isLoading = false;

  final dio = Dio();
  final cloudFunctionUrl =
      'https://us-central1-eljudymarket.cloudfunctions.net/registerUser';

  Map<String, String> arabicRoleToEnglish = {
    'موظف': 'employee',
    'قائد فريق': 'team_leader',
    'الموارد البشرية': 'hr',
  };

  Map<String, String> arabicDeptToEnglish = {
    'تقنية المعلومات': 'IT',
    'الموارد البشرية': 'HR',
    'الدعم الفني': 'Support',
    'المبيعات': 'Sales',
    'الحسابات المالية': 'Finance',
    ' الموشن': 'motion graphics',
  };

  Map<String, String> arabicShiftToEnglish = {
    'نهاري': 'day',
    'ليلي': 'night',
    'مرن': 'flexible',
  };

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // UserCredential userCredential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(
      //       email: emailController.text.trim(),
      //       password: passwordController.text.trim(),
      //     );

  
      final  uid = '3kTs6Btxj2QPN8k8Tgxbbs58iz22'; // استخدم معرف

      // final fcmToken = await FirebaseMessaging.instance.getToken();

      final Response = await dio.post(
        cloudFunctionUrl,
        data: {
          'uid': '3kTs6Btxj2QPN8k8Tgxbbs58iz22',
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': arabicRoleToEnglish[role],
          'department': arabicDeptToEnglish[department],
          'shift': arabicShiftToEnglish[shift],
          'fcm_token': "fcmToken", // أضف هذا السطر
        },
      );
      log(uid);
      log('User registered with UID: $uid');
      log(nameController.text.trim());
      log(emailController.text.trim());
      log('Role: ${arabicRoleToEnglish[role]}');
      log('Department: ${arabicDeptToEnglish[department]}');
      log('Shift: ${arabicShiftToEnglish[shift]}');
      log('Response from cloud function: ${Response.data}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تسجيل المستخدم بنجاح')),
      );
      await saveUserSession(
        uid: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        role: arabicRoleToEnglish[role]!,
        department: arabicDeptToEnglish[department]!,
        shift: arabicShiftToEnglish[shift]!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    // } 
    // on FirebaseAuthException catch (e) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('❌ فشل في التسجيل: ${e.message}')));
    } catch (e) {
      log('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ حدث خطأ ما أثناء التسجيل')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfff6f8fa),

        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.07),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_add_alt_1,
                        size: 48,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration(
                          label: "الاسم",
                          icon: Icons.person,
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration(
                          label: "البريد الإلكتروني",
                          icon: Icons.email,
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'الرجاء إدخال البريد' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: _inputDecoration(
                          label: "كلمة المرور",
                          icon: Icons.lock,
                        ),
                        validator:
                            (value) =>
                                value!.length < 6
                                    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: role,
                        items:
                            ['موظف', 'قائد فريق', 'الموارد البشرية']
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => role = val!),
                        decoration: _inputDecoration(
                          label: 'الدور',
                          icon: Icons.badge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: department,
                        items:
                            [
                                  'تقنية المعلومات',
                                  'الموارد البشرية',
                                  'الدعم الفني',
                                  'المبيعات',
                                  'الحسابات المالية',
                                ]
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => department = val!),
                        decoration: _inputDecoration(
                          label: 'القسم',
                          icon: Icons.apartment,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: shift,
                        items:
                            ['نهاري', 'ليلي', 'مرن']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => shift = val!),
                        decoration: _inputDecoration(
                          label: 'نظام الشيفت',
                          icon: Icons.access_time,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: isLoading ? null : registerUser,
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                          label: const Text(
                            'تسجيل',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.indigo) : null,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
        ),
      );
}

Future<void> saveUserSession({
  required String uid,
  required String name,
  required String email,
  required String role,
  required String department,
  required String shift,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('uid', uid);
  await prefs.setString('name', name);
  await prefs.setString('email', email);
  await prefs.setString('role', role);
  await prefs.setString('department', department);
  await prefs.setString('shift', shift);
}
