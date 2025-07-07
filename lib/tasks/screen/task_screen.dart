import 'package:attendance_app/home/widgets/profile_header.dart';
import 'package:attendance_app/tasks/bloc/bloc.dart';
import 'package:attendance_app/tasks/bloc/state.dart';
import 'package:attendance_app/tasks/screen/widgets/shimmer_loading.dart';

import 'package:attendance_app/tasks/screen/widgets/task_card.dart';
import 'package:attendance_app/tasks/screen/widgets/taskesProcess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksOverview extends StatelessWidget {
  const TasksOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ProfileCard(
                  name: 'شادي',
                  role: 'مبرمج',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // الكارت العلوي
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "المهام الحالية",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),

 const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TaskesProcess(
                  ),
                ),
              ),  
              
               const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "مهامي التي لم تنتهي",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
                          BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const SliverToBoxAdapter(child: TaskShimmer());
                  } else if (state is TaskLoaded) {
                    if (state.tasks.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Text('لا توجد مهام')),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TaskCard(task: state.tasks[index]),
                        childCount: state.tasks.length,
                      ),
                    );
                  } else if (state is TaskError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(state.message)),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

