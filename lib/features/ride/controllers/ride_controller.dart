import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/domain/models/parcel_estimated_fare_model.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/refund_request/controllers/refund_request_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/bidding_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/estimated_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/final_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/nearest_driver_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/remaining_distance_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/ride_service_interface.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/services/pool_service.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_request.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_response.dart';

enum RideState {
  initial,
  riseFare,
  findingRider,
  acceptingRider,
  afterAcceptRider,
  otpSent,
  ongoingRide,
  completeRide
}

enum RideType { car, bike, parcel, luxury }

class RideController extends GetxController implements GetxService {
  final RideServiceInterface rideServiceInterface;
  final PoolService poolService;
  RideController(
      {required this.rideServiceInterface, required this.poolService});

  RideState currentRideState = RideState.initial;
  RideType selectedCategory = RideType.car;
  TripDetails? tripDetails;
  TripDetails? carpoolTripDetails;
  TripDetails? rideDetails;
  double currentFarePrice = 0;
  int rideCategoryIndex = 0;
  bool isLoading = false;
  String estimatedDistance = '0';
  String estimatedDuration = '0';
  double estimatedFare = 0;
  double actualFare = 0;
  List<FareModel> fareList = [];
  ParcelEstimatedFare? parcelEstimatedFare;
  String parcelFare = '0';
  String encodedPolyLine = '';
  bool loading = false;
  bool isEstimate = false;
  bool isSubmit = false;
  List<Nearest> nearestDriverList = [];
  FinalFare? finalFare;
  List<Bidding> biddingList = [];
  List<RemainingDistanceModel> remainingDistanceModel = [];
  bool isCouponApplicable = false;
  double discountFare = 0;
  double discountAmount = 0;
  List<String>? _thumbnailPaths;
  List<String>? get thumbnailPaths => _thumbnailPaths;

  TripDetails? get currentTripDetails => tripDetails;
  TripDetails? get currentCarpoolTripDetails => carpoolTripDetails;

  // Carpool properties
  Address? pickupAddress;
  Address? destinationAddress;
  String selectedDate = '';
  String selectedGender = 'both';
  int selectedSeats = 1;
  String selectedRideType = 'work';
  bool _isSearchingTrips = false;
  List<dynamic> availableTrips = [];
  String? carpollRouteId;
  bool _isCarpoolInitialized = false;

  bool get isSearchingTrips => _isSearchingTrips;
  bool get isCarpoolInitialized => _isCarpoolInitialized;

  TextEditingController inputFarePriceController =
      TextEditingController(text: '0.00');
  TextEditingController noteController = TextEditingController();

  void initData() {
    currentRideState = RideState.initial;
    tripDetails = null;
    isLoading = false;
    loading = false;
    encodedPolyLine = '';
  }

  void updateRideCurrentState(RideState newState) {
    currentRideState = newState;
    update();
  }

  void updateSelectedRideType(RideType newType) {
    selectedCategory = newType;
    update();
  }

  Future<void> setBidingAmount(String balance) async {
    if (balance.isNotEmpty) {
      actualFare = double.parse(balance);
      parcelFare = balance;
    }
    update();
  }

  String categoryName = '';
  String selectedCategoryId = '';
  FareModel? selectedType;
  void setRideCategoryIndex(int newIndex) {
    rideCategoryIndex = newIndex;
    var categoryList = Get.find<CategoryController>().categoryList;
    if (categoryList != null &&
        categoryList.isNotEmpty &&
        rideCategoryIndex < categoryList.length) {
      categoryName = categoryList[rideCategoryIndex].id ?? '';
    } else {
      categoryName = '';
    }

    if (fareList.isNotEmpty) {
      for (int i = 0; i < fareList.length; i++) {
        if (fareList[i].vehicleCategoryId == categoryName) {
          selectedType = fareList[i];
          break;
        }
      }

      if (selectedType != null) {
        estimatedDistance = selectedType?.estimatedDistance ?? '0';
        estimatedDuration = selectedType?.estimatedDuration ?? '0';
        selectedCategoryId = selectedType?.vehicleCategoryId ?? '';

        estimatedFare = (selectedType?.extraFareFee ?? 0) > 0
            ? selectedType?.extraEstimatedFare ?? 0
            : selectedType?.estimatedFare ?? 0;
        currentFarePrice = estimatedFare;
        actualFare = estimatedFare;
        isCouponApplicable = selectedType?.couponApplicable ?? false;
        discountFare = (selectedType?.extraFareFee ?? 0) > 0
            ? selectedType?.extraDiscountFare ?? 0
            : selectedType?.discountFare ?? 0;
        discountAmount = (selectedType?.extraFareFee ?? 0) > 0
            ? selectedType?.extraDiscountAmount ?? 0
            : selectedType?.discountAmount ?? 0;
      }
    }

    update();
  }

  void resetControllerValue() {
    currentRideState = RideState.initial;
    selectedCategory = RideType.car;
    rideCategoryIndex = 0;
    update();
  }

  void clearRideDetails() {
    tripDetails = null;
    rideDetails = null;
    update();
  }

  @override
  onInit() {
    if (tripDetails != null &&
        Get.find<AuthController>().getUserToken() != '') {
      startLocationRecord();
    } else {
      stopLocationRecord();
    }
    super.onInit();
  }

