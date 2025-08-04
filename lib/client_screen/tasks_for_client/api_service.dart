import 'package:dio/dio.dart';
import 'models.dart';

class TaskApiService {
  final Dio dio = Dio();

  Future<List<TaskCustomerModel>> fetchTasksForCustomer(String customerId) async {
    final url = 'https://drivo.elmoroj.com/api/tasks/customer/$customerId';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final tasks = (data['tasks'] as List)
          .map((e) => TaskCustomerModel.fromJson(e))
          .toList();
      return tasks;
    } else {
      throw Exception('فشل تحميل المهام');
    }
  }
}