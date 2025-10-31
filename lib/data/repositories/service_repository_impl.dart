import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  // Aquí se conectará con Supabase en el futuro
  
  @override
  Future<List<Service>> getServices() async {
    // Mock data por ahora
    await Future.delayed(const Duration(seconds: 1));
    return [
      Service(id: '1', name: 'Corte de cabello', description: 'Incluye asesoría', durationMinutes: 60, price: 30000),
      Service(id: '2', name: 'Barba', description: 'Arreglo de barba', durationMinutes: 30, price: 25000),
      Service(id: '3', name: 'Tinte', description: 'Tinte de cabello', durationMinutes: 90, price: 45000),
      Service(id: '4', name: 'Masaje', description: 'Masaje relajante', durationMinutes: 30, price: 20000),
      Service(id: '5', name: 'Peinado especial', description: 'Peinado para eventos', durationMinutes: 120, price: 60000),
    ];
  }

  @override
  Future<Service> getServiceById(String id) async {
    final services = await getServices();
    return services.firstWhere((s) => s.id == id);
  }
}
