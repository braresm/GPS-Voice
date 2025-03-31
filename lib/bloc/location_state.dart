import 'package:equatable/equatable.dart';
import '../models/location_model.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationTracking extends LocationState {
  final LocationModel location;

  const LocationTracking({required this.location});

  @override
  List<Object?> get props => [location];
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
} 