import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';

import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_category_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

class ParcelDetailInputView extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const ParcelDetailInputView({
    super.key,
    required this.expandableKey,
  });

  @override
  State<ParcelDetailInputView> createState() =>
      _ParcelDetailInputViewState();
}

class _ParcelDetailInputViewState extends State<ParcelDetailInputView> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return GetBuilder<RideController>(
          builder: (rideController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                /// CATEGORY (مهم جدًا)
                const ParcelCategoryView(isDetails: true),

                const SizedBox(height: 10),

                TextFieldTitle(
                  title: 'category'.tr,
                  textOpacity: 0.8,
                ),

                CustomTextField(
                  prefixIcon: Images.editProfilePhone,
                  borderRadius: 50,
                  showBorder: false,
                  hintText: 'category'.tr,
                  isEnabled: false,
                  fillColor: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.04),
                  controller: parcelController.parcelTypeController,
                  prefix: false,
                ),

                const SizedBox(height: 15),

                /// WEIGHT
                TextFieldTitle(
                  title: 'parcel_weight'.tr,
                  textOpacity: 0.8,
                ),

                CustomTextField(
                  prefixIcon: Images.editProfilePhone,
                  borderRadius: 50,
                  showBorder: false,
                  hintText: 'parcel_weight_hint'.tr,
                  inputType: TextInputType.number,
                  inputAction: TextInputAction.done,
                  isAmount: true,
                  prefix: false,
                  controller: parcelController.parcelWeightController,
                  focusNode: parcelController.parcelWeightNode,
                  fillColor: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.04),
                  onTap: () {
                    parcelController.focusOnBottomSheet(
                        widget.expandableKey);
                  },
                ),

                const SizedBox(height: 25),

                /// SAVE
                rideController.isEstimate
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : ButtonWidget(
                        buttonText: "save_details".tr,
                        onPressed: () async {

                          if (parcelController
                              .parcelWeightController.text
                              .trim()
                              .isEmpty) {

                            FocusScope.of(context).requestFocus(
                                parcelController.parcelWeightNode);

                            showCustomSnackBar(
                                'parcel_weight_is_required'.tr);

                            return;
                          }

                          final value =
                              await rideController.getEstimatedFare(true);

                          if (value?.statusCode == 200) {

                            parcelController.updateParcelState(
                              ParcelDeliveryState.suggestVehicle,
                            );

                            parcelController
                                .updateParcelDetailsStatus();
                          }
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