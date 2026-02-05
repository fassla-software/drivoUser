import 'driver_model.dart';
import 'vehicle_model.dart';
import 'match_point_model.dart';

class LocationPoint {
  final double lat;
  final double lng;
  final String placeName;

  LocationPoint({
    required this.lat,
    required this.lng,
    required this.placeName,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    try {
      return LocationPoint(
        lat: (json['lat'] ?? 0.0).toDouble(),
        lng: (json['lng'] ?? 0.0).toDouble(),
        placeName: json['place_name'] ?? '',
      );
    } catch (e) {
      print('Error parsing LocationPoint: $e');
      print('JSON data: $json');
      return LocationPoint(lat: 0.0, lng: 0.0, placeName: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'place_name': placeName,
    };
  }
}

class RecurringInfo {
  final String recurrenceType;
  final List<DateTime> selectedDates;
  final List<DateTime> availableDates;

  RecurringInfo({
    required this.recurrenceType,
    required this.selectedDates,
    required this.availableDates,
  });

  factory RecurringInfo.fromJson(Map<String, dynamic> json) {
    return RecurringInfo(
      recurrenceType: json['recurrence_type'] ?? '',
      selectedDates: (json['selected_dates'] as List?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
      availableDates: (json['available_dates'] as List?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recurrence_type': recurrenceType,
      'selected_dates': selectedDates.map((e) => e.toIso8601String()).toList(),
      'available_dates':
          availableDates.map((e) => e.toIso8601String()).toList(),
    };
  }
}

class PoolRide {
  final int routeId;
  final Driver driver;
  final Vehicle vehicle;
  final String category;
  final String startTime;
  final int seatsAvailable;
  final bool isAc;
  final bool isSmokingAllowed;
  final MatchPoint pickupMatchPoint;
  final MatchPoint dropoffMatchPoint;
  final String pickupAddress;
  final String dropoffAddress;
  final int price;
  final bool hasMusic;
  final bool hasScreenEntertainment;
  final bool allowLuggage;
  final String allowedGender;
  final int allowedAgeMin;
  final int allowedAgeMax;
  final String? encodedPolyline;
  final MatchPoint? routeStartPoint;
  final MatchPoint? routeEndPoint;
  final LocationPoint? closestPickup;
  final LocationPoint? closestDropoff;
  final bool? isRecurring;
  final RecurringInfo? recurringInfo;

  PoolRide({
    required this.routeId,
    required this.driver,
    required this.vehicle,
    required this.category,
    required this.startTime,
    required this.seatsAvailable,
    required this.isAc,
    required this.isSmokingAllowed,
    required this.pickupMatchPoint,
    required this.dropoffMatchPoint,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.price,
    required this.hasMusic,
    required this.hasScreenEntertainment,
    required this.allowLuggage,
    required this.allowedGender,
    required this.allowedAgeMin,
    required this.allowedAgeMax,
    this.encodedPolyline,
    this.routeStartPoint,
    this.routeEndPoint,
    this.closestPickup,
    this.closestDropoff,
    this.isRecurring,
    this.recurringInfo,
  });

  factory PoolRide.fromJson(Map<String, dynamic> json) {
    try {
      return PoolRide(
        routeId: json['route_id'] ?? 0,
        driver: Driver.fromJson(json['driver'] ?? {}),
        vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
        category: json['category'] ?? '',
        startTime: json['start_time'] ?? '',
        seatsAvailable: json['seats_available'] ?? 0,
        isAc: json['is_ac'] ?? false,
        isSmokingAllowed: json['is_smoking_allowed'] ?? false,
        pickupMatchPoint: MatchPoint.fromJson(json['pickup_match_point'] ?? {}),
        dropoffMatchPoint:
            MatchPoint.fromJson(json['dropoff_match_point'] ?? {}),
        pickupAddress: json['pickup_address'] ?? '',
        dropoffAddress: json['dropoff_address'] ?? '',
        price: json['price'] ?? 0,
        hasMusic: json['has_music'] ?? false,
        hasScreenEntertainment: json['has_screen_entertainment'] ?? false,
        allowLuggage: json['allow_luggage'] ?? false,
        allowedGender: json['allowed_gender'] ?? '',
        allowedAgeMin: json['allowed_age_min'] ?? 0,
        allowedAgeMax: json['allowed_age_max'] ?? 0,
        encodedPolyline: json['encoded_polyline'],
        routeStartPoint: json['route_start_point'] != null
            ? MatchPoint.fromJson(json['route_start_point'])
            : null,
        routeEndPoint: json['route_end_point'] != null
            ? MatchPoint.fromJson(json['route_end_point'])
            : null,
        closestPickup: json['closest_pickup'] != null
            ? LocationPoint.fromJson(json['closest_pickup'])
            : null,
        closestDropoff: json['closest_dropoff'] != null
            ? LocationPoint.fromJson(json['closest_dropoff'])
            : null,
        isRecurring: json['is_recurring'],
        recurringInfo: json['recurring_info'] != null
            ? RecurringInfo.fromJson(json['recurring_info'])
            : null,
      );
    } catch (e) {
      print('Error parsing PoolRide: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'driver': driver.toJson(),
      'vehicle': vehicle.toJson(),
      'category': category,
      'start_time': startTime,
      'seats_available': seatsAvailable,
      'is_ac': isAc,
      'is_smoking_allowed': isSmokingAllowed,
      'pickup_match_point': pickupMatchPoint.toJson(),
      'dropoff_match_point': dropoffMatchPoint.toJson(),
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'price': price,
      'has_music': hasMusic,
      'has_screen_entertainment': hasScreenEntertainment,
      'allow_luggage': allowLuggage,
      'allowed_gender': allowedGender,
      'allowed_age_min': allowedAgeMin,
      'allowed_age_max': allowedAgeMax,
      'encoded_polyline': encodedPolyline,
      'route_start_point': routeStartPoint?.toJson(),
      'route_end_point': routeEndPoint?.toJson(),
      'closest_pickup': closestPickup?.toJson(),
      'closest_dropoff': closestDropoff?.toJson(),
      'is_recurring': isRecurring,
      'recurring_info': recurringInfo?.toJson(),
    };
  }
}
