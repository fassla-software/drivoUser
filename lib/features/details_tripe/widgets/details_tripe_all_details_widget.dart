import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DetailsTripeAllDetailsWidget extends StatefulWidget {
  const DetailsTripeAllDetailsWidget({super.key});

  @override
  State<DetailsTripeAllDetailsWidget> createState() =>
      _DetailsTripeAllDetailsWidgetState();
}

List<String> imagePath = [
  Images.userIcon,
  Images.windIcon,
  Images.windIcon,
  Images.audioIcon,
  Images.userIcon,
  Images.userIcon,
  Images.userIcon,
  Images.audioIcon,
  Images.audioIcon,
];
List<String> details = [
  '4 مقاعد ',
  'مسموح التدخين',
  'مكيف هواء',
  'شاشة ترفيه',
  'ذكور فقط',
  'سن 25 الي 35',
  'الكرسي الأمامي الأولوية للسن',
  'تشغيل موسيقي',
  'غير مسموح بالحقائب',
];

class _DetailsTripeAllDetailsWidgetState
    extends State<DetailsTripeAllDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
        height: size.height * 0.49,
        width: size.width * 0.90,
        padding: EdgeInsets.symmetric(horizontal: size.height * 0.01 + 5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.2),
              blurRadius: 25,
              spreadRadius: 1,
              offset: const Offset(1, 5),
            )
          ],
          color: Get.isDarkMode
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        child: Column(
          children: [
            _userImageAndName(),
            _detailsImageAndText(),
            SizedBox(height: size.height * 0.01 + 10),
            _defaultContainerText(),
          ],
        ));
  }

  Widget _detailsImageAndText() {
    var size = MediaQuery.of(context).size;

    return Column(
      spacing: size.height * 0.01 - 1,
      children: List.generate(imagePath.length, (index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              details[index],
              style: textSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Image.asset(
              imagePath[index],
              width: size.width * 0.06,
              color: Theme.of(context).primaryColor,
            ),
          ],
        );
      }),
    );
  }

  Widget _defaultContainerText() {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.08 + 6,
      width: size.width * 0.80,
      padding: EdgeInsets.symmetric(horizontal: size.height * 0.02),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Center(
        child: Text(
          textAlign: TextAlign.end,
          'هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة',
          style: textRegular.copyWith(
            color: Theme.of(context).cardColor,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
      ),
    );
  }

  Widget _userImageAndName() {
    var size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset(
          Images.arrowLeft2Icon,
          width: size.width * 0.02,
          color: Theme.of(context).primaryColor,
        ),
        Spacer(),
        Text(
          'علي عبدالعزيز',
          style: textRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium!.color!,
            fontSize: Dimensions.fontSizeLarge,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Padding(
          padding: EdgeInsets.only(right: size.width * 0.01 + 2),
          child: Container(
            width: size.width * 0.07,
            height: size.height * 0.07,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(Images.userIcon),
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
