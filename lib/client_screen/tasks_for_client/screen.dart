import 'package:attendance_app/client_screen/tasks_for_client/api_service.dart';
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
          title: const Text('مهامي'),
          backgroundColor: Colors.indigo,
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
                      onTap: () {
                        if (task.subtasks.isNotEmpty) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SubTasksOnboardingScreen(subtasks: task.subtasks),
                          ));
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
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final subtask = widget.subtasks[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحلة رقم ${currentIndex + 1}'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => currentIndex--),
                    child: const Text('السابق'),
                  ),
                if (currentIndex < widget.subtasks.length - 1)
                  ElevatedButton(
                    onPressed: () => setState(() => currentIndex++),
                    child: const Text('التالي'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}