import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/repositories/barber_repository.dart';

class GetBarbersByLocation {
  final BarberRepository repository;
  GetBarbersByLocation(this.repository);

  Future<List<Barber>> call(String locationId) {
    return repository.getBarbersByLocation(locationId);
  }
}