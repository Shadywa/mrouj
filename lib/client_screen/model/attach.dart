import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SalesUser {
  final String id;
  final String name;
  SalesUser({required this.id, required this.name});

  static Future<List<SalesUser>> fetchSalesUsers() async {
    final response = await Dio().get(
      'https://drivo.elmoroj.com/api/users/sales',
    );
    final List data = response.data;
    return data.map((e) => SalesUser(id: e['id'], name: e['name'])).toList();
  }

  static Future<List<SalesUser>> fetchAccountUsers() async {
    final response = await Dio().get(
      'https://drivo.elmoroj.com/api/users/finance',
    );
    final List data = response.data;
    return data.map((e) => SalesUser(id: e['id'], name: e['name'])).toList();
  }
}

void showSalesDialog(BuildContext context, String clientId) async {
  final salesUsers = await SalesUser.fetchSalesUsers();
  final selected = <String>{};

  showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('إضافة سيلز للعميل'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView(
                    children:
                        salesUsers.map((user) {
                          return CheckboxListTile(
                            value: selected.contains(user.id),
                            title: Text(user.name),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selected.add(user.id);
                                } else {
                                  selected.remove(user.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('إلغاء'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text('حفظ'),
                    onPressed: () async {
                      for (final salesId in selected) {
                        final Response = await Dio().post(
                          'https://drivo.elmoroj.com/api/customers/$clientId/add-attachment',
                          data: {'sales_id': salesId},
                        );
                        log('Response: ${Response.data}');
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة السيلز بنجاح')),
                      );
                    },
                  ),
                ],
              ),
        ),
      );
    },
  );
}

void showAccountDialog(BuildContext context, String clientId) async {
  final salesUsers = await SalesUser.fetchAccountUsers();
  final selected = <String>{};

  showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('إضافة محاسب للعميل'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView(
                    children:
                        salesUsers.map((user) {
                          return CheckboxListTile(
                            value: selected.contains(user.id),
                            title: Text(user.name),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selected.add(user.id);
                                } else {
                                  selected.remove(user.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('إلغاء'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text('حفظ'),
                    onPressed: () async {
                      try {
                        for (final salesId in selected) {
                          log(
                            'Adding sales ID: $salesId to client ID: $clientId',
                          );
                          final Response = await Dio().post(
                            'https://drivo.elmoroj.com/api/customers/$clientId/attachment-account/add',
                            data: {'account_id': salesId},
                          );
                          log('Response: ${Response.data}');
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إضافة المحاسب بنجاح'),
                          ),
                        );
                      } catch (e) {
                        log('Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('فشل في إضافة المحاسب')),
                        );
                      }
                    },
                  ),
                ],
              ),
        ),
      );
    },
  );
}

void showSocialDialog(BuildContext context, String clientId) async {
  final salesUsers = await SalesUser.fetchAccountUsers();
  final selected = <String>{};

  showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('إضافة محاسب للعميل'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView(
                    children:
                        salesUsers.map((user) {
                          return CheckboxListTile(
                            value: selected.contains(user.id),
                            title: Text(user.name),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selected.add(user.id);
                                } else {
                                  selected.remove(user.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('إلغاء'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text('حفظ'),
                    onPressed: () async {
                      for (final salesId in selected) {
                        final Response = await Dio().post(
                          'https://drivo.elmoroj.com/api/customers/$clientId/attachment-account/add',
                          data: {'sales_id': salesId},
                        );
                        log('Response: ${Response.data}');
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة السيلز بنجاح')),
                      );
                    },
                  ),
                ],
              ),
        ),
      );
    },
  );
}
