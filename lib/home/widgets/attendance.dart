import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  Widget buildCard({
    required String time,
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                    Row(
              children: [
                Icon(icon, color: color),
                               const SizedBox(width: 6),
      
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.black,
                  ),
                ),
               
              ],
            ),
            // الوقت والحالة
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
      
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor ?? Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            // العنوان والأيقونة
        
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
          padding: const EdgeInsets.symmetric( vertical: 30 , horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الترحيب
              const Text(
                'مرحبا shady',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // العنوان الرئيسي
             
              // كروت الحضور والانصراف
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: const Text(
                                       'تسجيل الحضور والانصراف',
                                       style: TextStyle(
                                         fontSize: 20,
                                         fontWeight: FontWeight.w600,
                                       ),
                                     ),
                     ),
              const SizedBox(height: 12),
                    buildCard(
                    time: '04:29:17',
                    title: 'تسجيل الحضور',
                    status: 'تم التسجيل',
                    color: Colors.purple,
                    icon: Icons.check_circle_outline,
                  ),
                    buildCard(
                time: '04:30:20',
                title: 'تسجيل الانصراف',
                status: 'تم التسجيل',
                color: Colors.pink,
                icon: Icons.check_circle,
              ),
              SizedBox(height: 18),
                  ] 
                ),
              ),
            
              // buildCard(
              //   time: 'غير نشط',
              //   title: 'الاستراحة',
              //   status: 'بدء الاستراحة',
              //   color: Colors.amber,
              //   icon: Icons.access_time,
              //   textColor: Colors.black87,
              // ),
            ],
          ),
        
      ),
    );
  }
}
