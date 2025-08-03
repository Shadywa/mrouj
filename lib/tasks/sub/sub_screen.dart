import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
  final ImagePicker _picker = ImagePicker();
// import 'dart:convert';

// --- Model ---
class SubStageModel {
  final String userId;
  final String description;
  final String status;
  final List<String> images; // paths
  SubStageModel({
    required this.userId,
    required this.description,
    required this.status,
    required this.images,
  });
}

// --- Bloc Events ---
abstract class SubStageEvent {}

class AddSubStageEvent extends SubStageEvent {
  final SubStageModel subStage;
  AddSubStageEvent(this.subStage);
}

class RemoveSubStageEvent extends SubStageEvent {
  final int index;
  RemoveSubStageEvent(this.index);
}

class SaveAllSubStagesEvent extends SubStageEvent {}

// --- Bloc States ---
abstract class SubStageState {}

class SubStageInitial extends SubStageState {
  final List<SubStageModel> subStages;
  SubStageInitial(this.subStages);
}

class SubStageLoading extends SubStageState {}

class SubStageSuccess extends SubStageState {
  final String message;
  SubStageSuccess(this.message);
}

class SubStageError extends SubStageState {
  final String message;
  SubStageError(this.message);
}

// --- Bloc ---
class SubStageBloc extends Bloc<SubStageEvent, SubStageState> {
  final int taskId;
  List<SubStageModel> _subStages = [];

  SubStageBloc(this.taskId) : super(SubStageInitial([])) {
    on<AddSubStageEvent>((event, emit) {
      _subStages.add(event.subStage);
      emit(SubStageInitial(List.from(_subStages)));
    });
    on<RemoveSubStageEvent>((event, emit) {
      _subStages.removeAt(event.index);
      emit(SubStageInitial(List.from(_subStages)));
    });
    on<SaveAllSubStagesEvent>((event, emit) async {
      emit(SubStageLoading());
      try {
        final dio = Dio();
        final url = 'https://drivo.elmoroj.com/api/tasks/$taskId/subtasks';
        // نرفع أول مرحلة فقط حسب الشكل المطلوب
        if (_subStages.isEmpty) {
          emit(SubStageError('لا يوجد مراحل للرفع'));
          return;
        }
        final sub = _subStages[0];
        FormData formData = FormData();
        formData.fields.add(MapEntry('description', sub.description));
        for (final opt in sub.status.split(',')) {
          formData.fields.add(MapEntry('status_options[]', opt.trim()));
        }
        formData.fields.add(MapEntry('status', sub.status));
        for (int j = 0; j < sub.images.length; j++) {
          formData.files.add(MapEntry(
            'images[]',
            await MultipartFile.fromFile(sub.images[j]),
          ));
        }
        log('--- بيانات المرسلة ---');
        log(formData.fields.toString());
        log('--- الصور المرسلة ---');
        log(formData.files.map((e) => e.value.filename).toList().toString());
        final response = await dio.post(url, data: formData);
        log('--- رد السيرفر ---');
        log(response.statusCode.toString());
        log(response.data.toString());
        if (response.statusCode == 200) {
          emit(SubStageSuccess('تم رفع المرحلة بنجاح'));
          _subStages.clear();
          emit(SubStageInitial([]));
        } else {
          emit(SubStageError('فشل رفع المرحلة: ${response.statusCode}'));
        }
      } catch (e) {
        log('--- خطأ أثناء رفع البيانات ---');
        log(e.toString());
        emit(SubStageError('خطأ أثناء رفع البيانات: $e'));
      }
    });
  }
}

// --- Screen ---
class SubStageScreen extends StatefulWidget {
  final int taskId;
  const SubStageScreen({super.key, required this.taskId});

  @override
  State<SubStageScreen> createState() => _SubStageScreenState();
}

