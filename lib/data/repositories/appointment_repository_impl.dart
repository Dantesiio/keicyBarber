import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  // Aquí se conectará con Supabase en el futuro
  @override
  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      // Citas confirmadas para probar
      Appointment(
        id: '1',
        serviceName: 'Corte Y Barba',
        dateTime: DateTime(2024, 1, 15, 10, 0),
        barberName: 'Carlos Rodríguez',
        location: 'Sede Bogotá',
        price: 45000,
        status: 'Confirmada',
      ),
      // Citas completadas para probar
      Appointment(
        id: '2',
        serviceName: 'Corte De Cabello',
        dateTime: DateTime(2023, 12, 20, 14, 30),
        barberName: 'Miguel Torres',
        location: 'Sede Medellín',
        price: 30000,
        status: 'Completada',
      ),
      Appointment(
        id: '3',
        serviceName: 'Limpieza Facial Completa',
        dateTime: DateTime(2023, 11, 10, 16, 0),
        barberName: 'Andrés Silva',
        location: 'Sede Cali',
        price: 20000,
        status: 'Completada',
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
