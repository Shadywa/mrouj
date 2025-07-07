import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String? name;
  final String? role;
  const ProfileCard({super.key, this.name, this.role});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(10),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.2),
          //     spreadRadius: 2,
          //     blurRadius: 5,
          //     offset: const Offset(0, 3), // تأثير الظل
          //   ),
          // ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // الصورة
            CircleAvatar(
              radius: 25, // الحجم الصغير المناسب
              backgroundImage: AssetImage(
                'assets/download.png', // استبدلها بصورة المستخدم
              ),
            ),
            const SizedBox(width: 10),
            // النصوص
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'اسم المستخدم',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                 role ?? ' موظف',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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
