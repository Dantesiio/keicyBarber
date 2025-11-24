import '/domain/entities/barber.dart';

abstract class BarberRepository {
  Future<List<Barber>> getBarbersByLocation(String locationId);
}