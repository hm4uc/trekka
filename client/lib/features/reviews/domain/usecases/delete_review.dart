import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class DeleteReview implements UseCase<void, String> {
  final ReviewRepository repository;

  DeleteReview(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteReview(id);
  }
}

