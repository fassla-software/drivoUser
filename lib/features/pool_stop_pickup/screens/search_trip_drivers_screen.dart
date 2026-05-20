import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SearchTripDriversScreen extends StatelessWidget {
  const SearchTripDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: Text(
          'Search Results'.tr,
          style: textBold.copyWith(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),      body: GetBuilder<PoolStopPickupController>(
        builder: (poolController) {
          if (poolController.isSearchingTrips) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (poolController.availableTrips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.noDataFound,
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    'no_rides_found'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    'try_different_route_or_date'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

       return ListView(
  children: [
    // Header
   

    const SizedBox(height: Dimensions.paddingSizeDefault),

    // Ride Cards
    ...poolController.availableTrips.map(
      (ride) => _buildRideCard(
        context,
        ride,
        poolController.availableTrips.indexOf(ride),
        poolController,
      ),
    ),

    const SizedBox(height: 20),
  ],
);
        },
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, PoolRide ride, int index,
      PoolStopPickupController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: const Color(0xFF0F9D88).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F9D88).withOpacity(0.08),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Info
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: ride.driver.profileImage != null
                    ? NetworkImage(ride.driver.profileImage!)
                    : null,
                child: ride.driver.profileImage == null
                    ? Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driver.fullName,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    Text(
                      ride.driver.gender.capitalizeFirst!,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${ride.price} ${'egp'.tr}',
                  style: textBold.copyWith(
                    color: Colors.green,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Vehicle Info
          Row(
            children: [
              Image.asset(
                Images.car,
                height: 20,
                width: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '${ride.vehicle.brand} ${ride.vehicle.model}',
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
             
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Trip Details
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                _formatTime(ride.startTime),
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const Spacer(),
              
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Amenities
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (ride.isAc) _buildAmenityChip(context, Icons.ac_unit, 'ac'.tr),
              if (ride.hasMusic)
                _buildAmenityChip(context, Icons.music_note, 'music'.tr),
              if (ride.allowLuggage)
                _buildAmenityChip(context, Icons.luggage, 'luggage'.tr),
              if (ride.isSmokingAllowed)
                _buildAmenityChip(context, Icons.smoke_free, 'smoking'.tr),
                
              if (ride.hasScreenEntertainment)
                _buildAmenityChip(context, Icons.tv, 'screen_entertainment'.tr),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Join Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
             onPressed: () {
  Get.to(
    () => TripDetailsScreen(
      trip: ride,
      rideController: Get.find<RideController>(),
    ),
  );
},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              child: controller.isJoining(ride.routeId)
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'view_details'.tr,
                      style: textBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateTime) {
    try {
      DateTime dt = DateTime.parse(dateTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
