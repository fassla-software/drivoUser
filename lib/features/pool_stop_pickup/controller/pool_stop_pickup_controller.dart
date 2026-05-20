import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_ride_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/services/pool_service.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_request.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_response.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/join_request.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/boarding_point_model.dart';

import 'package:ride_sharing_user_app/localization/localization_controller.dart';

class PoolStopPickupController extends GetxController implements GetxService {
  final PoolService poolService;

  PoolStopPickupController({required this.poolService});
  // Map controller
  GoogleMapController? mapController;

  // Selected addresses
  Address? pickupAddress;
  Address? destinationAddress;

  // Loading states
  bool _isLoading = false;
  bool _isSearchingTrips = false;
  Set<int> _joiningRouteIds = {};

  // Text controllers
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  // Available trips for this route
  List<PoolRide> availableTrips = [];

  // Search parameters
  String selectedGender = 'both';
  int selectedSeats = 1;
  String selectedRideType = 'work';
  String selectedDate = '';

  // New carpool type state fields
  String selectedCarpoolType = 'trip';
  List<BoardingPoint> boardingPoints = [];
  
  String? selectedStartCity;
  String? selectedEndCity;
  BoardingPoint? selectedBoardingPointStart;
  BoardingPoint? selectedBoardingPointEnd;
  
  bool isLoadingBoardingPoints = false;
  String? selectedDepartureTime;
  String? selectedReturnTime;

  bool get isLoading => _isLoading;
  bool get isSearchingTrips => _isSearchingTrips;
  bool isJoining(int routeId) => _joiningRouteIds.contains(routeId);

