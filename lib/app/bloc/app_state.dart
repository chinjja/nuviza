part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
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
  final bool showInfomation;
  final bool showRemaining;

  const AppLoaded({
    required this.status,
    required this.data,
    required this.location,
    this.showInfomation = true,
    this.showRemaining = true,
  });

  AppLoaded copyWith({
    AppStatus? status,
    List<NuvizaTerminal>? data,
    Location? location,
    bool? showInfomation,
    bool? showRemaining,
  }) {
    return AppLoaded(
      status: status ?? this.status,
      data: data ?? this.data,
      location: location ?? this.location,
      showInfomation: showInfomation ?? this.showInfomation,
      showRemaining: showRemaining ?? this.showRemaining,
    );
  }

  @override
  List<Object> get props => [
        status,
        data,
        location,
        showInfomation,
        showRemaining,
      ];
}

class AppCameraChanged extends AppState {
  final LatLng point;
  final double? zoom;

  const AppCameraChanged({
    required this.point,
    this.zoom,
  });

  @override
  List<Object?> get props => [point, zoom];
}

class AppFailed extends AppState {
  final dynamic error;
  const AppFailed(this.error);

  @override
  List<Object?> get props => [error];
}
