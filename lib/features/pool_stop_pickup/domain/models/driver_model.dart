import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';

class Driver {
  final String id;
  final String fullName;
  final String gender;
  final String? profileImage;

  Driver({
    required this.id,
    required this.fullName,
    required this.gender,
    this.profileImage,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    try {
      String? profileImageUrl;
      final rawProfileImage = json['profile_image'];

      if (rawProfileImage != null && rawProfileImage.toString().isNotEmpty) {
        // Check if it's already a full URL
        if (rawProfileImage.toString().startsWith('http')) {
          profileImageUrl = rawProfileImage;
        } else {
          // Construct full URL using config base URL for driver profile images
          try {
            final configController = Get.find<ConfigController>();
            final baseUrl =
                configController.config?.imageBaseUrl?.profileImageDriver;
            if (baseUrl != null && baseUrl.isNotEmpty) {
              profileImageUrl = '$baseUrl/$rawProfileImage';
            }
          } catch (e) {
            print('Error getting config for driver image: $e');
          }
        }
      }

      return Driver(
        id: json['id'] ?? '',
        fullName: json['full_name'] ?? '',
        gender: json['gender'] ?? '',
        profileImage: profileImageUrl,
      );
    } catch (e) {
      print('Error parsing Driver: $e');
      return Driver(
        id: '',
        fullName: '',
        gender: '',
        profileImage: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'gender': gender,
      'profile_image': profileImage,
    };
  }
}
