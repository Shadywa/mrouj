import 'package:attendance_app/client_screen/tasks_for_client/api_service.dart';
import 'package:attendance_app/client_screen/tasks_for_client/empty_subtasks_screen.dart';
import 'package:attendance_app/tasks/create/screen/create_task.dart';
import 'package:attendance_app/tasks/sub/create_sub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tasks_bloc.dart';
import 'models.dart';

class TasksScreen extends StatelessWidget {
  final String customerId;
  const TasksScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TasksBloc(TaskApiService())..add(FetchTasksEvent(customerId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مهام العميل'),
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateTaskScreen(customerId: customerId,), // ضع هنا اسم صفحة الإضافة الخاصة بك
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TasksError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            if (state is TasksLoaded) {
              final tasks = state.tasks;
              if (tasks.isEmpty) {
                return const Center(child: Text('لا توجد مهام'));
              }
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      title: Text(task.taskName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(task.description),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        if (task.subtasks.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SubTasksOnboardingScreen(subtasks: task.subtasks),
                          ));
                        } else {
                          // الذهاب إلى شاشة الإنشاء أولاً
                          final createdSubtasks = await   Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmptySubtasksScreen(onCreate: () { 
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => SubStageScreen(taskId: task.id),
                                          ),
                                        );
                                       },
                                     
                                      ),
                                    ),
                                  );
                          // بعد الإنشاء، إذا تم إنشاء مراحل، يذهب إلى شاشة المراحل
                          if (createdSubtasks != null && createdSubtasks.isNotEmpty) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => SubTasksOnboardingScreen(subtasks: createdSubtasks),
                            ));
                          }
                        }
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class SubTasksOnboardingScreen extends StatefulWidget {
  final List<SubTaskModel> subtasks;
  const SubTasksOnboardingScreen({super.key, required this.subtasks});

  @override
  State<SubTasksOnboardingScreen> createState() => _SubTasksOnboardingScreenState();
}

class _SubTasksOnboardingScreenState extends State<SubTasksOnboardingScreen> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color getProgressColor() {
    // المرحلة الحالية
    final subtask = widget.subtasks[currentIndex];
    final options = subtask.statusOptions;
    final total = options.length;
    final currentIndexInOptions = options.indexOf(subtask.status);

    // لو الحالة غير موجودة في الخيارات
    if (currentIndexInOptions == -1 || total == 0) return Colors.red.shade100;

    final percent = (currentIndexInOptions + 1) / total;

    if (percent == 0) return Colors.red.shade100;
    if (percent < 0.5) return Colors.orange.shade100;
    if (percent < 1) return Colors.yellow.shade100;
    return Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مراحل المهمة'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        color: getProgressColor(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.subtasks.length,
          onPageChanged: (i) => setState(() => currentIndex = i),
          itemBuilder: (context, i) {
            final subtask = widget.subtasks[i];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('مرحلة رقم ${i + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(subtask.description, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: subtask.statusOptions.map((s) => Chip(label: Text(s))).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text('الحالة الحالية: ${subtask.status}', style: const TextStyle(fontSize: 16, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  if (subtask.images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: subtask.images.map((img) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Image.network(img, width: 100, fit: BoxFit.cover),
                        )).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (subtask.comments.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: subtask.comments.map((c) => Card(
                          child: ListTile(
                            title: Text(c.userName),
                            subtitle: Text(c.comment),
                            trailing: c.images.isNotEmpty
                              ? Image.network(c.images.first, width: 40, height: 40, fit: BoxFit.cover)
                              : null,
                          ),
                        )).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text('(${currentIndex + 1} / ${widget.subtasks.length})', style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}