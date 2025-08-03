import 'dart:developer';
import 'package:attendance_app/client_screen/bloc/update_bloc/bloc.dart';
import 'package:attendance_app/client_screen/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';


class GeneralWorkCommentsScreen extends StatefulWidget {
  final String userName;
  final String userRole;
  final ClientModel client;
  const GeneralWorkCommentsScreen({
    super.key,
    required this.client,
    required this.userName,
    required this.userRole,
  });

  @override
  State<GeneralWorkCommentsScreen> createState() => _WorkCommentsScreenState();
}

class _WorkCommentsScreenState extends State<GeneralWorkCommentsScreen> {
  final commentController = TextEditingController();
  List<GeneralComment> workComments = [];

  @override
  void initState() {
    super.initState();
  
      workComments = widget.client.generalComments ?? [];
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
                    GeneralComment(
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
                                              Text('بواسطة: ${c.userName } '),
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
                         

                          List<String> uids = [
  ...?widget.client.attachmentSales,
  ...?widget.client.attachment_account,
  ...?widget.client.attachment_socialmedia,
];


                          BlocProvider.of<ClientActionBloc>(context).add(
                            AddGeneralWorkCommentEvent(
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
