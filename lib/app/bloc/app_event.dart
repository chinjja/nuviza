part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppInitEvent extends AppEvent {
  const AppInitEvent();
}

class AppFetchEvent extends AppEvent {
  const AppFetchEvent();
}

class AppMoveMeEvent extends AppEvent {
  const AppMoveMeEvent();
}

class AppMoveEvent extends AppEvent {
  final LatLng center;

  const AppMoveEvent(this.center);

  @override
  List<Object> get props => [center];
}

class AppZoomInEvent extends AppEvent {
  const AppZoomInEvent();
}

class AppZoomOutEvent extends AppEvent {
  const AppZoomOutEvent();
}
