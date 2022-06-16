part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

enum AppStatus {
  initial,
  loading,
  success,
  failure,
}

class AppLoaded extends AppState {
  final AppStatus status;
  final List<NuvizaTerminal> data;
  final Location location;
  const AppLoaded({
    required this.status,
    required this.data,
    required this.location,
  });

  AppLoaded copyWith(
      {AppStatus? status, List<NuvizaTerminal>? data, Location? location}) {
    return AppLoaded(
      status: status ?? this.status,
      data: data ?? this.data,
      location: location ?? this.location,
    );
  }

  @override
  List<Object> get props => [status, data, location];
}

class AppMoved extends AppState {
  final LatLng center;

  const AppMoved(this.center);

  @override
  List<Object> get props => [center];
}
