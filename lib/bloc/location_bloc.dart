import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_event.dart';
import 'location_state.dart';
import '../models/location_model.dart';
import '../services/platform_tts.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;
  LatLng? _lastPosition;
  double _totalDistance = 0;
  double _lastSpokenDistance = 0;

  LocationBloc() : super(LocationInitial()) {
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<UpdateLocation>(_onUpdateLocation);
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await PlatformTts.initialize();
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const LocationError(message: 'Location permissions are denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const LocationError(
            message: 'Location permissions are permanently denied'));
        return;
      }

      // Reset tracking variables
      _lastPosition = null;
      _totalDistance = 0;
      _lastSpokenDistance = 0;

      // Start location updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        final newPosition = LatLng(position.latitude, position.longitude);
        
        if (_lastPosition != null) {
          _totalDistance += Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );
        }

        _lastPosition = newPosition;
        add(UpdateLocation(
          position: newPosition,
          totalDistance: _totalDistance,
        ));
      });
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }

  void _onStopLocationTracking(
    StopLocationTracking event,
    Emitter<LocationState> emit,
  ) {
    _positionStreamSubscription?.cancel();
    _lastPosition = null;
    _totalDistance = 0;
    _lastSpokenDistance = 0;
    PlatformTts.stop();
    emit(LocationInitial());
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    final location = LocationModel(
      position: event.position,
      totalDistance: event.totalDistance,
      timestamp: DateTime.now(),
    );

    emit(LocationTracking(location: location));

    // Calculate the next 5-meter interval
    final nextInterval = (_lastSpokenDistance ~/ 5 + 1) * 5.0;
    
    // Speak when we've reached or passed the next 5-meter interval
    if (event.totalDistance >= nextInterval) {
      await PlatformTts.speak(
        'You have traveled ${nextInterval.toInt()} meters',
      );
      _lastSpokenDistance = nextInterval;
    }
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    PlatformTts.stop();
    return super.close();
  }
} 