import '../entities/platform_charges_entity.dart';
import '../repositories/payment_repository.dart';

class GetPlatformChargesUseCase {
  final PaymentRepository _repository;

  GetPlatformChargesUseCase(this._repository);

  Future<PlatformChargesEntity> call() async {
    return await _repository.getPlatformCharges();
  }
}
