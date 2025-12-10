import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/update_profile.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, User>> register(
      {required String fullname, required String email, required String password}) async {
    try {
      // Gọi API Đăng ký - API sẽ trả về token trong response
      final userModel = await remoteDataSource.register(fullname, email, password);
      // Lưu user (với token) vào cache
      await localDataSource.cacheUser(userModel);

      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return const Left(ServerFailure('Lỗi không xác định', 500));
    }
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return const Left(CacheFailure('Chưa đăng nhập'));
      }
      final remoteUser = await remoteDataSource.getProfile(token);
      final userWithToken = UserModel(
        id: remoteUser.id,
        email: remoteUser.email,
        fullname: remoteUser.fullname,
        token: token,
        avatar: remoteUser.avatar,
        gender: remoteUser.gender,
        ageGroup: remoteUser.ageGroup,
        age: remoteUser.age,
        job: remoteUser.job,
        bio: remoteUser.bio,
        budget: remoteUser.budget,
        preferences: remoteUser.preferences,
      );
      await localDataSource.cacheUser(userWithToken);
      return Right(userWithToken);
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await localDataSource.clearUser();
      }
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      final localUser = await localDataSource.getLastUser();
      if (localUser != null) return Right(localUser);
      return const Left(CacheFailure('Lỗi kiểm tra trạng thái'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return _performLogout(() async {
      final token = await localDataSource.getToken();
      if (token != null) {
        await remoteDataSource.logout(token);
      }
    });
  }

  @override
  Future<Either<Failure, void>> logoutAllDevices() async {
    return _performLogout(() async {
      final token = await localDataSource.getToken();
      if (token != null) {
        await remoteDataSource.logoutAllDevices(token);
      }
    });
  }

  Future<Either<Failure, void>> _performLogout(Future<void> Function() apiCall) async {
    try {
      // 1. Gọi API để server biết
      await apiCall();

      // 2. Xóa data dưới máy (Quan trọng)
      await localDataSource.clearUser();

      return const Right(null);
    } on ServerException catch (e) {
      // Dù API lỗi (ví dụ token hết hạn 401), ta vẫn phải xóa local để user thoát ra được
      await localDataSource.clearUser();
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      await localDataSource.clearUser();
      return const Left(CacheFailure('Lỗi khi đăng xuất'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(UpdateProfileParams params) async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) return const Left(CacheFailure('Chưa đăng nhập'));

      // 1. Gọi API Update
      final updatedUserRemote = await remoteDataSource.updateProfile(token, params);

      // 2. Vì API trả về User object không có trường token, ta phải gán lại token cũ vào
      // để khi lưu cache không bị mất token
      final userToCache = UserModel(
        id: updatedUserRemote.id,
        email: updatedUserRemote.email,
        fullname: updatedUserRemote.fullname,
        token: token,
        avatar: updatedUserRemote.avatar,
        gender: updatedUserRemote.gender,
        ageGroup: updatedUserRemote.ageGroup,
        age: updatedUserRemote.age,
        job: updatedUserRemote.job,
        bio: updatedUserRemote.bio,
        budget: updatedUserRemote.budget,
        preferences: updatedUserRemote.preferences,
      );

      // 3. Cập nhật Cache Local
      await localDataSource.cacheUser(userToCache);

      return Right(userToCache);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Lỗi cập nhật hồ sơ', 500));
    }
  }
}
