import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  // Aquí se conectará con Supabase en el futuro
  
  @override
  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Appointment(
        id: '1',
        serviceName: 'Corte Y Barba',
        dateTime: DateTime(2024, 1, 15, 10, 0),
        barberName: 'Carlos Rodríguez',
        location: 'Sede Bogotá',
        price: 45000,
        status: 'Confirmada',
      ),
    ];
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock: simula creación exitosa
  }

  @override
  Future<void> cancelAppointment(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock: simula cancelación exitosa
  }
}
