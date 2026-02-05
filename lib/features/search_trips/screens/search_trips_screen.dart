import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/details_tripe/screens/details_trips_screen.dart';
import 'package:ride_sharing_user_app/features/home/controllers/search_tripe_controller.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/search_tripe_response_model.dart';
import 'package:intl/intl.dart';

import '../../ride/controllers/ride_controller.dart';
import '../../ride/screens/trip_details_screen.dart';

class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

List<String> sortOptions = ['الأرخص', 'الأسرع', 'الأقرب', 'الأعلى تقييماً'];

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  String selectedSort = 'الأرخص';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<SearchTripeController>(builder: (searchTripeController) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              // Route summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // From-To locations
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            Images.currentLocation,
                            height: 16,
                            width: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            'مدينة نصر', // Placeholder
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Get.isDarkMode
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).hintColor,
                          size: 20,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            Images.activityDirection,
                            height: 16,
                            width: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            'وسط البلد', // Placeholder
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Get.isDarkMode
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    // Date and time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).hintColor,
                          size: 16,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          'اليوم، 15 يناير 2025', // Placeholder
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).hintColor,
                          size: 16,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          '08:00 ص', // Placeholder
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Sort options
              Row(
                children: [
                  Text(
                    'ترتيب حسب:',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Get.isDarkMode
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                          color: Theme.of(context).hintColor.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSort,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).hintColor,
                          ),
                          items: sortOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSort = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Results count
              Row(
                children: [
                  Text(
                    'تم العثور على ${searchTripeController.searchTripeList.length} رحلة',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Get.isDarkMode
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'فلترة',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Trips list
              Expanded(
                child: searchTripeController.isLoadingSearchTripe
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: searchTripeController.searchTripeList.length,
                        itemBuilder: (context, index) {
                          final trip =
                              searchTripeController.searchTripeList[index];
                          return _buildTripCard(context, trip);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTripCard(BuildContext context, SearchTripeAll trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Driver info and price
          Row(
            children: [
              // Driver avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(Images.userIcon), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              // Driver name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          trip.driver?.fullName ?? 'Unknown Driver',
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Get.isDarkMode
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                        // Verification if available
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '5.0', // Placeholder
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${trip.price ?? 0} ريال', // Currency
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'للشخص',
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Trip details
          Row(
            children: [
              // Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.startTime != null
                          ? DateFormat('hh:mm a').format(trip.startTime!)
                          : '',
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Get.isDarkMode
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                    Text(
                      trip.pickupAddress ?? '',
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Arrow and duration
              Column(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).hintColor,
                    size: 20,
                  ),
                ],
              ),
              // Arrival
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.dropoffAddress ?? '',
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Car info and available seats
          Row(
            children: [
              Icon(
                Icons.directions_car,
                color: Theme.of(context).hintColor,
                size: 20,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                'سيارة',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.people,
                color: Theme.of(context).hintColor,
                size: 20,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                '${trip.seatsAvailable ?? 0} مقاعد متاحة',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),

          if (trip.isRecurring == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.repeat,
                    size: 16, color: Theme.of(context).primaryColor),
                const SizedBox(width: 4),
                Text(
                  'رحلة متكررة',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            )
          ],

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Book button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to trip details with real model
                Get.to(() => DetailsTripScreen(
                      isMyTrip: false,
                      isEndTrip: false,
                      tripModel: trip,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              child: Text(
                'احجز الآن',
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
