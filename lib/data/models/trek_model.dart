import 'comment_model.dart';

class ItineraryDay {
  final int day;
  final String title;
  final String altitude;
  final String walkingHours;
  final String status; // "Rest Day" on acclimatization days (shown instead of hours)
  final String description;

  ItineraryDay({
    required this.day,
    required this.title,
    required this.altitude,
    required this.walkingHours,
    this.status = '',
    required this.description,
  });
}

class TrekContact {
  final String type; // jeep | hotel | emergency
  final String name;
  final String location;
  final String phone;
  final String price; // jeep fare / hotel per-night
  final String verifiedDate;
  final List<String> amenities;
  final String imageUrl; // hotel photo
  final String badge; // ECO-FRIENDLY / VERIFIED / HIMALAYAN AIR / PARK AUTHORITY
  final String description; // emergency detailed card

  TrekContact({
    required this.type,
    required this.name,
    required this.location,
    required this.phone,
    required this.price,
    required this.verifiedDate,
    this.amenities = const [],
    this.imageUrl = '',
    this.badge = '',
    this.description = '',
  });
}

class TrekCosts {
  final String permitFees;
  final String transportation;
  final String accommodation;
  final String food;
  final String guidePorter;
  final String totalEstimate;

  TrekCosts({
    required this.permitFees,
    required this.transportation,
    required this.accommodation,
    required this.food,
    required this.guidePorter,
    required this.totalEstimate,
  });
}

class BudgetItem {
  final String label;
  final String amount;
  final String note; // FIXED / EST. / DAILY
  final String icon; // permit / transport / hotel / food

  BudgetItem({
    required this.label,
    required this.amount,
    required this.note,
    required this.icon,
  });
}

class PermitInfo {
  final String name;
  final String fee;
  final String whereToGet;
  final String description;

  PermitInfo({
    required this.name,
    required this.fee,
    required this.whereToGet,
    this.description = '',
  });
}

class TrekSeason {
  final String name; // Spring
  final String months; // March – May
  final String description;

  TrekSeason({
    required this.name,
    required this.months,
    required this.description,
  });
}

class TrekCoordinates {
  final String latitude;
  final String longitude;
  final String elevation;

  TrekCoordinates({
    required this.latitude,
    required this.longitude,
    required this.elevation,
  });

  bool get isEmpty => latitude.isEmpty && longitude.isEmpty;
}

class TrekModel {
  final String id;
  final String name;
  final String region;
  final String duration;
  final String difficulty;
  final String distance;
  final String maxAltitude;
  final String overview;
  final String lastUpdated;
  final String contactsVerified;
  final String imageUrl;
  final List<String> bestSeason;
  final List<TrekSeason> seasons;
  final List<String> highlights;
  final List<ItineraryDay> itinerary;
  final TrekCosts cost;
  final List<BudgetItem> budget;
  final String costNotice;
  final List<PermitInfo> permits;
  final List<TrekContact> contacts;
  final TrekCoordinates? coordinates;
  final List<CommentModel> comments;
  final List<String> nearbyTreks;

  TrekModel({
    required this.id,
    required this.name,
    required this.region,
    required this.duration,
    required this.difficulty,
    required this.distance,
    required this.maxAltitude,
    required this.overview,
    required this.lastUpdated,
    this.contactsVerified = '',
    this.imageUrl = '',
    required this.bestSeason,
    this.seasons = const [],
    required this.highlights,
    required this.itinerary,
    required this.cost,
    this.budget = const [],
    this.costNotice = '',
    required this.permits,
    required this.contacts,
    this.coordinates,
    required this.comments,
    required this.nearbyTreks,
  });

  String get description => overview;

  TrekCosts get costs => cost;
}