  Future<Response?> getEstimatedFare(bool parcel) async {
    loading = true;
    isEstimate = true;
    update();
    parcelEstimatedFare = null;
    LocationController locController = Get.find<LocationController>();
    ParcelController parcelController = Get.find<ParcelController>();

    Address? fromPosition =
        parcel ? locController.parcelSenderAddress : locController.fromAddress;
    Address? toPosition =
        parcel ? locController.parcelReceiverAddress : locController.toAddress;

    if (fromPosition == null || toPosition == null) {
      loading = false;
      isEstimate = false;
      update();
      // Return early or handle error
      return null;
    }

    Response? response = await rideServiceInterface.getEstimatedFare(
      pickupLatLng: LatLng(fromPosition.latitude!, fromPosition.longitude!),
      destinationLatLng: LatLng(toPosition.latitude!, toPosition.longitude!),
      currentLatLng: LatLng(locController.initialPosition.latitude,
          locController.initialPosition.longitude),
      type: parcel ? 'parcel' : 'ride_request',
      pickupAddress: parcel
          ? parcelController.senderAddressController.text
          : locController.fromAddress?.address?.toString() ?? '',
      destinationAddress: parcel
          ? parcelController.receiverAddressController.text
          : locController.toAddress?.address ?? '',
      extraOne: locController.extraOneRoute,
      extraTwo: locController.extraTwoRoute,
      extraOneLatLng: locController.extraRouteAddress != null
          ? LatLng(
              locController.extraRouteAddress!.latitude!,
              locController.extraRouteAddress!.longitude!,
            )
          : null,
      extraTwoLatLng: locController.extraRouteTwoAddress != null
          ? LatLng(
              locController.extraRouteTwoAddress!.latitude!,
              locController.extraRouteTwoAddress!.longitude!,
            )
          : null,
      parcelWeight: Get.find<ParcelController>().parcelWeightController.text,
      parcelCategoryId: (parcel &&
              parcelController.parcelCategoryList != null &&
              parcelController.selectedParcelCategory <
                  parcelController.parcelCategoryList!.length)
          ? parcelController
              .parcelCategoryList![parcelController.selectedParcelCategory].id
          : '',
    );

    if (response != null && response.statusCode == 200) {
      loading = false;
      isEstimate = false;
      /*locController.pickupLocationController.clear();
      locController.destinationLocationController.clear();
      locController.extraRouteOneController.clear();
      locController.extraRouteTwoController.clear();*/

      if (parcel) {
        parcelEstimatedFare = ParcelEstimatedFare.fromJson(response.body);
        if (parcelEstimatedFare?.data != null) {
          encodedPolyLine = parcelEstimatedFare!.data!.encodedPolyline ?? '';
          parcelFare = parcelEstimatedFare!.data!.estimatedFare!.toString();
        }
      } else {
        fareList = [];
        if (response.body != null) {
          fareList
              .addAll(EstimatedFareModel.fromJson(response.body).data ?? []);
        }

        print(
            "${fareList.isNotEmpty ? fareList[rideCategoryIndex].toJson() : ''}");
        setRideCategoryIndex(rideCategoryIndex != 0 ? rideCategoryIndex : 0);
        if (fareList.isNotEmpty && rideCategoryIndex < fareList.length) {
          encodedPolyLine = fareList[rideCategoryIndex].polyline ?? '';
        }

        if (encodedPolyLine != '' && encodedPolyLine.isNotEmpty) {
          //   Get.find<MapController>().getPolyline();
        }
      }
    } else {
      loading = false;
      isEstimate = false;
      if (response != null) {
        ApiChecker.checkApi(response);
        if (response.statusCode == 403 && !parcel) {
          getCurrentRideStatus(navigateToMap: false);
        }
      }
    }

    update();
    return response;
  }

