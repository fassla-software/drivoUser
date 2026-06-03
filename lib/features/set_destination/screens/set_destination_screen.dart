import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';

class SetDestinationScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  const SetDestinationScreen({super.key, this.address, this.searchText});

  @override
  State<SetDestinationScreen> createState() => _SetDestinationScreenState();
}

class _SetDestinationScreenState extends State<SetDestinationScreen> {
  FocusNode pickLocationFocus = FocusNode();
  FocusNode destinationLocationFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<RideController>(builder: (rideController) {
          final bool hasActiveRide = false;
          return Stack(
            children: [
              // Background Map
              Positioned.fill(
                child: GoogleMap(
                  key: const ValueKey('destination_map'),
                  style: Get.isDarkMode
                      ? Get.find<ThemeController>().darkMap
                      : Get.find<ThemeController>().lightMap,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      Get.find<LocationController>().position.latitude != 0
                          ? Get.find<LocationController>().position.latitude
                          : Get.find<LocationController>()
                                  .getUserAddress()
                                  ?.latitude ??
                              0,
                      Get.find<LocationController>().position.longitude != 0
                          ? Get.find<LocationController>().position.longitude
                          : Get.find<LocationController>()
                                  .getUserAddress()
                                  ?.longitude ??
                              0,
                    ),
                    zoom: 16,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(8, 20),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),

              // Top Section (App Bar + Title)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      16, MediaQuery.of(context).padding.top, 16, 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Get.offAll(() => const DashboardScreen());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Icon(Icons.arrow_back,
                              size: 20,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Plan Your Trip',
                        style: textBold.copyWith(
                          fontSize: 24,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your stops and we\'ll find the best route',
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Card Form
              DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.35,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: const [0.35, 0.65, 0.85],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(20, 20, 20,
                          MediaQuery.of(context).padding.bottom + 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag Handle
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form Fields
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Icon(Icons.radio_button_checked,
                                      size: 20,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 60,
                                    width: 10,
                                    child: CustomDivider(
                                      height: 5,
                                      dashWidth: 1,
                                      axis: Axis.vertical,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(Icons.location_on,
                                      size: 24, color: Colors.black),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Inputs
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('From',
                                        style: textRegular.copyWith(
                                            fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    _InputFieldContainer(
                                      prefixIcon: const Icon(Icons.location_on,
                                          size: 18, color: Colors.black),
                                      onClear: () {
                                        locationController
                                            .pickupLocationController
                                            .clear();
                                      },
                                      child: CustomSearchField(
                                        isReadOnly: hasActiveRide,
                                        focusNode: pickLocationFocus,
                                        controller: locationController
                                            .pickupLocationController,
                                        hint: 'pick_location'.tr,
                                        onChanged: (value) async {
                                          return await Get.find<
                                                  LocationController>()
                                              .searchLocation(
                                            context,
                                            value,
                                            type: LocationType.from,
                                          );
                                        },
                                        onTap: () {
                                          if (hasActiveRide) {
                                            showCustomSnackBar(
                                                'your_ride_is_ongoing_complete'
                                                    .tr,
                                                isError: true);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text('To',
                                        style: textRegular.copyWith(
                                            fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _InputFieldContainer(
                                            prefixIcon: const Icon(
                                                Icons.location_on,
                                                size: 18,
                                                color: Colors.black),
                                            onClear: () {
                                              locationController
                                                  .destinationLocationController
                                                  .clear();
                                            },
                                            child: CustomSearchField(
                                              isReadOnly: hasActiveRide,
                                              focusNode:
                                                  destinationLocationFocus,
                                              controller: locationController
                                                  .destinationLocationController,
                                              hint: 'Where to?',
                                              onChanged: (value) async {
                                                return await Get.find<
                                                        LocationController>()
                                                    .searchLocation(
                                                  context,
                                                  value.trim(),
                                                  type: LocationType.to,
                                                );
                                              },
                                              onTap: () {
                                                if (hasActiveRide) {
                                                  showCustomSnackBar(
                                                      'your_ride_is_ongoing_complete'
                                                          .tr,
                                                      isError: true);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: () => locationController
                                              .setExtraRoute(),
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.3)),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.black),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Extra Routes support
                          if (locationController.extraOneRoute) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const SizedBox(width: 36),
                                Expanded(
                                  child: _InputFieldContainer(
                                    prefixIcon: const Icon(Icons.location_on,
                                        size: 18, color: Colors.black),
                                    onClear: () {
                                      locationController.setExtraRoute(
                                          remove: true);
                                    },
                                    child: CustomSearchField(
                                      isReadOnly: hasActiveRide,
                                      controller: locationController
                                          .extraRouteOneController,
                                      hint: 'extra_route_one'.tr,
                                      onChanged: (value) async {
                                        return await Get.find<
                                                LocationController>()
                                            .searchLocation(
                                          context,
                                          value,
                                          type: LocationType.extraOne,
                                        );
                                      },
                                      onTap: () {
                                        if (hasActiveRide) {
                                          showCustomSnackBar(
                                              'your_ride_is_ongoing_complete'
                                                  .tr,
                                              isError: true);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (locationController.extraTwoRoute) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const SizedBox(width: 36),
                                Expanded(
                                  child: _InputFieldContainer(
                                    prefixIcon: const Icon(Icons.location_on,
                                        size: 18, color: Colors.black),
                                    onClear: () {
                                      locationController.setExtraRoute(
                                          remove: true);
                                    },
                                    child: CustomSearchField(
                                      isReadOnly: hasActiveRide,
                                      controller: locationController
                                          .extraRouteTwoController,
                                      hint: 'extra_route_two'.tr,
                                      onChanged: (value) async {
                                        return await Get.find<
                                                LocationController>()
                                            .searchLocation(
                                          context,
                                          value,
                                          type: LocationType.extraTwo,
                                        );
                                      },
                                      onTap: () {
                                        if (hasActiveRide) {
                                          showCustomSnackBar(
                                              'your_ride_is_ongoing_complete'
                                                  .tr,
                                              isError: true);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Add Entrance Button
                          InkWell(
                            onTap: () => locationController.setAddEntrance(),
                            child: DottedBorder(
                              color: Colors.grey.withOpacity(0.5),
                              strokeWidth: 1,
                              dashPattern: const [6, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add,
                                        size: 20, color: Colors.black),
                                    const SizedBox(width: 8),
                                    Text('Add Entrance',
                                        style: textMedium.copyWith(
                                            fontSize: 16, color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // If addEntrance is true, show the entrance input
                          if (locationController.addEntrance) ...[
                            const SizedBox(height: 16),
                            _InputFieldContainer(
                              prefixIcon: const Icon(Icons.meeting_room,
                                  size: 18, color: Colors.black),
                              child: TextField(
                                controller:
                                    locationController.entranceController,
                                focusNode: locationController.entranceNode,
                                decoration: InputDecoration(
                                  hintText: 'enter_entrance'.tr,
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Info Box
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info,
                                    size: 20, color: Colors.black),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('You can add multiple routes',
                                      style: textRegular.copyWith(
                                          fontSize: 14, color: Colors.black)),
                                ),
                                Text('Learn more',
                                    style: textMedium.copyWith(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 12, color: Colors.black),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Find Driver Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (locationController
                                    .pickupLocationController.text.isEmpty) {
                                  showCustomSnackBar(
                                      'pickup_location_is_required'.tr);
                                  FocusScope.of(context)
                                      .requestFocus(pickLocationFocus);
                                } else if (locationController
                                    .destinationLocationController
                                    .text
                                    .isEmpty) {
                                  showCustomSnackBar(
                                      'destination_location_is_required'.tr);
                                  FocusScope.of(context)
                                      .requestFocus(destinationLocationFocus);
                                } else {
                                  rideController
                                      .getEstimatedFare(false)
                                      .then((value) {
                                    if (value?.statusCode == 200) {
                                      Get.find<LocationController>()
                                          .initAddLocationData();
                                      Get.to(() => const MapScreen(
                                            fromScreen: MapScreenType.ride,
                                            isShowCurrentPosition: false,
                                          ));
                                      Get.find<RideController>()
                                          .updateRideCurrentState(
                                              RideState.initial);
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: rideController.loading
                                  ? const SpinKitCircle(
                                      color: Colors.white, size: 24.0)
                                  : Text('Find driver',
                                      style: textMedium.copyWith(
                                          fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Search Predictions Overlay
              if (locationController.resultShow)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 160,
                  left: 20,
                  right: 20,
                  child: InkWell(
                    onTap: () =>
                        locationController.setSearchResultShowHide(show: false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          )
                        ],
                      ),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    locationController
                                        .predictionList[index].description!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        });
      }),
    );
  }
}

class _InputFieldContainer extends StatelessWidget {
  final Widget child;
  final Widget? prefixIcon;
  final VoidCallback? onClear;

  const _InputFieldContainer({
    required this.child,
    this.prefixIcon,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 8),
          ],
          Expanded(child: child),
          if (onClear != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.grey),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
