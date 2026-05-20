import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/screens/tripe_details_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolTripItemView extends StatelessWidget {
  final TripDetails tripDetails;
  final bool isDetailsScreen;

  const CarpoolTripItemView({
    super.key,
    required this.tripDetails,
    this.isDetailsScreen = false,
  });

  static const Color _cardBg = Color(0xFFF6F8F8);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isDetailsScreen ? null : () => _onTap(context),
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: scheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.groups_2_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'carpool'.tr,
                          style: textSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _statusChip(context, tripDetails.currentStatus ?? ''),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _routeRow(
                    context,
                    icon: Icons.trip_origin,
                    label: 'pickup_location'.tr,
                    value: tripDetails.pickupAddress ?? '—',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 11,
                      top: 4,
                      bottom: 4,
                    ),
                    child: Container(
                      width: 2,
                      height: 20,
                      color: scheme.primary.withOpacity(0.25),
                    ),
                  ),
                  _routeRow(
                    context,
                    icon: Icons.location_on_outlined,
                    label: 'destination'.tr,
                    value: tripDetails.destinationAddress ?? '—',
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Images.car,
                          height: 18,
                          width: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tripDetails.vehicle?.model?.name ??
                                tripDetails.vehicleCategory?.name ??
                                'carpool'.tr,
                            style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateConverter.isoStringToDateTimeString(
                            tripDetails.createdAt ?? '',
                          ),
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isDetailsScreen) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tripDetails.refId != null && tripDetails.refId!.isNotEmpty
                              ? '#${tripDetails.refId}'
                              : '',
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Text(
                          _fareText(),
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fareText() {
    final fare = (tripDetails.currentStatus == 'cancelled' ||
            tripDetails.currentStatus == 'completed')
        ? tripDetails.paidFare
        : (tripDetails.discountActualFare != null &&
                tripDetails.discountActualFare! > 0)
            ? tripDetails.discountActualFare
            : tripDetails.actualFare ?? tripDetails.estimatedFare;
    if (fare == null) return '';
    return PriceConverter.convertPrice(fare);
  }

  void _onTap(BuildContext context) {
    final status = tripDetails.currentStatus;
    if (status == 'accepted' ||
        status == 'ongoing' ||
        status == 'pending') {
      Get.find<RideController>().getRideDetails(tripDetails.id!).then((_) {
        if (status == 'accepted') {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.acceptingRider);
        } else if (status == 'ongoing') {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.ongoingRide);
        } else {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.findingRider);
        }
        Get.to(() => const MapScreen(fromScreen: MapScreenType.carpool));
      });
    } else if (status == 'completed' && tripDetails.paymentStatus == 'unpaid') {
      Get.find<RideController>().getFinalFare(tripDetails.id!).then((_) {
        Get.to(() => const PaymentScreen(fromParcel: false));
      });
    } else {
      Get.to(() => TripeDetailsScreen(
            tripId: tripDetails.id!,
            fromCarpoolTab: true,
          ));
    }
  }

  Widget _routeRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                value,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'completed':
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green.shade700;
        break;
      case 'cancelled':
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red.shade700;
        break;
      case 'ongoing':
      case 'accepted':
      case 'pending':
        bg = Theme.of(context).primaryColor.withOpacity(0.12);
        fg = Theme.of(context).primaryColor;
        break;
      default:
        bg = Colors.grey.withOpacity(0.12);
        fg = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.tr,
        style: textSemiBold.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: fg,
        ),
      ),
    );
  }
}
