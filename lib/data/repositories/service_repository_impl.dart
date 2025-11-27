import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_data_source.dart';
import '../../../core/errors/app_exception.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceDataSource dataSource;

  ServiceRepositoryImpl(this.dataSource);

  @override
  Future<List<Service>> getServices() async {
    try {
      final rows = await dataSource.fetchActiveServices();

      return rows.map((r) {
        return Service(
          id: r['id'].toString(),
          name: r['name'] as String,
          description: (r['description'] as String?) ?? '',
          durationMinutes: r['duration_minutes'] as int,
          price: (r['price_cents'] as int).toDouble(),
        );
      }).toList();
    } catch (e) {
      throw AppException(
        "No se pudieron cargar los servicios",
        code: "SERVICE_REPOSITORY_ERROR",
      );
    }
  }
}