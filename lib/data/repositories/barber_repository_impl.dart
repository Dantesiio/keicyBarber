import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/repositories/barber_repository.dart';

class BarberRepositoryImpl implements BarberRepository {
  // Aquí se conectará con Supabase en el futuro

  // Lista de todos los barberos como si vinieran de la DB
  final _allBarbers = [
    Barber(id: '1', name: 'Carlos Rodríguez', rating: 4.9, specialtys: ['Cortes clásicos', 'Estilos modernos'], locationId: '1'), // Bogotá
    Barber(id: '2', name: 'Miguel Angel', rating: 4.0, specialtys: ['Barbas y rituales'], locationId: '2'), // Medellín
    Barber(id: '3', name: 'Andrés Parra', rating: 4.3, specialtys: ['Colorimetría', 'Tratamientos capilares', 'Cortes infantiles'], locationId: '1'), // Bogotá
    Barber(id: '4', name: 'Juan David', rating: 4.7, specialtys: ['Cortes modernos'], locationId: '2'), // Medellín
  ];

  @override
  Future<List<Barber>> getBarbers() async {
    await Future.delayed(const Duration(seconds: 1));
    return _allBarbers;
  }

  @override
  Future<List<Barber>> getBarbersByLocation(String locationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _allBarbers
        .where((barber) => barber.locationId == locationId)
        .toList();
  }
}