import 'package:get/get.dart';
import '../models/find_match_request.dart';
import '../models/join_request.dart';

abstract class PoolInterface {
  Future<Response> findMatchingRides(FindMatchRequest request);
  Future<Response> joinRide(JoinRequest request);
  Future<Response> getBoardingPoints();
}
