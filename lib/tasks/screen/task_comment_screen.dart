import 'dart:io';
import 'package:attendance_app/tasks/task_comment_bloc/task_comment_bloc.dart';
import 'package:attendance_app/tasks/task_comment_bloc/task_comment_event.dart';
import 'package:attendance_app/tasks/task_comment_bloc/task_comment_state.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class TaskCommentScreen extends StatefulWidget {
  final int taskId;
  const TaskCommentScreen({super.key, required this.taskId});

  @override
  State<TaskCommentScreen> createState() => _TaskCommentScreenState();
}

class _TaskCommentScreenState extends State<TaskCommentScreen> {
  final TextEditingController commentController = TextEditingController();
  List<XFile> pickedImages = [];

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

  Future<void> _pickImages() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      _showDialog('يرجى السماح بالوصول للصور', DialogType.error);
      return;
    }
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        pickedImages.addAll(images);
      });
    }
  }

  Future<void> _downloadImage(String url) async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showDialog('يرجى السماح بالوصول للتخزين', DialogType.error);
          return;
        }
      }
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Pictures')
          : await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.data!);
      _showDialog('تم حفظ الصورة في:\n$filePath', DialogType.success);
    } catch (e) {
      _showDialog('حدث خطأ أثناء الحفظ: $e', DialogType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskCommentBloc(Dio())..add(FetchTaskCommentsEvent(widget.taskId)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('تعليقات المهمة'),
            backgroundColor: Colors.indigo,
            centerTitle: true,
          ),
          body: BlocConsumer<TaskCommentBloc, TaskCommentState>(
            listener: (context, state) {
              if (state is TaskCommentSuccess) {
                _showDialog(state.message, DialogType.success);
                commentController.clear();
                pickedImages.clear();
              } else if (state is TaskCommentError) {
                _showDialog(state.message, DialogType.error);
              }
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  if (state is TaskCommentLoading)
                    SliverList(delegate: SliverChildBuilderDelegate(
                      (_, i) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Card(margin: const EdgeInsets.all(8), child: Container(height: 100)),
                      ),
                      childCount: 3,
                    )),
                  if (state is TaskCommentLoaded)
                    SliverList(delegate: SliverChildBuilderDelegate(
                      (_, idx) {
                        final comment = state.comments[idx];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.indigo),
                                    const SizedBox(width: 8),
                                    Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text(comment.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(comment.comment),
                                if (comment.images.isNotEmpty)
                                  SizedBox(
                                    height: 120,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: comment.images.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (ctx, i) {
                                        final imgUrl = comment.images[i];
                                        return Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(imgUrl, width: 120, height: 120, fit: BoxFit.cover),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: IconButton(
                                                icon: const Icon(Icons.download, color: Colors.white, size: 28),
                                                onPressed: () => _downloadImage(imgUrl),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: state.comments.length,
                    )),
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      TextFormField(
                        controller: commentController,
                        minLines: 1, maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'أضف تعليق...', border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        if (pickedImages.isNotEmpty)
                          Expanded(
                            child: SizedBox(
                              height: 60,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: pickedImages.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 6),
                                itemBuilder: (_, i) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(File(pickedImages[i].path), width: 60, height: 60, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            pickedImages.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.7),
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
                          ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('إضافة صور'),
                          onPressed: _pickImages,
                        ),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('إضافة تعليق'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (commentController.text.trim().isEmpty) {
                              _showDialog('يرجى كتابة تعليق', DialogType.error);
                              return;
                            }
                            BlocProvider.of<TaskCommentBloc>(context).add(
                              AddTaskCommentEvent(
                                taskId: widget.taskId,
                                comment: commentController.text.trim(),
                                images: pickedImages.map((e) => File(e.path)).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
                  )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
