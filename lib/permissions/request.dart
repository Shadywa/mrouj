import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class RequestPermissionPage extends StatefulWidget {
  const RequestPermissionPage({super.key});

  @override
  State<RequestPermissionPage> createState() => _RequestPermissionPageState();
}

class _RequestPermissionPageState extends State<RequestPermissionPage> {
  final _formKey = GlobalKey<FormState>();
  String? userId;
  String? name;
  String type = 'خروج مبكر';
  DateTime? selectedDate;
  String duration = 'ساعة';
  final reasonController = TextEditingController();

  bool isSubmitting = false;

  final dio = Dio();
  final cloudFunctionUrl = 'https://us-central1-eljudymarket.cloudfunctions.net/requestPermission';

  @override
  void initState() {
    super.initState();
    _loadUser();
    selectedDate = DateTime.now();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('uid');
      name = prefs.getString('name');
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await dio.post(cloudFunctionUrl, data: {
        'userId': userId,
        'name': name,
        'mainType': 'استئذان', // ثابت هنا
        'type': type,           // من اختيار المستخدم
        'date': selectedDate!.toIso8601String(),
        'hours': duration,
        'reason': reasonController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال طلب الإذن بنجاح')),
      );

      setState(() {
        type = 'خروج مبكر';
        duration = 'ساعة';
        selectedDate = DateTime.now();
        reasonController.clear();
      });
    } catch (e) {
      log('Error submitting permission request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ حدث خطأ أثناء إرسال الطلب')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: const Color(0xfff6f8fa),
      appBar: AppBar(
        title: const Text('طلب إذن'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.indigo.shade50],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.09),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('نوع الإذن'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: type,
                        items: [
                          'خروج مبكر',
                          'تأخير',
                          'استئذان خلال اليوم'
                        ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setState(() => type = val!),
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('اليوم'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: EasyDateTimeLine(
                          initialDate: selectedDate ?? today,
                          // : DateTime(today.year, today.month, today.day),
                        locale: 'ar',
                          // يمنع اختيار تاريخ قبل اليوم
                          onDateChange: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          // locale: 'ar',
                          activeColor: Colors.indigo,
                          dayProps: const EasyDayProps(
                            width: 48,
                            height: 64,
                            dayStructure: DayStructure.dayStrDayNum,
                            // borderRadius: 12,
                            // locale: 'ar',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('مدة الإذن'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: duration,
                        items: [
                          'ساعة',
                          'ساعتين',
                          'نصف يوم'
                        ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) => setState(() => duration = val!),
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('سبب الإذن'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: reasonController,
                        decoration: _inputDecoration(hint: 'اكتب السبب هنا'),
                        maxLines: 3,
                        validator: (val) => val!.isEmpty ? 'الرجاء كتابة السبب' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          onPressed: isSubmitting ? null : _submitRequest,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                          label: const Text('إرسال الطلب', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (name != null)
                  Text(
                    'المستخدم: $name',
                    style: TextStyle(
                      color: Colors.indigo.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 1.5),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0, right: 2.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.indigo.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