  List<String> _splitString(String value) {
    final regex = RegExp(r'\s*-\s*|\s+to\s+');
    final parts = value.split(regex);
    return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  List<String> get availableCities {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final cities = boardingPoints
        .map((p) {
          final nameToUse = (isLtr ? p.name : p.nameAr).isNotEmpty 
              ? (isLtr ? p.name : p.nameAr) 
              : p.name;
          final parts = _splitString(nameToUse);
          return parts.isNotEmpty ? parts.first : '';
        })
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  List<BoardingPoint> getAreasForCity(String? city) {
    if (city == null) return [];
    final isLtr = Get.find<LocalizationController>().isLtr;
    return boardingPoints.where((p) {
      final nameToUse = (isLtr ? p.name : p.nameAr).isNotEmpty 
          ? (isLtr ? p.name : p.nameAr) 
          : p.name;
      final parts = _splitString(nameToUse);
      return parts.isNotEmpty && parts.first == city;
    }).toList();
  }

  String getAreaName(BoardingPoint point) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final nameToUse = (isLtr ? point.name : point.nameAr).isNotEmpty 
        ? (isLtr ? point.name : point.nameAr) 
        : point.name;
    final parts = _splitString(nameToUse);
    if (parts.length > 1) {
      return parts.sublist(1).join(' - ').trim();
    }
    return nameToUse.trim();
  }

  void setPickupAddress(Address address) {
    pickupAddress = address;
    pickupController.text = address.address ?? '';
    update();
  }

  void setDestinationAddress(Address address) {
    destinationAddress = address;
    destinationController.text = address.address ?? '';
    update();
  }

  void setSelectedCarpoolType(String type, {bool notify = true}) {
    selectedCarpoolType = type;
    if (notify) update();
  }

  void setSelectedStartCity(String? city) {
    selectedStartCity = city;
    selectedBoardingPointStart = null; // Reset area when city changes
    update();
  }

  void setSelectedEndCity(String? city) {
    selectedEndCity = city;
    selectedBoardingPointEnd = null; // Reset area when city changes
    update();
  }

  void setSelectedBoardingPointStart(BoardingPoint? point) {
    selectedBoardingPointStart = point;
    update();
  }

  void setSelectedBoardingPointEnd(BoardingPoint? point) {
    selectedBoardingPointEnd = point;
    update();
  }

  void setTimes({String? departure, String? returnTime}) {
    if (departure != null) selectedDepartureTime = departure;
    if (returnTime != null) selectedReturnTime = returnTime;
    update();
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getBoardingPoints() async {
    isLoadingBoardingPoints = true;
    update();
    try {
      final list = await poolService.getBoardingPoints();
      if (list != null) {
        boardingPoints = list;
      }
    } catch (e) {
      print('Error in PoolStopPickupController.getBoardingPoints: $e');
    } finally {
      isLoadingBoardingPoints = false;
      update();
    }
  }

  Future<void> searchAvailableTrips() async {
    if (selectedCarpoolType == 'travel') {
      if (selectedBoardingPointStart == null || selectedBoardingPointEnd == null) {
        Get.snackbar(
            'Error', 'Please select both start and end boarding points');
        return;
      }
    } else {
      if (pickupAddress == null || destinationAddress == null) {
        Get.snackbar(
            'Error', 'Please select both pickup and destination locations');
        return;
      }
    }

    if (selectedDate.isEmpty) {
      Get.snackbar('Error', 'Please select a date');
      return;
    }

    _isSearchingTrips = true;
    update();

    try {
      // Create the request object
      FindMatchRequest request = FindMatchRequest(
        carpoolType: selectedCarpoolType,
        pickupLat: selectedCarpoolType == 'travel' ? null : pickupAddress!.latitude!,
        pickupLng: selectedCarpoolType == 'travel' ? null : pickupAddress!.longitude!,
        dropoffLat: selectedCarpoolType == 'travel' ? null : destinationAddress!.latitude!,
        dropoffLng: selectedCarpoolType == 'travel' ? null : destinationAddress!.longitude!,
        day: selectedDate,
        gender: selectedGender,
        seatsRequired: selectedSeats,
        rideType: selectedRideType,
        departureTime: selectedCarpoolType == 'routine' ? selectedDepartureTime : null,
        returnTime: selectedCarpoolType == 'routine' ? selectedReturnTime : null,
        boardingPointStartId: selectedCarpoolType == 'travel' ? selectedBoardingPointStart?.id : null,
        boardingPointEndId: selectedCarpoolType == 'travel' ? selectedBoardingPointEnd?.id : null,
      );

      // Make the API call
      FindMatchResponse? response =
          await poolService.findMatchingRides(request);

      // Process the response
      if (response != null && response.responseCode == 'default_200') {
        // Clear previous results
        availableTrips.clear();

        // Add new results
        availableTrips.addAll(response.data);

        // Update UI
        update();

        if (availableTrips.isEmpty) {
          Get.snackbar('No Rides Found', 'Try different route or date');
        } else {
          print('Found ${availableTrips.length} rides successfully');
        }
      } else {
        availableTrips.clear();
        Get.snackbar(
            'Error', response?.message ?? 'Failed to search for trips');
      }
    } catch (e) {
      availableTrips.clear();
      Get.snackbar(
          'Error', 'Failed to search for trips: ${e.toString()}');
    } finally {
      _isSearchingTrips = false;
      update();
    }
  }

  Future<String?> joinRide(PoolRide poolRide) async {
    if (selectedCarpoolType != 'travel') {
      if (pickupAddress == null || destinationAddress == null) {
        Get.snackbar('Error', 'Pickup and destination addresses are required');
        return null;
      }
    }

    _joiningRouteIds.add(poolRide.routeId);
    update();

    try {
      // Create the join request
      JoinRequest request = JoinRequest(
        routeId: poolRide.routeId,
        seatsCount: selectedSeats,
        pickupLat: selectedCarpoolType == 'travel' ? (poolRide.closestPickup?.lat ?? 0.0) : pickupAddress!.latitude!,
        pickupLng: selectedCarpoolType == 'travel' ? (poolRide.closestPickup?.lng ?? 0.0) : pickupAddress!.longitude!,
        dropoffLat: selectedCarpoolType == 'travel' ? (poolRide.closestDropoff?.lat ?? 0.0) : destinationAddress!.latitude!,
        dropoffLng: selectedCarpoolType == 'travel' ? (poolRide.closestDropoff?.lng ?? 0.0) : destinationAddress!.longitude!,
        fare: poolRide.price,
      );

      // Make the API call
      bool success = await poolService.joinRide(request);

      if (success) {
        final response =
            await Get.find<CarPollRideController>().carpoolSubmitRideRequest(
          poolRide.routeId.toString(),
          poolRide.price.toDouble(),
          selectedCarpoolType == 'travel' ? (poolRide.closestPickup?.lat ?? 0.0) : pickupAddress!.latitude!,
          selectedCarpoolType == 'travel' ? (poolRide.closestPickup?.lng ?? 0.0) : pickupAddress!.longitude!,
          selectedCarpoolType == 'travel' ? (poolRide.closestDropoff?.lat ?? 0.0) : destinationAddress!.latitude!,
          selectedCarpoolType == 'travel' ? (poolRide.closestDropoff?.lng ?? 0.0) : destinationAddress!.longitude!,
        );

        if (response.statusCode == 200 && response.body['data'] != null) {
          final tripId = response.body['data']['id']?.toString();
          if (tripId != null && tripId.isNotEmpty) {
            Get.snackbar(
              'Success',
              'Join request sent successfully! The driver will be notified.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            return tripId;
          }
        }

        Get.snackbar(
          'Error',
          'Failed to create trip. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to send join request. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to join ride: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _joiningRouteIds.remove(poolRide.routeId);
      update();
    }
    return null;
  }

  void setSearchParameters({
    String? gender,
    int? seats,
    String? rideType,
    String? date,
  }) {
    if (gender != null) selectedGender = gender;
    if (seats != null) selectedSeats = seats;
    if (rideType != null) selectedRideType = rideType;
    if (date != null) selectedDate = date;
    update();
  }

  void clearAddresses() {
    pickupAddress = null;
    destinationAddress = null;
    selectedBoardingPointStart = null;
    selectedBoardingPointEnd = null;
    pickupController.clear();
    destinationController.clear();
    availableTrips.clear();
    update();
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}
