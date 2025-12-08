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
    super.bio,
    super.budget,
    super.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API Login/Register trả về: { "status": "success", "data": { "profile": {...}, "token": "..." } }
    // API Get Profile trả về: { "status": "success", "data": { ... } }
    // API Update Profile trả về: { "status": "success", "data": { ... } }
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

    return UserModel(
      id: userData['id']?.toString() ?? userData['usr_id']?.toString() ?? '',
      fullname: userData['usr_fullname'] ?? '',
      email: userData['usr_email'] ?? '',
      token: token,
      avatar: userData['usr_avatar'],
      gender: userData['usr_gender'],
      ageGroup: userData['usr_age_group'],
      bio: userData['usr_bio'],
      // Map budget: API có thể trả về String hoặc Number
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
      'usr_bio': bio,
      'usr_budget': budget,
      'usr_preferences': preferences,
    };
  }
}