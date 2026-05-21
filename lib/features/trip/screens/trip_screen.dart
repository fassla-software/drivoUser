import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/features/trip/screens/tripe_details_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../ride/domain/models/trip_details_model.dart';
import '../domain/models/trip_model.dart';

class TripScreen extends StatefulWidget {
  final bool fromProfile;

  const TripScreen({
    super.key,
    required this.fromProfile,
  });

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with TickerProviderStateMixin {
  // Outer tab tracker: 0=Regular, 1=Carpool, 2=Parcel
  late TabController outerTabController;
  int _currentOuterIndex = 0;

  // Inner status tab trackers
  late TabController regularInnerTabController;
  int _currentRegularInnerIndex = 0;

  late TabController carpoolInnerTabController;
  int _currentCarpoolInnerIndex = 0;

  late TabController parcelInnerTabController;
  int _currentParcelInnerIndex = 0;

  final List<String> _statusValues = [
    'all',
    'ongoing',
    'cancelled',
    'completed',
    'returned',
  ];

  @override
  void initState() {
    super.initState();

    outerTabController = TabController(length: 3, vsync: this);
    regularInnerTabController = TabController(length: 5, vsync: this);
    carpoolInnerTabController = TabController(length: 5, vsync: this);
    parcelInnerTabController = TabController(length: 5, vsync: this);

    final controller = Get.find<TripController>();
    controller.initData();
    controller.getTripList(1);

    // Track tab changes explicitly to fetch data once on target index switch
    outerTabController.addListener(() {
      if (outerTabController.index != _currentOuterIndex) {
        setState(() {
          _currentOuterIndex = outerTabController.index;
        });
        _reloadCurrentOuter(controller);
      }
    });

    regularInnerTabController.addListener(() {
      if (regularInnerTabController.index != _currentRegularInnerIndex) {
        setState(() {
          _currentRegularInnerIndex = regularInnerTabController.index;
        });
        controller.getTripList(
          1,
          reload: true,
          tripType: 'ride_request',
          status: _statusValues[_currentRegularInnerIndex],
        );
      }
    });

    carpoolInnerTabController.addListener(() {
      if (carpoolInnerTabController.index != _currentCarpoolInnerIndex) {
        setState(() {
          _currentCarpoolInnerIndex = carpoolInnerTabController.index;
        });
        controller.getCarpoolTripList(
          1,
          reload: true,
          status: _statusValues[_currentCarpoolInnerIndex],
        );
      }
    });

    parcelInnerTabController.addListener(() {
      if (parcelInnerTabController.index != _currentParcelInnerIndex) {
        setState(() {
          _currentParcelInnerIndex = parcelInnerTabController.index;
        });
        controller.getParcelTripList(
          1,
          reload: true,
          status: _statusValues[_currentParcelInnerIndex],
        );
      }
    });
  }

  void _reloadCurrentOuter(TripController controller) {
    switch (_currentOuterIndex) {
      case 0:
        controller.getTripList(
          1,
          reload: true,
          tripType: 'ride_request',
          status: _statusValues[_currentRegularInnerIndex],
        );
        break;
      case 1:
        controller.getCarpoolTripList(
          1,
          reload: true,
          status: _statusValues[_currentCarpoolInnerIndex],
        );
        break;
      case 2:
        controller.getParcelTripList(
          1,
          reload: true,
          status: _statusValues[_currentParcelInnerIndex],
        );
        break;
    }
  }

  @override
  void dispose() {
    outerTabController.dispose();
    regularInnerTabController.dispose();
    carpoolInnerTabController.dispose();
    parcelInnerTabController.dispose();
    super.dispose();
  }

  // ─── Shared inner-status tab bar style ────────────────────────────────────
  TabBar _buildInnerTabBar(TabController controller) {
    final tabs = [
      Tab(text: 'all_trip'.tr),
      Tab(text: 'ongoing'.tr),
      Tab(text: 'cancelled'.tr),
      Tab(text: 'completed'.tr),
      Tab(text: 'returned'.tr),
    ];

    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      unselectedLabelColor: Colors.grey,
      labelColor: Colors.black,
      labelStyle: textSemiBold,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      dividerHeight: 1,
      dividerColor: Theme.of(context).primaryColor.withOpacity(0.15),
      tabs: tabs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              /// ================= TOP BLACK HEADER =================
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'trip_history'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= OUTER TAB BAR =================
              Container(
                color: Colors.black,
                child: TabBar(
                  controller: outerTabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: textSemiBold.copyWith(fontSize: 13),
                  unselectedLabelStyle: textRegular.copyWith(fontSize: 13),
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: Colors.white, width: 2.5),
                  ),
                  dividerHeight: 0,
                  tabs: [
                    Tab(text: 'regular_trips'.tr),
                    Tab(text: 'carpool'.tr),
                    Tab(text: 'parcel'.tr),
                  ],
                ),
              ),