  Future<Response> submitRideRequest(String note, bool parcel,
      {bool isCarpool = false, String categoryId = ''}) async {
    initCountingTimeStates();
    isSubmit = true;
    update();

    LocationController locController = Get.find<LocationController>();
    Address? pickUpPosition = parcel
        ? locController.parcelSenderAddress
        : tripDetails == null
            ? locController.fromAddress
            : Address();
    Address? destinationPosition = parcel
        ? locController.parcelReceiverAddress
        : tripDetails == null
            ? locController.toAddress
            : Address();

    if (pickUpPosition == null || destinationPosition == null) {
      // Handle error: Pickup or destination is missing
      isSubmit = false;
      update();
      return Response(statusCode: 400, statusText: "Invalid address");
    }

    Response response = await rideServiceInterface.submitRideRequest(
      pickupLat: pickUpPosition.latitude?.toString() ?? '',
      pickupLng: pickUpPosition.longitude?.toString() ?? '',
      destinationLat: destinationPosition.latitude?.toString() ?? '',
      destinationLng: destinationPosition.longitude?.toString() ?? '',
      customerCurrentLat: locController.initialPosition.latitude.toString(),
      customerCurrentLng: locController.initialPosition.longitude.toString(),
      type: parcel
          ? 'parcel'
          : isCarpool
              ? 'carpool'
              : 'ride_request',
      pickupAddress: parcel
          ? Get.find<ParcelController>().senderAddressController.text
          : tripDetails == null
              ? locController.fromAddress?.address?.toString() ?? ''
              : tripDetails?.pickupAddress ?? '',
      destinationAddress: parcel
          ? Get.find<ParcelController>().receiverAddressController.text
          : locController.toAddress?.address ??
              tripDetails?.destinationAddress ??
              '',
      vehicleCategoryId: parcel ? categoryId : selectedCategoryId,
      estimatedDistance: parcel
          ? parcelEstimatedFare?.data?.estimatedDistance?.toString() ?? '0'
          : estimatedDistance,
      estimatedTime: parcel
          ? parcelEstimatedFare?.data?.estimatedDuration
                  ?.replaceFirst('min', '') ??
              '0'
          : estimatedDuration,
      estimatedFare: parcel ? parcelFare : estimatedFare.toString(),
      actualFare: parcel
          ? parcelFare
          : estimatedFare != actualFare
              ? actualFare.toString()
              : estimatedFare.toString(),
      bid: parcel ? false : estimatedFare != actualFare,
      note: note,
      paymentMethod: Get.find<PaymentController>().paymentTypeList.isNotEmpty
          ? Get.find<PaymentController>()
              .paymentTypeList[Get.find<PaymentController>().paymentTypeIndex]
          : 'cash',
      encodedPolyline: parcel
          ? encodedPolyLine
          : (fareList.isNotEmpty && rideCategoryIndex < fareList.length)
              ? fareList[rideCategoryIndex].polyline ?? ''
              : '',
      middleAddress: [
        locController.extraRouteAddress?.address ?? '',
        locController.extraRouteTwoAddress?.address ?? ''
      ],
      entrance: locController.entranceController.text.toString(),
      extraOne: locController.extraOneRoute,
      extraTwo: locController.extraTwoRoute,
      extraLatOne: locController.extraRouteAddress != null
          ? locController.extraRouteAddress!.latitude.toString()
          : '',
      extraLngOne: locController.extraRouteAddress != null
          ? locController.extraRouteAddress!.longitude.toString()
          : '',
      extraLatTwo: locController.extraRouteTwoAddress != null
          ? locController.extraRouteTwoAddress!.latitude.toString()
          : '',
      extraLngTwo: locController.extraRouteTwoAddress != null
          ? locController.extraRouteTwoAddress!.longitude.toString()
          : '',
      areaId: parcel
          ? ''
          : (fareList.isNotEmpty && rideCategoryIndex < fareList.length)
              ? fareList[rideCategoryIndex].areaId ?? ''
              : '',
      senderName: Get.find<ParcelController>().senderNameController.text,
      senderPhone: Get.find<ParcelController>().getSenderContactNumber,
      senderAddress: Get.find<ParcelController>().senderAddressController.text,
      receiverName: Get.find<ParcelController>().receiverNameController.text,
      receiverPhone: Get.find<ParcelController>().getReceiverContactNumber,
      receiverAddress:
          Get.find<ParcelController>().receiverAddressController.text,
      parcelCategoryId: (parcel &&
              Get.find<ParcelController>().parcelCategoryList != null &&
              Get.find<ParcelController>().selectedParcelCategory <
                  Get.find<ParcelController>().parcelCategoryList!.length)
          ? Get.find<ParcelController>()
              .parcelCategoryList![
                  Get.find<ParcelController>().selectedParcelCategory]
              .id
          : '',
      payer: Get.find<ParcelController>().payReceiver ? 'receiver' : "sender",
      weight: Get.find<ParcelController>().parcelWeightController.text,
      tripRequestId: parcel ? null : tripDetails?.id,
      returnFee: parcel ? parcelEstimatedFare?.data?.returnFee : 0,
      cancellationFee: parcel ? parcelEstimatedFare?.data?.cancellationFee : 0,
      extraEstimatedFare: parcel
          ? (parcelEstimatedFare?.data?.extraEstimatedFare ?? 0)
          : (selectedType?.extraEstimatedFare ?? 0),
      extraDiscountFare: parcel
          ? (parcelEstimatedFare?.data?.extraDiscountFare ?? 0)
          : (selectedType?.extraDiscountFare ?? 0),
      extraDiscountAmount: parcel
          ? (parcelEstimatedFare?.data?.extraDiscountAmount ?? 0)
          : (selectedType?.extraDiscountAmount ?? 0),
      extraReturnFee: parcel
          ? (parcelEstimatedFare?.data?.extraReturnFee ?? 0)
          : (selectedType?.extraReturnFee ?? 0),
      extraCancellationFee: parcel
          ? (parcelEstimatedFare?.data?.extraCancellationFee ?? 0)
          : (selectedType?.extraCancellationFee ?? 0),
      extraFareAmount: parcel
          ? (parcelEstimatedFare?.data?.extraFareAmount ?? 0)
          : (selectedType?.extraFareAmount ?? 0),
      extraFareFee: parcel
          ? (parcelEstimatedFare?.data?.extraFareFee ?? 0)
          : (selectedType?.extraFareFee ?? 0),
      zoneId: parcel
          ? parcelEstimatedFare?.data?.zoneId ?? ''
          : selectedType?.zoneId,
      isCarpool: isCarpool,
      carpollRouteId: (isCarpool && carpollRouteId != null)
          ? int.tryParse(carpollRouteId!)
          : null,
    );

    if (response.statusCode == 200 && response.body['data'] != null) {
      biddingList = [];
      tripDetails = TripDetailsModel.fromJson(response.body).data;
      if (tripDetails != null) {
        tripDetails!.id = response.body['data']['id'];
        encodedPolyLine = tripDetails?.encodedPolyline ?? '';
        if (encodedPolyLine != '' && encodedPolyLine.isNotEmpty) {
          //  Get.find<MapController>().getPolyline();
        }
        PusherHelper().pusherDriverStatus(response.body['data']['id']);
      }

      Get.find<ParcelController>().receiverNameController.clear();
      Get.find<ParcelController>().receiverContactController.clear();
      Get.find<ParcelController>().receiverAddressController.clear();
      Get.find<ParcelController>().onChangeReceiverCountryCode(null);
      Get.find<ParcelController>().onChangeSenderCountryCode(null);
      Get.find<ParcelController>().parcelWeightController.clear();

      isSubmit = false;
      noteController.clear();
    } else {
      isSubmit = false;
      ApiChecker.checkApi(response);
      if (response.statusCode == 403) {
        getCurrentRideStatus(navigateToMap: false);
      }
    }
    actualFare = 0;
    isLoading = false;
    update();
    if (isCarpool) {
      Get.offAll(() => const DashboardScreen());
    }

    return response;
  }

