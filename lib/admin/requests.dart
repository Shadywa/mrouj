import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class TeamLeaderApprovalPage extends StatefulWidget {
  const TeamLeaderApprovalPage({super.key});

  @override
  State<TeamLeaderApprovalPage> createState() => _TeamLeaderApprovalPageState();
}

class _TeamLeaderApprovalPageState extends State<TeamLeaderApprovalPage> {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://us-central1-eljudymarket.cloudfunctions.net';
  bool _isLoading = true;
  List<PermissionRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchPending();
  }

  Future<void> _fetchPending() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final leaderId = prefs.getString('uid');
    if (leaderId == null) return;

    try {
      final resp = await _dio.get(
        '$_baseUrl/getPendingPermissionsForLeader',
        queryParameters: {'leaderId': leaderId},
      );
      final List data = resp.data as List;
      _requests = data.map((j) => PermissionRequest.fromJson(j)).toList();
    } catch (e) {
      debugPrint('Error fetching pending: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final leaderId = prefs.getString('uid');
    try {
      await _dio.post('$_baseUrl/approveByTeamLeader', data: {
        'requestId': requestId,
        'leaderId': leaderId,
      });
      _showSuccess('تمت الموافقة بنجاح');
      setState(() {
        _requests.removeWhere((r) => r.id == requestId);
      });
    } catch (e) {
      _showError('فشل في الموافقة');
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final leaderId = prefs.getString('uid');
    try {
      await _dio.post('$_baseUrl/rejectPermission', data: {
        'requestId': requestId,
        'reviewerId': leaderId,
        'reason': 'رفض من التيم ليدر',
      });
      _showSuccess('تم الرفض بنجاح');
      setState(() {
        _requests.removeWhere((r) => r.id == requestId);
      });
    } catch (e) {
      _showError('فشل في الرفض');
    }
  }

  void _showSuccess(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'نجاح',
      desc: message,
      autoHide: const Duration(seconds: 2),
    ).show();
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: 'خطأ',
      desc: message,
      autoHide: const Duration(seconds: 3),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text(
          'طلبات الإذن (التيم ليدر)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد طلبات حالياً',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: const Color(0xFF2A2A40),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  req.userName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _infoText('📅 التاريخ', req.date),
                        //    _infoText('⏱ الساعات', req.hours.toString()),
                            _infoText('📄 السبب', req.reason),
                            const Divider(color: Colors.white24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _approveRequest(req.id),
                                  icon: const Icon(Icons.check, color: Colors.white),
                                  label: const Text('موافقة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _rejectRequest(req.id),
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  label: const Text('رفض'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PermissionRequest {
  final String id;
  final String userId;
  final String userName;
  final String date;
  final double hours;
  final String reason;

  PermissionRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.hours,
    required this.reason,
  });

  factory PermissionRequest.fromJson(Map<String, dynamic> json) {
    return PermissionRequest(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? '',
      date: json['date'],
      hours: (json['hours'] as num).toDouble(),
      reason: json['reason'] ?? '',
    );
  }
}