              /// ================= WHITE CONTAINER =================
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: TabBarView(
                    controller: outerTabController,
                    children: [
                      // ── Regular Trips ──────────────────────────────
                      _OuterTabContent(
                        innerTabBar:
                            _buildInnerTabBar(regularInnerTabController),
                        innerTabController: regularInnerTabController,
                        child: GetBuilder<TripController>(
                          builder: (tc) => _StatusTabView(
                            controller: regularInnerTabController,
                            rideType: 'normal',
                            tripModelBuilder: (_) => tc.tripModel,
                            onPaginate: (offset) => tc.getTripList(
                              offset,
                              tripType: 'ride_request',
                              status: _statusValues[_currentRegularInnerIndex],
                            ),
                          ),
                        ),
                      ),

                      // ── Carpool Trips ──────────────────────────────
                      _OuterTabContent(
                        innerTabBar:
                            _buildInnerTabBar(carpoolInnerTabController),
                        innerTabController: carpoolInnerTabController,
                        child: GetBuilder<TripController>(
                          builder: (tc) => _StatusTabView(
                            controller: carpoolInnerTabController,
                            rideType: 'carpool',
                            tripModelBuilder: (_) => tc.carpoolTripModel,
                            onPaginate: (offset) => tc.getCarpoolTripList(
                              offset,
                              status: _statusValues[_currentCarpoolInnerIndex],
                            ),
                          ),
                        ),
                      ),

                      // ── Parcel Trips ───────────────────────────────
                      _OuterTabContent(
                        innerTabBar:
                            _buildInnerTabBar(parcelInnerTabController),
                        innerTabController: parcelInnerTabController,
                        child: GetBuilder<TripController>(
                          builder: (tc) => _StatusTabView(
                            controller: parcelInnerTabController,
                            rideType: 'parcel',
                            tripModelBuilder: (_) => tc.parcelTripModel,
                            onPaginate: (offset) => tc.getParcelTripList(
                              offset,
                              status: _statusValues[_currentParcelInnerIndex],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget: wraps an inner tab-bar + the tab view content
// ─────────────────────────────────────────────────────────────────────────────
class _OuterTabContent extends StatelessWidget {
  final TabBar innerTabBar;
  final TabController innerTabController;
  final Widget child;

  const _OuterTabContent({
    required this.innerTabBar,
    required this.innerTabController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        innerTabBar,
        const SizedBox(height: 10),
        Expanded(child: child),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget: renders the 5-status TabBarView for a given TripModel
// ─────────────────────────────────────────────────────────────────────────────
class _StatusTabView extends StatelessWidget {
  final TabController controller;
  final String rideType;
  final TripModel? Function(int index) tripModelBuilder;
  final Future<void> Function(int offset) onPaginate;

  const _StatusTabView({
    required this.controller,
    required this.rideType,
    required this.tripModelBuilder,
    required this.onPaginate,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: List.generate(
        5,
        (i) => _TripListView(
          tripModel: tripModelBuilder(i),
          rideType: rideType,
          onPaginate: onPaginate,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget: renders a paginated list or shimmer/no-data
// ─────────────────────────────────────────────────────────────────────────────
class _TripListView extends StatefulWidget {
  final TripModel? tripModel;
  final String rideType;
  final Future<void> Function(int offset) onPaginate;

  const _TripListView({
    required this.tripModel,
    required this.rideType,
    required this.onPaginate,
  });

  @override
  State<_TripListView> createState() => _TripListViewState();
}

class _TripListViewState extends State<_TripListView> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tripModel == null || widget.tripModel!.data == null) {
      return const NotificationShimmer();
    }

    final List<TripDetails> rides = widget.rideType == 'carpool'
        ? widget.tripModel!.carpoolRides
        : widget.rideType == 'parcel'
            ? widget.tripModel!.parcelRides
            : widget.tripModel!.normalRides;

    if (rides.isEmpty) {
      return const NoDataWidget(title: 'no_trip_found');
    }
    return SingleChildScrollView(
      controller: scrollController,
      child: PaginatedListWidget(
        scrollController: scrollController,
        totalSize: widget.tripModel!.totalSize,
        offset: widget.tripModel!.offset != null
            ? int.tryParse(widget.tripModel!.offset.toString())
            : null,
        onPaginate: (int? offset) async => widget.onPaginate(offset!),
        itemView: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: ListView.separated(
            itemCount: rides.length,
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return TripItemCard(tripDetails: rides[index]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TripItemCard (unchanged visual design, kept from original)
// ─────────────────────────────────────────────────────────────────────────────
class TripItemCard extends StatelessWidget {
  final TripDetails tripDetails;

  const TripItemCard({
    super.key,
    required this.tripDetails,
  });

  @override
  Widget build(BuildContext context) {
    String driverName = "Driver";

    if (tripDetails.driver != null) {
      final firstName = tripDetails.driver?.firstName?.toString() ?? "";
      final lastName = tripDetails.driver?.lastName?.toString() ?? "";
      final full = "$firstName $lastName".trim();
      if (full.isNotEmpty) driverName = full;
    }

    final price = tripDetails.actualFare ?? 0;
    print('type ata: ${tripDetails.type}');
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        onTap: () {
          Get.to(() => TripeDetailsScreen(
                tripId: tripDetails.id!,
                fromCarpoolTab: true,
              ));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              /// TOP – driver info + price
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: tripDetails.driver?.profileImage != null
                          ? Image.network(
                              tripDetails.driver?.profileImage ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.person, color: Colors.white),
                            )
                          : const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              tripDetails.driverRating,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$price £",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        "total",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// ROUTE
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 14),
                      SizedBox(height: 4),
                      Icon(Icons.flag, color: Colors.white, size: 14),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tripDetails.pickupAddress ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          tripDetails.destinationAddress ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// DATE + TIME
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    tripDetails.formattedDate,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const Spacer(),
                  if (tripDetails.carpoolTypeString.isNotEmpty) ...[
                    Chip(
                      label: Text(tripDetails.carpoolTypeString),
                      color: WidgetStatePropertyAll(Colors.white),
                    ),
                    Spacer()
                  ],
                  const Icon(Icons.access_time, color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    tripDetails.formattedTime,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
