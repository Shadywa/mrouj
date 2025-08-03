import 'dart:convert';

class SalesComment {
  final String userId;
  final String userName;
  final String comment;

  SalesComment({
    required this.userId,
    required this.comment,
    required this.userName,
  });

  factory SalesComment.fromJson(dynamic json) {
    // إذا جاء كـ String JSON داخل List
    if (json is String) {
      final decoded = jsonDecode(json);
      return SalesComment(
        userId: decoded['user_id'],
        comment: decoded['comment'],
        userName: decoded['user_name'] ?? '', // إضافة userName مع
      );
    }
    // إذا جاء كـ Map
    return SalesComment(
      userId: json['user_id'],
      comment: json['comment'],
      userName: json['user_name'] ?? '', // إضافة userName مع
    );
  }

  Map<String, dynamic> toJson() => {'user_id': userId, 'comment': comment};
}

class SocialMediaComment {
  final String userId;
  final String userName;
  final String comment;
  final String date;

  SocialMediaComment({
    required this.userId,
    required this.comment,
    required this.userName,
    required this.date,
  });

  factory SocialMediaComment.fromJson(dynamic json) {
    // إذا جاء كـ String JSON داخل List
    if (json is String) {
      final decoded = jsonDecode(json);
      return SocialMediaComment(
        date: decoded['date'] ?? DateTime.now().toString().substring(0, 16),
        userId: decoded['user_id'],
        comment: decoded['comment'],
        userName: decoded['user_name'] ?? '', // إضافة userName مع
      );
    }
    // إذا جاء كـ Map
    return SocialMediaComment(
      date: json['date'] ?? DateTime.now().toString().substring(0, 16),
      userId: json['user_id'],
      comment: json['comment'],
      userName: json['user_name'] ?? '', // إضافة userName مع
    );
  }

  Map<String, dynamic> toJson() => {'user_id': userId, 'comment': comment};
}

class AccountComment {
  final String userId;
  final String userName;
  final String date;

  final String comment;

  AccountComment({
    required this.userId,
    required this.date,

    required this.comment,
    required this.userName,
  });

  factory AccountComment.fromJson(dynamic json) {
    // إذا جاء كـ String JSON داخل List
    if (json is String) {
      final decoded = jsonDecode(json);
      return AccountComment(
        date: decoded['date'],
        userId: decoded['user_id'],
        comment: decoded['comment'],
        userName: decoded['user_name'] ?? '', // إضافة userName مع
      );
    }
    // إذا جاء كـ Map
    return AccountComment(
      date: json['date'] ?? DateTime.now().toString().substring(0, 16),
      userId: json['user_id'],
      comment: json['comment'],
      userName: json['user_name'] ?? '', // إضافة userName مع
    );
  }

  Map<String, dynamic> toJson() => {'user_id': userId, 'comment': comment};
}

class WorkComment {
  final String userId;
  final String comment;
  final String date;
  final String userName;

  WorkComment({
    required this.userId,
    required this.comment,
    required this.date,
    required this.userName,
  });

  factory WorkComment.fromJson(Map<String, dynamic> json) => WorkComment(
    userId: json['user_id'],
    comment: json['comment'],
    userName: json['user_name'], // إضافة userName مع
    date: json['date'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'comment': comment,
    'date': date,
  };
}

class GeneralComment {
  final String userId;
  final String userName;
  final String date;
  final String comment;

  GeneralComment({
    required this.userId,
    required this.date,
    required this.comment,
    required this.userName,
  });

