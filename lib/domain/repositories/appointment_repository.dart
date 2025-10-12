import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<void> createAppointment(Appointment appointment);
  Future<void> cancelAppointment(String id);
}
