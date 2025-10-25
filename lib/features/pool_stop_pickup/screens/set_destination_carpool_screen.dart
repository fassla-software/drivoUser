import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/input_field_for_set_route.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

class SetDestinationCarPoolScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  const SetDestinationCarPoolScreen({super.key, this.address, this.searchText});

  @override
  State<SetDestinationCarPoolScreen> createState() =>
      _SetDestinationCarPoolScreenState();
}

class _SetDestinationCarPoolScreenState
    extends State<SetDestinationCarPoolScreen>
    with SingleTickerProviderStateMixin {
  FocusNode pickLocationFocus = FocusNode();
  FocusNode destinationLocationFocus = FocusNode();

  // Animated background state
  late final PageController _backgroundPageController;
  final List<String> _backgroundImages = const [
    'assets/image/static_carpool_panner2.JPG',
    'assets/image/static_carpool_panner3.JPG',
    'assets/image/static_carpool_panner4.JPG',
  ];
  int _currentBackgroundIndex = 0;
  Timer? _backgroundAutoSwitchTimer;
  bool _floatFlip = false;

  // Intro banner animation
  late final AnimationController _bannerController;
  late final Animation<Offset> _bannerSlide;
  late final Animation<double> _bannerOpacity;
  late final Animation<double> _bannerExpand;
  late final Animation<Offset> _logoSlide;
  bool _showBanner = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _backgroundPageController = PageController();

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeOutCubic),
    );
    _bannerOpacity = CurvedAnimation(
      parent: _bannerController,
      curve: Curves.easeIn,
    );
    _bannerExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bannerController, curve: Curves.easeOut));
    _logoSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.2))
        .animate(CurvedAnimation(
            parent: _bannerController, curve: Curves.easeInOut));
    _bannerController.forward();

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);

    // Get current location and set it as pickup after controllers are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LocationController>()
          .getCurrentLocation(
        isAnimate: false,
        type: LocationType.from,
      )
          .then((currentAddress) {
        if (currentAddress != null) {
          Get.find<LocationController>().setPickUp(currentAddress);
        } else {
          Get.find<LocationController>()
              .setPickUp(Get.find<LocationController>().getUserAddress());
        }
      });
    });

    if (widget.address != null) {
      Get.find<LocationController>().setDestination(widget.address);
    }
    if (widget.searchText != null) {
      Get.find<LocationController>()
          .setDestination(Address(address: widget.searchText));
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Get.find<LocationController>().searchLocation(
            context, widget.searchText ?? '',
            type: LocationType.to);
      });
    }

    // Start animated background timers
    _backgroundAutoSwitchTimer =
        Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _currentBackgroundIndex =
          (_currentBackgroundIndex + 1) % _backgroundImages.length;
      _backgroundPageController.animateToPage(
        _currentBackgroundIndex,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
      setState(() {
        _floatFlip = !_floatFlip;
      });
    });

    // Auto-expand the banner after a short showcase
    Timer(const Duration(seconds: 7), () {
      if (!mounted) return;
      setState(() => _isExpanded = true);
    });
  }

  @override
  void dispose() {
    _backgroundAutoSwitchTimer?.cancel();
    _backgroundPageController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBackground(BuildContext context) {
    return Positioned.fill(
      child: Stack(children: [
        // Sliding image carousel
        PageView.builder(
          controller: _backgroundPageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _backgroundImages.length,
          itemBuilder: (context, index) {
            return AnimatedScale(
              scale: _currentBackgroundIndex == index ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              child: Image.asset(
                _backgroundImages[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        // Gradient scrim for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.20),
                Colors.black.withOpacity(0.45),
              ],
            ),
          ),
        ),
        // Floating glow orbs
      ]),
    );
  }

  // Animated gradient text widget for banner (defined after this class)

  Widget _buildIntroBanner() {
    if (!_showBanner) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Stack(
          children: [
            // Expanded banner background
            if (_isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.75),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
              ),
            // Logo at top when expanded
            if (_isExpanded)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    height: 40,
                    child: Image.asset(
                      'assets/image/logo_name_black.png',
                      color: Theme.of(context).primaryColor,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            // Original compact banner
            if (!_isExpanded)
              FadeTransition(
                opacity: _bannerOpacity,
                child: SlideTransition(
                  position: _bannerSlide,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.90),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/image/logo_name_black.png',
                                height: 26,
                                color: Theme.of(context).primaryColor,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              _AnimatedGradientText(
                                text: 'Welcome to Carpool',
                                style: textMedium.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BodyWidget(
      appBar: AppBarWidget(
        title: 'select_location'.tr,
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offAll(() => const DashboardScreen());
          }
        },
      ),
      body: GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<RideController>(builder: (rideController) {
          return Stack(clipBehavior: Clip.none, children: [
            _buildAnimatedBackground(context),
            _buildIntroBanner(),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.paddingSizeSmall),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeSmall),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.02),
                                ],
                              ),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            Dimensions.paddingSizeSmall,
                                            Dimensions.paddingSizeLarge,
                                            Dimensions.paddingSizeSmall,
                                            0,
                                          ),
                                          child: Column(children: [
                                            SizedBox(
                                              width: Dimensions.iconSizeLarge,
                                              child: Image.asset(
                                                Images.currentLocation,
                                                color: Theme.of(context)
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .secondary,
                                              ),
                                            ),
                                            SizedBox(
                                                height: 70,
                                                width: 10,
                                                child: CustomDivider(
                                                  height: 5,
                                                  dashWidth: .75,
                                                  axis: Axis.vertical,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary,
                                                )),
                                            SizedBox(
                                              width: Dimensions.iconSizeMedium,
                                              child: Transform(
                                                alignment: Alignment.center,
                                                transform: Get.find<
                                                            LocalizationController>()
                                                        .isLtr
                                                    ? Matrix4.rotationY(0)
                                                    : Matrix4.rotationY(
                                                        math.pi),
                                                child: Image.asset(
                                                  Images.activityDirection,
                                                  color: Theme.of(context)
                                                      .buttonTheme
                                                      .colorScheme!
                                                      .secondary,
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall),
                                                  decoration: BoxDecoration(
                                                    color: Get.isDarkMode
                                                        ? Theme.of(context)
                                                            .cardColor
                                                        : Theme.of(context)
                                                            .primaryColorDark
                                                            .withOpacity(.25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .radiusSmall),
                                                  ),
                                                  child: Row(children: [
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeExtraSmall),
                                                    Expanded(
                                                        child:
                                                            CustomSearchField(
                                                                isReadOnly:
                                                                    rideController.rideDetails ==
                                                                            null
                                                                        ? false
                                                                        : true,
                                                                focusNode:
                                                                    pickLocationFocus,
                                                                controller:
                                                                    locationController
                                                                        .pickupLocationController,
                                                                hint:
                                                                    'pick_location'
                                                                        .tr,
                                                                onChanged:
                                                                    (value) async {
                                                                  return await Get
                                                                          .find<
                                                                              LocationController>()
                                                                      .searchLocation(
                                                                    context,
                                                                    value,
                                                                    type: LocationType
                                                                        .from,
                                                                  );
                                                                },
                                                                onTap: () {
                                                                  if (rideController
                                                                          .rideDetails !=
                                                                      null) {
                                                                    showCustomSnackBar(
                                                                        'your_ride_is_ongoing_complete'
                                                                            .tr,
                                                                        isError:
                                                                            true);
                                                                  }
                                                                })),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall),
                                                    InkWell(
                                                      onTap: () {
                                                        if (rideController
                                                                .rideDetails !=
                                                            null) {
                                                          showCustomSnackBar(
                                                              'your_ride_is_ongoing_complete'
                                                                  .tr,
                                                              isError: true);
                                                        } else {
                                                          RouteHelper
                                                              .goPageAndHideTextField(
                                                                  context,
                                                                  PickMapScreen(
                                                                    type: LocationType
                                                                        .from,
                                                                    oldLocationExist:
                                                                        locationController.pickPosition.latitude >
                                                                                0
                                                                            ? true
                                                                            : false,
                                                                  ));
                                                        }
                                                      },
                                                      child: Icon(
                                                          Icons.place_outlined,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.7)),
                                                    ),
                                                  ]),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                                  child: Text(
                                                    'to'.tr,
                                                    style: textRegular.copyWith(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                if (locationController
                                                    .extraOneRoute)
                                                  Container(
                                                    height: 50,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall),
                                                    decoration: BoxDecoration(
                                                      color: Get.isDarkMode
                                                          ? Theme.of(context)
                                                              .cardColor
                                                          : Theme.of(context)
                                                              .primaryColorDark
                                                              .withOpacity(.25),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall),
                                                    ),
                                                    child: Row(children: [
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeExtraSmall),
                                                      Expanded(
                                                          child:
                                                              CustomSearchField(
                                                                  isReadOnly:
                                                                      rideController.rideDetails ==
                                                                              null
                                                                          ? false
                                                                          : true,
                                                                  controller:
                                                                      locationController
                                                                          .extraRouteOneController,
                                                                  hint:
                                                                      'extra_route_one'
                                                                          .tr,
                                                                  onChanged:
                                                                      (value) async {
                                                                    return await Get.find<
                                                                            LocationController>()
                                                                        .searchLocation(
                                                                      context,
                                                                      value,
                                                                      type: LocationType
                                                                          .extraOne,
                                                                    );
                                                                  },
                                                                  onTap: () {
                                                                    if (rideController
                                                                            .rideDetails !=
                                                                        null) {
                                                                      showCustomSnackBar(
                                                                          'your_ride_is_ongoing_complete'
                                                                              .tr,
                                                                          isError:
                                                                              true);
                                                                    }
                                                                  })),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall),
                                                      InkWell(
                                                        onTap: () {
                                                          if (rideController
                                                                  .rideDetails !=
                                                              null) {
                                                            showCustomSnackBar(
                                                                'your_ride_is_ongoing_complete'
                                                                    .tr,
                                                                isError: true);
                                                          } else {
                                                            RouteHelper
                                                                .goPageAndHideTextField(
                                                                    context,
                                                                    PickMapScreen(
                                                                      type: LocationType
                                                                          .extraOne,
                                                                      oldLocationExist: locationController.pickPosition.latitude >
                                                                              0
                                                                          ? true
                                                                          : false,
                                                                    ));
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.place_outlined,
                                                          color: Colors.white
                                                              .withOpacity(0.7),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () =>
                                                            locationController
                                                                .setExtraRoute(
                                                                    remove:
                                                                        true),
                                                        child: Icon(Icons.clear,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.7)),
                                                      ),
                                                    ]),
                                                  ),
                                                SizedBox(
                                                  height: locationController
                                                          .extraOneRoute
                                                      ? Dimensions
                                                          .paddingSizeDefault
                                                      : 0,
                                                ),
                                                locationController.extraTwoRoute
                                                    ? Container(
                                                        height: 50,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Get.isDarkMode
                                                              ? Theme.of(
                                                                      context)
                                                                  .cardColor
                                                              : Theme.of(
                                                                      context)
                                                                  .primaryColorDark
                                                                  .withOpacity(
                                                                      .25),
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusSmall),
                                                        ),
                                                        child: Row(children: [
                                                          const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          Expanded(
                                                              child:
                                                                  CustomSearchField(
                                                                      isReadOnly: rideController.rideDetails ==
                                                                              null
                                                                          ? false
                                                                          : true,
                                                                      controller:
                                                                          locationController
                                                                              .extraRouteTwoController,
                                                                      hint: 'extra_route_two'
                                                                          .tr,
                                                                      onChanged:
                                                                          (value) async {
                                                                        return await Get.find<LocationController>()
                                                                            .searchLocation(
                                                                          context,
                                                                          value,
                                                                          type:
                                                                              LocationType.extraTwo,
                                                                        );
                                                                      },
                                                                      onTap:
                                                                          () {
                                                                        if (rideController.rideDetails !=
                                                                            null) {
                                                                          showCustomSnackBar(
                                                                              'your_ride_is_ongoing_complete'.tr,
                                                                              isError: true);
                                                                        }
                                                                      })),
                                                          const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeSmall),
                                                          InkWell(
                                                            onTap: () {
                                                              if (rideController
                                                                      .rideDetails !=
                                                                  null) {
                                                                showCustomSnackBar(
                                                                    'your_ride_is_ongoing_complete'
                                                                        .tr,
                                                                    isError:
                                                                        true);
                                                              } else {
                                                                RouteHelper
                                                                    .goPageAndHideTextField(
                                                                        context,
                                                                        PickMapScreen(
                                                                          type:
                                                                              LocationType.extraTwo,
                                                                          oldLocationExist: locationController.pickPosition.latitude > 0
                                                                              ? true
                                                                              : false,
                                                                        ));
                                                              }
                                                            },
                                                            child: Icon(
                                                                Icons
                                                                    .place_outlined,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.7)),
                                                          ),
                                                          InkWell(
                                                            onTap: () =>
                                                                locationController
                                                                    .setExtraRoute(
                                                                        remove:
                                                                            true),
                                                            child: Icon(
                                                                Icons.clear,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.7)),
                                                          ),
                                                        ]),
                                                      )
                                                    : const SizedBox(),
                                                SizedBox(
                                                    height: locationController
                                                            .extraTwoRoute
                                                        ? Dimensions
                                                            .paddingSizeDefault
                                                        : 0),
                                                Row(children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 50,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeSmall),
                                                      decoration: BoxDecoration(
                                                        color: Get.isDarkMode
                                                            ? Theme.of(context)
                                                                .cardColor
                                                            : Theme.of(context)
                                                                .primaryColorDark
                                                                .withOpacity(
                                                                    .25),
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusSmall),
                                                      ),
                                                      child: Row(children: [
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Expanded(
                                                            child:
                                                                CustomSearchField(
                                                                    isReadOnly: rideController.rideDetails ==
                                                                            null
                                                                        ? false
                                                                        : true,
                                                                    focusNode:
                                                                        destinationLocationFocus,
                                                                    controller:
                                                                        locationController
                                                                            .destinationLocationController,
                                                                    hint:
                                                                        'destination'
                                                                            .tr,
                                                                    onChanged:
                                                                        (value) async {
                                                                      return await Get.find<LocationController>().searchLocation(
                                                                          context,
                                                                          value
                                                                              .trim(),
                                                                          type:
                                                                              LocationType.to);
                                                                    },
                                                                    onTap: () {
                                                                      if (rideController
                                                                              .rideDetails !=
                                                                          null) {
                                                                        showCustomSnackBar(
                                                                            'your_ride_is_ongoing_complete'
                                                                                .tr,
                                                                            isError:
                                                                                true);
                                                                      }
                                                                    })),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall),
                                                        locationController
                                                                .selecting
                                                            ? SpinKitCircle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                size: 40.0)
                                                            : InkWell(
                                                                onTap: () {
                                                                  if (rideController
                                                                          .rideDetails !=
                                                                      null) {
                                                                    showCustomSnackBar(
                                                                        'your_ride_is_ongoing_complete'
                                                                            .tr,
                                                                        isError:
                                                                            true);
                                                                  } else {
                                                                    RouteHelper
                                                                        .goPageAndHideTextField(
                                                                      context,
                                                                      PickMapScreen(
                                                                        type: LocationType
                                                                            .to,
                                                                        oldLocationExist: locationController.pickPosition.latitude >
                                                                                0
                                                                            ? true
                                                                            : false,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Icon(
                                                                    Icons
                                                                        .place_outlined,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.7)),
                                                              ),
                                                      ]),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: locationController
                                                            .extraTwoRoute
                                                        ? 0
                                                        : Dimensions
                                                            .paddingSizeSmall,
                                                  ),
                                                  (!Get.find<ConfigController>()
                                                              .config!
                                                              .addIntermediatePoint! ||
                                                          locationController
                                                              .extraTwoRoute)
                                                      ? const SizedBox()
                                                      : InkWell(
                                                          onTap: () =>
                                                              locationController
                                                                  .setExtraRoute(),
                                                          child: Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Get
                                                                      .isDarkMode
                                                                  ? Theme.of(
                                                                          context)
                                                                      .cardColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .primaryColorDark
                                                                      .withOpacity(
                                                                          .35),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall),
                                                            ),
                                                            child: const Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                ]),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeDefault),
                                                locationController.addEntrance
                                                    ? SizedBox(
                                                        width: 200,
                                                        child: InputField(
                                                          showSuffix: false,
                                                          controller:
                                                              locationController
                                                                  .entranceController,
                                                          node:
                                                              locationController
                                                                  .entranceNode,
                                                          hint: 'enter_entrance'
                                                              .tr,
                                                        ))
                                                    : InkWell(
                                                        onTap: () =>
                                                            locationController
                                                                .setAddEntrance(),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              SizedBox(
                                                                  height: 25,
                                                                  child:
                                                                      Transform(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    transform: Get.find<LocalizationController>()
                                                                            .isLtr
                                                                        ? Matrix4
                                                                            .rotationY(
                                                                                0)
                                                                        : Matrix4.rotationY(
                                                                            math.pi),
                                                                    child: Image.asset(
                                                                        Images
                                                                            .curvedArrow,
                                                                        color: Theme.of(context)
                                                                            .buttonTheme
                                                                            .colorScheme!
                                                                            .secondary),
                                                                  )),
                                                              const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeSmall),
                                                              Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Colors
                                                                            .white),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          top: Dimensions
                                                                              .paddingSizeDefault),
                                                                      child:
                                                                          Text(
                                                                        'add_entrance'
                                                                            .tr,
                                                                        style: textMedium
                                                                            .copyWith(
                                                                          color: Colors
                                                                              .white
                                                                              .withOpacity(.75),
                                                                          fontSize:
                                                                              Dimensions.fontSizeLarge,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ]),
                                                      ),
                                              ]),
                                        )),
                                      ]),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      Dimensions.paddingSizeExtraLarge,
                                      Dimensions.paddingSizeSmall,
                                      Dimensions.paddingSizeExtraLarge,
                                      Dimensions.paddingSizeExtraLarge,
                                    ),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'you_can_add_multiple_route_to'.tr,
                                            style: textRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color:
                                                  Colors.white.withOpacity(.75),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (Get.find<ConfigController>()
                                                          .config!
                                                          .maintenanceMode !=
                                                      null &&
                                                  Get.find<ConfigController>()
                                                          .config!
                                                          .maintenanceMode!
                                                          .maintenanceStatus ==
                                                      1 &&
                                                  Get.find<ConfigController>()
                                                          .config!
                                                          .maintenanceMode!
                                                          .selectedMaintenanceSystem!
                                                          .userApp ==
                                                      1) {
                                                showCustomSnackBar(
                                                    'maintenance_mode_on_for_ride'
                                                        .tr,
                                                    isError: true);
                                              } else {
                                                if (locationController
                                                            .fromAddress ==
                                                        null ||
                                                    locationController
                                                            .fromAddress!
                                                            .address ==
                                                        null ||
                                                    locationController
                                                        .fromAddress!
                                                        .address!
                                                        .isEmpty) {
                                                  showCustomSnackBar(
                                                      'pickup_location_is_required'
                                                          .tr);
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          pickLocationFocus);
                                                } else if (locationController
                                                    .pickupLocationController
                                                    .text
                                                    .isEmpty) {
                                                  showCustomSnackBar(
                                                      'pickup_location_is_required'
                                                          .tr);
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          pickLocationFocus);
                                                } else if (locationController
                                                            .toAddress ==
                                                        null ||
                                                    locationController
                                                            .toAddress!
                                                            .address ==
                                                        null ||
                                                    locationController
                                                        .toAddress!
                                                        .address!
                                                        .isEmpty) {
                                                  showCustomSnackBar(
                                                      'destination_location_is_required'
                                                          .tr);
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          destinationLocationFocus);
                                                } else if (locationController
                                                    .destinationLocationController
                                                    .text
                                                    .isEmpty) {
                                                  showCustomSnackBar(
                                                      'destination_location_is_required'
                                                          .tr);
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          destinationLocationFocus);
                                                } else {
                                                  rideController
                                                      .getEstimatedFare(false)
                                                      .then((value) {
                                                    if (value.statusCode ==
                                                        200) {
                                                      Get.find<
                                                              LocationController>()
                                                          .initAddLocationData();
                                                      Get.to(
                                                        () => const MapScreen(
                                                          fromScreen:
                                                              MapScreenType
                                                                  .carpool,
                                                          isShowCurrentPosition:
                                                              false,
                                                        ),
                                                      );
                                                      Get.find<RideController>()
                                                          .updateRideCurrentState(
                                                        RideState.initial,
                                                      );
                                                    }
                                                  });
                                                }
                                              }
                                            },
                                            child: rideController.loading
                                                ? SpinKitCircle(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    size: 40.0)
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeDefault,
                                                    ),
                                                    child: Text(
                                                      'done'.tr,
                                                      style:
                                                          textRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeExtraLarge,
                                                        color: Theme.of(context)
                                                            .buttonTheme
                                                            .colorScheme!
                                                            .secondary,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ]),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]))),
            locationController.resultShow
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => locationController.setSearchResultShowHide(
                          show: false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? Theme.of(context).canvasColor
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeDefault),
                        ),
                        margin: EdgeInsets.fromLTRB(
                            30, locationController.topPosition, 30, 0),
                        child: ListView.builder(
                          itemCount: locationController.predictionList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Get.find<LocationController>().setLocation(
                                  fromSearch: true,
                                  locationController
                                      .predictionList[index].placeId!,
                                  locationController
                                      .predictionList[index].description!,
                                  null,
                                  type: locationController.locationType,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeDefault,
                                  horizontal: Dimensions.paddingSizeSmall,
                                ),
                                child: Row(children: [
                                  const Icon(Icons.location_on),
                                  Expanded(
                                      child: Text(
                                    locationController
                                        .predictionList[index].description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                  )),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ]);
        });
      }),
    ));
  }
}

class _AnimatedGradientText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _AnimatedGradientText({required this.text, required this.style});

  @override
  State<_AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<_AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final colors = [
          Colors.blueAccent,
          Colors.cyan,
          Colors.indigoAccent,
        ];
        final stops = [
          0.0,
          (_controller.value * 0.6) + 0.2,
          1.0,
        ];
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: colors,
              stops: stops,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}
