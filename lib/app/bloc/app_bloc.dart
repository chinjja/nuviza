import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuviza/provider/geo_api.dart';
import 'package:nuviza/repository/nuviza_repository.dart';
import 'package:nuviza/repository/nuviza_terminal.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  static const defaultZoom = 16.0;

  final NuvizaRepository repo;
  AppBloc(this.repo) : super(AppInitial()) {
    on<InitAppEvent>((event, emit) async {
      try {
        final location = await repo.fetchLocation();
        final data = await repo.fetchTerminals();
        emit(AppLoaded(
          status: AppStatus.success,
          data: data,
          location: location,
        ));
        add(const FetchAppEvent());
        await emit.forEach(
            repo.onLocation
                .throttleTime(const Duration(seconds: 5))
                .asyncMap((loc) async => Tuple2(
                      loc,
                      await repo.fetchTerminals(),
                    )), onData: (Tuple2<Location, List<NuvizaTerminal>> data) {
          final state = this.state;
          if (state is AppLoaded) {
            return state.copyWith(location: data.item1, data: data.item2);
          }
          return state;
        });
      } catch (e) {
        emit(AppFailed(e));
      }
    });

    on<FetchAppEvent>((event, emit) async {
      final state = this.state;
      if (state is AppLoaded) {
        emit(state.copyWith(status: AppStatus.loading));
        final data = await repo.fetchTerminals();
        emit(state.copyWith(status: AppStatus.success, data: data));
      }
    });

    on<MyLocationAppEvent>((event, emit) async {
      final state = this.state;
      if (state is AppLoaded) {
        final location = await repo.fetchLocation();
        emit(state.copyWith(status: AppStatus.loading));
        emit(AppCameraChanged(point: location.latLng, zoom: defaultZoom));
        emit(state.copyWith(status: AppStatus.success));
      }
    });

    on<CameraAppEvent>((event, emit) {
      final state = this.state;
      if (state is AppLoaded) {
        emit(AppCameraChanged(point: event.point, zoom: event.zoom));
        emit(state);
      }
    });

    on<ZoomAppEvent>((event, emit) {
      final state = this.state;
      if (state is AppLoaded) {
        emit(state.copyWith(
          showInfomation: event.zoom > 15.2,
          showRemaining: event.zoom > 14.2,
        ));
      }
    });

    on<ShowTerminalAppEvent>((event, emit) {
      add(CameraAppEvent(
        point: event.terminal.latLng,
        zoom: defaultZoom,
      ));
    });
  }
}
