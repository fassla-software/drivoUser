import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/user_pool_stop_pick_trip.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:math' as math;

enum TripState { driverOnWay, driverArrived, tripStarted }

class StartTripScreen extends StatefulWidget {
  const StartTripScreen({super.key});

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  TripState _currentState = TripState.driverOnWay;
  Timer? _driverLocationTimer;

  // Static data for simulation
  final LatLng _userLocation = const LatLng(24.7136, 46.6753); // Riyadh
  final LatLng _finalDestination =
      const LatLng(24.7749, 46.7380); // King Saud University

  // Driver's moving location (simulated)
  LatLng _driverLocation = const LatLng(24.6877, 46.7219); // Starting position

  // Rest points for the full trip
  final List<LatLng> _restPoints = [
    LatLng(24.7300, 46.6900), // Rest point 1
    LatLng(24.7500, 46.7100), // Rest point 2
    LatLng(24.7650, 46.7250), // Rest point 3
  ];

  @override
  void initState() {
    super.initState();
    _startDriverLocationSimulation();
  }

  @override
  void dispose() {
    _driverLocationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startDriverLocationSimulation() {
    // Simulate driver moving towards user location (15x faster)
    _driverLocationTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_currentState == TripState.driverOnWay) {
        setState(() {
          // Move driver closer to user location (15x faster movement)
          double latDiff =
              (_userLocation.latitude - _driverLocation.latitude) * 1.3;
          double lngDiff =
              (_userLocation.longitude - _driverLocation.longitude) * 1.3;

          _driverLocation = LatLng(
            _driverLocation.latitude + latDiff,
            _driverLocation.longitude + lngDiff,
          );

          // Check if driver is close enough to user
          double distance = _calculateDistance(_driverLocation, _userLocation);
          if (distance < 100) {
            // 100 meters
            _currentState = TripState.driverArrived;
            timer.cancel();
          }

          _updateMarkersAndPolylines();
        });
      }
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth radius in meters
    double lat1Rad = point1.latitude * (math.pi / 180);
    double lat2Rad = point2.latitude * (math.pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (math.pi / 180);
    double deltaLngRad =
        (point2.longitude - point1.longitude) * (math.pi / 180);

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  Future<void> _updateMarkersAndPolylines() async {
    _markers.clear();
    _polylines.clear();

    // Add user marker
    _markers.add(Marker(
      markerId: const MarkerId('user'),
      position: _userLocation,
      icon: BitmapDescriptor.fromBytes(
        await _getBytesFromAsset(Images.fromIcon, 100),
      ),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'Pickup Point',
      ),
    ));

    if (_currentState == TripState.driverOnWay) {
      // Add driver marker
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation,
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset(Images.carTop, 60),
        ),
        infoWindow: const InfoWindow(
          title: 'Driver',
          snippet: 'On the way',
        ),
      ));

      // Add polyline from driver to user
      _polylines.add(Polyline(
        polylineId: const PolylineId('driverToUser'),
        points: [_driverLocation, _userLocation],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    } else if (_currentState == TripState.driverArrived) {
      // Driver at user location
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _userLocation,
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset(Images.carTop, 60),
        ),
        infoWindow: const InfoWindow(
          title: 'Driver',
          snippet: 'Arrived',
        ),
      ));
    } else if (_currentState == TripState.tripStarted) {
      // Show full trip path with rest points
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _userLocation,
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset(Images.carTop, 60),
        ),
        infoWindow: const InfoWindow(
          title: 'Driver',
          snippet: 'Trip Started',
        ),
      ));

      // Add destination marker
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _finalDestination,
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset(Images.targetLocationIcon, 80),
        ),
        infoWindow: const InfoWindow(
          title: 'Destination',
          snippet: 'Final Stop',
        ),
      ));

      // Add rest point markers
      for (int i = 0; i < _restPoints.length; i++) {
        _markers.add(Marker(
          markerId: MarkerId('rest_$i'),
          position: _restPoints[i],
          icon: BitmapDescriptor.fromBytes(
            await _getBytesFromAsset(Images.mapLocationIcon, 50),
          ),
          infoWindow: InfoWindow(
            title: 'Rest Point ${i + 1}',
            snippet: 'Stop along the way',
          ),
        ));
      }

      // Create trip path with rest points
      List<LatLng> tripPath = [_userLocation];
      tripPath.addAll(_restPoints);
      tripPath.add(_finalDestination);

      _polylines.add(Polyline(
        polylineId: const PolylineId('tripPath'),
        points: tripPath,
        color: Theme.of(context).primaryColor,
        width: 5,
      ));

      // Add individual segments with different colors
      for (int i = 0; i < tripPath.length - 1; i++) {
        _polylines.add(Polyline(
          polylineId: PolylineId('segment_$i'),
          points: [tripPath[i], tripPath[i + 1]],
          color: i % 2 == 0 ? Colors.green : Colors.orange,
          width: 3,
        ));
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _startTrip() {
    setState(() {
      _currentState = TripState.tripStarted;
    });
    _updateMarkersAndPolylines();

    // Animate camera to show full trip
    if (_mapController != null) {
      List<LatLng> allPoints = [
        _userLocation,
        ..._restPoints,
        _finalDestination
      ];
      _fitMarkersInScreen(allPoints);
    }

    // Show success message and navigate to detailed trip view after a delay
    showCustomSnackBar(
      'بدأت الرحلة!',
      subMessage: 'تم بدء الرحلة بنجاح. يمكنك متابعة التفاصيل الكاملة.',
      isError: false,
      seconds: 2,
    );

    // Navigate to detailed trip view after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.off(() => const UserPoolStopPickTrip());
      }
    });
  }

  void _fitMarkersInScreen(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  String _getStatusText() {
    switch (_currentState) {
      case TripState.driverOnWay:
        return 'Driver is on the way to pick you up';
      case TripState.driverArrived:
        return 'Driver has arrived! Ready to start the trip?';
      case TripState.tripStarted:
        return 'Trip started! Following the planned route';
    }
  }

  Color _getStatusColor() {
    switch (_currentState) {
      case TripState.driverOnWay:
        return Colors.orange;
      case TripState.driverArrived:
        return Colors.green;
      case TripState.tripStarted:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 13.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _updateMarkersAndPolylines();
            },
            markers: _markers,
            polylines: _polylines,
            style: Get.isDarkMode
                ? Get.find<ThemeController>().darkMap
                : Get.find<ThemeController>().lightMap,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // Status Card
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getStatusText(),
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trip Details Card (when trip started)
          if (_currentState == TripState.tripStarted)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Trip Route',
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Pickup Point'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...List.generate(
                        _restPoints.length,
                        (index) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.orange,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 12),
                                  Text('Rest Point ${index + 1}'),
                                ],
                              ),
                            )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('Final Destination'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.off(() => const UserPoolStopPickTrip());
                        },
                        icon: Icon(Icons.info_outline, size: 18),
                        label: Text('View Detailed Trip Info'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action Button
          if (_currentState == TripState.driverArrived)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: ButtonWidget(
                buttonText: 'Start Trip',
                onPressed: _startTrip,
              ),
            ),

          // Current Location Button
          Positioned(
            bottom: _currentState == TripState.tripStarted
                ? 280
                : _currentState == TripState.driverArrived
                    ? 100
                    : 30,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).cardColor,
              onPressed: () {
                if (_mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _userLocation,
                        zoom: 15.0,
                      ),
                    ),
                  );
                }
              },
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
