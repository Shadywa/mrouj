import 'package:attendance_app/client_screen/screen/client_screen.dart';
import 'package:attendance_app/home/main_screen.dart';
import 'package:attendance_app/notification/data/bloc/bloc.dart';
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
import 'dart:async';
import 'package:just_audio/just_audio.dart';

class MainNavigationScreen extends StatefulWidget {
  final String? role;
  final String? name;
  final int initialIndex ;

  const MainNavigationScreen({super.key, this.role, this.name , this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String? role;
  String? department;
  bool _dataLoaded = false;
  int _unreadNotifications = 0;
  int _lastUnreadNotifications = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserData();
    _startNotificationPolling();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _startNotificationPolling() {
    _fetchUnreadNotifications();
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchUnreadNotifications();
    });
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('uid') ?? "";
      final response = await Dio().get(
        'https://drivo.elmoroj.com/api/notifications/unread-count/user/$userId',
      );
      final data = response.data;
      final count = data["Total_unread_project_notifications for user"] ?? 0;
      if (mounted) {
        setState(() {
          _lastUnreadNotifications = _unreadNotifications;
          _unreadNotifications = count;
        });
        if (_unreadNotifications > _lastUnreadNotifications) {
          // تشغيل صوت الإشعار عند زيادة العدد باستخدام just_audio
          final player = AudioPlayer();
          player.setAsset('assets/noti/notification.mp3').then((_) {
            player.play();
          });
        }
      }
    } catch (e) {
      // تجاهل الخطأ أو أضف لوج
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    department = prefs.getString('department');
    setState(() {
      _dataLoaded = true;
    });
  }

  List<Map<String, dynamic>> getTabsData() {
    final tabs = [
      {
        'widget': BlocProvider(
          create: (context) => NotificationBloc(Dio()),
          child: HomeScreen1(),
        ),
        'tab': TabItem(icon: Icons.home, title: 'الرئيسية'),
      },
      {
        'widget': Directionality(
          textDirection: TextDirection.rtl,
          child: attendpage(),
        ),
        'tab': TabItem(icon: Icons.qr_code_scanner, title: 'الحضور'),
      },
      {
        'widget': BlocProvider(
          create: (context) => TaskBloc(Dio())..add(FetchTasks()),
          child: const TasksOverview(),
        ),
        'tab': TabItem(icon: Icons.add_circle_outline, title: 'التسكات'),
      },
      {
        'widget': NotificationsScreen(),
        'tab': TabItem(
          icon: Icons.notifications,
          title: 'إشعارات',
          count: _unreadNotifications > 0 ? Text('$_unreadNotifications') : null,
        ),
      },
      if (role == 'team_leader' ||
          department?.toLowerCase() == 'sales' ||
          department?.toLowerCase() == 'finance' ||
          department?.toLowerCase() == 'social')
        {
          'widget': ClientScreen( 
            department: department ?? '',
          ),
          'tab': TabItem(icon: Icons.people, title: 'العملاء'),
        },
      {
        'widget': ProfileScreen(),
        'tab': TabItem(icon: Icons.person, title: 'حسابي'),
      },
    ];

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabsData = getTabsData();
    final screens = tabsData.map((e) => e['widget'] as Widget).toList();
    final items = tabsData.map((e) => e['tab'] as TabItem).toList();
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
            // إذا خرج من تبويب الإشعارات، صفر العداد
            if (_currentIndex == 3 && index != 3) {
              _unreadNotifications = 0;
            }
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

// ملاحظة: تأكد من إضافة ملف الصوت notification.mp3 إلى مجلد assets وتسجيله في pubspec.yaml:
// assets:
//   - assets/notification.mp3
