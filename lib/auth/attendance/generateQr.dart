import 'dart:async';

import 'package:attendance_app/auth/attendance/attend.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrPage extends StatefulWidget {
  const GenerateQrPage({super.key});

  @override
  State<GenerateQrPage> createState() => _GenerateQrPageState();
}

class _GenerateQrPageState extends State<GenerateQrPage> {
  final AttendanceApi _api = AttendanceApi();
  String? _qrToken;
  DateTime? _expiresAt;
  Timer? _refreshTimer;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadQr();
    // كل فترة 5 دقائق نجدد
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _loadQr());
    // مؤقت لكل ثانية لتحديث العداد
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  Future<void> _loadQr() async {
    try {
      final resp = await _api.generateQr();
      setState(() {
        _qrToken = resp.qrToken;
        _expiresAt = resp.expiresAt;
        _updateRemaining();
      });
    } catch (e) {
      // تعامل مع الخطأ
      debugPrint('Failed to load QR: $e');
    }
  }

  void _updateRemaining() {
    if (_expiresAt == null) return;
    final now = DateTime.now().toUtc();
    final diff = _expiresAt!.toUtc().difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز الحضور المتغيّر')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _qrToken == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عرض رمز الـ QR
                    QrImageView(
                      data: _qrToken!,
                      version: QrVersions.auto,
                      size: 250,
                    ),
                    const SizedBox(height: 20),
                    // عداد تنازلي
                    Text(
                      'ينتهي خلال: ${_remaining.inMinutes.remainder(60).toString().padLeft(2,'0')}:${(_remaining.inSeconds.remainder(60)).toString().padLeft(2,'0')}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadQr,
                      child: const Text('تحديث الآن'),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
