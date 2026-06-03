import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';

class RouteWidget extends StatefulWidget {
  final String totalDistance;
  final String fromAddress;
  final String toAddress;
  final String extraOneAddress;
  final String extraTwoAddress;
  final String entrance;
  final bool fromParcelOngoing;
  const RouteWidget(
      {super.key,
      required this.totalDistance,
      required this.fromAddress,
      required this.toAddress,
      required this.extraOneAddress,
      required this.extraTwoAddress,
      required this.entrance,
      this.fromParcelOngoing = false});

  @override
  State<RouteWidget> createState() => _RouteWidgetState();
}

class _RouteWidgetState extends State<RouteWidget> {
  String totalDistance = '0', estDistance = '0', removeComma = '0';
  @override
  Widget build(BuildContext context) {
    if (widget.totalDistance.contains("km")) {
      removeComma = widget.totalDistance.replaceAll("km", '');
      totalDistance = removeComma.replaceAll(",", '');
    }
    estDistance = double.parse(totalDistance).toStringAsFixed(2);

    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return GetBuilder<LocationController>(
          builder: (locationController) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall),
                      child: Column(children: [
                        SizedBox(
                            width: Dimensions.iconSizeMedium,
                            child: Image.asset(
                              Images.currentLocation,
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .scrim,
                              colorBlendMode: BlendMode.modulate,
                            )),
                        SizedBox(
                            height: 65,
                            width: 10,
                            child: CustomDivider(
                              height: 2,
                              dashWidth: 1,
                              axis: Axis.vertical,
                              color: Theme.of(context).primaryColor,
                            )),
                        SizedBox(
                            width: Dimensions.iconSizeMedium,
                            child: Image.asset(Images.activityDirection,
                                color: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme!
                                    .scrim,
                                colorBlendMode: BlendMode.modulate)),
                      ]),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: 40,
                              child: Text(
                                widget.fromAddress,
                                style: textRegular.copyWith(
                                    color: Get.isDarkMode
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!
                                            .withOpacity(0.7)
                                        : null),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text('to'.tr,
                              style: textRegular.copyWith(
                                  color: Theme.of(context).primaryColor)),
                          SizedBox(
                              height: widget.extraOneAddress.isNotEmpty
                                  ? Dimensions.paddingSizeSmall
                                  : 0),
                          widget.extraOneAddress.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  child: Text(
                                    widget.extraOneAddress,
                                    style: textRegular.copyWith(
                                        color: Theme.of(Get.context!)
                                            .primaryColor
                                            .withOpacity(.75),
                                        fontSize: Dimensions.fontSizeSmall),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const SizedBox(),
                          widget.extraOneAddress.isNotEmpty &&
                                  widget.extraTwoAddress.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeExtraSmall),
                                  child: SizedBox(
                                      height: 20,
                                      width: 10,
                                      child: CustomDivider(
                                        height: 2,
                                        dashWidth: 1,
                                        axis: Axis.vertical,
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                )
                              : const SizedBox(),
                          widget.extraTwoAddress.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  child: Text(
                                    widget.extraTwoAddress,
                                    style: textRegular.copyWith(
                                        color: Theme.of(Get.context!)
                                            .primaryColor
                                            .withOpacity(.75),
                                        fontSize: Dimensions.fontSizeSmall),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            widget.toAddress,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: textRegular.copyWith(
                                color: Get.isDarkMode
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!
                                        .withOpacity(0.7)
                                    : null),
                          ),
                          if (widget.entrance.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                    height: 25,
                                    child: Image.asset(Images.curvedArrow)),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Container(
                                  transform:
                                      Matrix4.translationValues(0, 10, 0),
                                  child: Text(widget.entrance,
                                      style: textRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Get.isDarkMode
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!
                                                  .withOpacity(0.7)
                                              : null)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                GetBuilder<RideController>(builder: (rideController) {
                  final tripDetails = rideController.tripDetails;
                  if (tripDetails == null) return const SizedBox();

                  final createdAt = tripDetails.createdAt;
                  final timeText = DateConverter.dateToTimeOnly(
                    DateTime.now().add(
                      Duration(
                        minutes: int.tryParse(tripDetails
                                .formatedEstamitedTimeInMinutes
                                .split(' ')[0]) ??
                            0,
                      ),
                    ),
                  );
                  final durationText =
                      tripDetails.formatedEstamitedTimeInMinutes;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (durationText.isNotEmpty) ...[
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 16,
                                color: Get.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Theme.of(context).primaryColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${'estimated_time'.tr}: $durationText',
                                style: textRegular.copyWith(
                                  color: Get.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (timeText != '—') ...[
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? Colors.white.withValues(alpha: 0.06)
                                : Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Get.isDarkMode
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Get.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Theme.of(context).primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'The driver will meet you at this point at $timeText.'
                                      .tr,
                                  style: textRegular.copyWith(
                                    color: Get.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                if (!widget.fromParcelOngoing)
                  GetBuilder<RideController>(
                    builder: (rideController) {
                      return Padding(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              SizedBox(
                                  width: Dimensions.iconSizeMedium,
                                  child: Image.asset(Images.distanceCalculated,
                                      color: Theme.of(context)
                                          .buttonTheme
                                          .colorScheme!
                                          .scrim,
                                      colorBlendMode: BlendMode.modulate)),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              Text("total_distance".tr,
                                  style: textRegular.copyWith(
                                    color: Get.isDarkMode
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!
                                            .withOpacity(0.7)
                                        : null,
                                  )),
                            ]),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text(
                              widget.totalDistance.contains('km')
                                  ? widget.totalDistance
                                  : '${double.parse(widget.totalDistance).toStringAsFixed(2)} km',
                              style: textRegular.copyWith(
                                color: Get.isDarkMode
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!
                                        .withOpacity(0.7)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
