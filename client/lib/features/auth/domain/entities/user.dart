import 'package:equatable/equatable.dart';

class User extends Equatable {
  // ⚠️ Sửa int -> dynamic để nhận được cả ID số (1) hoặc UUID chuỗi ("e56b...")
  final dynamic id;
  final String email;
  final String fullname;
  final String? token; // Token để lưu session
  final String? avatar;
  final String? gender;
  final String? ageGroup;
  final String? bio;
  final double? budget;
  final List<String>? preferences;

  const User({
    required this.id,
    required this.email,
    required this.fullname,
    this.token,
    this.avatar,
    this.gender,
    this.ageGroup,
    this.bio,
    this.budget,
    this.preferences,
  });

  User copyWith({
    dynamic id,
    String? email,
    String? fullname,
    String? token,
    String? avatar,
    String? gender,
    String? ageGroup,
    String? bio,
    double? budget,
    List<String>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      token: token ?? this.token,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      bio: bio ?? this.bio,
      budget: budget ?? this.budget,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullname,
        token,
        avatar,
        gender,
        ageGroup,
        bio,
        budget,
        preferences,
      ];
}
