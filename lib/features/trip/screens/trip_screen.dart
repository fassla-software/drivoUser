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

class TripScreen extends StatefulWidget {
  final bool fromProfile;

  const TripScreen({
    super.key,
    required this.fromProfile,
  });

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 6, vsync: this);

    final controller = Get.find<TripController>();

    controller.initData();
    controller.getTripList(1);

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        controller.setStatusIndex(tabController.index);

        if (tabController.index == 5) {
          controller.getCarpoolTripList(1, reload: true);
        } else {
          controller.getTripList(1, reload: true);
        }
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
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

                  /// BACK BUTTON
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                 

                  /// TITLE
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

                child: Padding(
                  padding: const EdgeInsets.all(
                    Dimensions.paddingSizeDefault,
                  ),

                  child: GetBuilder<TripController>(
                    builder: (tripController) {
                      return Column(
                        children: [

                          const SizedBox(height: 10),

                          /// ================= TAB BAR =================
                          TabBar(
                            controller: tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,

                            unselectedLabelColor: Colors.grey,

                            labelColor: Colors.black,

                            labelStyle: textSemiBold,

                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),

                            dividerHeight: 1,

                            dividerColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.15),

                            tabs: [
                              Tab(text: 'all_trip'.tr),
                              Tab(text: 'ongoing'.tr),
                              Tab(text: 'cancelled'.tr),
                              Tab(text: 'completed'.tr),
                              Tab(text: 'returned'.tr),
                              Tab(text: 'Carpool Trips'.tr),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// ================= TAB VIEW =================
                          Expanded(
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                tabBarBodyWidget(
                                    tripController),
                                tabBarBodyWidget(
                                    tripController),
                                tabBarBodyWidget(
                                    tripController),
                                tabBarBodyWidget(
                                    tripController),
                                tabBarBodyWidget(
                                    tripController),
                                carpoolTabBodyWidget(
                                    tripController),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Widget tabBarBodyWidget(TripController tripController) {
    return (tripController.tripModel != null &&
            tripController.tripModel!.data != null)
        ? tripController.tripModel!.data!.isNotEmpty
            ? SingleChildScrollView(
                controller: scrollController,
                child: PaginatedListWidget(
                  scrollController: scrollController,
                  totalSize: tripController.tripModel!.totalSize,
                  offset: tripController.tripModel!.offset != null
                      ? int.parse(
                          tripController.tripModel!.offset.toString(),
                        )
                      : null,
                  onPaginate: (int? offset) async {
                    await tripController.getTripList(offset!);
                  },
                  itemView: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: ListView.separated(
                      itemCount:
                          tripController.tripModel!.data!.length,
                      padding: const EdgeInsets.all(0),
                      physics:
                          const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return TripItemCard(
                          tripDetails:
                              tripController.tripModel!.data![index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                    ),
                  ),
                ),
              )
            : const NoDataWidget(title: 'no_trip_found')
        : const NotificationShimmer();
  }

  Widget carpoolTabBodyWidget(
      TripController tripController) {
    return (tripController.carpoolTripModel != null &&
            tripController.carpoolTripModel!.data != null)
        ? tripController
                .carpoolTripModel!.data!.isNotEmpty
            ? ListView.separated(
                itemCount: tripController
                    .carpoolTripModel!.data!.length,
                padding:
                    const EdgeInsets.only(bottom: 70),
                itemBuilder: (context, index) {
                  return TripItemCard(
                    tripDetails: tripController
                        .carpoolTripModel!.data![index],
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
              )
            : const NoDataWidget(title: 'no_trip_found')
        : const NotificationShimmer();
  }
}

class TripItemCard extends StatelessWidget {
  final dynamic tripDetails;

  const TripItemCard({
    super.key,
    required this.tripDetails,
  });

  @override
  Widget build(BuildContext context) {

    String driverName = "Driver";

    if (tripDetails.driver != null) {
      final firstName = tripDetails.driver.firstName?.toString() ?? "";
      final lastName = tripDetails.driver.lastName?.toString() ?? "";

      final full = "$firstName $lastName".trim();

      if (full.isNotEmpty) {
        driverName = full;
      }
    }

    final price = tripDetails.paidFare ?? tripDetails.price ?? 0;

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

          /// TOP
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
                          tripDetails.driver.profileImage,
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
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 3),
                        Text(
                          "4.5",
                          style: TextStyle(
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
              Column(
                children: const [
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
                      tripDetails.destinationAddress ??
                          tripDetails.dropoffAddress ??
                          "",
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

          /// DATE TIME
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                tripDetails.createdAt?.toString().substring(0, 10) ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time,
                  color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                tripDetails.createdAt?.toString().substring(11, 16) ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
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