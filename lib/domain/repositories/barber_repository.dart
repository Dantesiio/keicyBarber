import 'package:keicybarber/domain/entities/barber.dart';

abstract class BarberRepository {
  Future<List<Barber>> getBarbers();
  Future<List<Barber>> getBarbersByLocation(String locationId);
}