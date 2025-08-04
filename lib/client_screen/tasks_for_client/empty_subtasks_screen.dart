import 'package:flutter/material.dart';

class EmptySubtasksScreen extends StatelessWidget {
  final VoidCallback onCreate;
  const EmptySubtasksScreen({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مراحل المهمة')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('لا توجد مراحل لهذه المهمة', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text('إنشاء مرحلة'),
            ),
          ],
        ),
      ),
    );
  }
}