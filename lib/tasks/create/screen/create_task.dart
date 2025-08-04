import 'package:attendance_app/botton_navigate/bottom_nav.dart';
import 'package:attendance_app/tasks/bloc/add_bloc/task_bloc.dart';
import 'package:attendance_app/tasks/bloc/add_bloc/task_event.dart';
import 'package:attendance_app/tasks/bloc/add_bloc/task_state.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateTaskScreen extends StatefulWidget {
  final String customerId;
  const CreateTaskScreen({super.key , required this.customerId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String status = 'pending';
  
  late final String userId;
   final List<String> statusList = ['pending', 'done', 'in_progress'];
  XFile? pickedImage;

  

  @override
  void initState() {
    super.initState();
    userId = widget.customerId;
  }

  void _showDialog(String msg, DialogType type) {
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.rightSlide,
      title: type == DialogType.success ? 'نجاح' : 'خطأ',
      desc: msg,
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (_) => TaskBloc(Dio()),
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('إدارة المهام'),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                centerTitle: true,
              ),
              body: BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskSuccess) {
                    _showDialog(state.message, DialogType.success);
                    Future.delayed(const Duration(milliseconds: 700), () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) => MainNavigationScreen(initialIndex: 2,),
                      ), (route) => false
                
                      );
                    });
                  } else if (state is TaskError) {
                    _showDialog(state.message, DialogType.error);
                  }
                },
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: nameController,
                                  decoration: const InputDecoration(labelText: 'اسم المهمة'),
                                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: descController,
                                  decoration: const InputDecoration(labelText: 'الوصف'),
                                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('الحالة:'),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: status,
                                      items: statusList
                                          .map((s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => status = val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('تاريخ البداية:'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDialog<DateTime>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('اختر تاريخ البداية'),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: EasyDateTimeLine(
                                                  initialDate: startDate ?? DateTime.now(),
                                                  onDateChange: (date) {
                                                    Navigator.pop(context, date);
                                                  },
                                                  activeColor: Colors.indigo,
                                                ),
                                              ),
                                            ),
                                          );
                                          if (picked != null) setState(() => startDate = picked);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(startDate == null ? 'اختر التاريخ' : startDate!.toString().substring(0, 10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('تاريخ النهاية:'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final picked = await showDialog<DateTime>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('اختر تاريخ النهاية'),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: EasyDateTimeLine(
                                                  initialDate: endDate ?? DateTime.now(),
                                                  onDateChange: (date) {
                                                    Navigator.pop(context, date);
                                                  },
                                                  activeColor: Colors.indigo,
                                                ),
                                              ),
                                            ),
                                          );
                                          if (picked != null) setState(() => endDate = picked);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(endDate == null ? 'اختر التاريخ' : endDate!.toString().substring(0, 10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    if (pickedImage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Image.file(
                                          File(pickedImage!.path),
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.image),
                                      label: const Text('إضافة صورة'),
                                      onPressed: _pickImage,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('إضافة مهمة' , style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate() && startDate != null && endDate != null) {
                                        BlocProvider.of<TaskBloc>(context).add(
                                          AddTaskEvent(
                                            userId: userId,
                                            taskName: nameController.text.trim(),
                                            description: descController.text.trim(),
                                            startTime: startDate!.toString().substring(0, 10),
                                            endTime: endDate!.toString().substring(0, 10),
                                            status: status,
                                            image: pickedImage != null ? File(pickedImage!.path) : null,
                                          ),
                                        );
                                      } else {
                                        _showDialog('يرجى تعبئة جميع الحقول واختيار التواريخ', DialogType.error);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // عرض المهام
                      if (state is TaskLoading)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Container(height: 80),
                              ),
                            ),
                            childCount: 3,
                          ),
                        ),
                      // if (state is TasksLoaded)
                      //   SliverList(
                      //     delegate: SliverChildBuilderDelegate(
                      //       (context, index) {
                      //         final task = state.tasks[index];
                      //         return Card(
                      //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //           child: ListTile(
                      //             title: Text(task['task_name'] ?? ''),
                      //             subtitle: Text(task['description'] ?? ''),
                      //             trailing: Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 Text('من: ${task['start_time'] ?? ''}'),
                      //                 Text('إلى: ${task['end_time'] ?? ''}'),
                      //                 Text('الحالة: ${task['status'] ?? ''}'),
                      //               ],
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //       childCount: state.tasks.length,
                      //     ),
                      //   ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
