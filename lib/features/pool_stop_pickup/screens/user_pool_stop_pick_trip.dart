import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
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

class UserPoolStopPickTrip extends StatefulWidget {
  const UserPoolStopPickTrip({super.key});

  @override
  State<UserPoolStopPickTrip> createState() => _UserPoolStopPickTripState();
}

class _UserPoolStopPickTripState extends State<UserPoolStopPickTrip> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  int _currentStopIndex = 0;
  Timer? _tripProgressTimer;

  // Static trip data
  final Map<String, dynamic> _tripData = {
    'driverName': 'أحمد محمد',
    'driverImage': Images.userIcon,
    'rating': 4.8,
    'carModel': 'تويوتا كامري 2022',
    'carColor': 'أبيض',
    'carPlate': 'أ ب ج 1234',
    'estimatedArrival': '09:15 ص',
    'totalDistance': '25 كم',
    'totalDuration': '45 دقيقة',
    'tripPrice': 45.0,
    'currency': 'جنيه',
  };

  // Trip route with rest points and passengers
  final List<Map<String, dynamic>> _tripStops = [
    {
      'location': LatLng(24.7136, 46.6753),
      'name': 'نقطة الانطلاق',
      'address': 'مدينة نصر، القاهرة',
      'type': 'start',
      'time': '08:30 ص',
      'isCompleted': true,
      'passengers': [
        {'name': 'أنت', 'avatar': Images.userIcon, 'isMe': true},
        {'name': 'سارة أحمد', 'avatar': Images.userIcon, 'isMe': false},
      ],
    },
    {
      'location': LatLng(24.7300, 46.6900),
      'name': 'محطة المترو',
      'address': 'محطة مترو الأنفاق',
      'type': 'pickup',
      'time': '08:45 ص',
      'isCompleted': true,
      'passengers': [
        {'name': 'محمد علي', 'avatar': Images.userIcon, 'isMe': false},
      ],
    },
    {
      'location': LatLng(24.7500, 46.7100),
      'name': 'مول التجاري',
      'address': 'المول التجاري الكبير',
      'type': 'pickup',
      'time': '09:00 ص',
      'isCompleted': false,
      'passengers': [
        {'name': 'فاطمة حسن', 'avatar': Images.userIcon, 'isMe': false},
      ],
    },
    {
      'location': LatLng(24.7650, 46.7250),
      'name': 'الجامعة',
      'address': 'جامعة الملك سعود',
      'type': 'dropoff',
      'time': '09:10 ص',
      'isCompleted': false,
      'passengers': [
        {'name': 'سارة أحمد', 'avatar': Images.userIcon, 'isMe': false},
      ],
    },
    {
      'location': LatLng(24.7749, 46.7380),
      'name': 'وجهتك النهائية',
      'address': 'وسط البلد، القاهرة',
      'type': 'destination',
      'time': '09:15 ص',
      'isCompleted': false,
      'passengers': [
        {'name': 'أنت', 'avatar': Images.userIcon, 'isMe': true},
        {'name': 'محمد علي', 'avatar': Images.userIcon, 'isMe': false},
        {'name': 'فاطمة حسن', 'avatar': Images.userIcon, 'isMe': false},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTripProgressSimulation();
  }

  @override
  void dispose() {
    _tripProgressTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startTripProgressSimulation() {
    // Simulate trip progress every 10 seconds
    _tripProgressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentStopIndex < _tripStops.length - 1) {
        setState(() {
          _tripStops[_currentStopIndex]['isCompleted'] = true;
          _currentStopIndex++;
        });
        _updateMapView();
      } else {
        timer.cancel();
      }
    });

    _updateMapView();
  }

  Future<void> _updateMapView() async {
    _markers.clear();
    _polylines.clear();

    // Add route polyline
    List<LatLng> routePoints =
        _tripStops.map((stop) => stop['location'] as LatLng).toList();

    _polylines.add(Polyline(
      polylineId: const PolylineId('tripRoute'),
      points: routePoints,
      color: Theme.of(context).primaryColor,
      width: 5,
    ));

    // Add markers for each stop
    for (int i = 0; i < _tripStops.length; i++) {
      final stop = _tripStops[i];
      String iconPath;

      switch (stop['type']) {
        case 'start':
          iconPath = Images.fromIcon;
          break;
        case 'pickup':
          iconPath = Images.mapLocationIcon;
          break;
        case 'dropoff':
          iconPath = Images.mapLocationIcon;
          break;
        case 'destination':
          iconPath = Images.targetLocationIcon;
          break;
        default:
          iconPath = Images.mapLocationIcon;
      }

      _markers.add(Marker(
        markerId: MarkerId('stop_$i'),
        position: stop['location'],
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset(
              iconPath,
              stop['type'] == 'start' || stop['type'] == 'destination'
                  ? 100
                  : 80),
        ),
        infoWindow: InfoWindow(
          title: stop['name'],
          snippet: stop['address'],
        ),
      ));
    }

    // Add current vehicle position (simulate moving)
    if (_currentStopIndex < _tripStops.length) {
      LatLng currentPosition = _tripStops[_currentStopIndex]['location'];
      _markers.add(Marker(
        markerId: const MarkerId('vehicle'),
        position: currentPosition,
        icon: BitmapDescriptor.fromBytes(
          await _getBytesFromAsset(Images.carTop, 70),
        ),
        infoWindow: InfoWindow(
          title: _tripData['carModel'],
          snippet: 'السائق: ${_tripData['driverName']}',
        ),
      ));
    }

    if (mounted) {
      setState(() {});
      _fitMarkersInScreen();
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

  void _fitMarkersInScreen() {
    if (_tripStops.isEmpty || _mapController == null) return;

    List<LatLng> allPoints =
        _tripStops.map((stop) => stop['location'] as LatLng).toList();

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (LatLng point in allPoints) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Map View
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _tripStops.first['location'],
                zoom: 12.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _updateMapView();
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
          ),

          // Trip Information Panel
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Driver Info
                    _buildDriverInfo(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Trip Progress
                    _buildTripProgress(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Trip Stops
                    _buildTripStops(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(_tripData['driverImage']),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tripData['driverName'],
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _tripData['rating'].toString(),
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_tripData['carModel']} - ${_tripData['carColor']}',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                Text(
                  'رقم اللوحة: ${_tripData['carPlate']}',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // Call driver
                },
                icon: Icon(
                  Icons.phone,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Message driver
                },
                icon: Icon(
                  Icons.message,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripProgress() {
    double progress =
        (_currentStopIndex / (_tripStops.length - 1)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).hintColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدم الرحلة',
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).hintColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                '${(progress * 100).toInt()}%',
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressInfo(
                icon: Icons.access_time,
                label: 'الوصول المتوقع',
                value: _tripData['estimatedArrival'],
              ),
              _buildProgressInfo(
                icon: Icons.route,
                label: 'المسافة الكلية',
                value: _tripData['totalDistance'],
              ),
              _buildProgressInfo(
                icon: Icons.payments,
                label: 'التكلفة',
                value: '${_tripData['tripPrice']} ${_tripData['currency']}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).hintColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: textMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTripStops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'محطات الرحلة',
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tripStops.length,
          itemBuilder: (context, index) {
            final stop = _tripStops[index];
            final isCompleted = stop['isCompleted'] as bool;
            final isCurrent = index == _currentStopIndex;

            return Container(
              margin:
                  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: isCurrent
                      ? Theme.of(context).primaryColor
                      : isCompleted
                          ? Colors.green
                          : Theme.of(context).hintColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Theme.of(context).primaryColor
                              : isCompleted
                                  ? Colors.green
                                  : Theme.of(context).hintColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCurrent
                              ? Icons.location_on
                              : isCompleted
                                  ? Icons.check
                                  : Icons.circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop['name'],
                              style: textBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            Text(
                              stop['address'],
                              style: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        stop['time'],
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),

                  // Passengers at this stop
                  if (stop['passengers'] != null &&
                      (stop['passengers'] as List).isNotEmpty) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      stop['type'] == 'start'
                          ? 'الركاب من البداية:'
                          : stop['type'] == 'pickup'
                              ? 'ركاب جدد:'
                              : stop['type'] == 'dropoff'
                                  ? 'ركاب ينزلون:'
                                  : 'الركاب المتبقون:',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children:
                          (stop['passengers'] as List).map<Widget>((passenger) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: passenger['isMe']
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2)
                                : Theme.of(context).hintColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(passenger['avatar']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                passenger['name'],
                                style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  fontWeight: passenger['isMe']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Share trip location
                },
                icon: Icon(Icons.share_location),
                label: Text('مشاركة الموقع'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Emergency contact
                },
                icon: Icon(Icons.emergency, color: Colors.red),
                label: Text('طوارئ', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Cancel trip
              _showCancelTripDialog();
            },
            icon: Icon(Icons.cancel),
            label: Text('إلغاء الرحلة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelTripDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إلغاء الرحلة'),
          content: Text('هل أنت متأكد من إلغاء هذه الرحلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('لا'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showCustomSnackBar(
                  'تم الإلغاء',
                  subMessage: 'تم إلغاء الرحلة بنجاح',
                  isError: false,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('نعم، إلغاء'),
            ),
          ],
        );
      },
    );
  }
}
