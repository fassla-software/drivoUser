import 'package:get/get.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import '../interfaces/pool_interface.dart';
import '../models/find_match_request.dart';
import '../models/join_request.dart';

class PoolRepository implements PoolInterface {
  final ApiClient apiClient;

  PoolRepository({required this.apiClient});

  @override
  Future<Response> findMatchingRides(FindMatchRequest request) async {
    return await apiClient.postData(
      AppConstants.findRidesUri,
      request.toJson(),
    );
  }

  @override
  Future<Response> joinRide(JoinRequest request) async {
    return await apiClient.postData(
      AppConstants.joinTripe,
      request.toJson(),
    );
  }

  @override
  Future<Response> getBoardingPoints() async {
    return await apiClient.getData(
      AppConstants.boardingPointsUri,
    );
  }
}
