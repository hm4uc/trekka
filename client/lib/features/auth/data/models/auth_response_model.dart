import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullname,
    super.token,
    super.avatar,
    super.gender,
    super.ageGroup,
    super.age,
    super.job,
    super.bio,
    super.budget,
    super.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userData;
    String? token;

    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      if (data.containsKey('profile') && data.containsKey('token')) {
        userData = data['profile'] as Map<String, dynamic>;
        token = data['token'] as String?;
      } else {
        userData = data;
        token = null;
      }
    } else if (json.containsKey('user')) {
      userData = json['user'];
      token = json['token'];
    } else {
      userData = json;
      token = json['token'];
    }

    // Xử lý tuổi - nhận cả số và chuỗi
    int? ageValue;
    if (userData['usr_age'] != null) {
      if (userData['usr_age'] is int) {
        ageValue = userData['usr_age'];
      } else if (userData['usr_age'] is String) {
        ageValue = int.tryParse(userData['usr_age']);
      } else if (userData['usr_age'] is num) {
        ageValue = (userData['usr_age'] as num).toInt();
      }
    }

    return UserModel(
      id: userData['id']?.toString() ?? userData['usr_id']?.toString() ?? '',
      fullname: userData['usr_fullname'] ?? '',
      email: userData['usr_email'] ?? '',
      token: token,
      avatar: userData['usr_avatar'],
      gender: userData['usr_gender'],
      ageGroup: userData['usr_age_group'],
      age: ageValue,
      job: userData['usr_job'],
      bio: userData['usr_bio'],
      budget: userData['usr_budget'] is String
          ? double.tryParse(userData['usr_budget'])
          : (userData['usr_budget'] as num?)?.toDouble(),
      preferences: (userData['usr_preferences'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usr_fullname': fullname,
      'usr_email': email,
      'token': token,
      'usr_avatar': avatar,
      'usr_gender': gender,
      'usr_age_group': ageGroup,
      'usr_age': age,
      'usr_job': job,
      'usr_bio': bio,
      'usr_budget': budget,
      'usr_preferences': preferences,
    };
  }
}