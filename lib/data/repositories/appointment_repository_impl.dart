import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../source/appointment_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentDataSource _dataSource = AppointmentDataSourceImpl();

  @override
  Future<List<Appointment>> getAppointments() async {
    return await _dataSource.getAllAppointments();
  }

  @override
  Future<void> createAppointment(Appointment appointment) async {
    await _dataSource.createAppointment(appointment);
  }

  @override
  Future<void> cancelAppointment(String id) async {
    await _dataSource.cancelAppointment(id);
  }
}