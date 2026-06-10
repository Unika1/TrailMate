import 'package:trailmate/data/models/trek_model.dart';
import 'package:trailmate/data/repositories/trek_repository_impl.dart';

class FilterTreksUseCase {
  final TrekRepositoryImpl repository;

  FilterTreksUseCase(this.repository);

  Future<List<TrekModel>> call({
    String? region,
    String? duration,
    String? difficulty,
  }) {
    return repository.getAllTreks(
      region: region,
      duration: duration,
      difficulty: difficulty,
    );
  }
}