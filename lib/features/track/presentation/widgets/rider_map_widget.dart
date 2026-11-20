import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/models/route_result.dart';
import '../../../../core/services/routing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/map_style.dart';
import '../../../../core/utils/map_utils.dart';
import '../../../../core/utils/rider_marker_icon.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../domain/entities/rider_location_entity.dart';

/// Live map of kitchen → rider → customer for an out-for-delivery order.
/// Mirrors the rider app's map: dark style, a glide-animated rotating rider
/// marker, and a real road-following route instead of a straight line.
class RiderMapWidget extends StatefulWidget {
  const RiderMapWidget({
    super.key,
    required this.order,
    required this.outlets,
    this.riderLocation,
  });

  final OrderHistoryEntity order;
  final List<Outlet> outlets;
  final RiderLocationEntity? riderLocation;

  @override
  State<RiderMapWidget> createState() => _RiderMapWidgetState();
}

class _RiderMapWidgetState extends State<RiderMapWidget>
    with TickerProviderStateMixin {
  final RoutingService _routingService = getIt<RoutingService>();

  GoogleMapController? _mapController;
  String? _mapStyle;
  BitmapDescriptor? _riderIcon;

  LatLng? _riderPosition;
  double _riderBearing = 0;
  AnimationController? _riderAnimController;

  RouteResult? _routeResult;
  bool _routeStale = false;
  bool _isFetchingRoute = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMapStyle());
    unawaited(_loadRiderIcon());
    final location = widget.riderLocation;
    if (location != null) {
      _riderPosition = LatLng(location.latitude, location.longitude);
    }
    unawaited(_refreshRoute());
  }

  @override
  void didUpdateWidget(covariant RiderMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLocation = oldWidget.riderLocation;
    final newLocation = widget.riderLocation;
    if (newLocation != null &&
        (oldLocation == null ||
            oldLocation.latitude != newLocation.latitude ||
            oldLocation.longitude != newLocation.longitude)) {
      _animateRiderTo(LatLng(newLocation.latitude, newLocation.longitude));
      unawaited(_refreshRoute());
    }
  }

  @override
  void dispose() {
    _riderAnimController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    final style = await MapStyle.dark();
    if (mounted) setState(() => _mapStyle = style);
  }

  Future<void> _loadRiderIcon() async {
    final icon = await RiderMarkerIcon.get();
    if (mounted) setState(() => _riderIcon = icon);
  }

  // Glides the marker between GPS fixes instead of snapping, and rotates it
  // to face the direction of travel.
  void _animateRiderTo(LatLng next) {
    final start = _riderPosition;
    if (start == null) {
      setState(() => _riderPosition = next);
      return;
    }
    if (start.latitude == next.latitude && start.longitude == next.longitude) {
      return;
    }

    final bearing = MapUtils.calculateBearing(start, next);
    _riderAnimController?.dispose();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final animation = LatLngTween(begin: start, end: next).animate(controller);
    animation.addListener(() {
      if (!mounted) return;
      setState(() {
        _riderPosition = animation.value;
        _riderBearing = bearing;
      });
    });
    _riderAnimController = controller;
    unawaited(controller.forward());
  }

  Future<void> _refreshRoute() async {
    final origin = _riderPosition;
    final destination = _destinationPoint ?? _kitchenPoints.firstOrNull;
    if (origin == null || destination == null || _isFetchingRoute) return;

    _isFetchingRoute = true;
    final result = await _routingService.getRoute(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    _isFetchingRoute = false;
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _routeResult = result;
        _routeStale = false;
      });
      if (_routeResult!.points.isNotEmpty) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            MapUtils.boundsFromPoints(_routeResult!.points),
            48.0,
          ),
        );
      }
    } else if (_routeResult != null) {
      setState(() => _routeStale = true);
    }
  }

  List<LatLng> get _kitchenPoints {
    final outletIds = widget.order.lineItems
        .map((item) => item.outletId)
        .toSet();
    return widget.outlets
        .where(
          (outlet) =>
              outletIds.contains(outlet.id) &&
              outlet.latitude != null &&
              outlet.longitude != null,
        )
        .map((outlet) => LatLng(outlet.latitude!, outlet.longitude!))
        .toList();
  }

  LatLng? get _destinationPoint {
    final lat = widget.order.deliveryLatitude;
    final lng = widget.order.deliveryLongitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final points = _routeResult?.points;
    if (points != null && points.isNotEmpty) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(MapUtils.boundsFromPoints(points), 48.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kitchenPoints = _kitchenPoints;
    final destination = _destinationPoint;
    final rider = _riderPosition;

    final points = [...kitchenPoints, ?destination, ?rider];

    if (points.isEmpty) {
      return Container(
        height: 220,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.rscPanel,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Waiting for location updates…',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    final markers = <Marker>{
      for (final point in kitchenPoints)
        Marker(
          markerId: MarkerId('kitchen_${point.latitude}_${point.longitude}'),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(title: '🏪 Kitchen'),
        ),
      if (destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: '📍 Delivery address'),
        ),
      if (rider != null)
        Marker(
          markerId: const MarkerId('rider'),
          position: rider,
          rotation: _riderBearing,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          icon:
              _riderIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: '🏍️ Your rider'),
          zIndexInt: 2,
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: GoogleMap(
          mapType: MapType.normal,
          style: _mapStyle,
          initialCameraPosition: CameraPosition(target: points.first, zoom: 14),
          markers: markers,
          polylines: {
            if (_routeResult != null && _routeResult!.points.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routeResult!.points,
                color: _routeStale
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.primary,
                width: 4,
                patterns: _routeStale
                    ? [PatternItem.dash(16), PatternItem.gap(8)]
                    : [],
              ),
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: _onMapCreated,
        ),
      ),
    );
  }
}
