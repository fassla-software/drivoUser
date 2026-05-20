import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SearchTripeDetailsWidget extends StatelessWidget {
  const SearchTripeDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: Dimensions.paddingSizeSmall,
      runSpacing: Dimensions.paddingSizeExtraSmall,
      children: [
        _defaultImageAndIcon(
          context,
          imagePath: Images.userIcon,
          name: '4 مقاعد',
        ),
        _defaultImageAndIcon(
          context,
          imagePath: Images.windIcon,
          name: 'مكيف',
        ),
        _defaultImageAndIcon(
          context,
          imagePath: Images.audioIcon,
          name: 'شاشة ترفيه',
        ),
        _defaultImageAndIcon(
          context,
          imagePath: Images.userIcon,
          name: 'مسموح بالتدخين',
        ),
      ],
    );
  }

  Widget _defaultImageAndIcon(
    BuildContext context, {
    required String name,
    required String imagePath,
  }) {
    return Row(
      spacing: MediaQuery.sizeOf(context).width * 0.01,
      children: [
        Text(
          name,
          style: textRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontSize: Dimensions.fontSizeSmall,
            fontWeight: FontWeight.w400,
          ),
        ),
        Image.asset(
          imagePath,
          width: MediaQuery.sizeOf(context).width * 0.05,
        ),
      ],
    );
  }
}
