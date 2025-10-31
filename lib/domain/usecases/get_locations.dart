import 'package:keicybarber/domain/entities/location.dart';
import 'package:keicybarber/domain/usecases/location_repository.dart';

class GetLocations {
  final LocationRepository repository;

  GetLocations(this.repository);

  Future<List<Location>> call() async => repository.getLocations();
}