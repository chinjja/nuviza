part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class InitAppEvent extends AppEvent {
  const InitAppEvent();
}

class FetchAppEvent extends AppEvent {
  const FetchAppEvent();
}

class MyLocationAppEvent extends AppEvent {
  const MyLocationAppEvent();
}

class CameraAppEvent extends AppEvent {
  final LatLng point;
  final double? zoom;

  const CameraAppEvent({required this.point, this.zoom});

  @override
  List<Object?> get props => [point, zoom];
}

class ShowTerminalAppEvent extends AppEvent {
  final NuvizaTerminal terminal;
  const ShowTerminalAppEvent(this.terminal);

  @override
  List<Object?> get props => [terminal];
}

class ZoomAppEvent extends AppEvent {
  final double zoom;

  const ZoomAppEvent(this.zoom);

  @override
  List<Object?> get props => [zoom];
}
