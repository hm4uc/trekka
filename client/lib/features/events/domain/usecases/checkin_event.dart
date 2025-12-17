import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class CheckinEvent {
  final EventRepository repository;

  CheckinEvent(this.repository);

  Future<Either<Failure, Event>> call(String id) async {
    return await repository.checkinEvent(id);
  }
}