class _SubStageScreenState extends State<SubStageScreen> {
  final TextEditingController descController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  String status = '';
  List<String> images = [];
  List<String> statusOptions = [];

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? '';
  }

  void _showDialog(String msg, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg, style: TextStyle(color: color)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // حالات افتراضية أول مرة فقط
    statusOptions = [

    ];
    status = statusOptions.isNotEmpty ? statusOptions[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubStageBloc(widget.taskId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('رفع مراحل التصميم'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3E6F3), Color(0xFFF8FAFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BlocConsumer<SubStageBloc, SubStageState>(
            listener: (context, state) {
              if (state is SubStageSuccess) {
                _showDialog(state.message, Colors.green);
              } else if (state is SubStageError) {
                _showDialog(state.message, Colors.red);
              }
            },
            builder: (context, state) {
              List<SubStageModel> subStages = [];
              if (state is SubStageInitial) {
                subStages = state.subStages;
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('بيانات المرحلة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: descController,
                                decoration: InputDecoration(
                                  labelText: 'وصف المرحلة',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: statusOptions.contains(status) ? status : null,
                                      items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => status = val);
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'الحالة',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: statusController,
                                      decoration: InputDecoration(
                                        labelText: 'إضافة حالة جديدة',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.indigo),
                                    onPressed: () {
                                      final newStatus = statusController.text.trim();
                                      if (newStatus.isNotEmpty && !statusOptions.contains(newStatus)) {
                                        setState(() {
                                          statusOptions.add(newStatus);
                                          status = newStatus;
                                          statusController.clear();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (statusOptions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: statusOptions.length,
                                      itemBuilder: (context, i) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Chip(
                                          label: Text(statusOptions[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                                          backgroundColor: Colors.indigo.shade100,
                                          deleteIcon: const Icon(Icons.close),
                                          onDeleted: () {
                                            setState(() {
                                              if (status == statusOptions[i]) status = statusOptions.isNotEmpty ? statusOptions[0] : '';
                                              statusOptions.removeAt(i);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              const Text('صور المرحلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigo)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('اختيار صور من المعرض'),
                                    onPressed: () async {
                                      final picked = await _picker.pickMultiImage();
                                      if (picked.isNotEmpty) {
                                        setState(() {
                                          images.addAll(picked.map((x) => x.path));
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text('عدد الصور: ${images.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (images.isNotEmpty)
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    itemBuilder: (context, i) => Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.indigo, width: 2),
                                            image: DecorationImage(
                                              image: Image.file(
                                                File(images[i]),
                                              ).image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                images.removeAt(i);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    if (descController.text.trim().isEmpty || status.isEmpty) return;
                                    final uid = await getUserId();
                                    context.read<SubStageBloc>().add(
                                      AddSubStageEvent(
                                        SubStageModel(
                                          userId: uid,
                                          description: descController.text.trim(),
                                          status: status,
                                          images: List.from(images),
                                        ),
                                      ),
                                    );
                                    descController.clear();
                                    setState(() {
                                      status = statusOptions.isNotEmpty ? statusOptions[0] : '';
                                      images.clear();
                                    });
                                  },
                                  child: const Text('إضافة مرحلة'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('المراحل المضافة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 12),
                      if (subStages.isEmpty)
                        Center(
                          child: Text('لا توجد مراحل مضافة بعد', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        ),
                      if (subStages.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subStages.length,
                          itemBuilder: (context, i) => Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: Text('${i + 1}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(subStages[i].description, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('الحالة: ${subStages[i].status} | صور: ${subStages[i].images.length}', style: const TextStyle(fontSize: 15)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  context.read<SubStageBloc>().add(RemoveSubStageEvent(i));
                                },
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          onPressed: subStages.isEmpty || state is SubStageLoading
                              ? null
                              : () {
                                  context.read<SubStageBloc>().add(SaveAllSubStagesEvent());
                                },
                          child: state is SubStageLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('رفع جميع المراحل'),
                        ),
                      ),
                    ],
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