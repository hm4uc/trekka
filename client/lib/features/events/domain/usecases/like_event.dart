import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/event_repository.dart';

class LikeEvent {
  final EventRepository repository;

  LikeEvent(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String id) async {
    return await repository.likeEvent(id);
  }
}

