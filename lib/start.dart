import 'package:attendance_app/auth/sign_in.dart';
import 'package:attendance_app/botton_navigate/bottom_nav.dart';
import 'package:attendance_app/home/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    navigateUser();
  }

  Future<void> navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    if (role == null) {
      // لو المستخدم مش مسجل، روح لتسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    } else {
      // لو فيه دور، روح حسب الدور
      switch (role) {
        case 'employee':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
          );
          break;
        case 'team_leader':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()),
          );
          break;
        default:
          // لو الدور غير معروف، روح لتسجيل الدخول احتياطًا
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // شاشة انتظار بسيطة أثناء تحميل البيانات
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
