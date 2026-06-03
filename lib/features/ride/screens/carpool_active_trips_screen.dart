import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolActiveTripsScreen extends StatelessWidget {
  final List<TripDetails> trips;
  final bool fromRefresh;
  final bool navigateToMap;

  const CarpoolActiveTripsScreen({
    super.key,
    required this.trips,
    required this.fromRefresh,
    required this.navigateToMap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active Carpool Trips',
          style: textBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: InkWell(
              onTap: () {
                Get.find<RideController>().processSelectedCarpoolTrip(
                  trip,
                  fromRefresh,
                  navigateToMap,
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trip ID: #${trip.refId ?? trip.id?.substring(0, 8) ?? "Unknown"}',
                          style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            trip.currentStatus?.toUpperCase() ?? 'UNKNOWN',
                            style: textMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Theme.of(context).hintColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          trip.formattedDate.isNotEmpty ? trip.formattedDate : 'N/A',
                          style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Icon(Icons.access_time, size: 16, color: Theme.of(context).hintColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          trip.formattedTime.isNotEmpty ? trip.formattedTime : 'N/A',
                          style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    if (trip.pickupAddress != null && trip.pickupAddress!.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.my_location, size: 16, color: Theme.of(context).primaryColor),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Expanded(
                            child: Text(
                              trip.pickupAddress!,
                              style: textRegular,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    if (trip.destinationAddress != null && trip.destinationAddress!.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.red),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Expanded(
                            child: Text(
                              trip.destinationAddress!,
                              style: textRegular,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
