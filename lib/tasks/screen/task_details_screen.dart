import 'package:attendance_app/client_screen/model/attach.dart';
import 'package:attendance_app/tasks/screen/task_comment_screen.dart';
import 'package:attendance_app/tasks/sub/sub_screen.dart';
import 'package:flutter/material.dart';
import 'model/task.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          title: const Text('تفاصيل المهمة'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // صورة المهمة
              Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    task.image ?? '',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoField(label: 'اسم المهمة', value: task.taskName),
                    _InfoField(label: 'الوصف', value: task.description),
                    _InfoField(
                        label: 'من',
                        value:
                            '${task.startTime.year}/${task.startTime.month.toString().padLeft(2, '0')}/${task.startTime.day.toString().padLeft(2, '0')}'),
                    _InfoField(
                        label: 'إلى',
                        value:
                            '${task.endTime.year}/${task.endTime.month.toString().padLeft(2, '0')}/${task.endTime.day.toString().padLeft(2, '0')}'),
                    _InfoField(
                        label: 'الحالة',
                        value: task.status == 'notcompleted'
                            ? 'غير مكتملة'
                            : 'مكتملة'),
                    _InfoField(
                        label: 'تاريخ الإنشاء',
                        value:
                            '${task.createdAt.year}/${task.createdAt.month.toString().padLeft(2, '0')}/${task.createdAt.day.toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text(
                      'اضف مشترك',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showTecnialDialog(context, task.id.toString());
                      
                    },
                  ),
                ),
              ),
                   Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text(
                      ' تعليقات التاسك',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => TaskCommentScreen(taskId: task.id),
                      ));
                      
                    },
                  ),
                ),
              ),
                Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text(
                      '  اضافه تسكات فرعيه ',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SubStageScreen(taskId: task.id),
                      ));
                      
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}