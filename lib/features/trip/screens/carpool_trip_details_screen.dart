import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/carpool_trip_item_view.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/rider_info.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolTripDetailsScreen extends StatefulWidget {
  final String tripId;
  const CarpoolTripDetailsScreen({super.key, required this.tripId});

  @override
  State<CarpoolTripDetailsScreen> createState() =>
      _CarpoolTripDetailsScreenState();
}

class _CarpoolTripDetailsScreenState extends State<CarpoolTripDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<RideController>().getRideDetails(widget.tripId, isUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8F8),
        body: GetBuilder<RideController>(
          builder: (rideController) {
            final trip = rideController.tripDetails;
            return PopScope(
              onPopInvokedWithResult: (_, __) {
                rideController.clearRideDetails();
              },
              child: BodyWidget(
                appBar: AppBarWidget(
                  title: 'carpool_details'.tr,
                  subTitle: trip?.refId,
                  showBackButton: true,
                  centerTitle: true,
                  isShowIcon: true,
                  height: kToolbarHeight + 16,
                  toolbarHeight: kToolbarHeight,
                ),
                body: trip == null
                    ? const LoaderWidget()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CarpoolTripItemView(
                              tripDetails: trip,
                              isDetailsScreen: true,
                            ),
                            const SizedBox(
                                height: Dimensions.paddingSizeDefault),
                            if (trip.driver != null) ...[
                              Container(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: RiderInfo(tripDetails: trip),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                            ],
                            _infoCard(context, trip),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, trip) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'trip_details'.tr,
            style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (trip.vehicle != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                  child: ImageWidget(
                    width: 56,
                    height: 56,
                    image: trip.vehicle?.model?.image != null
                        ? '${Get.find<ConfigController>().config!.imageBaseUrl!.vehicleModel!}/${trip.vehicle!.model!.image!}'
                        : '',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.vehicle?.model?.name ?? 'carpool'.tr,
                        style: textSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      if (trip.vehicle?.licencePlateNumber != null)
                        Text(
                          trip.vehicle!.licencePlateNumber!,
                          style: textRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _detailLine(context, 'payment_method'.tr, trip.paymentMethod?.tr ?? '—'),
          _detailLine(
            context,
            'total_fare'.tr,
            trip.paidFare != null
                ? PriceConverter.convertPrice(trip.paidFare!)
                : (trip.estimatedFare != null
                    ? PriceConverter.convertPrice(trip.estimatedFare!)
                    : '—'),
          ),
          _detailLine(
            context,
            'trip_status'.tr,
            trip.currentStatus?.tr ?? '—',
          ),
          if (trip.note != null && trip.note!.isNotEmpty)
            _detailLine(context, 'note'.tr, trip.note!),
        ],
      ),
    );
  }

  Widget _detailLine(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
