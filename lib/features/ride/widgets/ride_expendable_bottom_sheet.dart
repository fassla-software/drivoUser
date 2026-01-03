import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widget/accepting_ongoing_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/map/widget/initial_widget.dart';
import 'package:ride_sharing_user_app/features/map/widget/otp_sent_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/map/widget/risefare_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/finding_rider_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/tolltip_widget.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/confirmation_trip_dialog.dart';
import 'package:ride_sharing_user_app/features/ride/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_details.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/services/pool_service.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_request.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/find_match_response.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RideExpendableBottomSheet extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  final bool isCarpool;
  const RideExpendableBottomSheet({
    super.key,
    required this.expandableKey,
    required this.isCarpool,
  });

  @override
  State<RideExpendableBottomSheet> createState() =>
      _RideExpendableBottomSheetState();
}

class _RideExpendableBottomSheetState extends State<RideExpendableBottomSheet>
    with TickerProviderStateMixin {
  bool isFinished = false;

  // Animation controllers for stunning effects
  late AnimationController _backgroundController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Background carousel
  final List<String> _backgroundImages = [
    'assets/image/static_carpool_panner2.JPG',
    'assets/image/static_carpool_panner3.JPG',
    'assets/image/static_carpool_panner4.JPG',
  ];
  final PageController _backgroundPageController = PageController();
  int _currentBackgroundIndex = 0;
  Timer? _backgroundAutoSwitchTimer;
  bool _floatFlip = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _backgroundController.forward();
    _slideController.forward();
    _fadeController.forward();

    // Start background carousel
    _startBackgroundCarousel();
  }

  void _startBackgroundCarousel() {
    _backgroundAutoSwitchTimer =
        Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      _currentBackgroundIndex =
          (_currentBackgroundIndex + 1) % _backgroundImages.length;
      _backgroundPageController.animateToPage(
        _currentBackgroundIndex,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
      );
      setState(() {
        _floatFlip = !_floatFlip;
      });
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _backgroundPageController.dispose();
    _backgroundAutoSwitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(
      builder: (carRideController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.paddingSizeDefault),
              topRight: Radius.circular(Dimensions.paddingSizeDefault),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).hintColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background
              _buildAnimatedBackground(),

              // Main content with glassy effect
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                  topRight: Radius.circular(Dimensions.paddingSizeDefault),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).canvasColor.withOpacity(0.85),
                          Theme.of(context).canvasColor.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                        topRight:
                            Radius.circular(Dimensions.paddingSizeDefault),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated handle bar
                          _buildAnimatedHandleBar(),

                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          // Main content
                          GetBuilder<RideController>(
                            builder: (rideController) {
                              return GetBuilder<LocationController>(
                                builder: (locationController) {
                                  String firstRoute = '';
                                  String secondRoute = '';
                                  List<dynamic> extraRoute = [];
                                  if (rideController.tripDetails
                                              ?.intermediateAddresses !=
                                          null &&
                                      rideController.tripDetails
                                              ?.intermediateAddresses !=
                                          '["",""]') {
                                    extraRoute = jsonDecode(
                                      rideController
                                          .tripDetails!.intermediateAddresses!,
                                    );
                                    if (extraRoute.isNotEmpty) {
                                      firstRoute = extraRoute[0].toString();
                                    }
                                    if (extraRoute.isNotEmpty &&
                                        extraRoute.length > 1) {
                                      secondRoute = extraRoute[1].toString();
                                    }
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        (rideController.currentRideState ==
                                                RideState.initial)
                                            ? (widget.isCarpool
                                                ? _buildCarpoolInitialWidget(
                                                    locationController,
                                                  )
                                                : _buildRegularInitialWidget(
                                                    rideController))
                                            : (rideController
                                                        .currentRideState ==
                                                    RideState.riseFare)
                                                ? _buildAnimatedWidget(
                                                    RaiseFareBottomSheet(
                                                    expandableKey:
                                                        widget.expandableKey,
                                                  ))
                                                : (rideController
                                                            .currentRideState ==
                                                        RideState.findingRider)
                                                    ? _buildAnimatedWidget(
                                                        FindingRiderWidget(
                                                        expandableKey: widget
                                                            .expandableKey,
                                                        fromPage:
                                                            FindingRide.ride,
                                                      ))
                                                    : (rideController
                                                                    .currentRideState ==
                                                                RideState
                                                                    .acceptingRider ||
                                                            rideController
                                                                    .currentRideState ==
                                                                RideState
                                                                    .ongoingRide)
                                                        ? _buildAnimatedWidget(
                                                            AcceptingAndOngoingBottomSheet(
                                                            firstRoute:
                                                                firstRoute,
                                                            secondRoute:
                                                                secondRoute,
                                                            expandableKey: widget
                                                                .expandableKey,
                                                          ))
                                                        : (rideController
                                                                    .currentRideState ==
                                                                RideState
                                                                    .otpSent)
                                                            ? _buildAnimatedWidget(
                                                                OtpSentBottomSheet(
                                                                firstRoute:
                                                                    firstRoute,
                                                                secondRoute:
                                                                    secondRoute,
                                                                expandableKey:
                                                                    widget
                                                                        .expandableKey,
                                                              ))
                                                            : (rideController
                                                                        .currentRideState ==
                                                                    RideState
                                                                        .ongoingRide)
                                                                ? _buildAnimatedWidget(
                                                                    _buildOngoingRideWidget(
                                                                        rideController))
                                                                : const SizedBox(),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Sliding image carousel
          PageView.builder(
            controller: _backgroundPageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _backgroundImages.length,
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _currentBackgroundIndex == index ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOut,
                child: Image.asset(
                  _backgroundImages[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Floating glow orbs
          _buildFloatingGlowOrbs(),
        ],
      ),
    );
  }

  Widget _buildFloatingGlowOrbs() {
    return IgnorePointer(
      child: Stack(
        children: [
          _buildGlowOrb(
            alignmentA: Alignment(-0.8, _floatFlip ? -0.7 : -0.5),
            alignmentB: Alignment(-0.6, _floatFlip ? -0.5 : -0.7),
            color: Colors.blueAccent.withOpacity(0.15),
            size: 120,
          ),
          _buildGlowOrb(
            alignmentA: Alignment(_floatFlip ? 0.6 : 0.5, -0.3),
            alignmentB: Alignment(_floatFlip ? 0.5 : 0.6, -0.1),
            color: Colors.cyanAccent.withOpacity(0.12),
            size: 150,
          ),
          _buildGlowOrb(
            alignmentA: Alignment(-0.3, _floatFlip ? 0.6 : 0.5),
            alignmentB: Alignment(0.0, _floatFlip ? 0.5 : 0.6),
            color: Colors.deepPurpleAccent.withOpacity(0.10),
            size: 180,
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb({
    required Alignment alignmentA,
    required Alignment alignmentB,
    required Color color,
    required double size,
  }) {
    return AnimatedAlign(
      duration: const Duration(seconds: 6),
      curve: Curves.easeInOut,
      alignment: _floatFlip ? alignmentA : alignmentB,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(_glowAnimation.value),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_glowAnimation.value * 0.5),
                  blurRadius: size / 2,
                  spreadRadius: size / 8,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHandleBar() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 10),
          child: Container(
            height: 7,
            width: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).highlightColor.withOpacity(0.8),
                  Theme.of(context).highlightColor,
                  Theme.of(context).highlightColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(
                Dimensions.paddingSizeExtraSmall,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).highlightColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedWidget(Widget child) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: child,
      ),
    );
  }

  Widget _buildRegularInitialWidget(RideController rideController) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Column(
              children: [
                // Vehicle selection row with enhanced design
                if (rideController.fareList.isNotEmpty)
                  _buildStunningFareCard(rideController),
                const SizedBox(height: 16),
                // The rest of the initial widget
                InitialWidget(
                  expandableKey: widget.expandableKey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStunningFareCard(RideController rideController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 1,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.attach_money,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Fare',
                  style: textMedium.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  PriceConverter.convertPrice(rideController.estimatedFare),
                  style: textBold.copyWith(
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Best Price',
              style: textMedium.copyWith(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingRideWidget(RideController rideController) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return ConfirmationDialogWidget(
              icon: Images.endTrip,
              description: 'end_this_trip_at_your_destination'.tr,
              onYesPressed: () async {
                Get.back();
                Get.dialog(
                  const ConfirmationTripDialog(
                    isStartedTrip: false,
                  ),
                  barrierDismissible: false,
                );
                await Future.delayed(const Duration(seconds: 5));
                Get.find<RideController>().stopLocationRecord();
                rideController.updateRideCurrentState(
                  RideState.completeRide,
                );
                Get.find<MapController>().notifyMapController();
                Get.off(() => const PaymentScreen());
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 1,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip is Ongoing',
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your driver is on the way',
                        style: textMedium.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(
                TextSpan(
                  style: textRegular.copyWith(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color!
                        .withOpacity(0.8),
                  ),
                  children: [
                    TextSpan(
                      text: "the_car_just_arrived_at".tr,
                      style: textRegular.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(text: " ".tr),
                    TextSpan(
                      text: "your_destination".tr,
                      style: textMedium.copyWith(
                        fontSize: 13,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const ActivityScreenRiderDetails(),
          ],
        ),
      ),
    );
  }

  // Carpool UI Methods
  Widget _buildCarpoolInitialWidget(LocationController locationController) {
    return GetBuilder<RideController>(
      builder: (rideController) {
        // Initialize carpool addresses only once when widget builds
        if (!rideController.isCarpoolInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            rideController.initializeCarpoolFromLocationController();
          });
        }

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, animationValue, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Header
                      _buildAnimatedHeader(),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Animated Location Summary
                      _buildAnimatedLocationSummary(locationController),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Animated Search Parameters
                      _buildAnimatedSearchParameters(rideController),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Animated Available Trips
                      if (rideController.availableTrips.isNotEmpty) ...[
                        rideController.isLoading
                            ? _buildLoadingIndicator()
                            : _buildAnimatedAvailableTrips(rideController),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                      ],

                      // Animated Search Button
                      _buildAnimatedSearchButton(rideController),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedHeader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.groups,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carpool Ride Setup',
                          style: textBold.copyWith(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find and join rides with other travelers',
                          style: textMedium.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLocationSummary(LocationController locationController) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.route,
                          size: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your Route',
                        style: textBold.copyWith(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Pickup location
                  _buildLocationRow(
                    Icons.my_location,
                    'Pickup',
                    locationController.fromAddress?.address ??
                        'Loading pickup location...',
                    Colors.green,
                  ),
                  const SizedBox(height: 6),

                  // Destination location
                  _buildLocationRow(
                    Icons.location_on,
                    'Destination',
                    locationController.toAddress?.address ??
                        'Loading destination...',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationRow(
      IconData icon, String label, String address, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 10,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textMedium.copyWith(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                address,
                style: textRegular.copyWith(
                  fontSize: 11,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSearchParameters(RideController rideController) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Date Selection
                  _buildAnimatedParameterField(
                    context: context,
                    icon: Icons.calendar_today,
                    label: 'date'.tr,
                    value: rideController.selectedDate.isEmpty
                        ? 'tap_to_select_date'.tr
                        : rideController.selectedDate,
                    onTap: () => _selectDate(rideController, context),
                  ),
                  const SizedBox(height: 8),

                  // Gender and Seats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedDropdownField(
                          context: context,
                          icon: Icons.person,
                          label: 'gender'.tr,
                          value: rideController.selectedGender,
                          items: ['both', 'male', 'female'],
                          onChanged: (value) {
                            rideController.setCarpoolSearchParameters(
                                gender: value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildAnimatedDropdownField(
                          context: context,
                          icon: Icons.people,
                          label: 'seats'.tr,
                          value: rideController.selectedSeats.toString(),
                          items: ['1', '2', '3'],
                          onChanged: (value) {
                            rideController.setCarpoolSearchParameters(
                              seats: int.parse(value!),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ride Type
                  _buildAnimatedDropdownField(
                    context: context,
                    icon: Icons.work,
                    label: 'ride_type'.tr,
                    value: rideController.selectedRideType,
                    items: [
                      'work',
                      'college',
                      'transportation',
                      'governorates traveling',
                    ],
                    onChanged: (value) {
                      rideController.setCarpoolSearchParameters(
                          rideType: value);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedParameterField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textMedium.copyWith(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: textRegular.copyWith(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdownField({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 10,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: textMedium.copyWith(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: Colors.grey[600],
              ),
              style: textRegular.copyWith(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item.capitalizeFirst!,
                    style: textRegular.copyWith(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Searching for rides...',
            style: textMedium.copyWith(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAvailableTrips(RideController rideController) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[50]!,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.search,
                          size: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available Rides (${rideController.availableTrips.length})',
                        style: textBold.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...rideController.availableTrips
                      .asMap()
                      .entries
                      .map((entry) => _buildAnimatedTripCard(
                            entry.value,
                            rideController,
                            entry.key,
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSearchButton(RideController rideController) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: rideController.isSearchingTrips
                      ? null
                      : () => _searchForCarpoolRides(rideController),
                  child: Center(
                    child: rideController.isSearchingTrips
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Searching...',
                                style: textBold.copyWith(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Search Rides',
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
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTripCard(
      dynamic trip, RideController rideController, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 1,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _StunningTripCard(
                trip: trip,
                rideController: rideController,
                onTap: () =>
                    _navigateToTripDetails(trip, rideController, context),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StunningTripCard extends StatefulWidget {
  final dynamic trip;
  final RideController rideController;
  final VoidCallback onTap;

  const _StunningTripCard({
    required this.trip,
    required this.rideController,
    required this.onTap,
  });

  @override
  State<_StunningTripCard> createState() => _StunningTripCardState();
}

class _StunningTripCardState extends State<_StunningTripCard>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _cardAnimationController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _cardSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start initial animations
    _cardAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Header Section with Driver Info
                        _buildHeaderSection(),

                        const SizedBox(height: 12),

                        // Closest Points Preview
                        _buildClosestPointsPreview(),

                        const SizedBox(height: 12),

                        // Tap to view details hint
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tap to view details',
                                style: textMedium.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              children: [
                // Driver Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: widget.trip.driver.profileImage != null &&
                          widget.trip.driver.profileImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            widget.trip.driver.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 24,
                                color: Theme.of(context).primaryColor,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 24,
                          color: Theme.of(context).primaryColor,
                        ),
                ),

                const SizedBox(width: 12),

                // Driver Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.driver.fullName.isNotEmpty
                            ? widget.trip.driver.fullName
                            : 'Unknown Driver',
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 • ${widget.trip.driver.gender.isNotEmpty ? '${widget.trip.driver.gender[0].toUpperCase()}${widget.trip.driver.gender.substring(1)}' : 'Unknown'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '\$${widget.trip.price.toString()}',
                    style: textBold.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClosestPointsPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Closest Points',
                style: textMedium.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Closest Pickup
          if (widget.trip.closestPickup != null) ...[
            _buildLocationRow(
              Icons.directions_walk,
              'Pickup',
              widget.trip.closestPickup!.placeName,
              Colors.green,
            ),
            const SizedBox(height: 4),
          ],

          // Closest Dropoff
          if (widget.trip.closestDropoff != null) ...[
            _buildLocationRow(
              Icons.directions_walk,
              'Dropoff',
              widget.trip.closestDropoff!.placeName,
              Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow(
      IconData icon, String label, String address, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address,
            style: textRegular.copyWith(
              fontSize: 13,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

Future<List<LatLng>> _getRoutePolyline(
  LatLng origin,
  LatLng destination,
) async {
  try {
    // Use Google Maps Directions API to get the actual route
    final String apiKey =
        'AIzaSyCeF4BHLDezqD1pH7mlzxEchtX962QU9Os'; // From AppConstants
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final polyline = route['overview_polyline']['points'];

        // Decode the polyline using the existing method from MapController
        return _decodeEncodedPolyline(polyline);
      } else {
        throw Exception('No route found: ${data['status']}');
      }
    } else {
      throw Exception('Failed to get route: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting route: $e');
    // Fallback to straight line if API fails
    return [origin, destination];
  }
}

List<LatLng> _decodeEncodedPolyline(String encoded) {
  try {
    if (encoded.isEmpty) return [];

    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  } catch (e) {
    print('Error decoding polyline: $e');
    return [];
  }
}

LatLngBounds _getBounds(List<LatLng> points) {
  double? minLat, maxLat, minLng, maxLng;

  for (LatLng point in points) {
    minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
    maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
    minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
    maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
  }

  return LatLngBounds(
    southwest: LatLng(minLat!, minLng!),
    northeast: LatLng(maxLat!, maxLng!),
  );
}

Widget _buildParameterField({
  required IconData icon,
  required String label,
  required String value,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 600),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animationValue, child) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - animationValue)),
        child: Opacity(
          opacity: animationValue,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: textMedium.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: textRegular.copyWith(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildDropdownField({
  required IconData icon,
  required String label,
  required String value,
  required List<String> items,
  required Function(String?) onChanged,
  required BuildContext context,
}) {
  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 600),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, animationValue, child) {
      return Transform.translate(
        offset: Offset(0, 20 * (1 - animationValue)),
        child: Opacity(
          opacity: animationValue,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon and Label
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        icon,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dropdown Container
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    style: textRegular.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item.capitalizeFirst!,
                          style: textRegular.copyWith(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _selectDate(RideController rideController, BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 60)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color.fromARGB(
                  255,
                  0,
                  0,
                  0,
                ), // Primary color for selected date
                onPrimary: Colors.white, // Text color on selected date
                surface: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF242424)
                    : Colors.white, // Background color
                onSurface: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xff1D2D2B), // Text color for dates
                onSurfaceVariant:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600], // Text color for other dates
              ),
          dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF242424)
              : Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(
                255,
                0,
                0,
                0,
              ), // Button text color
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    String formattedDate =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    rideController.setCarpoolSearchParameters(date: formattedDate);
  }
}

Future<void> _searchForCarpoolRides(RideController rideController) async {
  if (rideController.pickupAddress == null ||
      rideController.destinationAddress == null) {
    Get.snackbar(
      'Error',
      'Please select both pickup and destination locations',
    );
    return;
  }

  if (rideController.selectedDate.isEmpty) {
    Get.snackbar('Error', 'Please select a date');
    return;
  }

  // Set searching state
  rideController.setSearchingTrips(true);

  try {
    // Create the request object
    FindMatchRequest request = FindMatchRequest(
      pickupLat: rideController.pickupAddress!.latitude!,
      pickupLng: rideController.pickupAddress!.longitude!,
      dropoffLat: rideController.destinationAddress!.latitude!,
      dropoffLng: rideController.destinationAddress!.longitude!,
      day: rideController.selectedDate,
      gender: rideController.selectedGender,
      seatsRequired: rideController.selectedSeats,
      rideType: rideController.selectedRideType,
    );

    // Make the API call using RideController's poolService
    FindMatchResponse? response =
        await rideController.poolService.findMatchingRides(request);

    // Process the response
    if (response != null && response.responseCode == 'default_200') {
      // Clear previous results
      rideController.availableTrips.clear();
      rideController.availableTrips.addAll(response.data);
      rideController.update();

      if (rideController.availableTrips.isEmpty) {
        Get.snackbar('No Rides Found', 'Try different route or date');
      } else {
        print(
          'Found ${rideController.availableTrips.length} rides successfully',
        );
      }
    } else {
      rideController.availableTrips.clear();
      rideController.update();
      Get.snackbar(
        'Error',
        response?.message ?? 'Failed to search for trips',
      );
    }
  } catch (e) {
    rideController.availableTrips.clear();
    rideController.update();
    Get.snackbar('Error', 'Failed to search for trips: ${e.toString()}');
  } finally {
    rideController.setSearchingTrips(false);
  }
}

void _navigateToTripDetails(
    dynamic trip, RideController rideController, BuildContext context) {
  Get.to(() => TripDetailsScreen(
        trip: trip,
        rideController: rideController,
      ));
}

void _selectTrip(dynamic trip, RideController rideController) {
  rideController.selectCarpoolTrip(trip);
}

void _showRouteMap(dynamic trip, BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Trip Route',
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Map
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        trip.pickupMatchPoint.lat,
                        trip.pickupMatchPoint.lng,
                      ),
                      zoom: 13,
                    ),
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: true,
                    compassEnabled: true,
                    markers: {
                      // Main pickup point
                      Marker(
                        markerId: const MarkerId('pickup'),
                        position: LatLng(
                          trip.pickupMatchPoint.lat,
                          trip.pickupMatchPoint.lng,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        infoWindow: InfoWindow(
                          title: 'Pickup Point',
                          snippet: trip.pickupAddress,
                        ),
                      ),
                      // Main dropoff point
                      Marker(
                        markerId: const MarkerId('dropoff'),
                        position: LatLng(
                          trip.dropoffMatchPoint.lat,
                          trip.dropoffMatchPoint.lng,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow: InfoWindow(
                          title: 'Dropoff Point',
                          snippet: trip.dropoffAddress,
                        ),
                      ),
                      // Closest pickup point if available
                      if (trip.closestPickup != null)
                        Marker(
                          markerId: const MarkerId('closest_pickup'),
                          position: LatLng(
                            trip.closestPickup!.lat,
                            trip.closestPickup!.lng,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                          infoWindow: InfoWindow(
                            title: 'Your Closest Pickup Point',
                            snippet: trip.closestPickup!.placeName,
                          ),
                        ),
                      // Closest dropoff point if available
                      if (trip.closestDropoff != null)
                        Marker(
                          markerId: const MarkerId('closest_dropoff'),
                          position: LatLng(
                            trip.closestDropoff!.lat,
                            trip.closestDropoff!.lng,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange,
                          ),
                          infoWindow: InfoWindow(
                            title: 'Your Closest Dropoff Point',
                            snippet: trip.closestDropoff!.placeName,
                          ),
                        ),
                    },
                    polylines: trip.encodedPolyline != null &&
                            trip.encodedPolyline!.isNotEmpty
                        ? {
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points:
                                  _decodeEncodedPolyline(trip.encodedPolyline!),
                              color: Theme.of(context).primaryColor,
                              width: 4,
                            ),
                          }
                        : {},
                    onMapCreated: (controller) {
                      Future.delayed(const Duration(milliseconds: 200), () {
                        _fitMapBounds(controller, trip);
                      });
                    },
                  ),
                ),
              ),
              // Bottom actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    if (trip.closestPickup != null &&
                        trip.closestPickup!.lat != null &&
                        trip.closestPickup!.lng != null) ...[
                      ElevatedButton.icon(
                        onPressed: () => _openInGoogleMaps(
                          trip.closestPickup!.lat,
                          trip.closestPickup!.lng,
                        ),
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate to Meeting Point'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Walking distance to pickup: ${PriceConverter.formatDistance(PriceConverter.calculateDistance(
                        trip.pickupMatchPoint.lat,
                        trip.pickupMatchPoint.lng,
                        trip.closestPickup?.lat ?? trip.pickupMatchPoint.lat,
                        trip.closestPickup?.lng ?? trip.pickupMatchPoint.lng,
                      ))}',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _fitMapBounds(GoogleMapController controller, dynamic trip) {
  double minLat = double.infinity;
  double maxLat = -double.infinity;
  double minLng = double.infinity;
  double maxLng = -double.infinity;

  void updateBounds(double lat, double lng) {
    minLat = min(minLat, lat);
    maxLat = max(maxLat, lat);
    minLng = min(minLng, lng);
    maxLng = max(maxLng, lng);
  }

  // Include all points in bounds
  updateBounds(trip.pickupMatchPoint.lat, trip.pickupMatchPoint.lng);
  updateBounds(trip.dropoffMatchPoint.lat, trip.dropoffMatchPoint.lng);
  if (trip.closestPickup != null) {
    updateBounds(trip.closestPickup!.lat, trip.closestPickup!.lng);
  }
  if (trip.closestDropoff != null) {
    updateBounds(trip.closestDropoff!.lat, trip.closestDropoff!.lng);
  }

  // Add padding
  final bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );

  controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
}

void _openInGoogleMaps(double lat, double lng) async {
  try {
    // Use Google Maps directions URL to navigate to the meeting point
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Fallback to search URL
      final fallbackUrl = 'https://maps.google.com/maps?q=$lat,$lng';
      if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      } else {
        // Second fallback
        final secondFallbackUrl =
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        if (await canLaunchUrl(Uri.parse(secondFallbackUrl))) {
          await launchUrl(Uri.parse(secondFallbackUrl),
              mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Could not open Google Maps. Please install Google Maps app.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  } catch (e) {
    print('Error opening Google Maps: $e');
    Get.snackbar(
      'Error',
      'Could not open Google Maps. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
