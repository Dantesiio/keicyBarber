import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/usecases/barber_repository.dart';

class BarberRepositoryImpl implements BarberRepository {
  // Aquí se conectará con Supabase en el futuro

  @override
  Future<List<Barber>> getBarbers() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Barber(id: '1', name: 'Carlos Rodríguez', specialty: 'Cortes clásicos'),
      Barber(id: '2', name: 'Miguel Angel', specialty: 'Barbas y rituales'),
      Barber(id: '3', name: 'Andrés Parra', specialty: 'Colorimetría'),
    ];
  }

  @override
  Future<List<Barber>> getBarbersByLocation(String locationId) async {
    // En un futuro, esto filtraría por sede
    return await getBarbers();
  }
}