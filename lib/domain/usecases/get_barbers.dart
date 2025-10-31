import 'package:keicybarber/domain/entities/barber.dart';
import 'package:keicybarber/domain/usecases/barber_repository.dart';

class GetBarbers {
  final BarberRepository repository;

  GetBarbers(this.repository);

  Future<List<Barber>> call() async => repository.getBarbers();
}