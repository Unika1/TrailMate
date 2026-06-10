import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/trek_model.dart';
import '../../data/repositories/trek_repository_impl.dart';
import 'auth_provider.dart';

class TrekProvider extends ChangeNotifier {
  final TrekRepositoryImpl _repository = TrekRepositoryImpl();
  final Ref _ref;

  TrekProvider(this._ref);

  List<TrekModel> treks = [];
  List<TrekModel> savedRoutes = [];
  List<CommentModel> comments = [];

  bool isLoading = false;
  String? errorMessage;

  String selectedRegion = 'All Treks';
  String selectedDuration = 'Duration';
  String selectedDifficulty = 'Difficulty';

  String _searchQuery = '';

  TrekModel? get mainTrek => treks.isNotEmpty ? treks.first : null;

  String? get _token => _ref.read(authProvider).token;

  bool isRouteSaved(String trekId) {
    return savedRoutes.any((trek) => trek.id == trekId);
  }

  List<TrekModel> get filteredTreks {
    if (_searchQuery.isEmpty) return treks;
    final q = _searchQuery.toLowerCase();
    return treks
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.region.toLowerCase().contains(q) ||
            t.difficulty.toLowerCase().contains(q))
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadTreks() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      treks = await _repository.getAllTreks(
        region: selectedRegion,
        duration: selectedDuration,
        difficulty: selectedDifficulty,
      );
    } catch (e) {
      errorMessage = 'Failed to load treks. Check backend connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFilters({
    String? region,
    String? duration,
    String? difficulty,
  }) async {
    if (region != null) selectedRegion = region;
    if (duration != null) selectedDuration = duration;
    if (difficulty != null) selectedDifficulty = difficulty;

    await loadTreks();
  }

  Future<void> resetFilters() async {
    selectedRegion = 'All Treks';
    selectedDuration = 'Duration';
    selectedDifficulty = 'Difficulty';
    _searchQuery = '';
    await loadTreks();
  }

  Future<void> loadSavedRoutes() async {
    final token = _token;
    if (token == null) return;

    try {
      savedRoutes = await _repository.getSavedRoutes(token);
      notifyListeners();
    } catch (_) {
      // silently fail — saved routes will just be empty
    }
  }

  Future<void> saveRoute(TrekModel trek) async {
    final token = _token;
    if (token == null) {
      // offline toggle for demo / no-auth
      if (isRouteSaved(trek.id)) {
        savedRoutes.removeWhere((item) => item.id == trek.id);
      } else {
        savedRoutes.add(trek);
      }
      notifyListeners();
      return;
    }

    try {
      if (isRouteSaved(trek.id)) {
        await _repository.removeSavedRoute(trek.id, token);
        savedRoutes.removeWhere((item) => item.id == trek.id);
      } else {
        await _repository.saveRoute(trek.id, token);
        savedRoutes.add(trek);
      }
      notifyListeners();
    } catch (_) {
      // revert nothing – just keep current state
    }
  }

  Future<void> loadComments(String trekId) async {
    try {
      comments = await _repository.getComments(trekId);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load comments.';
      notifyListeners();
    }
  }

  Future<void> addComment(
    String trekId,
    String userName,
    String message, {
    String? imagePath,
  }) async {
    await _repository.addComment(trekId, userName, message,
        imagePath: imagePath);
    await loadComments(trekId);
  }
}

final trekProvider = ChangeNotifierProvider<TrekProvider>((ref) {
  return TrekProvider(ref);
});
