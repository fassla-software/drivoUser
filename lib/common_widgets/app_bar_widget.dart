import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/calender_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/drop_down_widget.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isHome;
  final String? subTitle;
  final bool showTripHistoryFilter;
  final double? height;
  final double? toolbarHeight;
  final bool? isShowIcon;
  const AppBarWidget(
      {super.key,
      required this.title,
      this.subTitle,
      this.showBackButton = true,
      this.onBackPressed,
      this.centerTitle = false,
      this.showActionButton = true,
      this.isHome = false,
      this.showTripHistoryFilter = false,
      this.fontSize,
      this.fontWeight,
      this.height,
      this.toolbarHeight,
      this.isShowIcon,  });

  @override
  Widget build(BuildContext context) {
    final bool nudgeTitleToScreenCenter = centerTitle &&
        showBackButton &&
        !showTripHistoryFilter &&
        isShowIcon == true;
    final double titleCenterNudgeDx = nudgeTitleToScreenCenter
        ? (Directionality.of(context) == TextDirection.rtl ? 1 : -1) *
            (kToolbarHeight / 2)
        : 0.0;

    return PreferredSize(
      preferredSize: Size.fromHeight(height ?? 150.0),
      child: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: toolbarHeight ?? kToolbarHeight,
          leadingWidth: showBackButton ? kToolbarHeight : null,
          automaticallyImplyLeading: false,
          title: isShowIcon == true
              ? Padding(
                  padding: EdgeInsets.only(top: centerTitle ? 20 : 16),
                  child: InkWell(
                    onTap: isHome
                        ? () {
                            Address? address =
                                Get.find<LocationController>().getUserAddress();
                            if (address == null || address.longitude == null) {
                              Get.to(() => const AccessLocationScreen());
                            } else {
                              Get.find<LocationController>().updatePosition(
                                LatLng(address.latitude!, address.longitude!),
                                false,
                                LocationType.location,
                              );
                              Get.to(() => const PickMapScreen(
                                  type: LocationType.accessLocation,
                                  oldLocationExist: true));
                            }
                          }
                        : null,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: centerTitle
                            ? 0
                            : Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Transform.translate(
                        offset: Offset(titleCenterNudgeDx, 0),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: centerTitle
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.end,
                        children: [
                          if (showTripHistoryFilter)
                            Row(children: [
                              Text(
                                title.tr,
                                style: textRegular.copyWith(
                                  fontSize:
                                      fontSize ?? Dimensions.fontSizeLarge,
                                  fontWeight: fontWeight,
                                  color: Get.isDarkMode
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              GetBuilder<TripController>(
                                  builder: (tripController) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.paddingSizeDefault),
                                    child: DropDownWidget<int>(
                                      showText: false,
                                      showLeftSide: false,
                                      menuItemWidth: 120,
                                      icon: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.filter_list_sharp,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 16),
                                      ),
                                      maxListHeight: 200,
                                      items: tripController.filterList
                                          .map((item) =>
                                              CustomDropdownMenuItem<int>(
                                                value: tripController.filterList
                                                    .indexOf(item),
                                                child: Text(
                                                  item.tr,
                                                  style: textRegular.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Get.find<TripController>()
                                                                    .filterIndex ==
                                                                Get.find<
                                                                        TripController>()
                                                                    .filterList
                                                                    .indexOf(
                                                                        item)
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.white
                                                        : Get.find<TripController>()
                                                                    .filterIndex ==
                                                                Get.find<
                                                                        TripController>()
                                                                    .filterList
                                                                    .indexOf(
                                                                        item)
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      hintText: tripController
                                          .filterList[Get.find<TripController>()
                                              .filterIndex]
                                          .tr,
                                      borderRadius: 5,
                                      onChanged: (int selectedItem) {
                                        if (selectedItem ==
                                            tripController.filterList.length -
                                                1) {
                                          showDialog(
                                            context: context,
                                            builder: (_) => CalenderWidget(
                                                onChanged: (value) =>
                                                    Get.back()),
                                          );
                                        } else {
                                          tripController
                                              .setFilterTypeName(selectedItem);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ])
                          else if (centerTitle)
                            Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      title.tr,
                                      style: textRegular.copyWith(
                                        fontSize: fontSize ??
                                            Dimensions.fontSizeLarge,
                                        fontWeight: fontWeight,
                                        color: Get.isDarkMode
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.white,
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(children: [
                              Text(
                                title.tr,
                                style: textRegular.copyWith(
                                  fontSize:
                                      fontSize ?? Dimensions.fontSizeLarge,
                                  fontWeight: fontWeight,
                                  color: Get.isDarkMode
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                          if (subTitle != null || isHome)
                            SizedBox(height: centerTitle ? 10 : 8),
                          subTitle != null
                              ? Text(
                                  '${'trip'.tr} #$subTitle',
                                  style: textRegular.copyWith(
                                    fontSize: fontSize ??
                                        (isHome
                                            ? Dimensions.fontSizeLarge
                                            : Dimensions.fontSizeLarge),
                                    color: Get.isDarkMode
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.white,
                                  ),
                                  maxLines: 1,
                                  textAlign: centerTitle
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const SizedBox(),
                          isHome
                              ? GetBuilder<LocationController>(
                                  builder: (locationController) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeExtraSmall),
                                    child: Row(
                                        mainAxisAlignment: centerTitle
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.place_outlined,
                                              color: Get.isDarkMode
                                                  ? Colors.white
                                                      .withOpacity(0.8)
                                                  : Colors.white,
                                              size: 16),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeSeven),
                                          if (centerTitle)
                                            Flexible(
                                              child: Text(
                                                locationController
                                                        .getUserAddress()
                                                        ?.address ??
                                                    '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: textRegular.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Colors.white
                                                            .withOpacity(0.8)
                                                        : Colors.white,
                                                    fontSize: Dimensions
                                                        .fontSizeExtraSmall),
                                              ),
                                            )
                                          else
                                            Expanded(
                                                child: Text(
                                              locationController
                                                      .getUserAddress()
                                                      ?.address ??
                                                  '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textRegular.copyWith(
                                                  color: Get.isDarkMode
                                                      ? Colors.white
                                                          .withOpacity(0.8)
                                                      : Colors.white,
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall),
                                            )),
                                        ]),
                                  );
                                })
                              : const SizedBox.shrink(),
                        ],
                      ),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          centerTitle: false,
          excludeHeaderSemantics: true,
          titleSpacing: 0,
          leading: showBackButton
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Get.isDarkMode
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white,
                    onPressed: () => onBackPressed != null
                        ? onBackPressed!()
                        : Navigator.canPop(context)
                            ? Get.back()
                            : Get.offAll(() => const DashboardScreen()),
                  ),
                )
              : SizedBox.shrink()
          // Padding(
          //         padding: const EdgeInsets.all(Dimensions.paddingSize),
          //         child: Image.asset(Images.icon,
          //             height: Get.height * 0.01, width: Get.width * 0.01),
          //       ),
          ),
    );
  }

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 150);
}
