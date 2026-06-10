import '../../data/models/trek_model.dart';

abstract class TrekRepository {
  List<TrekModel> getAllTreks();
  List<TrekModel> filterTreks({String? region, String? duration, String? difficulty});
  void saveRoute(TrekModel trek);
  List<TrekModel> getSavedRoutes();
}
