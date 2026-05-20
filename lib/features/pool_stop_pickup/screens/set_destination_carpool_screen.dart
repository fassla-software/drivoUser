import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/search_trip_drivers_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'dart:math' as math;
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/boarding_point_model.dart';

class SetDestinationCarPoolScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  final bool fromDashboard;
  final VoidCallback? onBackToWelcome;
  final String? carpoolType;

  const SetDestinationCarPoolScreen({
    super.key,
    this.address,
    this.searchText,
    this.fromDashboard = false,
    this.onBackToWelcome,
    this.carpoolType,
  });

  @override
  State<SetDestinationCarPoolScreen> createState() =>
      _SetDestinationCarPoolScreenState();
}

class _SetDestinationCarPoolScreenState
    extends State<SetDestinationCarPoolScreen> {
  static const Color _pickerBlue = Color.fromARGB(255, 184, 212, 240);
  final FocusNode _pickLocationFocus = FocusNode();
  final FocusNode _destinationLocationFocus = FocusNode();

  late DateTime _selectedDate;
  TimeOfDay _selectedDepartureTime = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _selectedReturnTime = const TimeOfDay(hour: 17, minute: 0);
  int _selectedSeats = 5;

  final DateFormat _displayDateFormat = DateFormat('MM/dd/yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;

    // Set the selected carpool type
    final type = widget.carpoolType ?? 'trip';
    final poolController = Get.find<PoolStopPickupController>();
    poolController.setSelectedCarpoolType(type, notify: false);

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LocationController>()
          .getCurrentLocation(isAnimate: false, type: LocationType.from)
          .then((currentAddress) {
        if (currentAddress != null) {
          Get.find<LocationController>().setPickUp(currentAddress);
        } else {
          Get.find<LocationController>()
              .setPickUp(Get.find<LocationController>().getUserAddress());
        }
      });

      // If travel type is selected, fetch boarding points
      if (type == 'travel') {
        poolController.getBoardingPoints();
      }
    });

    if (widget.address != null) {
      Get.find<LocationController>().setDestination(widget.address);
    }
    if (widget.searchText != null) {
      Get.find<LocationController>()
          .setDestination(Address(address: widget.searchText));
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Get.find<LocationController>().searchLocation(
          context,
          widget.searchText ?? '',
          type: LocationType.to,
        );
      });
    }

    // Set initial date & times in the controller
    poolController.setSearchParameters(
      date: _apiDateFormat.format(_selectedDate),
    );
    poolController.setTimes(
      departure:
          '${_selectedDepartureTime.hour.toString().padLeft(2, '0')}:${_selectedDepartureTime.minute.toString().padLeft(2, '0')}',
      returnTime:
          '${_selectedReturnTime.hour.toString().padLeft(2, '0')}:${_selectedReturnTime.minute.toString().padLeft(2, '0')}',
    );
  }

  ThemeData _pickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color.fromARGB(255, 84, 161, 239),
            onPrimary: Colors.white,
          ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: _pickerBlue,
        headerForegroundColor: Colors.white,
        todayForegroundColor: WidgetStateProperty.all(_pickerBlue),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _pickerBlue;
          }
          return null;
        }),
      ),
      timePickerTheme: TimePickerThemeData(
        dialHandColor: const Color.fromARGB(255, 0, 0, 0),
        dialBackgroundColor: _pickerBlue.withOpacity(0.12),
        hourMinuteColor: _pickerBlue.withOpacity(0.15),
        hourMinuteTextColor: const Color.fromARGB(255, 0, 0, 0),
        dayPeriodColor:
            const Color.fromARGB(255, 173, 202, 232).withOpacity(0.15),
        dayPeriodTextColor: const Color.fromARGB(255, 0, 0, 0),
        entryModeIconColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      Get.find<PoolStopPickupController>().setSearchParameters(
        date: _apiDateFormat.format(picked),
      );
    }
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDepartureTime,
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDepartureTime = picked);
      Get.find<PoolStopPickupController>().setTimes(
        departure:
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _pickReturnTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedReturnTime,
      builder: (context, child) {
        return Theme(
          data: _pickerTheme(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedReturnTime = picked);
      Get.find<PoolStopPickupController>().setTimes(
        returnTime:
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  bool _isMaintenanceMode() {
    final maintenance = Get.find<ConfigController>().config?.maintenanceMode;
    return maintenance != null &&
        maintenance.maintenanceStatus == 1 &&
        maintenance.selectedMaintenanceSystem?.userApp == 1;
  }

  Future<void> _searchForRides() async {
    final locationController = Get.find<LocationController>();
    final type = widget.carpoolType ?? 'trip';

    if (_isMaintenanceMode()) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
      return;
    }

    if (type != 'travel') {
      if (locationController.fromAddress == null ||
          locationController.fromAddress!.address == null ||
          locationController.fromAddress!.address!.isEmpty ||
          locationController.pickupLocationController.text.isEmpty) {
        showCustomSnackBar('pickup_location_is_required'.tr);
        _pickLocationFocus.requestFocus();
        return;
      }

      if (locationController.toAddress == null ||
          locationController.toAddress!.address == null ||
          locationController.toAddress!.address!.isEmpty ||
          locationController.destinationLocationController.text.isEmpty) {
        showCustomSnackBar('destination_location_is_required'.tr);
        _destinationLocationFocus.requestFocus();
        return;
      }
    }

    final poolController = Get.find<PoolStopPickupController>();
    if (type != 'travel') {
      poolController.setPickupAddress(locationController.fromAddress!);
      poolController.setDestinationAddress(locationController.toAddress!);
    }
    poolController.setSearchParameters(
      seats: _selectedSeats,
      date: _apiDateFormat.format(_selectedDate),
    );

    await poolController.searchAvailableTrips();
    if (!mounted) return;
    Get.to(() => const SearchTripDriversScreen());
  }

  void _openMapPicker(
      LocationType type, LocationController locationController) {
    if (Get.find<RideController>().rideDetails != null) {
      showCustomSnackBar('your_ride_is_ongoing_complete'.tr, isError: true);
      return;
    }
    RouteHelper.goPageAndHideTextField(
      context,
      PickMapScreen(
        type: type,
        oldLocationExist: locationController.pickPosition.latitude > 0,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final type = widget.carpoolType ?? 'trip';
    String title = 'One Trip';
    if (type == 'travel') title = 'Travel';
    if (type == 'routine') title = 'Routine';
    if (type == 'north_coast') title = 'North Coast';

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: widget.onBackToWelcome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBackToWelcome,
              )
            : widget.fromDashboard
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else {
                        Get.offAll(() => const DashboardScreen());
                      }
                    },
                  ),
        title: Text(
          title,
          style: textBold.copyWith(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.carpoolType ?? 'trip';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: GetBuilder<LocationController>(
        builder: (locationController) {
          return GetBuilder<RideController>(
            builder: (rideController) {
              return GetBuilder<PoolStopPickupController>(
                builder: (poolController) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeDefault,
                          0,
                          Dimensions.paddingSizeDefault,
                          widget.fromDashboard
                              ? 90
                              : Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShareJourneyBanner(),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefault),
                            Text(
                              'Where do you want to go?',
                              style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            // Dynamic Location Selection
                            if (type == 'travel')
                              BoardingPointsCard(poolController: poolController)
                            else
                              LocationCard(
                                rideController: rideController,
                                locationController: locationController,
                                pickFocus: _pickLocationFocus,
                                destinationFocus: _destinationLocationFocus,
                                onOpenMap: _openMapPicker,
                              ),

                            const SizedBox(
                                height: Dimensions.paddingSizeDefault),

                            // Dynamic Date/Time selectors
                            if (type == 'routine')
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TripFieldTile(
                                          icon: Icons.calendar_today_outlined,
                                          label: 'Date',
                                          value: _displayDateFormat
                                              .format(_selectedDate),
                                          onTap: _pickDate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TripFieldTile(
                                          icon: Icons.access_time,
                                          label: 'Departure Time',
                                          value: _selectedDepartureTime
                                              .format(context),
                                          onTap: _pickDepartureTime,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeDefault),
                                      Expanded(
                                        child: TripFieldTile(
                                          icon: Icons.access_time,
                                          label: 'Return Time',
                                          value: _selectedReturnTime
                                              .format(context),
                                          onTap: _pickReturnTime,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: TripFieldTile(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Date',
                                      value: _displayDateFormat
                                          .format(_selectedDate),
                                      onTap: _pickDate,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(
                                height: Dimensions.paddingSizeDefault),
                            SeatsDropdown(
                              value: _selectedSeats,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedSeats = value);
                                }
                              },
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: poolController.isSearchingTrips
                                    ? null
                                    : _searchForRides,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: poolController.isSearchingTrips
                                    ? const SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 22,
                                      )
                                    : Text(
                                        'Search for Rides',
                                        style: textBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (locationController.resultShow)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => locationController
                                .setSearchResultShowHide(show: false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeDefault,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.fromLTRB(
                                24,
                                locationController.topPosition,
                                24,
                                0,
                              ),
                              child: ListView.builder(
                                itemCount:
                                    locationController.predictionList.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.find<LocationController>()
                                          .setLocation(
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
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on),
                                          Expanded(
                                            child: Text(
                                              locationController
                                                  .predictionList[index]
                                                  .description!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ================= BOARDING POINTS CARD (TRAVEL TYPE) =================
class BoardingPointsCard extends StatelessWidget {
  final PoolStopPickupController poolController;

  const BoardingPointsCard({
    super.key,
    required this.poolController,
  });

  @override
  Widget build(BuildContext context) {
    if (poolController.isLoadingBoardingPoints) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.black),
      );
    }

    final cities = poolController.availableCities;
    final startAreas =
        poolController.getAreasForCity(poolController.selectedStartCity);
    final endAreas =
        poolController.getAreasForCity(poolController.selectedEndCity);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= START LOCATION =================
          Text(
            'Boarding Point (Start)',
            style: textSemiBold.copyWith(
              color: Colors.black,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: 8),

          // Start City Dropdown
          BoardingPointsDropdown<String>(
            hint: 'Select City',
            value: cities.contains(poolController.selectedStartCity)
                ? poolController.selectedStartCity
                : null,
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city,
                    style: textRegular.copyWith(color: Colors.black)),
              );
            }).toList(),
            onChanged: poolController.setSelectedStartCity,
          ),

          if (poolController.selectedStartCity != null) ...[
            const SizedBox(height: 8),
            // Start Area Dropdown
            BoardingPointsDropdown<BoardingPoint>(
              hint: 'Select Area',
              value:
                  startAreas.contains(poolController.selectedBoardingPointStart)
                      ? poolController.selectedBoardingPointStart
                      : null,
              items: startAreas.map((point) {
                return DropdownMenuItem<BoardingPoint>(
                  value: point,
                  child: Text(poolController.getAreaName(point),
                      style: textRegular.copyWith(color: Colors.black)),
                );
              }).toList(),
              onChanged: poolController.setSelectedBoardingPointStart,
            ),
          ],

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // ================= END LOCATION =================
          Text(
            'Boarding Point (End)',
            style: textSemiBold.copyWith(
              color: Colors.black,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: 8),

          // End City Dropdown
          BoardingPointsDropdown<String>(
            hint: 'Select City',
            value: cities.contains(poolController.selectedEndCity)
                ? poolController.selectedEndCity
                : null,
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city,
                    style: textRegular.copyWith(color: Colors.black)),
              );
            }).toList(),
            onChanged: poolController.setSelectedEndCity,
          ),

          if (poolController.selectedEndCity != null) ...[
            const SizedBox(height: 8),
            // End Area Dropdown
            BoardingPointsDropdown<BoardingPoint>(
              hint: 'Select Area',
              value: endAreas.contains(poolController.selectedBoardingPointEnd)
                  ? poolController.selectedBoardingPointEnd
                  : null,
              items: endAreas.map((point) {
                return DropdownMenuItem<BoardingPoint>(
                  value: point,
                  child: Text(poolController.getAreaName(point),
                      style: textRegular.copyWith(color: Colors.black)),
                );
              }).toList(),
              onChanged: poolController.setSelectedBoardingPointEnd,
            ),
          ],
        ],
      ),
    );
  }
}

// ================= BOARDING POINTS DROPDOWN =================
class BoardingPointsDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const BoardingPointsDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8D4F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: textRegular.copyWith(color: Colors.black.withOpacity(0.6)),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ================= SHARE JOURNEY BANNER =================
class ShareJourneyBanner extends StatelessWidget {
  const ShareJourneyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFB8D4F0),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.stars_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share your journey',
                  style: textBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Find drivers going your way',
                  style: textRegular.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ride smart with more seats open to your route',
                    style: textRegular.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= LOCATION CARD =================
class LocationCard extends StatelessWidget {
  final RideController rideController;
  final LocationController locationController;
  final FocusNode pickFocus;
  final FocusNode destinationFocus;
  final void Function(LocationType type, LocationController controller)
      onOpenMap;

  const LocationCard({
    super.key,
    required this.rideController,
    required this.locationController,
    required this.pickFocus,
    required this.destinationFocus,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRideLocked = rideController.rideDetails != null;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  height: 58,
                  width: 10,
                  child: CustomDivider(
                    height: 5,
                    dashWidth: 0.75,
                    axis: Axis.vertical,
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
                Transform(
                  alignment: Alignment.center,
                  transform: Get.find<LocalizationController>().isLtr
                      ? Matrix4.rotationY(0)
                      : Matrix4.rotationY(math.pi),
                  child: Image.asset(
                    Images.activityDirection,
                    width: 18,
                    height: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Location',
                  style: textSemiBold.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const SizedBox(height: 6),
                LocationInputField(
                  isReadOnly: isRideLocked,
                  focusNode: pickFocus,
                  controller: locationController.pickupLocationController,
                  onChanged: (value) => Get.find<LocationController>()
                      .searchLocation(context, value, type: LocationType.from),
                  onTap: () {
                    if (isRideLocked) {
                      showCustomSnackBar(
                        'your_ride_is_ongoing_complete'.tr,
                        isError: true,
                      );
                    }
                  },
                  onMapTap: () =>
                      onOpenMap(LocationType.from, locationController),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(
                  'Destination',
                  style: textSemiBold.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                const SizedBox(height: 6),
                LocationInputField(
                  isReadOnly: isRideLocked,
                  focusNode: destinationFocus,
                  controller: locationController.destinationLocationController,
                  onChanged: (value) => Get.find<LocationController>()
                      .searchLocation(context, value.trim(),
                          type: LocationType.to),
                  onTap: () {
                    if (isRideLocked) {
                      showCustomSnackBar(
                        'your_ride_is_ongoing_complete'.tr,
                        isError: true,
                      );
                    }
                  },
                  onMapTap: () =>
                      onOpenMap(LocationType.to, locationController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= LOCATION INPUT FIELD =================
class LocationInputField extends StatelessWidget {
  final bool isReadOnly;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final Future<dynamic> Function(String) onChanged;
  final VoidCallback onTap;
  final VoidCallback onMapTap;

  const LocationInputField({
    super.key,
    required this.isReadOnly,
    this.focusNode,
    required this.controller,
    required this.onChanged,
    required this.onTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: const Color(0xFFB8D4F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchField(
              isReadOnly: isReadOnly,
              focusNode: focusNode,
              controller: controller,
              hint: 'Location',
              onChanged: onChanged,
              onTap: onTap,
            ),
          ),
          InkWell(
            onTap: onMapTap,
            child: const Icon(Icons.location_on, color: Colors.black, size: 22),
          ),
        ],
      ),
    );
  }
}

// ================= TRIP FIELD TILE =================
class TripFieldTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const TripFieldTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              label,
              style: textSemiBold.copyWith(
                color: Colors.black,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.18)),
            ),
            child: Text(
              value,
              style: textRegular.copyWith(
                color: Colors.black,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================= SEATS DROPDOWN =================
class SeatsDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;

  const SeatsDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_seat_outlined,
                size: 18, color: Colors.black),
            const SizedBox(width: 6),
            Text(
              'Seats',
              style: textSemiBold.copyWith(
                color: Colors.black,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withOpacity(0.18)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              items: List.generate(
                8,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(
                    '${index + 1}',
                    style: textRegular.copyWith(color: Colors.black),
                  ),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
