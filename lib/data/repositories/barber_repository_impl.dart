import '../../domain/entities/barber.dart';
import '../../domain/repositories/barber_repository.dart';
import '../datasources/barber_data_source.dart';
import '../../../core/errors/app_exception.dart';

class BarberRepositoryImpl implements BarberRepository {
  final BarberDataSource dataSource;

  BarberRepositoryImpl(this.dataSource);

  @override
  Future<List<Barber>> getBarbersByLocation(String locationId) async {
    try {
      final rel = await dataSource.fetchBarberRelations(locationId);

      final ids = rel.map((e) => e['barber_id'] as String).toList();
      if (ids.isEmpty) return [];

      final barberRows = await dataSource.fetchBarberProfiles(ids);

      final serviceRows = await dataSource.fetchBarberServices(ids);

      final Map<String, List<String>> specByBarber = {};
      for (final row in serviceRows) {
        final barberId = row['barber_id'] as String;
        final svcName = (row['services'] as Map)['name'] as String;

        specByBarber.putIfAbsent(barberId, () => []).add(svcName);
      }

      return barberRows.map((row) {
        final profile = row['profiles'] as Map;
        final id = row['profile_id'] as String;

        return Barber(
          id: id,
          name: '${profile['first_name']} ${profile['last_name']}'.trim(),
          rating: (row['average_rating'] as num?)?.toDouble() ?? 0.0,
          specialtys: specByBarber[id] ?? const [],
          locationId: locationId,
        );
      }).toList();
    } catch (e) {
      throw AppException("No se pudieron cargar los barberos", code: "BARBER_REPOSITORY_ERROR");
    }
  }
}