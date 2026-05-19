import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';

import 'package:ride_sharing_user_app/features/map/widget/parcel_accept_rider_widget.dart';
import 'package:ride_sharing_user_app/features/map/widget/parcel_info_details_widget.dart';
import 'package:ride_sharing_user_app/features/map/widget/parcel_ongoing_bottomsheet_widget.dart';
import 'package:ride_sharing_user_app/features/map/widget/parcel_otp_bottomsheet_widget.dart';

import 'package:ride_sharing_user_app/features/parcel/widgets/choose_effificent_vehicle_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/finding_rider_widget.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/parcel_details_input_view.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/sender_receiver_info_widget.dart';

import 'package:ride_sharing_user_app/features/ride/widgets/rise_fare_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class ParcelExpendableBottomSheet extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const ParcelExpendableBottomSheet({
    super.key,
    required this.expandableKey,
  });

  @override
  State<ParcelExpendableBottomSheet> createState() =>
      _ParcelExpendableBottomSheetState();
}

class _ParcelExpendableBottomSheetState
    extends State<ParcelExpendableBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return GetBuilder<RideController>(
          builder: (rideController) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                  topRight: Radius.circular(Dimensions.paddingSizeDefault),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).hintColor,
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 7,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: _buildContent(parcelController),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ FIXED STATE MACHINE (NO TERNARY CHAOS)
  Widget _buildContent(ParcelController parcelController) {
    switch (parcelController.currentParcelState) {
      case ParcelDeliveryState.initial:
        return SenderReceiverInfoWidget(
          expandableKey: widget.expandableKey,
        );

      case ParcelDeliveryState.addOtherParcelDetails:
        return ParcelDetailInputView(
          expandableKey: widget.expandableKey,
        );

      case ParcelDeliveryState.parcelInfoDetails:
        return ParcelInfoDetailsWidget(
          expandableKey: widget.expandableKey,
        );

      case ParcelDeliveryState.riseFare:
        return RiseFareWidget(
          expandableKey: widget.expandableKey,
          fromPage: RiseFare.parcel,
        );

      case ParcelDeliveryState.suggestVehicle:
        return const ChooseEfficientVehicleWidget();

      case ParcelDeliveryState.findingRider:
        return FindingRiderWidget(
          fromPage: FindingRide.parcel,
          expandableKey: widget.expandableKey,
        );

      case ParcelDeliveryState.acceptRider:
        return ParcelAcceptedRideWidget(
          expandableKey: widget.expandableKey,
        );

      case ParcelDeliveryState.otpSent:
        return ParcelOtpBottomSheetWidget(
          expandableKey: widget.expandableKey,
        );

      case ParcelDeliveryState.parcelOngoing:
        return ParcelOngoingBottomSheetWidget(
          expandableKey: widget.expandableKey,
        );

      default:
        return const SizedBox();
    }
  }
}