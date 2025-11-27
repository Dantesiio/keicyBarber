import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_data_source.dart';
import '../../../core/errors/app_exception.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Future<List<Location>> getLocations() async {
    try {
      final rows = await dataSource.fetchLocations();

      return rows.map((r) {
        return Location(
          id: r['id'].toString(),
          name: r['name'] as String,
          address: (r['address'] as String?) ?? '',
          latitude: r['latitude'] != null ? (r['latitude'] as num).toDouble() : null,
          longitude: r['longitude'] != null ? (r['longitude'] as num).toDouble() : null,
        );
      }).toList();
    } catch (e) {
      throw AppException(
        "No se pudieron cargar las sedes",
        code: "LOCATION_REPOSITORY_ERROR",
      );
    }
  }
}