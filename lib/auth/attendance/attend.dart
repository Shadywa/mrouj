import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRAttendancePage extends StatefulWidget {
  const QRAttendancePage({super.key});

  @override
  State<QRAttendancePage> createState() => _QRAttendancePageState();
}

class _QRAttendancePageState extends State<QRAttendancePage> {
  bool isProcessing = false;
  bool hasScanned = false;
  final AttendanceApi api = AttendanceApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('تسجيل الحضور'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // خلفية دائرية شفافة خلف الكاميرا
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // الكاميرا مع إطار دائري
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.shade700,
                    width: 4,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: MobileScanner(
                    controller: MobileScannerController(torchEnabled: false),
                    fit: BoxFit.cover,
                    onDetect: (capture) async {
                      if (isProcessing || hasScanned) return;
                      isProcessing = true;

                      final barcode = capture.barcodes.first;
                      final qrToken = barcode.rawValue;
                      if (qrToken == null) {
                        isProcessing = false;
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getString('uid');
                      if (userId == null) {
                        _showError('لا يوجد مستخدم مسجل');
                        return;
                      }

                      try {
                        final result = await api.markAttendance(userId: userId, qrToken: qrToken);
                        if (result.success) {
                          hasScanned = true;
                          _showSuccess(result.message ?? 'تم تسجيل الحضور بنجاح');
                        } else {
                          _showError(result.error ?? 'فشل تسجيل الحضور');
                        }
                      } catch (e) {
                        _showError('حدث خطأ أثناء الاتصال');
                      } finally {
                        await Future.delayed(const Duration(seconds: 2));
                        isProcessing = false;
                      }
                    },
                  ),
                ),
              ),
            ),
            // تعليمات وأزرار أسفل الشاشة
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'وجّه الكاميرا نحو رمز QR الخاص بالحضور',
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.flash_on, color: Colors.blue.shade700),
                          tooltip: 'تشغيل/إيقاف الفلاش',
                          onPressed: () {
                            MobileScannerController().toggleTorch();
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.cameraswitch, color: Colors.blue.shade700),
                          tooltip: 'تبديل الكاميرا',
                          onPressed: () {
                            MobileScannerController().switchCamera();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: '✅ نجاح',
      desc: message,
      autoHide: const Duration(seconds: 2),
      onDismissCallback: (_) {
        Navigator.pop(context); 
      },
    ).show();
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: '❌ خطأ',
      desc: message,
      autoHide: const Duration(seconds: 3),
    ).show();
    isProcessing = false;
  }
}


class AttendanceApi {
  final Dio _dio;

  /// عنوان الدوال في Firebase
  static const _baseUrl = 'https://us-central1-eljudymarket.cloudfunctions.net';

  AttendanceApi([Dio? dio]) : _dio = dio ?? Dio();

  /// يجلب رمز QR المتغيّر وصلاحيته
  Future<GenerateQrResponse> generateQr() async {
    final response = await _dio.get('$_baseUrl/generateAttendanceQR');
    return GenerateQrResponse.fromJson(response.data);
  }

  /// يتحقق من رمز QR ويسجل حضور المستخدم
  Future<MarkAttendanceResponse> markAttendance({
    required String userId,
    required String qrToken,
    String? timestamp, // ISO8601
  }) async {
    final data = {
      'userId': userId,
      'qrToken': qrToken,
      if (timestamp != null) 'timestamp': timestamp,
    };
    final response = await _dio.post(
      '$_baseUrl/markAttendanceWithQR',
      data: data,
    );
    return MarkAttendanceResponse.fromJson(response.data);
  }
}

/// نموذج استجابة QR
class GenerateQrResponse {
  final String qrToken;
  final DateTime expiresAt;

  GenerateQrResponse({required this.qrToken, required this.expiresAt});

  factory GenerateQrResponse.fromJson(Map<String, dynamic> json) {
    return GenerateQrResponse(
      qrToken: json['qrToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}

/// نموذج استجابة تسجيل الحضور
class MarkAttendanceResponse {
  final bool success;
  final String? message;
  final String? error;

  MarkAttendanceResponse({required this.success, this.message, this.error});

  factory MarkAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return MarkAttendanceResponse(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
    );
  }
}
