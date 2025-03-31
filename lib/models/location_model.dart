import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel extends Equatable {
  final LatLng position;
  final double totalDistance;
  final DateTime timestamp;

  const LocationModel({
    required this.position,
    required this.totalDistance,
    required this.timestamp,
  });

  LocationModel copyWith({
    LatLng? position,
    double? totalDistance,
    DateTime? timestamp,
  }) {
    return LocationModel(
      position: position ?? this.position,
      totalDistance: totalDistance ?? this.totalDistance,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [position, totalDistance, timestamp];
} 