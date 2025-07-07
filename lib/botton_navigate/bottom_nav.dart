import 'package:attendance_app/client_screen/screen/client_screen.dart';
import 'package:attendance_app/home/main_screen.dart';
import 'package:attendance_app/notification/notification.dart';
import 'package:attendance_app/profile/profile.dart';
import 'package:attendance_app/tasks/screen/task_screen.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/home/screen/home_screen.dart';
import 'package:attendance_app/tasks/bloc/bloc.dart';
import 'package:attendance_app/tasks/bloc/event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationScreen extends StatefulWidget {
  final String? role;
  final String? name;

  const MainNavigationScreen({super.key, this.role, this.name});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String? role;
  String? department;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
      department = prefs.getString('department');
    });
  }

  List<Widget> getScreens() {
    final screens = [
      HomeScreen1(),
      Directionality(textDirection: TextDirection.rtl, child: attendpage()),
      BlocProvider(
        create: (context) => TaskBloc(Dio())..add(FetchTasks()),
        child: const TasksOverview(),
      ),
      NotificationsScreen(),
      // العملاء يظهر فقط إذا تحقق الشرط
      if (role == 'team_leader' ||
          department?.toLowerCase() == 'sales' ||
          department?.toLowerCase() == 'social')
        ClientScreen(),
      ProfileScreen(), // حسابي دائماً يظهر
    ];
    return screens;
  }

  List<TabItem> getTabItems() {
    final items = [
      TabItem(icon: Icons.home, title: 'الرئيسية'),
      TabItem(icon: Icons.qr_code_scanner, title: 'الحضور'),
      TabItem(icon: Icons.add_circle_outline, title: 'التسكات'),
      TabItem(icon: Icons.notifications, title: 'إشعارات'),
      if (role == 'team_leader' ||
          department?.toLowerCase() == 'sales' ||
          department?.toLowerCase() == 'social')
        TabItem(icon: Icons.people, title: 'العملاء '),
      TabItem(icon: Icons.person, title: 'حسابي'),
    ];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final screens = getScreens();
    final items = getTabItems();

    final safeIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

    return Scaffold(
      body: screens[safeIndex],
      bottomNavigationBar: BottomBarInspiredInside(
        items: items,
        backgroundColor: Colors.white,
        color: Colors.grey,
        colorSelected: Colors.deepPurple,
        indexSelected: safeIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        chipStyle: const ChipStyle(
          convexBridge: true,
          background: Colors.white,
        ),
        animated: true,
        itemStyle: ItemStyle.circle,
        titleStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        height: 45,
      ),
    );
  }
}
