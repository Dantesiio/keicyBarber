import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../../data/repositories/appointment_repository_impl.dart';

class GetAppointments {
  final AppointmentRepository _repository = AppointmentRepositoryImpl();

  Future<List<Appointment>> execute() async {
    return await _repository.getAppointments();
  }
}
