import 'package:flutter/material.dart';

class EmptyTask extends StatelessWidget {
  const EmptyTask({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline,
              size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "لا توجد مهام حالية",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