  void clearExtraRoute() {
    Get.find<LocationController>().extraOneRoute = false;
    Get.find<LocationController>().extraTwoRoute = false;
    Get.find<LocationController>().extraRouteAddress = null;
    Get.find<LocationController>().extraRouteTwoAddress = null;
  }

  Future<Response?> getRideDetails(String tripId,
      {bool isUpdate = true}) async {
    isLoading = true;
    tripDetails = null;
    _thumbnailPaths = null;
    if (isUpdate) {
      update();
    }

    Response? response = await rideServiceInterface.getRideDetails(tripId);
    if (response?.statusCode == 200) {
      Get.find<MapController>().notifyMapController();
      tripDetails = TripDetailsModel.fromJson(response!.body).data!;
      estimatedDistance = tripDetails!.estimatedDistance!.toString();
      isLoading = false;

      encodedPolyLine = tripDetails!.encodedPolyline!;
      List<Attachments> attachments =
          tripDetails?.parcelRefund?.attachments ?? [];
      _thumbnailPaths = List.filled(attachments.length, '');

      if (tripDetails?.parcelRefund?.attachments != null) {
        Future.forEach(tripDetails!.parcelRefund!.attachments!,
            (element) async {
          if (element.file!.contains('.mp4')) {
            String? path = await Get.find<RefundRequestController>()
                .generateThumbnail(element.file!);
            _thumbnailPaths?[tripDetails!.parcelRefund!.attachments!
                .indexOf(element)] = path ?? '';

            update();
          }
        });
      }
    }

    update();
    return response;
  }

