import 'package:keicybarber/domain/entities/location.dart';
import 'package:keicybarber/domain/usecases/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  // Aquí se conectará con Supabase en el futuro

  @override
  Future<List<Location>> getLocations() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Location(id: '1', name: 'Sede Bogotá', address: 'Calle Falsa 123'),
      Location(id: '2', name: 'Sede Medellín', address: 'Avenida Siempre Viva 742'),
    ];
  }
}