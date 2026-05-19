import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Trip details card matching the carpool design (black card, driver, route, summary).
class CarpoolTripDetailsCard extends StatelessWidget {
  final TripDetails tripDetails;

  const CarpoolTripDetailsCard({super.key, required this.tripDetails});

  static const Color _cardBlack = Colors.black;
  static const Color _statusBlue = Color(0xFF2F6BFF);

  @override
  Widget build(BuildContext context) {
    final driver = tripDetails.driver;
    final vehicle = tripDetails.vehicle;
    final status = tripDetails.currentStatus ?? '';
    final fare = _fareAmount();
    final seats = (tripDetails.riseRequestCount != null &&
            tripDetails.riseRequestCount! > 0)
        ? tripDetails.riseRequestCount!
        : (tripDetails.vehicle?.model?.seatCapacity ?? 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: _cardBlack,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (driver != null) ...[
            _driverSection(context, driver, status),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          if (vehicle != null) ...[
            _carDetailsSection(context, vehicle),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          _metaRow(context, seats),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _routeSection(context),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _summaryBox(context, fare),
        ],
      ),
    );
  }

  Widget _driverSection(BuildContext context, Driver driver, String status) {
    final name =
        '${driver.firstName ?? ''} ${driver.lastName ?? ''}'.trim();
    final rating = double.tryParse(
            tripDetails.driverAvgRating?.toString() ?? '0') ??
        0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: ImageWidget(
            height: 52,
            width: 52,
            image: driver.profileImage != null
                ? '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImageDriver}/${driver.profileImage}'
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
                name.isNotEmpty ? name : 'driver'.tr,
                style: textSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeLarge,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: textRegular.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: Dimensions.fontSizeSmall,
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
            Row(
              children: [
                _contactButton(
                  icon: Icons.phone_outlined,
                  onTap: driver.phone != null && driver.phone!.isNotEmpty
                      ? () => _launchTel(driver.phone!)
                      : null,
                ),
                const SizedBox(width: 8),
                _contactButton(
                  icon: Icons.chat_bubble_outline,
                  onTap: driver.id != null
                      ? () => Get.find<MessageController>().createChannel(
                            driver.id!,
                            tripDetails.id,
                          )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _statusBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.tr,
                style: textSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _contactButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _carDetailsSection(BuildContext context, Vehicle vehicle) {
    final plate = _formatPlate(vehicle.licencePlateNumber ?? '');
    final modelName = vehicle.model?.name ?? tripDetails.vehicleCategory?.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'vehicle_information'.tr,
          style: textRegular.copyWith(
            color: Colors.white.withOpacity(0.65),
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modelName,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Colors.black,
                      ),
                    ),
                    if (plate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        plate,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.black54,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _parseVehicleColor(vehicle.vehicleColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaRow(BuildContext context, int seats) {
    final createdAt = tripDetails.createdAt;
    final dateText = createdAt != null && createdAt.isNotEmpty
        ? DateConverter.isoStringToLocalDateAndMonthOnly(createdAt)
        : '—';
    final timeText = createdAt != null && createdAt.isNotEmpty
        ? DateConverter.isoDateTimeStringToLocalTime(createdAt)
        : (tripDetails.estimatedTime?.isNotEmpty == true
            ? tripDetails.estimatedTime!
            : '—');

    return Row(
      children: [
        Expanded(
          child: _metaItem(
            icon: Icons.calendar_today_outlined,
            label: dateText,
          ),
        ),
        Expanded(
          child: _metaItem(
            icon: Icons.access_time,
            label: timeText,
          ),
        ),
        Expanded(
          child: _metaItem(
            icon: Icons.people_outline,
            label: '$seats ${'seats'.tr}',
          ),
        ),
      ],
    );
  }

  Widget _metaItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: textRegular.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: Dimensions.fontSizeExtraSmall,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _routeSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.location_on_outlined,
                size: 18, color: Colors.white.withOpacity(0.9)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CustomPaint(
                size: const Size(2, 36),
                painter: _DottedLinePainter(color: Colors.white38),
              ),
            ),
            Icon(Icons.flag_outlined,
                size: 18, color: Colors.white.withOpacity(0.9)),
          ],
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tripDetails.pickupAddress ?? '—',
                style: textRegular.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeSmall,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 28),
              Text(
                tripDetails.destinationAddress ?? '—',
                style: textRegular.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeSmall,
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

  Widget _summaryBox(BuildContext context, double? fare) {
    final priceText =
        fare != null ? PriceConverter.convertPrice(fare) : '—';
    final distanceText = _distanceLabel();

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Fare'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _cardBlack,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  priceText,
                  style: textSemiBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Distance'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                distanceText,
                style: textSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _distanceLabel() {
    if (tripDetails.distanceText != null &&
        tripDetails.distanceText!.isNotEmpty) {
      return tripDetails.distanceText!;
    }
    final raw = tripDetails.actualDistance?.isNotEmpty == true
        ? tripDetails.actualDistance
        : tripDetails.estimatedDistance?.toString();
    return PriceConverter.formatDistance(raw);
  }

  double? _fareAmount() {
    if (tripDetails.currentStatus == 'cancelled' ||
        tripDetails.currentStatus == 'completed') {
      return tripDetails.paidFare;
    }
    if (tripDetails.discountActualFare != null &&
        tripDetails.discountActualFare! > 0) {
      return tripDetails.discountActualFare;
    }
    return tripDetails.actualFare ?? tripDetails.estimatedFare;
  }

  String _formatPlate(String plate) {
    if (plate.isEmpty) return '';
    return plate.split('').join(' ').trim();
  }

  Color _parseVehicleColor(String? colorValue) {
    if (colorValue == null || colorValue.isEmpty) return Colors.black;
    final hex = colorValue.replaceAll('#', '');
    if (hex.length == 6) {
      final value = int.tryParse('FF$hex', radix: 16);
      if (value != null) return Color(value);
    }
    switch (colorValue.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'silver':
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Future<void> _launchTel(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dashHeight = 4;
    const dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
