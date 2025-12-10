import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params);
  }
}

class UpdateProfileParams extends Equatable {
  final String fullname;
  final String gender;
  final int? age; // 👇 Đổi thành int
  final String job; // 👇 Mới
  final String bio;
  final String avatar;
  final double? budget;
  final List<String>? preferences;

  const UpdateProfileParams({
    required this.fullname,
    required this.gender,
    required this.age,
    required this.job,
    required this.bio,
    required this.avatar,
    this.budget,
    this.preferences,
  });

  Map<String, dynamic> toJson() => {
        "usr_fullname": fullname,
        "usr_gender": gender,
        "usr_age": age, // Gửi số
        "usr_job": job,
        "usr_bio": bio,
        "usr_avatar": avatar,
        "usr_budget": budget,
        "usr_preferences": preferences,
      };

  @override
  List<Object?> get props => [fullname, gender, age, job, bio, avatar, budget, preferences];
}