
import '../../../profile/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullname,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API structure: { "token": "...", "user": { "usr_id": 1, ... } }
    final userJson = json['user'] ?? {};
    return UserModel(
      id: userJson['usr_id'] ?? 0,
      email: userJson['usr_email'] ?? '',
      fullname: userJson['usr_fullname'] ?? '',
      token: json['token'], // Token nằm ở root level của response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usr_id': id,
      'usr_fullname': fullname,
      'usr_email': email,
      'token': token,
    };
  }
}