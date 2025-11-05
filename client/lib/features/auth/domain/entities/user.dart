import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String usrFullname;
  final String usrEmail;
  final String? usrGender;
  final int? usrAge;
  final String? usrJob;
  final List<String>? usrPreferences;
  final double? usrBudget;
  final String? usrAvatar;
  final String? usrBio;
  final bool isActive;
  final DateTime usrCreatedAt;

  const User({
    required this.id,
    required this.usrFullname,
    required this.usrEmail,
    this.usrGender,
    this.usrAge,
    this.usrJob,
    this.usrPreferences,
    this.usrBudget,
    this.usrAvatar,
    this.usrBio,
    required this.isActive,
    required this.usrCreatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    usrFullname,
    usrEmail,
    usrGender,
    usrAge,
    usrJob,
    usrPreferences,
    usrBudget,
    usrAvatar,
    usrBio,
    isActive,
    usrCreatedAt,
  ];
}