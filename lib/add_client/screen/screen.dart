import 'dart:developer';

import 'package:attendance_app/add_client/bloc/bloc.dart';
import 'package:attendance_app/add_client/bloc/event.dart';
import 'package:attendance_app/add_client/bloc/state.dart';
import 'package:attendance_app/add_client/model/add_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final serviceController = TextEditingController();
  final statusController = TextEditingController();
  final salesCommentController = TextEditingController();
  final salesComments = <SalesCommentModel>[]; // بدل <String>[]
  DateTime? lastContactAt;
  DateTime? nextContactAt;
  String? selectedStatus;
  String? selectedService;

  void _pickDate({required bool isNext}) async {
    DateTime initial = DateTime.now();
    DateTime selected = initial;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNext ? 'اختر موعد التواصل القادم' : 'اختر آخر تواصل'),
        content: SizedBox(
          width: double.maxFinite,
          child: EasyDateTimeLine(
            initialDate: initial,
            // startDate: DateTime.now(),
            locale: 'ar',
            onDateChange: (date) {
              selected = date;
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
                if (isNext) {
                  nextContactAt = selected;
                } else {
                  lastContactAt = selected;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = [
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
    ];

    final serviceOptions = [
      'تصميم اعلانات',
      'تصميم هوية بصرية',
      'تصميم فيديو  موشن',
      'إدارة سوشيال ميديا',
      'برمجة تطبيق',
      'تصميم موقع',
      'استشارة تسويقية',
      // أضف المزيد حسب الحاجة
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => AddClientBloc(Dio()),
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('إضافة عميل'),
            backgroundColor: Colors.blueAccent,
            centerTitle: true,
            foregroundColor: Colors.white,
          ),
          body: BlocConsumer<AddClientBloc, AddClientState>(
            listener: (context, state) {
              if (state is AddClientSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة العميل بنجاح')),
                );
                Navigator.pop(context);
              } else if (state is AddClientError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: 'الاسم'),
                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(labelText: 'الخدمة المطلوبة'),
                              items: serviceOptions
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedService = val;
                                });
                              },
                              validator: (v) => v == null ? 'اختر الخدمة' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(labelText: 'الحالة'),
                              items: statusOptions
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedStatus = val;
                                });
                              },
                              validator: (v) => v == null ? 'اختر الحالة' : null,
                            ),
                            const SizedBox(height: 12),
                            // Sales Comments
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: salesCommentController,
                                    decoration: const InputDecoration(labelText: 'تعليق للمبيعات'),
                                    onFieldSubmitted: (val) async {
                                      if (val.trim().isNotEmpty) {
                                        final String uid = await SharedPreferences.getInstance().then((prefs) => prefs.getString('uid') ?? '');
                                        setState(() {
                                          salesComments.add(
                                            SalesCommentModel(userId: uid, comment: val.trim()),
                                          );
                                          salesCommentController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_comment),
                                  onPressed: () async {
                                    if (salesCommentController.text.trim().isNotEmpty) {
                                      final String uid = await SharedPreferences.getInstance().then((prefs) => prefs.getString('uid') ?? '');
                                      setState(() {
                                        salesComments.add(
                                          SalesCommentModel(userId: uid, comment: salesCommentController.text.trim()),
                                        );
                                        salesCommentController.clear();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (salesComments.isNotEmpty)
                              Column(
                                children: salesComments
                                    .map((c) => ListTile(
                                          title: Text(c.comment),
                                          subtitle: Text('بواسطة: ${c.userId}'),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              setState(() => salesComments.remove(c));
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: 12),
                            // Dates
                            ListTile(
                              title: Text(lastContactAt == null
                                  ? 'آخر تواصل: ---'
                                  : 'آخر تواصل: ${lastContactAt!.toString().substring(0, 10)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_calendar),
                                onPressed: () => _pickDate(isNext: false),
                              ),
                            ),
                            ListTile(
                              title: Text(nextContactAt == null
                                  ? 'موعد التواصل القادم: ---'
                                  : 'موعد التواصل القادم: ${nextContactAt!.toString().substring(0, 10)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_calendar),
                                onPressed: () => _pickDate(isNext: true),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: state is AddClientLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          log('Adding client: ${nameController.text.trim()} , ${emailController.text.trim()}, ${phoneController.text.trim()}, $selectedService, $salesComments, $selectedStatus, $lastContactAt, $nextContactAt'
                                          );

                                          final String uid = await SharedPreferences.getInstance().then((prefs) => prefs.getString('uid') ?? '');
                                          final client = ClientaddModel(
                                            id: uid,
                                            name: nameController.text.trim(),
                                            email: emailController.text.trim(),
                                            phone: phoneController.text.trim(),
                                            serviceRequired: selectedService,
                                            salesComments: salesComments, // الآن قائمة SalesCommentModel
                                            status: selectedStatus,
                                            lastContactAt: lastContactAt,
                                            nextContactAt: nextContactAt,
                                          );
                                          BlocProvider.of<AddClientBloc>(context).add(SubmitAddClient(client));
                                        }
                                      },
                                child: state is AddClientLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('إضافة العميل', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}