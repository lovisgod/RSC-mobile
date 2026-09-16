import '../entities/daily_special.dart';

abstract class DailySpecialsRepository {
  Future<List<DailySpecial>> getDailySpecials();
}
