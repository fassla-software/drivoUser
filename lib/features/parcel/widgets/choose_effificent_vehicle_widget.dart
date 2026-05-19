import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'package:ride_sharing_user_app/features/parcel/domain/models/suggested_vehicle_category_model.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/suggested_category_card.dart';

import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class ChooseEfficientVehicleWidget extends StatefulWidget {
  const ChooseEfficientVehicleWidget({super.key});

  @override
  State<ChooseEfficientVehicleWidget> createState() =>
      _ChooseEfficientVehicleWidgetState();
}

class _ChooseEfficientVehicleWidgetState
    extends State<ChooseEfficientVehicleWidget> {

  @override
@override
@override
void initState() {
  super.initState();

  print('INIT CHOOSE VEHICLE');

  WidgetsBinding.instance.addPostFrameCallback((_) async {

    print('CALLING API');

    final parcelController = Get.find<ParcelController>();

    await parcelController.getSuggestedCategoryList();
  });
}

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ParcelController>(
      builder: (parcelController) {

        return GetBuilder<RideController>(
          builder: (rideController) {

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// LOADING
                if (parcelController.getSuggested)

                  Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    ),
                  )

                /// VEHICLE LIST
                else if (parcelController
                        .suggestedVehicleCategoryList !=
                    null &&
                    parcelController
                        .suggestedVehicleCategoryList!
                        .isNotEmpty)

                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount: parcelController
                        .suggestedVehicleCategoryList!
                        .length,

                    itemBuilder: (context, index) {

                      SuggestedCategory vehicle =
                          parcelController
                                  .suggestedVehicleCategoryList![
                              index];

                      return SuggestedCategoryCard(
                        suggestedCategory: vehicle,
                      );
                    },
                  )

                else

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                    ),

                    child: Text(
                      'No vehicles found',

                      style: textMedium.copyWith(
                        color:
                            Theme.of(context).hintColor,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical:
                        Dimensions.paddingSizeDefault,
                  ),

                  child: Text(
                    'find_your_best_parcel_delivery_vehicles'
                        .tr,

                    style: textMedium.copyWith(
                      color:
                          Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                Text(
                  'find_your_best_parcel_delivery_vehicles_hint'
                      .tr,

                  style: textMedium.copyWith(
                    color: Theme.of(context).hintColor,
                  ),

                  textAlign: TextAlign.center,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical:
                        Dimensions.paddingSizeSmall,
                  ),

                  child: Text(
                    'or'.tr,

                    style: textMedium.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize:
                          Dimensions.fontSizeLarge,
                    ),
                  ),
                ),

                rideController.isSubmit

                    ? Center(
                        child: SpinKitCircle(
                          color: Theme.of(context)
                              .primaryColor,
                          size: 40.0,
                        ),
                      )

                    : ButtonWidget(
                        buttonText:
                            'choose_the_efficient_vehicles'
                                .tr,

                        fontSize:
                            Dimensions.fontSizeDefault,

                        onPressed: () {

                          rideController
                              .submitRideRequest(
                                  '', true)
                              .then((value) {

                            if (value.statusCode ==
                                200) {

                              Get.find<
                                      ParcelController>()
                                  .updateParcelState(
                                ParcelDeliveryState
                                    .findingRider,
                              );

                              Get.find<MapController>()
                                  .getPolyline();

                              Get.find<MapController>()
                                  .notifyMapController();

                              parcelController
                                  .updatePaymentPerson(
                                false,
                              );
                            }
                          });
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
