import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetNextAppointment {
  final AppointmentRepository repository;

  GetNextAppointment(this.repository);

  Future<Appointment?> call() async {
    return await repository.getNextAppointment();
  }
}