import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetAppointments {
  final AppointmentRepository repository;

  GetAppointments(this.repository);

  Future<List<Appointment>> call() async {
    return await repository.getAppointments();
  }
}
