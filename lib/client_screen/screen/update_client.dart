import 'dart:developer';

import 'package:attendance_app/client_screen/bloc/update_bloc/bloc.dart';
import 'package:attendance_app/client_screen/model/attach.dart';
import 'package:attendance_app/client_screen/public/screen/public_screen.dart';
import 'package:attendance_app/client_screen/screen/work_comment.dart';
import 'package:attendance_app/client_screen/tasks_for_client/screen.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../model/model.dart';

class ClientDetailsScreen extends StatefulWidget {
  final ClientModel client;
  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final commentController = TextEditingController();
  String? userName;
  String? userRole;
  String selectedStatus = 'نشط';

  // Controllers for editing info
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  DateTime? nextContactAt;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserRole();
    selectedStatus = widget.client.status ?? 'نشط';
    nameController = TextEditingController(text: widget.client.name);
    emailController = TextEditingController(text: widget.client.email);
    phoneController = TextEditingController(text: widget.client.phone);
    nextContactAt = widget.client.nextContactAt;
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? '';
    });
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('department');
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _showNextContactDialog() async {
    DateTime initialDate = nextContactAt ?? DateTime.now();
    DateTime selectedDate = initialDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر موعد التواصل القادم'),
          content: SizedBox(
            width: double.maxFinite,
            child: EasyDateTimeLine(
              initialDate: initialDate,
              locale: 'ar',
              onDateChange: (date) {
                selectedDate = date;
              },
              activeColor: Colors.indigo,
              dayProps: const EasyDayProps(
                width: 48,
                height: 64,
                dayStructure: DayStructure.dayStrDayNum,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  nextContactAt = selectedDate;
                });
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showEditInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعديل بيانات العميل'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                  ),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
    );
  }

  void _saveAllChanges(BuildContext context) {
    // أرسل كل التعديلات دفعة واحدة للـ bloc أو للسيرفر
    BlocProvider.of<ClientActionBloc>(context).add(
      UpdateClientEvent(
        id: widget.client.id,
        uids: widget.client.attachmentSales ?? [],
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        nextContactAt: nextContactAt,
        status: selectedStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientActionBloc(Dio()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('تفاصيل العميل'),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'تعديل بيانات العميل',
                onPressed: _showEditInfoDialog,
              ),
            ],
          ),
          body: BlocConsumer<ClientActionBloc, ClientActionState>(
            listener: (context, state) {
              if (state is ClientActionSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                commentController.clear();
              } else if (state is ClientActionError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // صورة العميل
                    CircleAvatar(
                      radius: 48,
                      backgroundImage:
                          widget.client.profilePicture.startsWith('http')
                              ? NetworkImage(widget.client.profilePicture)
                              : null,
                      backgroundColor: Colors.grey[200],
                      child:
                          widget.client.profilePicture.startsWith('http')
                              ? null
                              : const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey,
                              ),
                    ),
                    const SizedBox(height: 18),
                    _InfoField(label: 'الاسم', value: nameController.text),
                    _InfoField(
                      label: 'البريد الإلكتروني',
                      value: emailController.text,
                    ),
                    _InfoField(
                      label: 'رقم الهاتف',
                      value: phoneController.text,
                    ),
                    if (widget.client.phone2 != null &&
                        widget.client.phone2!.isNotEmpty)
                      _InfoField(
                        label: 'رقم إضافي 2',
                        value: widget.client.phone2!,
                      ),
                    if (widget.client.phone3 != null &&
                        widget.client.phone3!.isNotEmpty)
                      _InfoField(
                        label: 'رقم إضافي 3',
                        value: widget.client.phone3!,
                      ),
                    _InfoField(
                      label: 'الخدمة المطلوبة',
                      value: widget.client.serviceRequired ?? '---',
                    ),
                    // عرض كل تعليقات المبيعات
                    if (widget.client.salesComments != null &&
                        widget.client.salesComments!.isNotEmpty)
                      ...widget.client.salesComments!.map(
                        (c) => _InfoField(
                          label: 'ملاحظة مبيعات',
                          value: c.comment,
                        ),
                      ),
                    if (widget.client.salesComments == null ||
                        widget.client.salesComments!.isEmpty)
                      _InfoField(label: 'ملاحظات المبيعات', value: '---'),
                    _InfoField(
                      label: 'تاريخ الإنشاء',
                      value: _formatDate(widget.client.createdAt),
                    ),
                    _InfoField(
                      label: 'آخر تحديث',
                      value: _formatDate(widget.client.updatedAt),
                    ),
                    _InfoField(
                      label: 'آخر تواصل',
                      value: _formatDate(widget.client.lastContactAt),
                    ),
                    _InfoField(
                      label: 'موعد التواصل القادم',
                      value: _formatDate(nextContactAt),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.edit_calendar,
                          color: Colors.blueAccent,
                        ),
                        onPressed: _showNextContactDialog,
                      ),
                    ),
                    _InfoField(label: 'الحالة', value: selectedStatus),
                    const SizedBox(height: 18),
                    // تغيير الحالة
                    Row(
                      children: [
                        const Text(
                          'تغيير الحالة:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: selectedStatus,
                          items:
                              [
                                    'تجاهل العميل',
                                    'متابعة العميل',
                                    'مهتم',
                                    'محتاج متابعة',
                                    'منتظر عرض',
                                    'تم إرسال عرض',
                                    'فرصة تحت التفاوض',
                                    'تم التحويل لفرصة',
                                    'غير مهتم',
                                    'لا يرد',
                                    'بيانات خاطئة',
                                    'نشط',
                                    'غير نشط',
                                    'مغلق',
                                  ]
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => selectedStatus = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'حفظ كل التعديلات',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          state is ClientActionLoading
                              ? null
                              : () => _saveAllChanges(context),
                    ),
                    const SizedBox(height: 24),
                    // إضافة تعليق
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.comment, color: Colors.white),
                        label: const Text(
                          'تعليقات العمل',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => WorkCommentsScreen(
                                    client: widget.client,
                                    userName: userName ?? '',
                                    userRole: userRole ?? '',
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                            const SizedBox(height: 24),
                    // إضافة تعليق
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.comment, color: Colors.white),
                        label: const Text(
                          ' التعليقات العامه',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => GeneralWorkCommentsScreen(
                                    client: widget.client,
                                    userName: userName ?? '',
                                    userRole: userRole ?? '',
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                         SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.comment, color: Colors.white),
                        label: const Text(
                          ' متابعه التاسكات ',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => TasksScreen(
                                     customerId: 
                                    widget.client.id.toString(),
                              
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    // زر إضافة مشترك/سيلز
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person, color: Colors.white),
                        label: Text(
                          userRole == 'sales' ? 'اضافه سيلز ' : 'اضف مشترك',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          log('userRole: $userRole');
                          if (userRole == 'sales') {
                            showSalesDialog(context, widget.client.id);
                          } else if (userRole == 'Finance') {
                            showAccountDialog(context, widget.client.id);
                          } else if (userRole == 'social') {
                            showSocialDialog(context, widget.client.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('لا يمكنك إضافة مشترك'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // الأزرار الخاصة بالحسابات والسوشيال تظهر فقط إذا كان role == sales
                    if (userRole == 'sales') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.countertops,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'اضف للحسابات ',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            showAccountDialog(context, widget.client.id);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.social_distance,
                            color: Colors.white,
                          ),
                          label: const Text(
                            '  تحويل للسوشيال ',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            showSocialDialog(context, widget.client.id);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _InfoField({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
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
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
