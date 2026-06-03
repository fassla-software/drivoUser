import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button_widget/slider_button_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

enum FindingRide { ride, parcel }

class FindingRiderWidget extends StatefulWidget {
  final FindingRide fromPage;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  const FindingRiderWidget({
    super.key,
    required this.fromPage,
    required this.expandableKey,
  });

  @override
  State<FindingRiderWidget> createState() => _FindingRiderWidgetState();
}

class _FindingRiderWidgetState extends State<FindingRiderWidget> {
  bool isSearching = true;

  @override
  void initState() {
    Get.find<RideController>().countingTimeStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        return GetBuilder<ParcelController>(
          builder: (parcelController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: isSearching
                  ? rideController.tripDetails?.type == "carpool"
                      ? _CarpoolPendingWidget(
                          tripDetails: rideController.tripDetails!,
                          expandableKey: widget.expandableKey,
                        )
                      : Column(
                          children: [
                            TollTipWidget(
                              title: rideController.selectedCategory ==
                                      RideType.parcel
                                  ? 'deliveryman'
                                  : 'rider_finding',
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.27,
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        Colors.grey.withOpacity(.50),
                                    color: Theme.of(context).primaryColor,
                                    value: rideController.firstCount,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.27,
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        Colors.grey.withOpacity(.50),
                                    color: Theme.of(context).primaryColor,
                                    value: rideController.secondCount,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.27,
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        Colors.grey.withOpacity(.50),
                                    color: Theme.of(context).primaryColor,
                                    value: rideController.thirdCount,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault,
                              ),
                              child: Image.asset(
                                Images.newBidFareIcon,
                                width: 70,
                                color: Theme.of(
                                  context,
                                )
                                    .buttonTheme
                                    .colorScheme!
                                    .scrim
                                    .withOpacity(0.2),
                                colorBlendMode: BlendMode.modulate,
                              ),
                            ),
                            Text(
                              widget.fromPage == FindingRide.parcel
                                  ? 'finding_deliveryman'.tr
                                  : rideController.stateCount == 0
                                      ? 'searching_for_rider'.tr
                                      : rideController.stateCount == 1
                                          ? 'please_wait_just_for_a_moment'.tr
                                          : rideController.stateCount == 2
                                              ? 'looks_like_riders_around_you_are_busy_now'
                                                  .tr
                                              : 'looks_like_riders_around_you_are_not_interested'
                                                  .tr,
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            (rideController.stateCount == 2 ||
                                    widget.fromPage == FindingRide.parcel)
                                ? Text(
                                    'please_hold_on_a_little_more'.tr,
                                    style: textMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  )
                                : const SizedBox(),
                            if (rideController.stateCount != 3 &&
                                widget.fromPage == FindingRide.ride)
                              const SizedBox(
                                height: Dimensions.paddingSizeLarge * 2,
                              ),
                            if (rideController.stateCount == 3 &&
                                widget.fromPage == FindingRide.ride) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                  horizontal:
                                      Dimensions.paddingSizeExtraOverLarge,
                                ),
                                child: ButtonWidget(
                                  buttonText: 'keep_searching'.tr,
                                  onPressed: () {
                                    widget.expandableKey.currentState
                                        ?.contract();
                                    rideController.initCountingTimeStates(
                                      isRestart: true,
                                    );
                                  },
                                  backgroundColor:
                                      Colors.grey.withOpacity(0.25),
                                  radius: 10,
                                  textColor: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     left: Dimensions.paddingSizeExtraOverLarge ,
                              //     right: Dimensions.paddingSizeExtraOverLarge ,
                              //     bottom: Dimensions.paddingSizeDefault,
                              //   ),
                              //   child: ButtonWidget(
                              //     buttonText: 'rise_fare'.tr,
                              //     onPressed: (){
                              //      // widget.expandableKey.currentState?.contract();
                              //       rideController.updateRideCurrentState(RideState.riseFare);
                              //     },
                              //     radius: 10,
                              //   ),
                              // ),
                            ],
                            if (widget.fromPage == FindingRide.parcel)
                              const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),
                            !(rideController.stateCount == 3 &&
                                    widget.fromPage == FindingRide.ride)
                                ? Center(
                                    child: SliderButton(
                                      action: () {
                                        isSearching = false;
                                        widget.expandableKey.currentState
                                            ?.expand();
                                        setState(() {});
                                      },
                                      label: Text(
                                        'cancel_searching'.tr,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      dismissThresholds: 0.5,
                                      dismissible: false,
                                      shimmer: false,
                                      width: 1170,
                                      height: 40,
                                      buttonSize: 40,
                                      radius: 20,
                                      icon: Center(
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Get.find<LocalizationController>()
                                                      .isLtr
                                                  ? Icons
                                                      .arrow_forward_ios_rounded
                                                  : Icons.keyboard_arrow_left,
                                              color: Colors.grey,
                                              size: 20.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      isLtr: Get.find<LocalizationController>()
                                          .isLtr,
                                      boxShadow: const BoxShadow(blurRadius: 0),
                                      buttonColor: Colors.transparent,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.15),
                                      baseColor: Theme.of(context).primaryColor,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeDefault,
                          ),
                          child: Image.asset(
                            Images.cancelRideIcon,
                            width: 70,
                            color: Theme.of(
                              context,
                            ).buttonTheme.colorScheme!.scrim,
                          ),
                        ),
                        Text(
                          'are_you_sure'.tr,
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                        Text(
                          'you_want_to_cancel_searching'.tr,
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        rideController.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                ),
                                child: CircularProgressIndicator(),
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeDefault,
                                      horizontal:
                                          Dimensions.paddingSizeExtraOverLarge,
                                    ),
                                    child: ButtonWidget(
                                      buttonText: 'keep_searching'.tr,
                                      onPressed: () {
                                        widget.expandableKey.currentState
                                            ?.contract();
                                        isSearching = true;
                                        setState(() {});
                                        rideController.initCountingTimeStates(
                                          isRestart: true,
                                        );
                                      },
                                      backgroundColor: Colors.grey.withOpacity(
                                        0.25,
                                      ),
                                      radius: 10,
                                      textColor: Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left:
                                          Dimensions.paddingSizeExtraOverLarge,
                                      right:
                                          Dimensions.paddingSizeExtraOverLarge,
                                      bottom: Dimensions.paddingSizeDefault,
                                    ),
                                    child: ButtonWidget(
                                      buttonText: 'cancel_searching'.tr,
                                      onPressed: () {
                                        //  widget.expandableKey.currentState?.contract();
                                        print(
                                          "======== ${rideController.tripDetails?.id}",
                                        );

                                        // Get the trip ID safely
                                        String? tripId = widget.fromPage == FindingRide.parcel
                                            ? ((parcelTripDetails?.data != null && parcelTripDetails!.data!.isNotEmpty)
                                                ? parcelTripDetails!.data!.first.id
                                                : null)
                                            : rideController.tripDetails?.id;

                                        if (tripId == null) {
                                          showCustomSnackBar(
                                            'No trip ID found',
                                            isError: true,
                                          );
                                          return;
                                        }

                                        rideController
                                            .tripStatusUpdate(
                                          tripId,
                                          'cancelled',
                                          'ride_request_cancelled_successfully',
                                          '',
                                        )
                                            .then((value) {
                                          if (value?.statusCode == 200) {
                                            if (widget.fromPage == FindingRide.parcel) {
                                              parcelController.updateParcelState(ParcelDeliveryState.initial);
                                              parcelController.updateParcelTripState(ParcelTripState.initial);
                                              parcelTripDetails = null;
                                            } else {
                                              rideController
                                                  .updateRideCurrentState(
                                                RideState.initial,
                                              );
                                            }
                                            Get.find<MapController>()
                                                .notifyMapController();
                                            Get.find<RideController>()
                                                .clearRideDetails();
                                            Get.find<BottomMenuController>()
                                                .navigateToDashboard();
                                          }
                                        });
                                      },
                                      radius: 10,
                                    ),
                                  ),
                                ],
                              ),
                        if (rideController.isLoading)
                          const SizedBox(
                            height: Dimensions.paddingSizeSignUp,
                          ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _CarpoolPendingWidget extends StatefulWidget {
  final dynamic tripDetails;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const _CarpoolPendingWidget({
    required this.tripDetails,
    required this.expandableKey,
  });

  @override
  State<_CarpoolPendingWidget> createState() => _CarpoolPendingWidgetState();
}

class _CarpoolPendingWidgetState extends State<_CarpoolPendingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize animations
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _slideAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _openInGoogleMaps(double lat, double lng) async {
    try {
      // Get current location as origin
      Position? currentPosition;
      try {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          showCustomSnackBar(
            'Please enable location services to get directions.',
            isError: true,
          );
          return;
        }

        // Check location permission
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            showCustomSnackBar(
              'Please grant location permission to get directions.',
              isError: true,
            );
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          showCustomSnackBar(
            'Location permissions are permanently denied. Please enable in settings.',
            isError: true,
          );
          return;
        }

        // Get current position
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('Error getting current location: $e');
        // Continue without current location if there's an error
      }

      String url;
      if (currentPosition != null) {
        // Use current location as origin and provided coordinates as destination
        url =
            'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$lng,$lat&travelmode=driving';
      } else {
        // Fallback to just destination if current location is not available
        url =
            'https://www.google.com/maps/dir/?api=1&destination=$lng,$lat&travelmode=driving';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'https://maps.google.com/maps?q=$lng,$lat';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(Uri.parse(fallbackUrl),
              mode: LaunchMode.externalApplication);
        } else {
          showCustomSnackBar(
            'Could not open Google Maps. Please install Google Maps app.',
            isError: true,
          );
        }
      }
    } catch (e) {
      showCustomSnackBar(
        'Could not open Google Maps. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          // Animated Header
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Animated Car Icon
                      AnimatedBuilder(
                        animation: _rotateController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carpool Trip Pending',
                              style: textBold.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Waiting for driver confirmation...',
                              style: textRegular.copyWith(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Animated Status Icon
                      AnimatedBuilder(
                        animation: _fadeController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.hourglass_empty,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Driver Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Driver Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: widget.tripDetails.driver.profileImage != null
                        ? Image.network(
                            widget.tripDetails.driver.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          )
                        : Container(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.tripDetails.driver.firstName} ${widget.tripDetails.driver.lastName}',
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 5),
                          Text(
                            _getDriverRating(),
                            style: textRegular.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.tripDetails.vehicle.model.name} • ${widget.tripDetails.vehicle.licencePlateNumber}',
                        style: textRegular.copyWith(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Trip Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.route,
                        color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Trip Details',
                      style: textBold.copyWith(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Pickup Location
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.tripDetails.pickupAddress ?? 'Pickup location',
                        style: textRegular.copyWith(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Destination Location
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.tripDetails.destinationAddress ?? 'Destination',
                        style: textRegular.copyWith(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Trip Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      Icons.access_time,
                      '${_formatNumber(widget.tripDetails.estimatedTime)} min',
                      'Duration',
                    ),
                    _buildInfoItem(
                      Icons.straighten,
                      PriceConverter.formatDistance(
                          widget.tripDetails.estimatedDistance),
                      'Distance',
                    ),
                    _buildInfoItem(
                      Icons.attach_money,
                      '\$${widget.tripDetails.estimatedFare?.toString() ?? '0'}',
                      'Fare',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Navigation Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[700]!,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  if (widget.tripDetails.carpoolRideLocation != null) {
                    _openInGoogleMaps(
                      widget.tripDetails.carpoolRideLocation.latitude,
                      widget.tripDetails.carpoolRideLocation.longitude,
                    );
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Navigate to Meeting Point',
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Cancel Button
          Container(
            width: double.infinity,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(22.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22.5),
                onTap: () {
                  // Cancel trip logic
                  String? tripId = widget.tripDetails.id;
                  if (tripId != null) {
                    Get.find<RideController>()
                        .tripStatusUpdate(
                      tripId,
                      'cancelled',
                      'ride_request_cancelled_successfully',
                      '',
                    )
                        .then((value) {
                      if (value?.statusCode == 200) {
                        Get.find<RideController>()
                            .updateRideCurrentState(RideState.initial);
                        Get.find<MapController>().notifyMapController();
                        Get.find<RideController>().clearRideDetails();
                        Get.find<BottomMenuController>().navigateToDashboard();
                      }
                    });
                  }
                },
                child: Center(
                  child: Text(
                    'Cancel Trip',
                    style: textMedium.copyWith(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';

    try {
      double number;
      if (value is String) {
        number = double.parse(value);
      } else if (value is double) {
        number = value;
      } else if (value is int) {
        number = value.toDouble();
      } else {
        return '0';
      }

      return number.toStringAsFixed(1);
    } catch (e) {
      return '0';
    }
  }

  String _getDriverRating() {
    try {
      // Try to get driver_avg_rating from the trip details
      if (widget.tripDetails.driverAvgRating != null) {
        return _formatNumber(widget.tripDetails.driverAvgRating);
      }

      // Fallback to a default rating
      return '4.5';
    } catch (e) {
      return '4.5';
    }
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 5),
        Text(
          value,
          style: textBold.copyWith(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: textRegular.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
