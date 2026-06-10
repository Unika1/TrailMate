import '../datasources/api_service.dart';
import '../models/trek_model.dart';
import '../models/comment_model.dart';

class TrekRepositoryImpl {
  final ApiService _apiService = ApiService();

  TrekModel _mapTrek(Map<String, dynamic> json) {
    return TrekModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      duration: json['duration'] ?? '',
      difficulty: json['difficulty'] ?? '',
      distance: json['distance'] ?? '',
      maxAltitude: json['maxAltitude'] ?? '',
      overview: json['description'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      contactsVerified: json['contactsVerified'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bestSeason: List<String>.from(json['bestSeason'] ?? []),
      seasons: (json['seasons'] as List? ?? []).map((item) {
        return TrekSeason(
          name: item['name'] ?? '',
          months: item['months'] ?? '',
          description: item['description'] ?? '',
        );
      }).toList(),
      highlights: List<String>.from(json['highlights'] ?? []),
      itinerary: (json['itinerary'] as List? ?? []).map((item) {
        return ItineraryDay(
          day: item['day'] ?? 0,
          title: item['title'] ?? '',
          altitude: item['altitude'] ?? '',
          walkingHours: item['walkingHours'] ?? '',
          status: item['status'] ?? '',
          description: item['description'] ?? '',
        );
      }).toList(),
      cost: TrekCosts(
        permitFees: json['costs']?['permitFees'] ?? '',
        transportation: json['costs']?['transportation'] ?? '',
        accommodation: json['costs']?['accommodation'] ?? '',
        food: json['costs']?['food'] ?? '',
        guidePorter: json['costs']?['guidePorter'] ?? '',
        totalEstimate: json['costs']?['totalEstimate'] ?? '',
      ),
      budget: (json['budget'] as List? ?? []).map((item) {
        return BudgetItem(
          label: item['label'] ?? '',
          amount: item['amount'] ?? '',
          note: item['note'] ?? '',
          icon: item['icon'] ?? '',
        );
      }).toList(),
      costNotice: json['costNotice'] ?? '',
      permits: (json['permits'] as List? ?? []).map((item) {
        return PermitInfo(
          name: item['name'] ?? '',
          fee: item['fee'] ?? '',
          whereToGet: item['whereToGet'] ?? '',
          description: item['description'] ?? '',
        );
      }).toList(),
      contacts: (json['contacts'] as List? ?? []).map((item) {
        return TrekContact(
          type: item['type'] ?? '',
          name: item['name'] ?? '',
          location: item['location'] ?? '',
          phone: item['phone'] ?? '',
          price: item['price'] ?? '',
          verifiedDate: item['verifiedDate'] ?? '',
          amenities: List<String>.from(item['amenities'] ?? []),
          imageUrl: item['imageUrl'] ?? '',
          badge: item['badge'] ?? '',
          description: item['description'] ?? '',
        );
      }).toList(),
      coordinates: json['coordinates'] != null
          ? TrekCoordinates(
              latitude: json['coordinates']['latitude'] ?? '',
              longitude: json['coordinates']['longitude'] ?? '',
              elevation: json['coordinates']['elevation'] ?? '',
            )
          : null,
      comments: [],
      nearbyTreks: List<String>.from(json['nearbyTreks'] ?? []),
    );
  }

  Future<List<TrekModel>> getAllTreks({
    String? region,
    String? duration,
    String? difficulty,
  }) async {
    final data = await _apiService.getTreks(
      region: region,
      duration: duration,
      difficulty: difficulty,
    );
    return data.map((json) => _mapTrek(json)).toList();
  }

  Future<List<CommentModel>> getComments(String trekId) async {
    final data = await _apiService.getComments(trekId);
    return data
        .map((json) => CommentModel(
              userName: json['userName'] ?? 'Guest User',
              message: json['message'] ?? '',
              date: json['date'] ?? json['createdAt'] ?? '',
              imageUrl: json['imageUrl'] ?? '',
            ))
        .toList();
  }

  Future<void> addComment(
    String trekId,
    String userName,
    String message, {
    String? imagePath,
  }) async {
    await _apiService.addComment(trekId, userName, message,
        imagePath: imagePath);
  }

  Future<List<TrekModel>> getSavedRoutes(String token) async {
    final data = await _apiService.getSavedRoutes(token);
    return data.map((item) {
      final trek = item['trek'] ?? item;
      return _mapTrek(trek);
    }).toList();
  }

  Future<void> saveRoute(String trekId, String token) async {
    await _apiService.saveRoute(trekId, token);
  }

  Future<void> removeSavedRoute(String trekId, String token) async {
    await _apiService.removeSavedRoute(trekId, token);
  }
}
