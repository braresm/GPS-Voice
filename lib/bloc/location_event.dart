import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class StartLocationTracking extends LocationEvent {}

class StopLocationTracking extends LocationEvent {}

class UpdateLocation extends LocationEvent {
  final LatLng position;
  final double totalDistance;

  const UpdateLocation({
    required this.position,
    required this.totalDistance,
  });

  @override
  List<Object?> get props => [position, totalDistance];
} 