import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class MarkReviewHelpful implements UseCase<Map<String, dynamic>, String> {
  final ReviewRepository repository;

  MarkReviewHelpful(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String id) async {
    return await repository.markReviewHelpful(id);
  }
}

