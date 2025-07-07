class ClientaddModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? serviceRequired;
  final List<SalesCommentModel>? salesComments; // <-- عدل هنا
  final String? status;
  final DateTime? lastContactAt;
  final DateTime? nextContactAt;

  ClientaddModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.serviceRequired,
    this.salesComments,
    this.status,
    this.lastContactAt,
    this.nextContactAt,
  });

  Map<String, dynamic> toJson() => {
        'sales_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'service_required': serviceRequired,
        'sales_comments': salesComments?.map((e) => e.toJson()).toList(), // <-- عدل هنا
        'status': status,
        'last_contact_at': lastContactAt?.toIso8601String(),
        'next_contact_at': nextContactAt?.toIso8601String(),
      };
}

class SalesCommentModel {
  final String userId;
  final String comment;

  SalesCommentModel({required this.userId, required this.comment});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'comment': comment,
      };
}