import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/search_tripe_response_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';

class TripDetailsScreen extends StatefulWidget {
  final dynamic trip;
  final RideController rideController;

  const TripDetailsScreen({
    super.key,
    required this.trip,
    required this.rideController,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Trip Details',
                style: textBold.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      _buildDriverCard(),
                      const SizedBox(height: 16),
                      _buildTripInfoCard(),
                      const SizedBox(height: 16),
                      _buildVehicleCard(),
                      const SizedBox(height: 16),
                      _buildAmenitiesCard(),
                      const SizedBox(height: 16),
                      _buildRouteCard(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Driver Information',
                style: textBold.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Builder(builder: (context) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: widget.trip.driver.profileImage != null &&
                          widget.trip.driver.profileImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            widget.trip.driver.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                );
              }),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.driver.fullName.isNotEmpty
                          ? widget.trip.driver.fullName
                          : 'Unknown Driver',
                      style: textBold.copyWith(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 • ${widget.trip.driver.gender.isNotEmpty ? '${widget.trip.driver.gender[0].toUpperCase()}${widget.trip.driver.gender.substring(1)}' : 'Unknown'}',
                          style: textMedium.copyWith(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${widget.trip.price.toString()}',
                  style: textBold.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.route,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Trip Information',
                style: textBold.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Departure', _formatDateTime(widget.trip.startTime)),
          _buildInfoRow('Available Seats', '${widget.trip.seatsAvailable}'),
          _buildInfoRow('Pickup', widget.trip.pickupAddress ?? ''),
          _buildInfoRow('Destination', widget.trip.dropoffAddress ?? ''),
          if (widget.trip.isRecurring == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.repeat,
                          size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Trip Dates',
                        style: textBold.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (widget.trip.recurringInfo?.availableDates != null &&
                      (widget.trip.recurringInfo!.availableDates! as List)
                          .isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (widget.trip.recurringInfo!.availableDates! as List)
                              .where((date) {
                                final now = DateTime.now();
                                final today =
                                    DateTime(now.year, now.month, now.day);
                                final tripDate =
                                    DateTime(date.year, date.month, date.day);
                                return !tripDate.isBefore(today);
                              })
                              .take(31)
                              .map((date) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    _formatDate(date),
                                    style: textRegular.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Vehicle Details',
                style: textBold.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Brand',
            widget.trip.vehicle.brand.isNotEmpty
                ? widget.trip.vehicle.brand
                : 'Unknown',
          ),
          _buildInfoRow(
            'Model',
            widget.trip.vehicle.model.isNotEmpty
                ? widget.trip.vehicle.model
                : 'Vehicle',
          ),
          if (widget.trip.vehicle.plateNumber != null &&
              widget.trip.vehicle.plateNumber!.isNotEmpty)
            _buildInfoRow('Plate', widget.trip.vehicle.plateNumber!),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard() {
    final amenities = [
      if (widget.trip.isAc) _AmenityData(Icons.ac_unit, 'AC', Colors.blue),
      if (widget.trip.hasMusic)
        _AmenityData(Icons.music_note, 'Music', Colors.purple),
      if (widget.trip.hasScreenEntertainment)
        _AmenityData(Icons.tv, 'Entertainment', Colors.green),
      if (widget.trip.allowLuggage)
        _AmenityData(Icons.work, 'Luggage', Colors.brown),
      if (widget.trip.isSmokingAllowed)
        _AmenityData(Icons.smoking_rooms, 'Smoking', Colors.orange),
    ];

    if (amenities.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Amenities',
                style: textBold.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                amenities.map((amenity) => _buildAmenityChip(amenity)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Route Information',
                style: textBold.copyWith(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if ((widget.trip is SearchTripeAll || widget.trip is PoolRide) &&
              widget.trip.closestPickup != null) ...[
            _buildLocationRow(
              Icons.directions_walk,
              'Your Pickup Point',
              widget.trip.closestPickup!.placeName,
              Colors.green,
            ),
            const SizedBox(height: 12),
          ],
          if ((widget.trip is SearchTripeAll || widget.trip is PoolRide) &&
              widget.trip.closestDropoff != null) ...[
            _buildLocationRow(
              Icons.directions_walk,
              'Your Dropoff Point',
              widget.trip.closestDropoff!.placeName,
              Colors.red,
            ),
            const SizedBox(height: 12),
          ],
          if (widget.trip.closestPickup != null &&
              !(widget.trip is PoolRide &&
                  widget.trip.carpoolType == 'travel')) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk,
                      color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Walking distance to pickup: ${PriceConverter.formatDistance(PriceConverter.calculateDistance(
                        widget.trip.pickupMatchPoint.lat,
                        widget.trip.pickupMatchPoint.lng,
                        widget.trip.closestPickup?.lat ??
                            widget.trip.pickupMatchPoint.lat,
                        widget.trip.closestPickup?.lng ??
                            widget.trip.pickupMatchPoint.lng,
                      ))}',
                      style: textMedium.copyWith(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[600]!,
                Colors.blue[700]!,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => _showRouteMap(widget.trip, context),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'View Route on Map',
                      style: textBold.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => _selectTrip(widget.trip, widget.rideController),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 24, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Join This Trip',
                      style: textBold.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: textMedium.copyWith(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textRegular.copyWith(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
      IconData icon, String label, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textMedium.copyWith(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: textRegular.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityChip(_AmenityData amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: amenity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: amenity.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(amenity.icon, size: 16, color: amenity.color),
          const SizedBox(width: 8),
          Text(
            amenity.label,
            style: textRegular.copyWith(
              fontSize: 14,
              color: amenity.color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic date) {
    try {
      if (date is DateTime) {
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      if (date is String) {
        final DateTime dateTime = DateTime.parse(date);
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  void _showRouteMap(dynamic trip, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Trip Route',
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          trip.pickupMatchPoint.lat,
                          trip.pickupMatchPoint.lng,
                        ),
                        zoom: 13,
                      ),
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: true,
                      compassEnabled: true,
                      markers: {
                        Marker(
                          markerId: const MarkerId('pickup'),
                          position: LatLng(
                            trip.pickupMatchPoint.lat,
                            trip.pickupMatchPoint.lng,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                          infoWindow: InfoWindow(
                            title: 'Pickup Point',
                            snippet: trip.pickupAddress,
                          ),
                        ),
                        Marker(
                          markerId: const MarkerId('dropoff'),
                          position: LatLng(
                            trip.dropoffMatchPoint.lat,
                            trip.dropoffMatchPoint.lng,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                          infoWindow: InfoWindow(
                            title: 'Dropoff Point',
                            snippet: trip.dropoffAddress,
                          ),
                        ),
                        if (trip.closestPickup != null)
                          Marker(
                            markerId: const MarkerId('closest_pickup'),
                            position: LatLng(
                              trip.closestPickup!.lat,
                              trip.closestPickup!.lng,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure,
                            ),
                            infoWindow: InfoWindow(
                              title: 'Your Closest Pickup Point',
                              snippet: trip.closestPickup!.placeName,
                            ),
                          ),
                        if (trip.closestDropoff != null)
                          Marker(
                            markerId: const MarkerId('closest_dropoff'),
                            position: LatLng(
                              trip.closestDropoff!.lat,
                              trip.closestDropoff!.lng,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueOrange,
                            ),
                            infoWindow: InfoWindow(
                              title: 'Your Closest Dropoff Point',
                              snippet: trip.closestDropoff!.placeName,
                            ),
                          ),
                      },
                      polylines: trip.encodedPolyline != null &&
                              trip.encodedPolyline!.isNotEmpty
                          ? {
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: _decodeEncodedPolyline(
                                    trip.encodedPolyline!),
                                color: Theme.of(context).primaryColor,
                                width: 4,
                              ),
                            }
                          : {},
                      onMapCreated: (controller) {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _fitMapBounds(controller, trip);
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (trip.closestPickup != null &&
                          trip.closestPickup!.lat != null &&
                          trip.closestPickup!.lng != null) ...[
                        ElevatedButton.icon(
                          onPressed: () => _openInGoogleMaps(
                            trip.closestPickup!.lat,
                            trip.closestPickup!.lng,
                          ),
                          icon: const Icon(Icons.directions),
                          label: const Text('Navigate to Meeting Point'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!(trip is PoolRide &&
                          trip.carpoolType == 'travel')) ...[
                        Text(
                          'Walking distance to pickup: ${PriceConverter.formatDistance(PriceConverter.calculateDistance(
                            trip.pickupMatchPoint.lat,
                            trip.pickupMatchPoint.lng,
                            trip.closestPickup?.lat ??
                                trip.pickupMatchPoint.lat,
                            trip.closestPickup?.lng ??
                                trip.pickupMatchPoint.lng,
                          ))}',
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
    try {
      if (encoded.isEmpty) return [];

      final List<LatLng> poly = [];
      int index = 0;
      final int len = encoded.length;
      int lat = 0;
      int lng = 0;

      while (index < len) {
        int b;
        int shift = 0;
        int result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        final LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
        poly.add(p);
      }
      return poly;
    } catch (e) {
      debugPrint('Error decoding polyline: $e');
      return [];
    }
  }

  void _fitMapBounds(GoogleMapController controller, dynamic trip) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    void updateBounds(double lat, double lng) {
      minLat = min(minLat, lat);
      maxLat = max(maxLat, lat);
      minLng = min(minLng, lng);
      maxLng = max(maxLng, lng);
    }

    updateBounds(trip.pickupMatchPoint.lat, trip.pickupMatchPoint.lng);
    updateBounds(trip.dropoffMatchPoint.lat, trip.dropoffMatchPoint.lng);
    if (trip.closestPickup != null) {
      updateBounds(trip.closestPickup!.lat, trip.closestPickup!.lng);
    }
    if (trip.closestDropoff != null) {
      updateBounds(trip.closestDropoff!.lat, trip.closestDropoff!.lng);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    try {
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'https://maps.google.com/maps?q=$lat,$lng';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(Uri.parse(fallbackUrl),
              mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Could not open Google Maps. Please install Google Maps app.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
      Get.snackbar(
        'Error',
        'Could not open Google Maps. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _selectTrip(dynamic trip, RideController rideController) {
    rideController.selectCarpoolTrip(
      trip,
      bookingType: 'all',
      selectedDates: const [],
    );

    // Navigator.of(context).pop();
  }
}

class _AmenityData {
  final IconData icon;
  final String label;
  final Color color;

  _AmenityData(this.icon, this.label, this.color);
}
