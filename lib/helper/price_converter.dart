import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'dart:math';

class PriceConverter {
  static String convertPrice(double price,
      {double? discount, String? discountType, bool? loyaltyPoint}) {
    bool inRight =
        Get.find<ConfigController>().config!.currencySymbolPosition == 'right';
    String decimal =
        Get.find<ConfigController>().config!.currencyDecimalPoint ?? '1';
    String symbol = loyaltyPoint == null
        ? Get.find<ConfigController>().config!.currencySymbol ?? '\$'
        : '';
    String finalResult;
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price - discount;
      } else if (discountType == 'percent') {
        price = price - ((discount / 100) * price);
      }
    }
    if (inRight) {
      finalResult =
          '${(price).toStringAsFixed(int.parse(decimal)).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} $symbol';
    } else {
      finalResult = '$symbol '
          '${(price).toStringAsFixed(int.parse(decimal)).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
    return finalResult;
  }

  static double convertWithDiscount(
      double price, double discount, String discountType) {
    if (discountType == 'amount') {
      price = price - discount;
    } else if (discountType == 'percent') {
      price = price - ((discount / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
      String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : '\$'} OFF';
  }

  /// Formats a distance value for display.
  /// - If the distance is less than 1 km, it shows meters (e.g., "850 m")
  /// - If the distance is 1 km or more, it shows km with 1 decimal (e.g., "5.2 km")
  /// - Handles null, zero, and negative values gracefully
  static String formatDistance(dynamic distanceKm) {
    if (distanceKm == null) return '0 m';

    double distance;
    try {
      if (distanceKm is String) {
        // Remove 'km' suffix if present
        String cleanValue = distanceKm.replaceAll(RegExp(r'[^\d.]'), '');
        if (cleanValue.isEmpty) return '0 m';
        distance = double.parse(cleanValue);
      } else if (distanceKm is double) {
        distance = distanceKm;
      } else if (distanceKm is int) {
        distance = distanceKm.toDouble();
      } else {
        return '0 m';
      }
    } catch (e) {
      return '0 m';
    }

    if (distance <= 0) return '0 m';

    if (distance < 1) {
      // Convert to meters and show as integer
      int meters = (distance * 1000).round();
      return '$meters m';
    } else {
      // Show in km with 1 decimal place
      return '${distance.toStringAsFixed(1)} km';
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
