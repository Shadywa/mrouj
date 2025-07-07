import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class RequestAbsencePage extends StatefulWidget {
  const RequestAbsencePage({super.key});

  @override
  State<RequestAbsencePage> createState() => _RequestAbsencePageState();
}

class _RequestAbsencePageState extends State<RequestAbsencePage> {
  final _formKey = GlobalKey<FormState>();
  String? userId;
  String? name;
  DateTime? selectedDate;
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
        'mainType': 'غياب', // ثابت هنا
        'type': 'غياب' ,     // ثابت هنا
        'date': selectedDate!.toIso8601String(),
        'hours': 'يوم كامل', // الصحيح
        'reason': reasonController.text.trim(),
});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال طلب الغياب بنجاح')),
      );

      setState(() {
        selectedDate = DateTime.now();
        reasonController.clear();
      });
    } catch (e) {
      log('Error submitting absence request: $e');
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
        title: const Text('طلب غياب'),
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
                // Header أيقونة غياب
                Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.red.withOpacity(0.12),
                      child: const Icon(Icons.event_busy, color: Colors.red, size: 38),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "طلب غياب يوم كامل",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "يرجى اختيار اليوم وكتابة سبب الغياب",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                          // startDate: DateTime(today.year, today.month, today.day), // يمنع اختيار قبل اليوم
                          locale: 'ar',
                          onDateChange: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          activeColor: Colors.indigo,
                          dayProps: const EasyDayProps(
                            width: 48,
                            height: 64,
                            dayStructure: DayStructure.dayStrDayNum,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel('سبب الغياب'),
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