  factory GeneralComment.fromJson(dynamic json) {
    if (json is String) {
      final decoded = jsonDecode(json);
      return GeneralComment(
        date: decoded['date'],
        userId: decoded['user_id'],
        comment: decoded['comment'],
        userName: decoded['user_name'] ?? '',
      );
    }
    return GeneralComment(
      date: json['date'] ?? DateTime.now().toString().substring(0, 16),
      userId: json['user_id'],
      comment: json['comment'],
      userName: json['user_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'user_id': userId, 'comment': comment};
}

class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? phone2;
  final String? phone3;
  final String profilePicture;
  final String? serviceRequired;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastContactAt;
  final DateTime? nextContactAt;
  final String? status;
  final String? salesId;
  final List<String>? attachmentSales;
  final List<String>? attachment_account;
  final List<String>? attachment_socialmedia;
  final List<SalesComment>? salesComments;
  final List<WorkComment>? workComments;
  final List<AccountComment>? accountComments;
  final List<SocialMediaComment>? socialMediaComments;
  final bool? boolIsInSocial;
  final bool? boolIsInAccount;
  final List<GeneralComment>? generalComments;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.phone2,
    this.phone3,
    required this.profilePicture,
    this.serviceRequired,
    this.createdAt,
    this.updatedAt,
    this.lastContactAt,
    this.nextContactAt,
    this.status,
    this.salesId,
    this.attachmentSales,
    this.salesComments,
    this.workComments,
    this.attachment_account,
    this.accountComments,
    this.attachment_socialmedia,
    this.socialMediaComments,
    this.boolIsInSocial,
    this.boolIsInAccount,
    this.generalComments,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    id: json['id'].toString(),
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    phone2: json['phone2'],
    phone3: json['phone3'],
    profilePicture: json['profile_picture'] ?? '',
    serviceRequired: json['service_required'],
    createdAt:
        json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
    updatedAt:
        json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
    lastContactAt:
        json['last_contact_at'] != null
            ? DateTime.tryParse(json['last_contact_at'])
            : null,
    nextContactAt:
        json['next_contact_at'] != null
            ? DateTime.tryParse(json['next_contact_at'])
            : null,
    status: json['status'],
    salesId: json['sales_id'],
    attachment_account:
        json['attachment_account'] != null
            ? List<String>.from(json['attachment_account'])
            : null,
    attachmentSales:
        json['attachment_sales'] != null
            ? List<String>.from(json['attachment_sales'])
            : null,
    attachment_socialmedia:
        json['attachment_socialmedia'] != null
            ? List<String>.from(json['attachment_socialmedia'])
            : null,
    salesComments:
        json['sales_comments'] != null
            ? (json['sales_comments'] as List).expand((e) {
              if (e is String) {
                final decoded = jsonDecode(e);
                if (decoded is List) {
                  return decoded.map((item) => SalesComment.fromJson(item));
                } else {
                  return [SalesComment.fromJson(decoded)];
                }
              } else {
                return [SalesComment.fromJson(e)];
              }
            }).toList()
            : null,

    socialMediaComments:
        json['socialmedia_comments'] != null
            ? (json['socialmedia_comments'] as List).expand((e) {
              if (e is String) {
                final decoded = jsonDecode(e);
                if (decoded is List) {
                  return decoded.map(
                    (item) => SocialMediaComment.fromJson(item),
                  );
                } else {
                  return [SocialMediaComment.fromJson(decoded)];
                }
              } else {
                return [SocialMediaComment.fromJson(e)];
              }
            }).toList()
            : null,
    workComments:
        json['work_comments'] != null
            ? (json['work_comments'] as List)
                .map((e) => WorkComment.fromJson(e))
                .toList()
            : null,
    accountComments:
        json['account_comments'] != null
            ? (json['account_comments'] as List)
                .map((e) => AccountComment.fromJson(e))
                .toList()
            : null,
    boolIsInSocial: json['BoolIsInSocial'] == 1,
    boolIsInAccount: json['BoolIsInAccount'] == 1,
    generalComments: json['general_comments'] != null
        ? (json['general_comments'] as List)
            .map((e) => GeneralComment.fromJson(e))
            .toList()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'service_required': serviceRequired,
    'sales_comments': salesComments,
    'status': status,
    'last_contact_at': lastContactAt?.toIso8601String(),
    'next_contact_at': nextContactAt?.toIso8601String(),
    'BoolIsInSocial': boolIsInSocial == true ? 1 : 0,
    'BoolIsInAccount': boolIsInAccount == true ? 1 : 0,
    'general_comments': generalComments?.map((e) => e.toJson()).toList(),
  };
}
