import 'package:trekka/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String usrFullname,
    required String usrEmail,
    String? usrGender,
    int? usrAge,
    String? usrJob,
    List<String>? usrPreferences,
    double? usrBudget,
    String? usrAvatar,
    String? usrBio,
    required bool isActive,
    required DateTime usrCreatedAt,
  }) : super(
    id: id,
    usrFullname: usrFullname,
    usrEmail: usrEmail,
    usrGender: usrGender,
    usrAge: usrAge,
    usrJob: usrJob,
    usrPreferences: usrPreferences,
    usrBudget: usrBudget,
    usrAvatar: usrAvatar,
    usrBio: usrBio,
    isActive: isActive,
    usrCreatedAt: usrCreatedAt,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      usrFullname: json['usr_fullname'],
      usrEmail: json['usr_email'],
      usrGender: json['usr_gender'],
      usrAge: json['usr_age'],
      usrJob: json['usr_job'],
      usrPreferences: List<String>.from(json['usr_preferences'] ?? []),
      usrBudget: json['usr_budget'] != null ? double.parse(json['usr_budget'].toString()) : null,
      usrAvatar: json['usr_avatar'],
      usrBio: json['usr_bio'],
      isActive: json['is_active'],
      usrCreatedAt: DateTime.parse(json['usr_created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usr_fullname': usrFullname,
      'usr_email': usrEmail,
      'usr_gender': usrGender,
      'usr_age': usrAge,
      'usr_job': usrJob,
      'usr_preferences': usrPreferences,
      'usr_budget': usrBudget,
      'usr_avatar': usrAvatar,
      'usr_bio': usrBio,
      'is_active': isActive,
      'usr_created_at': usrCreatedAt.toIso8601String(),
    };
  }
}