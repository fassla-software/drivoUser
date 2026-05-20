import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../../util/images.dart';

class AppAdvertising extends StatelessWidget {
  const AppAdvertising({super.key});

  static const Color _cardBlue = Color(0xFFD4E9FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          Expanded(
            child: _AdvertisingCard(
              backgroundColor: _cardBlue,
              iconPath: Images.shieldIcon,
              title: 'Safety and comfort',
              subtitle: 'Driven by Safty, Powered by Trust.',
                            subtitleMaxLines: 2,

            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _AdvertisingCard(
              backgroundColor: _cardBlue,
              iconPath: Images.discountCopoun,
              title: 'Nonstop Offers',
              subtitle:
                  'Unlock exclusive coupones every month - only on Drivo',
              subtitleMaxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvertisingCard extends StatelessWidget {
  final Color backgroundColor;
  final String iconPath;
  final String title;
  final String subtitle;
  final int subtitleMaxLines;

  const _AdvertisingCard({
    required this.backgroundColor,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.subtitleMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 52,
            height: 52,
            color: Colors.black,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textBold.copyWith(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: textSemiBold.copyWith(
              fontSize: 10,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
