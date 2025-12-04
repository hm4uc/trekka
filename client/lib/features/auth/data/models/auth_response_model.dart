
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullname,
    super.token,
    super.avatar, // Thêm các trường mới
    super.gender,
    super.ageGroup,
    super.bio,
    super.budget,
    super.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API Login trả về: { "token": "...", "user": { ... } }
    // API Get Profile trả về: { "status": "success", "data": { ... } }
    // API Update Profile trả về: { "status": "success", "data": { ... } }

    Map<String, dynamic> userData;

    // Xác định nguồn dữ liệu user
    if (json.containsKey('user')) {
      userData = json['user'];
    } else if (json.containsKey('data')) {
      userData = json['data'];
    } else {
      userData = json;
    }

    return UserModel(
      id: userData['id'] ?? userData['usr_id'] ?? '',
      fullname: userData['usr_fullname'] ?? '',
      email: userData['usr_email'] ?? '',
      token: json['token'], // Token chỉ có khi login/register
      // Các trường Profile
      avatar: userData['usr_avatar'],
      gender: userData['usr_gender'],
      ageGroup: userData['usr_age_group'],
      bio: userData['usr_bio'],
      budget: (userData['usr_budget'] as num?)?.toDouble(),
      preferences: (userData['usr_preferences'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}