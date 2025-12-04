import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutAllDevices implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutAllDevices(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logoutAllDevices();
  }
}