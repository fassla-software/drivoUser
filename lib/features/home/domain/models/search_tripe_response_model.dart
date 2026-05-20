import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/boarding_point_model.dart';

class SearchTripeResponseModel {
  String? responseCode;
  String? message;
  dynamic totalSize;
  dynamic limit;
  dynamic offset;
  SearchTripeResponseData? data;
  List<dynamic>? errors;

  SearchTripeResponseModel({
    this.responseCode,
    this.message,
    this.totalSize,
    this.limit,
    this.offset,
    this.data,
    this.errors,
  });

  factory SearchTripeResponseModel.fromJson(Map<String, dynamic> json) =>
      SearchTripeResponseModel(
        responseCode: json['response_code'],
        message: json['message'],
        totalSize: json['total_size'],
        limit: json['limit'],
        offset: json['offset'],
        data: json['data'] != null
            ? SearchTripeResponseData.fromJson(json['data'])
            : null,
        errors: json['errors'],
      );
}

class SearchTripeResponseData {
  List<SearchTripeAll>? all;
  List<SearchTripeAll>? uncategorized;

  SearchTripeResponseData({
    this.all,
    this.uncategorized,
  });

  factory SearchTripeResponseData.fromJson(Map<String, dynamic> json) =>
      SearchTripeResponseData(
        all: (json['all'] as List?)
            ?.map((e) => SearchTripeAll.fromJson(e))
            .toList(),
        uncategorized: (json['uncategorized'] as List?)
            ?.map((e) => SearchTripeAll.fromJson(e))
            .toList(),
      );
}

class SearchTripeAll {
  int? routeId;
  Driver? driver;
  dynamic vehicle;
  String? category;
  DateTime? startTime;
  int? seatsAvailable;
  bool? isAc;
  bool? isSmokingAllowed;
  MatchPoint? pickupMatchPoint;
  MatchPoint? dropoffMatchPoint;
  String? pickupAddress;
  String? dropoffAddress;
  int? price;
  bool? hasMusic;
  bool? hasScreenEntertainment;
  bool? allowLuggage;
  String? allowedGender;
  dynamic allowedAgeMin;
  int? allowedAgeMax;
  bool? isRecurring;
  RecurringInfo? recurringInfo;
  String? encodedPolyline;
  ClosestPoint? closestPickup;
  ClosestPoint? closestDropoff;
  String? carpoolType;
  BoardingPoint? boardingPointStart;
  BoardingPoint? boardingPointEnd;
  String? departureTime;
  String? returnTime;

  SearchTripeAll({
    this.routeId,
    this.driver,
    this.vehicle,
    this.category,
    this.startTime,
    this.seatsAvailable,
    this.isAc,
    this.isSmokingAllowed,
    this.pickupMatchPoint,
    this.dropoffMatchPoint,
    this.pickupAddress,
    this.dropoffAddress,
    this.price,
    this.hasMusic,
    this.hasScreenEntertainment,
    this.allowLuggage,
    this.allowedGender,
    this.allowedAgeMin,
    this.allowedAgeMax,
    this.isRecurring,
    this.recurringInfo,
    this.encodedPolyline,
    this.closestPickup,
    this.closestDropoff,
    this.carpoolType,
    this.boardingPointStart,
    this.boardingPointEnd,
    this.departureTime,
    this.returnTime,
  });

  factory SearchTripeAll.fromJson(Map<String, dynamic> json) => SearchTripeAll(
        routeId: json['route_id'],
        driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
        vehicle: json['vehicle'],
        category: json['category'],
        startTime: json['start_time'] != null
            ? DateTime.parse(json['start_time'])
            : null,
        seatsAvailable: json['seats_available'],
        isAc: json['is_ac'],
        isSmokingAllowed: json['is_smoking_allowed'],
        pickupMatchPoint: json['pickup_match_point'] != null
            ? MatchPoint.fromJson(json['pickup_match_point'])
            : null,
        dropoffMatchPoint: json['dropoff_match_point'] != null
            ? MatchPoint.fromJson(json['dropoff_match_point'])
            : null,
        pickupAddress: json['pickup_address'],
        dropoffAddress: json['dropoff_address'],
        price: json['price'],
        hasMusic: json['has_music'],
        hasScreenEntertainment: json['has_screen_entertainment'],
        allowLuggage: json['allow_luggage'],
        allowedGender: json['allowed_gender'],
        allowedAgeMin: json['allowed_age_min'],
        allowedAgeMax: json['allowed_age_max'],
        isRecurring: json['is_recurring'],
        recurringInfo: json['recurring_info'] != null
            ? RecurringInfo.fromJson(json['recurring_info'])
            : null,
        encodedPolyline: json['encoded_polyline'],
        closestPickup: json['closest_pickup'] != null
            ? ClosestPoint.fromJson(json['closest_pickup'])
            : null,
        closestDropoff: json['closest_dropoff'] != null
            ? ClosestPoint.fromJson(json['closest_dropoff'])
            : null,
        carpoolType: json['carpool_type'],
        boardingPointStart: json['boarding_point_start'] != null
            ? BoardingPoint.fromJson(json['boarding_point_start'])
            : null,
        boardingPointEnd: json['boarding_point_end'] != null
            ? BoardingPoint.fromJson(json['boarding_point_end'])
            : null,
        departureTime: json['departure_time'],
        returnTime: json['return_time'],
      );
}

class Driver {
  String? id;
  String? fullName;
  String? gender;
  String? profileImage;

  Driver({
    this.id,
    this.fullName,
    this.gender,
    this.profileImage,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: json['id'],
        fullName: json['full_name'],
        gender: json['gender'],
        profileImage: json['profile_image'],
      );
}

class MatchPoint {
  double? lat;
  double? lng;

  MatchPoint({
    this.lat,
    this.lng,
  });

  factory MatchPoint.fromJson(Map<String, dynamic> json) => MatchPoint(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class RecurringInfo {
  String? recurrenceType;
  List<DateTime>? selectedDates;
  List<DateTime>? availableDates;

  RecurringInfo({
    this.recurrenceType,
    this.selectedDates,
    this.availableDates,
  });

  factory RecurringInfo.fromJson(Map<String, dynamic> json) => RecurringInfo(
        recurrenceType: json['recurrence_type'],
        selectedDates: (json['selected_dates'] as List?)
            ?.map((e) => DateTime.parse(e))
            .toList(),
        availableDates: (json['available_dates'] as List?)
            ?.map((e) => DateTime.parse(e))
            .toList(),
      );
}

class ClosestPoint {
  double? lat;
  double? lng;
  String? placeName;

  ClosestPoint({
    this.lat,
    this.lng,
    this.placeName,
  });

  factory ClosestPoint.fromJson(Map<String, dynamic> json) => ClosestPoint(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        placeName: json['place_name'],
      );
}
