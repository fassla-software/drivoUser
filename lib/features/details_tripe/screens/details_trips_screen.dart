import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/from_to_text_arrow_icon_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_all_details_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_all_request.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_all_users_request.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_button.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_end_trip_button.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_from_to_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_name_car_and_price.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_search_date_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_start_trip_button.dart';

import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_details_text_widgets.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_list_view_widget.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_search_date_widget.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_select_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/start_trip_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/search_tripe_response_model.dart';
import 'package:intl/intl.dart';

class DetailsTripScreen extends StatelessWidget {
  final bool isMyTrip;
  final bool? isEndTrip;
  final Map<String, dynamic>? tripData;
  final SearchTripeAll? tripModel;

  const DetailsTripScreen({
    super.key,
    required this.isMyTrip,
    this.isEndTrip,
    this.tripData,
    this.tripModel,
  });

  @override
  Widget build(BuildContext context) {
    // Use tripData if provided, otherwise use default data
    print('isRepated:${tripModel?.isRecurring}');
    final trip = tripModel != null
        ? {
            'driverName': tripModel!.driver?.fullName ?? 'Unknown',
            'driverImage': Images.userIcon, // specific image logic if needed
            'rating': 5.0,
            'price': tripModel!.price ?? 0,
            'currency': 'SAR',
            'carModel': 'Car',
            'carColor': 'Model',
            'departureTime': tripModel!.startTime != null
                ? DateFormat('hh:mm a').format(tripModel!.startTime!)
                : '',
            'arrivalTime': '',
            'availableSeats': tripModel!.seatsAvailable ?? 0,
            'totalSeats': 4,
            'pickupLocation': tripModel!.pickupAddress ?? '',
            'dropoffLocation': tripModel!.dropoffAddress ?? '',
            'distance': '',
            'duration': '',
            'isVerified': true,
          }
        : tripData ??
            {
              'driverName': 'أحمد محمد',
              'driverImage': Images.userIcon,
              'rating': 4.8,
              'price': 45.0,
              'currency': 'جنيه',
              'carModel': 'تويوتا كامري 2022',
              'carColor': 'أبيض',
              'departureTime': '08:30 ص',
              'arrivalTime': '09:15 ص',
              'availableSeats': 3,
              'totalSeats': 4,
              'pickupLocation': 'مدينة نصر',
              'dropoffLocation': 'وسط البلد',
              'distance': '15 كم',
              'duration': '45 دقيقة',
              'isVerified': true,
            };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            // Driver Info Card
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
                  // Driver avatar and info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(trip['driverImage']),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  trip['driverName'],
                                  style: textBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Get.isDarkMode
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                  ),
                                ),
                                if (trip['isVerified']) ...[
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trip['rating'].toString(),
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(125 تقييم)',
                                  style: textRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  color: Theme.of(context).hintColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip['carModel']} - ${trip['carColor']}',
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
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Call driver
                          },
                          icon: Icon(Icons.phone, size: 18),
                          label: Text('اتصال'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Message driver
                          },
                          icon: Icon(Icons.message, size: 18),
                          label: Text('رسالة'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Trip Details Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الرحلة',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Get.isDarkMode
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Route with timeline
                  Column(
                    children: [
                      // Departure
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 40,
                                color: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.3),
                              ),
                            ],
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      trip['departureTime'],
                                      style: textBold.copyWith(
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
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'نقطة الانطلاق',
                                        style: textRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  trip['pickupLocation'],
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Arrival
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      trip['arrivalTime'],
                                      style: textBold.copyWith(
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
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'الوجهة',
                                        style: textRegular.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  trip['dropoffLocation'],
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  // Trip info row
                  Row(
                    children: [
                      _buildInfoItem(
                        context,
                        icon: Icons.access_time,
                        label: 'المدة',
                        value: trip['duration'],
                      ),
                      _buildInfoItem(
                        context,
                        icon: Icons.straighten,
                        label: 'المسافة',
                        value: trip['distance'],
                      ),
                      _buildInfoItem(
                        context,
                        icon: Icons.people,
                        label: 'المقاعد المتاحة',
                        value:
                            '${trip['availableSeats']}/${trip['totalSeats']}',
                      ),
                    ],
                  ),
                  if (tripModel?.isRecurring == true) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    const Divider(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'تكرار الرحلة',
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Get.isDarkMode
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tripModel!.recurringInfo!.recurrenceType == 'repeated'
                          ? 'رحلة متكررة'
                          : 'رحلة لمرة واحدة',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (tripModel!.recurringInfo!.availableDates != null &&
                        tripModel!
                            .recurringInfo!.availableDates!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tripModel!.recurringInfo!.availableDates!
                            .map((date) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3)),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(date),
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ]
                  ],
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Price Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سعر الرحلة',
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '${trip['price']} ${trip['currency']} للشخص',
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'سعر مناسب',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Book Now Button
            if (!isMyTrip)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showBookingConfirmation(context, trip);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  child: Text(
                    'احجز الرحلة الآن',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).hintColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Get.isDarkMode
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.inverseSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation(
      BuildContext context, Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          title: Text(
            'تأكيد الحجز',
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل تريد حجز هذه الرحلة؟',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السائق: ${trip['driverName']}',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    Text(
                      'السعر: ${trip['price']} ${trip['currency']}',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    Text(
                      'الوقت: ${trip['departureTime']}',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: textMedium.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processBooking(context, trip);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'تأكيد الحجز',
                style: textMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processBooking(BuildContext context, Map<String, dynamic> trip) {
    // Show success message
    Get.snackbar(
      'تم الحجز بنجاح',
      'تم حجز الرحلة بنجاح. السائق في الطريق إليك.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Wait a moment for the snackbar, then navigate to StartTripScreen
    Future.delayed(const Duration(seconds: 1), () {
      Get.off(() => const StartTripScreen());
    });
  }
}