  Future<void> searchAvailableTrips() async {
    Get.find<LocationController>().fromAddress;
    Get.find<LocationController>().toAddress;

    if (pickupAddress == null || destinationAddress == null) {
      Get.snackbar(
          'Error', 'Please select both pickup and destination locations');
      return;
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
        pickupLat: pickupAddress!.latitude!,
        pickupLng: pickupAddress!.longitude!,
        dropoffLat: destinationAddress!.latitude!,
        dropoffLng: destinationAddress!.longitude!,
        day: selectedDate,
        gender: selectedGender,
        seatsRequired: selectedSeats,
        rideType: selectedRideType,
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
          'Error', 'Failed to search for hihuhihstrips: ${e.toString()}');
    } finally {
      _isSearchingTrips = false;
      update();
    }
  }

  bool runningTrip = false;

  Future<Response?> getCurrentRideStatus(
      {bool fromRefresh = false,
      bool navigateToMap = true,
      String type = ''}) async {
    runningTrip = true;
    Response? response = await rideServiceInterface.currentRideStatus(type);
    if (response?.statusCode == 200 && response?.body['data'] != null) {
      runningTrip = false;
      tripDetails = TripDetailsModel.fromJson(response!.body).data!;
      estimatedDistance = tripDetails!.estimatedDistance!.toString();
      String currentRideStatus = tripDetails!.currentStatus!;
      encodedPolyLine = tripDetails!.encodedPolyline ?? '';

      if (currentRideStatus == AppConstants.accepted ||
          currentRideStatus == AppConstants.ongoing) {
        updateRideCurrentState(currentRideStatus == AppConstants.accepted
            ? RideState.acceptingRider
            : RideState.ongoingRide);
        Get.find<MapController>().notifyMapController();
        if (navigateToMap) {
          Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
        }
      } else if (currentRideStatus == AppConstants.pending) {
        Get.find<RideController>()
            .updateRideCurrentState(RideState.findingRider);
        Get.find<RideController>().getBiddingList(tripDetails!.id!, 1);
        Get.find<MapController>().notifyMapController();
        if (navigateToMap) {
          Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
        }
      } else if (currentRideStatus == AppConstants.completed ||
          currentRideStatus == AppConstants.cancelled) {
        getFinalFare(tripDetails!.id!);
        Get.off(() => const PaymentScreen());
      } else {
        if (Get.find<LocationController>().getUserAddress() != null) {
          if (!fromRefresh) {
            Get.offAll(() => const DashboardScreen());
          }
        } else {
          Get.offAll(() => const AccessLocationScreen());
        }
      }
    } else {
      runningTrip = false;
      tripDetails = null;
      rideDetails = null;
      if (Get.find<LocationController>().getUserAddress() != null) {
        if (!fromRefresh) {
          Get.offAll(() => const DashboardScreen());
        }
      } else {
        Get.to(() => const AccessLocationScreen());
      }
    }
    update();
    return response;
  }

  Future<Response?> getCarpoolRideDetails(String tripId,
      {bool isUpdate = true}) async {
    isLoading = true;
    carpoolTripDetails = null;
    _thumbnailPaths = null;
    if (isUpdate) {
      update();
    }

    Response? response = await rideServiceInterface.getRideDetails(tripId);
    if (response?.statusCode == 200) {
      Get.find<MapController>().notifyMapController();
      carpoolTripDetails = TripDetailsModel.fromJson(response!.body).data!;
      estimatedDistance = carpoolTripDetails!.estimatedDistance!.toString();
      isLoading = false;

      encodedPolyLine = carpoolTripDetails!.encodedPolyline!;
      List<Attachments> attachments =
          carpoolTripDetails?.parcelRefund?.attachments ?? [];
      _thumbnailPaths = List.filled(attachments.length, '');

      if (carpoolTripDetails?.parcelRefund?.attachments != null) {
        Future.forEach(carpoolTripDetails!.parcelRefund!.attachments!,
            (element) async {
          if (element.file!.contains('.mp4')) {
            String? path = await Get.find<RefundRequestController>()
                .generateThumbnail(element.file!);
            _thumbnailPaths?[carpoolTripDetails!.parcelRefund!.attachments!
                .indexOf(element)] = path ?? '';

            update();
          }
        });
      }
    }

    update();
    return response;
  }

  Future<Response?> getCurrentCarpoolRideStatus(
      {bool fromRefresh = false,
      bool navigateToMap = true,
      String type = 'carpool'}) async {
    runningTrip = true;
    Response? response = await rideServiceInterface.currentRideStatus(type);
    if (response?.statusCode == 200 && response?.body['data'] != null) {
      runningTrip = false;
      carpoolTripDetails = TripDetailsModel.fromJson(response!.body).data!;
      estimatedDistance = carpoolTripDetails!.estimatedDistance!.toString();
      String currentRideStatus = carpoolTripDetails!.currentStatus!;
      encodedPolyLine = carpoolTripDetails!.encodedPolyline ?? '';

      if (currentRideStatus == AppConstants.accepted ||
          currentRideStatus == AppConstants.ongoing) {
        updateRideCurrentState(currentRideStatus == AppConstants.accepted
            ? RideState.acceptingRider
            : RideState.ongoingRide);
        Get.find<MapController>().notifyMapController();
        if (navigateToMap) {
          Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
        }
      } else if (currentRideStatus == AppConstants.pending) {
        Get.find<RideController>()
            .updateRideCurrentState(RideState.findingRider);
        Get.find<RideController>().getBiddingList(carpoolTripDetails!.id!, 1);
        Get.find<MapController>().notifyMapController();
        if (navigateToMap) {
          Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
        }
      } else if (currentRideStatus == AppConstants.completed ||
          currentRideStatus == AppConstants.cancelled) {
        if (carpoolTripDetails!.type != 'carpool') {
          getFinalFare(carpoolTripDetails!.id!);
          Get.off(() => const PaymentScreen());
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      } else {
        if (Get.find<LocationController>().getUserAddress() != null) {
          if (!fromRefresh) {
            Get.offAll(() => const DashboardScreen());
          }
        } else {
          Get.offAll(() => const AccessLocationScreen());
        }
      }
      tripDetails = carpoolTripDetails;
      carpollRouteId = null;
    } else {
      runningTrip = false;
      carpoolTripDetails = null;
      if (Get.find<LocationController>().getUserAddress() != null) {
        if (!fromRefresh) {
          Get.offAll(() => const DashboardScreen());
        }
      } else {
        Get.to(() => const AccessLocationScreen());
      }
    }
    update();
    return response;
  }

  Future<Response?> getCurrentRideCarpool(
      {bool fromRefresh = false,
      bool navigateToMap = true,
      String type = ''}) async {
    Response? response =
        await rideServiceInterface.currentRideStatus("carpool");
    print(" carpool======  ${response?.body['data']}");

    if (response?.statusCode == 200 && response?.body['data'] != null) {
      carpoolTripDetails = TripDetailsModel.fromJson(response!.body).data!;
      estimatedDistance = carpoolTripDetails!.estimatedDistance!.toString();
      encodedPolyLine = carpoolTripDetails!.encodedPolyline ?? '';
    }
    // else if (response.statusCode == 403) {
    //   rideDetails = null;
    // }
    update();
    return response;
  }

  Future<Response> getCurrentRide(
      {bool fromRefresh = false,
      bool navigateToMap = true,
      String type = ''}) async {
    Response response = await rideServiceInterface.currentRideStatus(type);
    print(" ride====== ${response.body['data']}");

    if (response.statusCode == 200 && response.body['data'] != null) {
      tripDetails =
          rideDetails = TripDetailsModel.fromJson(response.body).data!;
      estimatedDistance = rideDetails!.estimatedDistance!.toString();
      encodedPolyLine = rideDetails!.encodedPolyline ?? '';
    } else if (response.statusCode == 403) {
      rideDetails = null;
    }
    update();
    return response;
  }

  Future<Response?> remainingDistanceCarpool(String requestID,
      {bool mapBound = false}) async {
    isLoading = true;
    Response? response = await rideServiceInterface.remainDistance(requestID);
    if (response?.statusCode == 200) {
      Get.find<MapController>().getDriverToPickupOrDestinationPolyline(
          response!.body[0]["encoded_polyline"],
          mapBound: mapBound);
      remainingDistanceModel = [];
      for (var distance in response.body) {
        remainingDistanceModel.add(RemainingDistanceModel.fromJson(distance));
      }

      if (Get.find<MapController>().isInside &&
          carpoolTripDetails != null &&
          currentRideState == RideState.acceptingRider) {
        currentRideState = RideState.otpSent;
      }
      if (Get.find<MapController>().isInside &&
          Get.find<ParcelController>().currentParcelState ==
              ParcelDeliveryState.acceptRider) {
        Get.find<ParcelController>()
            .updateParcelState(ParcelDeliveryState.otpSent);
      }
      arrivalPickupPoint(carpoolTripDetails!.id!);
      isLoading = false;
    } else {
      isLoading = false;
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    update();
    return response;
  }

  Future<Response?> remainingDistance(String requestID,
      {bool mapBound = false}) async {
    isLoading = true;
    Response? response = await rideServiceInterface.remainDistance(requestID);
    if (response?.statusCode == 200) {
      Get.find<MapController>().getDriverToPickupOrDestinationPolyline(
          response!.body[0]["encoded_polyline"],
          mapBound: mapBound);
      remainingDistanceModel = [];
      for (var distance in response.body) {
        remainingDistanceModel.add(RemainingDistanceModel.fromJson(distance));
      }

      if (Get.find<MapController>().isInside &&
          tripDetails != null &&
          currentRideState == RideState.acceptingRider) {
        currentRideState = RideState.otpSent;
      }
      if (Get.find<MapController>().isInside &&
          Get.find<ParcelController>().currentParcelState ==
              ParcelDeliveryState.acceptRider) {
        Get.find<ParcelController>()
            .updateParcelState(ParcelDeliveryState.otpSent);
      }
      if (tripDetails != null) {
        arrivalPickupPoint(tripDetails!.id!);
      }
      isLoading = false;
    } else {
      isLoading = false;
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    update();
    return response;
  }

  Future<Response?> getBiddingList(String tripId, int offset) async {
    isLoading = true;

    Response? response = await rideServiceInterface.biddingList(tripId, offset);
    if (response?.statusCode == 200) {
      biddingList = [];
      biddingList.addAll(BiddingModel.fromJson(response!.body).data!);
      isLoading = false;
    } else {
      isLoading = false;
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    update();
    return response;
  }

  Future<Response?> ignoreBidding(String bidId, String tripId) async {
    isLoading = true;
    update();
    Response? response = await rideServiceInterface.ignoreBidding(bidId);
    if (response?.statusCode == 200) {
      getBiddingList(tripId, 1).then((value) {
        if (biddingList.isEmpty) {
          Get.back();
        }
      });
      isLoading = false;
    } else {
      getBiddingList(tripId, 1).then((value) {
        if (biddingList.isEmpty) {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300)).then((value) {
            if (response != null) {
              ApiChecker.checkApi(response);
            }
          });
        }
      });
      isLoading = false;
    }
    update();
    return response;
  }

  Future<Response?> getNearestDriverList(String lat, String lng) async {
    Response? response = await rideServiceInterface.nearestDriverList(lat, lng);
    if (response?.statusCode == 200) {
      nearestDriverList = [];
      nearestDriverList
          .addAll(NearestDriverModel.fromJson(response!.body).data!);
      Get.find<MapController>().searchDeliveryMen();
    } else {
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    update();
    return response;
  }

  Timer? _timer;
  void startLocationRecord() {
    ///For First time call next call every 10 seconds.......
    if (Get.find<RideController>().tripDetails != null &&
        Get.find<AuthController>().getUserToken() != '') {
      Get.find<RideController>().remainingDistance(
          Get.find<RideController>().tripDetails!.id!,
          mapBound: true);
    } else if (Get.find<RideController>().carpoolTripDetails != null &&
        Get.find<AuthController>().getUserToken() != '') {
      Get.find<RideController>().remainingDistanceCarpool(
          Get.find<RideController>().carpoolTripDetails!.id!,
          mapBound: true);
    } else {
      _timer?.cancel();
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (Get.find<RideController>().tripDetails != null &&
          Get.find<AuthController>().getUserToken() != '' &&
          (Get.find<RideController>().tripDetails?.currentStatus ==
                  'accepted' ||
              Get.find<RideController>().tripDetails?.currentStatus ==
                  'ongoing')) {
        Get.find<RideController>()
            .remainingDistance(Get.find<RideController>().tripDetails!.id!);
      } else if (Get.find<RideController>().carpoolTripDetails != null &&
          Get.find<AuthController>().getUserToken() != '' &&
          (Get.find<RideController>().carpoolTripDetails?.currentStatus ==
                  'accepted' ||
              Get.find<RideController>().carpoolTripDetails?.currentStatus ==
                  'ongoing')) {
        Get.find<RideController>().remainingDistanceCarpool(
            Get.find<RideController>().carpoolTripDetails!.id!);
      } else {
        _timer?.cancel();
      }
    });
  }

  void stopLocationRecord() {
    _timer?.cancel();
  }

  Future<Response?> tripAcceptOrRejected(
      String tripId, String type, String driverId) async {
    isLoading = true;
    update();
    Response? response =
        await rideServiceInterface.tripAcceptOrReject(tripId, type, driverId);
    if (response?.statusCode == 200) {
      biddingList = [];
      showCustomSnackBar('trip_is_accepted'.tr, isError: false);
      Get.back();
      getRideDetails(tripId).then((value) {
        if (value?.statusCode == 200) {
          if (tripDetails != null) {
            remainingDistance(tripDetails!.id!, mapBound: true);
          }
          updateRideCurrentState(RideState.otpSent);
          Get.find<MapController>().notifyMapController();
          Get.offAll(() => const MapScreen(fromScreen: MapScreenType.ride));
        }
      });
      isLoading = false;
    } else {
      getBiddingList(tripId, 1).then((value) {
        if (biddingList.isEmpty) {
          Get.back();
          Future.delayed(const Duration(milliseconds: 300)).then((value) {
            if (response != null) {
              ApiChecker.checkApi(response);
            }
          });
        }
      });
      isLoading = false;
    }
    update();
    return response;
  }

  void clearBiddingList() {
    biddingList = [];
    update();
  }

  Future<Response?> tripStatusUpdate(
      String tripId, String status, String message, String cancellationCause,
      {bool afterAccept = false}) async {
    isLoading = true;
    update();
    Response? response = await rideServiceInterface.tripStatusUpdate(
        tripId, status, cancellationCause);
    if (response?.statusCode == 200) {
      Get.find<TripController>().othersCancellationController.clear();
      if (status == "cancelled" && !afterAccept) {
        tripDetails = null;
      }
      showCustomSnackBar(message.tr, isError: false);
      isLoading = false;
    } else {
      isLoading = false;
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    update();
    return response;
  }

  Future<Response?> getFinalFare(String tripId) async {
    isLoading = true;
    update();
    Response? response = await rideServiceInterface.getFinalFare(tripId);
    if (response?.statusCode == 200) {
      if (response?.body['data'] != null) {
        finalFare = FinalFareModel.fromJson(response!.body).data!;
      }
    } else {
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    isLoading = false;
    update();
    return response;
  }

  Future<Response?> arrivalPickupPoint(String tripId) async {
    isLoading = true;
    Response? response = await rideServiceInterface.arrivalPickupPoint(tripId);
    if (response?.statusCode == 200) {
    } else {
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    isLoading = false;
    update();
    return response;
  }

  String driverLat = '0';
  String driverLng = '0';
  Future<void> detDriverLocation(String tripId) async {
    Response? response = await rideServiceInterface.arrivalPickupPoint(tripId);
    if (response?.statusCode == 200) {
      driverLat = response!.body['data']['latitude'];
      driverLng = response.body['data']['longitude'];
    }
    update();
  }

  double? firstCount = 0;
  double? secondCount = 0;
  double? thirdCount = 0;
  int stateCount = 0;
  Timer? _findingStateAnimation;

  void countingTimeStates() async {
    _findingStateAnimation?.cancel();
    if (stateCount == 0) {
      await Future.delayed(const Duration(seconds: 1)).then((value) {
        firstCount = null;
        secondCount = 0;
        thirdCount = 0;
        update();
      });

      _findingStateAnimation =
          Timer.periodic(const Duration(minutes: 1), (time) {
        firstCount = 1;
        stateCount = 1;
        countingTimeStates();
      });
    }

    if (stateCount == 1) {
      await Future.delayed(const Duration(milliseconds: 100)).then((value) {
        firstCount = 1;
        secondCount = null;
        thirdCount = 0;
        update();
      });

      _findingStateAnimation =
          Timer.periodic(const Duration(minutes: 1), (time) {
        secondCount = 1;
        stateCount = 2;
        countingTimeStates();
      });
    }

    if (stateCount == 2) {
      await Future.delayed(const Duration(milliseconds: 100)).then((value) {
        firstCount = 1;
        secondCount = 1;
        thirdCount = null;
        update();
      });

      _findingStateAnimation =
          Timer.periodic(const Duration(minutes: 3), (time) {
        thirdCount = 1;
        stateCount = 3;
        update();
        _findingStateAnimation?.cancel();
      });
    }

    if (stateCount == 3) {
      update();
    }
  }

  void initCountingTimeStates({bool isRestart = false}) {
    if (isRestart) {
      if (stateCount == 3) {
        firstCount = 0;
        secondCount = 0;
        thirdCount = 0;
        stateCount = 0;
      }
      countingTimeStates();
    } else {
      firstCount = 0;
      secondCount = 0;
      thirdCount = 0;
      stateCount = 0;
    }
  }

  void resumeCountingTimeState(int duration) {
    if (duration < 60) {
      secondCount = 0;
      thirdCount = 0;
      stateCount = 0;
    } else if (duration > 60 && duration < 120) {
      firstCount = 1;
      thirdCount = 0;
      stateCount = 1;
    } else if (duration > 120 && duration < 300) {
      firstCount = 1;
      secondCount = 1;
      stateCount = 2;
    } else {
      firstCount = 1;
      secondCount = 1;
      thirdCount = 1;
      stateCount = 3;
    }
    countingTimeStates();
  }

  Future<Response?> parcelReturned(String tripId) async {
    isLoading = true;
    update();
    Response? response = await rideServiceInterface.parcelReceived(tripId);
    if (response?.statusCode == 200) {
      getRideDetails(tripId);
      Get.find<ParcelController>().getOngoingParcelList();
    } else {
      if (response != null) {
        ApiChecker.checkApi(response);
      }
    }
    isLoading = false;
    update();
    return response;
  }

  // Carpool methods
  void setCarpoolAddresses(Address pickup, Address destination) {
    pickupAddress = pickup;
    destinationAddress = destination;
    update();
  }

  void setCarpoolSearchParameters({
    String? date,
    String? gender,
    int? seats,
    String? rideType,
  }) {
    if (date != null) selectedDate = date;
    if (gender != null) selectedGender = gender;
    if (seats != null) selectedSeats = seats;
    if (rideType != null) selectedRideType = rideType;
    update();
  }

  void selectCarpoolTrip(dynamic trip) async {
    carpollRouteId = trip.routeId.toString();
    isLoading = true;
    update();

    // Show loading dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(Get.context!).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Processing your request...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await submitRideRequest('', false, isCarpool: true);

      // Close loading dialog
      Get.back();

      // Show success snackbar
      Get.snackbar(
        'Success!',
        'Your carpool ride request has been submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      // Close loading dialog
      Get.back();

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to submit ride request: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearCarpoolData() {
    pickupAddress = null;
    destinationAddress = null;
    selectedDate = '';
    selectedGender = 'both';
    selectedSeats = 1;
    selectedRideType = 'work';
    availableTrips.clear();
    carpollRouteId = null;
    _isSearchingTrips = false;
    _isCarpoolInitialized = false;
    update();
  }

  void initializeCarpoolFromLocationController() {
    // Prevent multiple initializations
    if (_isCarpoolInitialized) {
      print('Carpool already initialized, skipping...');
      return;
    }

    LocationController locationController = Get.find<LocationController>();

    print('=== Initializing Carpool from LocationController ===');
    print(
        'LocationController fromAddress: ${locationController.fromAddress?.address}');
    print(
        'LocationController toAddress: ${locationController.toAddress?.address}');

    // Set pickup address from location controller
    if (locationController.fromAddress != null) {
      pickupAddress = locationController.fromAddress;
      print('Pickup address set: ${pickupAddress?.address}');
    } else {
      print('WARNING: fromAddress is null in LocationController');
    }

    // Set destination address from location controller
    if (locationController.toAddress != null) {
      destinationAddress = locationController.toAddress;
      print('Destination address set: ${destinationAddress?.address}');
    } else {
      print('WARNING: toAddress is null in LocationController');
    }

    // Mark as initialized
    _isCarpoolInitialized = true;

    print('Final carpool state:');
    print('- Pickup: ${pickupAddress?.address}');
    print('- Destination: ${destinationAddress?.address}');
    print('- PoolService available: ${poolService != null}');
    print('=== End Carpool Initialization ===');

    update();
  }

  void setSearchingTrips(bool searching) {
    _isSearchingTrips = searching;
    update();
  }

  void debugCarpoolState() {
    LocationController locationController = Get.find<LocationController>();

    print('=== Carpool Debug State ===');
    print('RideController State:');
    print('- Pickup Address: ${pickupAddress?.address}');
    print('- Destination Address: ${destinationAddress?.address}');
    print('- Selected Date: $selectedDate');
    print('- Selected Gender: $selectedGender');
    print('- Selected Seats: $selectedSeats');
    print('- Selected Ride Type: $selectedRideType');
    print('- Available Trips: ${availableTrips.length}');
    print('- Is Searching: $_isSearchingTrips');
    print('- Carpool Route ID: $carpollRouteId');
    print('- PoolService: ${poolService != null}');

    print('\nLocationController State:');
    print('- fromAddress: ${locationController.fromAddress?.address}');
    print('- toAddress: ${locationController.toAddress?.address}');
    print('==========================');
  }
}

class ThumbnailPathModel {
  final String? path;

  ThumbnailPathModel(this.path);
}
