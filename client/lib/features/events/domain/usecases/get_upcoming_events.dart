import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetUpcomingEvents {
  final EventRepository repository;

  GetUpcomingEvents(this.repository);

  Future<Either<Failure, List<Event>>> call({
    double? lat,
    double? lng,
    double radius = 5000,
    int limit = 10,
  }) async {
    return await repository.getUpcomingEvents(
      lat: lat,
      lng: lng,
      radius: radius,
      limit: limit,
    );
  }
}

