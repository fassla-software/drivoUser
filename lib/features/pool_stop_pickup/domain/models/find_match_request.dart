class FindMatchRequest {
  final String carpoolType;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String day;
  final String gender;
  final int seatsRequired;
  final String rideType;
  final String? departureTime;
  final String? returnTime;
  final int? boardingPointStartId;
  final int? boardingPointEndId;

  FindMatchRequest({
    required this.carpoolType,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    required this.day,
    required this.gender,
    required this.seatsRequired,
    required this.rideType,
    this.departureTime,
    this.returnTime,
    this.boardingPointStartId,
    this.boardingPointEndId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'carpool_type': carpoolType,
      'day': day,
      'gender': gender,
      'seats_required': seatsRequired,
      'ride_type': rideType,
    };

    if (pickupLat != null) data['pickup_lat'] = pickupLat;
    if (pickupLng != null) data['pickup_lng'] = pickupLng;
    if (dropoffLat != null) data['dropoff_lat'] = dropoffLat;
    if (dropoffLng != null) data['dropoff_lng'] = dropoffLng;
    if (departureTime != null && departureTime!.isNotEmpty) {
      data['departure_time'] = departureTime;
    }
    if (returnTime != null && returnTime!.isNotEmpty) {
      data['return_time'] = returnTime;
    }
    if (boardingPointStartId != null) {
      data['boarding_point_start_id'] = boardingPointStartId;
    }
    if (boardingPointEndId != null) {
      data['boarding_point_end_id'] = boardingPointEndId;
    }

    return data;
  }
}
