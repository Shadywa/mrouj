import 'package:attendance_app/home/widgets/attendance.dart';
import 'package:attendance_app/home/widgets/notifications.dart';
import 'package:attendance_app/home/widgets/profile_header.dart';
import 'package:attendance_app/notification/data/bloc/bloc.dart';

import 'package:attendance_app/notification/data/model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen1 extends StatelessWidget {
  const HomeScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(Dio())..add(FetchNotificationsEvent()),
      child: Scaffold(
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
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoading) {
                        return Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ShimmerNotificationCard(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ShimmerNotificationCard(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ShimmerNotificationCard(),
                            ),
                          ],
                        );
                      } else if (state is NotificationLoaded &&
                          state.notifications.isNotEmpty) {
                        final latestNotifications =
                            state.notifications.take(3).toList();

                        return Column(
                          children:
                              latestNotifications
                                  .map(
                                    (n) =>
                                        NotificationCardHome(notification: n),
                                  )
                                  .toList(),
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'لا توجد إشعارات حالياً',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerNotificationCard extends StatelessWidget {
  const ShimmerNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
