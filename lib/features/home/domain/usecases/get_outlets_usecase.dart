import '../../../menu/domain/entities/outlet.dart';
import '../repositories/home_repository.dart';

class GetOutletsUseCase {
  final HomeRepository _repository;
  const GetOutletsUseCase(this._repository);

  Future<List<Outlet>> call() => _repository.getOutlets();
}
