import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/custom_icon_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/discount_coupon_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_expendable_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_map_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_ride_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/carpoll_initial_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/carpoll_otp_sent_bottomsheet.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/carpoll_parcel_accept_rider_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/carpoll_parcel_ongoing_bottomsheet_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/carpoll_parcel_otp_bottomsheet_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/carpoll_otp_car_bike_animated_widget.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

enum MapScreenType { ride, splash, parcel, location }

class CarpollMap extends StatefulWidget {
  final MapScreenType fromScreen;
  final bool isShowCurrentPosition;
  const CarpollMap(
      {super.key, required this.fromScreen, this.isShowCurrentPosition = true});
  @override
  State<CarpollMap> createState() => _MapScreen2State();
}

class _MapScreen2State extends State<CarpollMap> with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  GlobalKey<ExpandableBottomSheetState> key =
      GlobalKey<ExpandableBottomSheetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Get.find<CarpollMapController>().setContainerHeight(
        (widget.fromScreen == MapScreenType.parcel) ? 200 : 260, false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Get.find<CarPollRideController>()
          .getRideDetails(
              Get.find<CarPollRideController>().currentTripDetails!.id!)
          .then((value) {
        if (value.statusCode == 200) {
          if (Get.find<CarPollRideController>().currentTripDetails!.type ==
              'parcel') {
            if (Get.find<CarPollRideController>()
                    .currentTripDetails!
                    .currentStatus ==
                'pending') {
              Get.find<ParcelController>()
                  .updateParcelState(ParcelDeliveryState.findingRider);
              Get.find<CarpollMapController>().getPolyline();
            } else if (Get.find<CarPollRideController>()
                    .currentTripDetails!
                    .currentStatus ==
                'accepted') {
              Get.find<ParcelController>()
                  .updateParcelState(ParcelDeliveryState.otpSent);
              Get.find<CarpollMapController>().getPolyline();
              Get.find<CarPollRideController>().startLocationRecord();
              Get.find<CarpollMapController>().notifyMapController();
            } else if (Get.find<CarPollRideController>()
                    .currentTripDetails!
                    .currentStatus ==
                'ongoing') {
              Get.find<ParcelController>()
                  .updateParcelState(ParcelDeliveryState.parcelOngoing);
              Get.find<CarpollMapController>().getPolyline();
              Get.find<CarPollRideController>().startLocationRecord();
              Get.find<CarpollMapController>().notifyMapController();
              if (Get.find<CarPollRideController>()
                          .currentTripDetails!
                          .parcelInformation
                          ?.payer ==
                      'sender' &&
                  Get.find<CarPollRideController>()
                          .currentTripDetails!
                          .paymentStatus ==
                      'unpaid') {
                Get.off(() => const PaymentScreen(fromParcel: true));
              }
            } else {
              Get.offAll(() => const DashboardScreen());
            }
          } else {
            if (Get.find<CarPollRideController>()
                    .currentTripDetails!
                    .currentStatus ==
                'pending') {
              Get.find<CarPollRideController>()
                  .updateRideCurrentState(RideState.findingRider);
              Get.find<CarpollMapController>().getPolyline();
            } else if (Get.find<CarPollRideController>()
                    .currentTripDetails!
                    .currentStatus ==
                'accepted') {
              Get.find<CarPollRideController>()
                  .updateRideCurrentState(RideState.acceptingRider);
              Get.find<CarpollMapController>().getPolyline();
              Get.find<CarPollRideController>().startLocationRecord();
              Get.find<CarpollMapController>().notifyMapController();
            } else if (Get.find<CarPollRideController>()
                    .currentTripDetails!
                    .currentStatus ==
                'ongoing') {
              Get.find<CarPollRideController>()
                  .updateRideCurrentState(RideState.ongoingRide);
              Get.find<CarpollMapController>().getPolyline();
              Get.find<CarPollRideController>().startLocationRecord();
              Get.find<CarpollMapController>().notifyMapController();
            } else if ((Get.find<CarPollRideController>()
                            .currentTripDetails!
                            .currentStatus ==
                        'completed' &&
                    Get.find<CarPollRideController>()
                            .currentTripDetails!
                            .paymentStatus ==
                        'unpaid') ||
                (Get.find<CarPollRideController>()
                            .currentTripDetails!
                            .currentStatus ==
                        'cancelled' &&
                    Get.find<CarPollRideController>()
                            .currentTripDetails!
                            .paymentStatus ==
                        'unpaid' &&
                    Get.find<CarPollRideController>()
                            .currentTripDetails!
                            .paidFare! >
                        0)) {
              Get.off(() => const PaymentScreen(fromParcel: false));
            } else {
              Get.offAll(() => const DashboardScreen());
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    Get.find<CarpollMapController>().mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, value) {
        if (didPop) {
          Future.delayed(const Duration(milliseconds: 500)).then((onValue) {
            if (Get.find<CarPollRideController>().currentRideState.name ==
                    'findingRider' ||
                Get.find<ParcelController>().currentParcelState.name ==
                    'findingRider') {
              Get.offAll(() => const DashboardScreen());
            }
          });
        } else {
          Get.offAll(() => const DashboardScreen());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          BodyWidget(
            topMargin: 0,
            appBar: AppBarWidget(
              title: 'the_deliveryman_need_you'.tr,
              centerTitle: true,
              onBackPressed: () {
                if (Navigator.canPop(context)) {
                  if (Get.find<CarPollRideController>().currentRideState.name ==
                          'findingRider' ||
                      Get.find<ParcelController>().currentParcelState.name ==
                          'findingRider') {
                    Get.offAll(() => const DashboardScreen());
                  } else {
                    Get.back();
                  }
                } else {
                  Get.offAll(() => const DashboardScreen());
                }
              },
            ),
            body: GetBuilder<CarpollMapController>(builder: (mapController) {
              return ExpandableBottomSheet(
                key: key,
                background: GetBuilder<CarPollRideController>(
                    builder: (rideController) {
                  return Stack(children: [
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: mapController.sheetHeight - 20),
                      child: GoogleMap(
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                          style: Get.isDarkMode
                              ? Get.find<ThemeController>().darkMap
                              : Get.find<ThemeController>().lightMap,
                          initialCameraPosition: CameraPosition(
                            target:
                                rideController.tripDetails?.pickupCoordinates !=
                                        null
                                    ? LatLng(
                                        rideController.tripDetails!
                                            .pickupCoordinates!.coordinates![1],
                                        rideController.tripDetails!
                                            .pickupCoordinates!.coordinates![0],
                                      )
                                    : Get.find<LocationController>()
                                        .initialPosition,
                            zoom: 16,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            mapController.mapController = controller;
                            if (Get.find<CarPollRideController>()
                                        .currentRideState
                                        .name ==
                                    'findingRider' ||
                                Get.find<CarPollRideController>()
                                        .currentRideState
                                        .name ==
                                    'riseFare') {
                              Get.find<CarpollMapController>().initializeData();
                              Get.find<CarpollMapController>()
                                  .setOwnCurrentLocation();
                            } else if (Get.find<CarPollRideController>()
                                    .currentRideState
                                    .name ==
                                'initial') {
                              mapController.getPolyline();
                            } else if (Get.find<CarPollRideController>()
                                    .currentRideState
                                    .name ==
                                'completeRide') {
                              Get.find<CarpollMapController>().initializeData();
                            } else {
                              Get.find<CarpollMapController>().initializeData();
                              Get.find<CarpollMapController>()
                                  .setMarkersInitialPosition();
                              Get.find<CarPollRideController>()
                                  .startLocationRecord();
                            }
                            _mapController = controller;
                          },
                          minMaxZoomPreference: const MinMaxZoomPreference(
                              0, AppConstants.mapZoom),
                          markers: Set<Marker>.of(mapController.markers),
                          polylines:
                              Set<Polyline>.of(mapController.polylines.values),
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          trafficEnabled: mapController.isTrafficEnable,
                          indoorViewEnabled: true,
                          mapToolbarEnabled: true),
                    ),
                    if (widget.isShowCurrentPosition)
                      Positioned(
                        bottom: Get.height * 0.34,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: GetBuilder<LocationController>(
                              builder: (locationController) {
                            return CustomIconCard(
                              index: 5,
                              icon: Images.currentLocation,
                              iconColor: Theme.of(context).primaryColor,
                              onTap: () async {
                                await locationController.getCurrentLocation(
                                    mapController: _mapController);
                                await _mapController
                                    ?.moveCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                      target: Get.find<LocationController>()
                                          .initialPosition,
                                      zoom: 16),
                                ));
                              },
                            );
                          }),
                        ),
                      ),
                    Positioned(
                      bottom: Get.height * 0.41,
                      right: 0,
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: CustomIconCard(
                            icon: mapController.isTrafficEnable
                                ? Images.trafficOnlineIcon
                                : Images.trafficOfflineIcon,
                            iconColor: mapController.isTrafficEnable
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                : Theme.of(context).hintColor,
                            index: 2,
                            onTap: () => mapController.toggleTrafficView(),
                          )),
                    ),
                    Positioned(
                        bottom: Get.height * 0.48,
                        right: 0,
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: CustomIconCard(
                              icon: Images.offerMapIcon,
                              iconColor:
                                  Theme.of(context).colorScheme.inverseSurface,
                              index: 2,
                              onTap: () {
                                Get.bottomSheet(
                                  const DiscountAndCouponBottomSheet(),
                                  backgroundColor: Theme.of(context).cardColor,
                                  isDismissible: false,
                                );
                              },
                            ))),
                  ]);
                }),
                persistentContentHeight: mapController.sheetHeight,
                expandableContent:
                    Column(mainAxisSize: MainAxisSize.min, children: [
                  widget.fromScreen == MapScreenType.parcel
                      ? GetBuilder<CarPollRideController>(
                          builder: (parcelController) {
                          return ParcelExpendableBottomSheet(
                              expandableKey: key);
                        })
                      : (widget.fromScreen == MapScreenType.ride ||
                              widget.fromScreen == MapScreenType.splash)
                          ? GetBuilder<CarPollRideController>(
                              builder: (rideController) {
                              switch (rideController.currentRideState.name) {
                                case 'initial':
                                  return CarPollInitialWidget(
                                      expandableKey: key);
                                case 'otpSent':
                                  return CarPollOtpSentBottomSheet(
                                      firstRoute: '',
                                      secondRoute: '',
                                      expandableKey: key);
                                case 'parcelAcceptRider':
                                  return CarPollParcelAcceptRiderWidget(
                                      expandableKey: key);
                                case 'parcelOngoing':
                                  return CarPollParcelOngoingBottomSheetWidget(
                                      expandableKey: key);
                                case 'parcelOtp':
                                  return CarPollParcelOtpBottomSheetWidget(
                                      expandableKey: key);
                                case 'otpCarBike':
                                  return CarPollOtpCarBikeAnimatedWidget();
                                default:
                                  return const SizedBox();
                              }
                            })
                          : const SizedBox(),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ]),
              );
            }),
          ),
          widget.fromScreen == MapScreenType.location
              ? Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          child: ButtonWidget(
                              buttonText: 'set_location'.tr,
                              onPressed: () => Get.back()),
                        )),
                  ),
                )
              : const SizedBox(),
        ]),
      ),
    );
  }
}
