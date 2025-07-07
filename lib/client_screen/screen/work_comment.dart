import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../model/model.dart';
import '../bloc/update_bloc/bloc.dart';

class WorkCommentsScreen extends StatefulWidget {
  final String userName;
  final String userRole;
  final ClientModel client;
  const WorkCommentsScreen({
    super.key,
    required this.client,
    required this.userName,
    required this.userRole,
  });

  @override
  State<WorkCommentsScreen> createState() => _WorkCommentsScreenState();
}

class _WorkCommentsScreenState extends State<WorkCommentsScreen> {
  final commentController = TextEditingController();
  List<WorkComment> workComments = [];

  @override
  void initState() {
    super.initState();
    if (widget.userRole.trim().toLowerCase() == 'finance') {
      workComments =
          List<AccountComment>.from(widget.client.accountComments ?? [])
              .map(
                (e) => WorkComment(
                  userId: e.userId,
                  comment: e.comment,
                  date: e.date,
                  userName: e.userName,
                ),
              )
              .toList();
    } else if (widget.userRole.trim().toLowerCase() == 'sales') {
      workComments = List<WorkComment>.from(widget.client.workComments ?? []);
    } else if (widget.userRole.trim().toLowerCase() == 'social') {
      workComments =
          List<AccountComment>.from(widget.client.workComments ?? [])
              .map(
                (e) => WorkComment(
                  userId: e.userId,
                  comment: e.comment,
                  date: e.date,
                  userName: e.userName,
                ),
              )
              .toList();
    } else {
      workComments = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientActionBloc(Dio()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('تعليقات العمل'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          body: BlocConsumer<ClientActionBloc, ClientActionState>(
            listener: (context, state) {
              if (state is ClientActionSuccess) {
                setState(() {
                  workComments.add(
                    WorkComment(
                      userName: '',
                      userId: '', // سيملأه السيرفر أو تجاهله في العرض
                      comment: commentController.text.trim(),
                      date: DateTime.now().toString().substring(0, 16),
                    ),
                  );
                  commentController.clear();
                });
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is ClientActionError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Expanded(
                      child:
                          workComments.isEmpty
                              ? const Center(child: Text('لا توجد تعليقات عمل'))
                              : ListView.builder(
                                itemCount: workComments.length,
                                itemBuilder: (context, index) {
                                  final c = workComments[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: ListTile(
                                      title: Text(c.comment),
                                      subtitle: Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text('بواسطة: ${c.userName} '),
                                            ],
                                          ),
                                          Spacer(),
                                          Text(
                                            c.date,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أضف تعليق عمل...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('إضافة تعليق'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          log(widget.userRole);
                          final userRole = widget.userRole.trim().toLowerCase();

                          List<String> uids = [];

                          if (userRole == 'finance') {
                            uids = widget.client.attachment_account ?? [];
                          } else if (userRole == 'sales') {
                            uids = widget.client.attachmentSales ?? [];
                          } else if (userRole == 'social') {
                            uids =
                                widget.client.attachmentSales ??
                                []; // أو استبدلها بالمتغير الصح إن كان فيه متغير ثاني للسوشيال
                          }

                          BlocProvider.of<ClientActionBloc>(context).add(
                            AddWorkCommentEvent(
                              uids: uids,
                              clientId: widget.client.id,
                              comment: commentController.text.trim(),
                              department: widget.userRole,
                            ),
                          );
                        },
                      ),
                    ),
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
