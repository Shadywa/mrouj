import 'package:flutter/material.dart';

class TaskesProcess extends StatelessWidget {
  const TaskesProcess({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( 
              "المهام",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "نسبة إكمال المهام",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // البار
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: const Color(0xFFE0E0E0),
              color: Colors.blue,
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            // أزرار المهام
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF5E5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "المهام المكتملة: 0",
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "المهام المتبقية: 0",
                    style: TextStyle(
                      color: Color(0xFF1976D2),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
