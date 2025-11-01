import 'package:keicybarber/domain/entities/location.dart';

abstract class LocationRepository {
  Future<List<Location>> getLocations();
}