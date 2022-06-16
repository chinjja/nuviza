import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuviza/provider/geo_api.dart';
import 'package:nuviza/repository/nuviza_repository.dart';
import 'package:nuviza/repository/nuviza_terminal.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final NuvizaRepository repo;
  AppBloc(this.repo) : super(AppInitial()) {
    on<AppInitEvent>((event, emit) async {
      final data = await repo.terminals;
      final location = await repo.location;
      emit(AppLoaded(
        status: AppStatus.success,
        data: data,
        location: location,
      ));
      await emit.forEach<Location>(repo.onLocation, onData: (data) {
        final state = this.state;
        if (state is AppLoaded) {
          return state.copyWith(location: data);
        }
        return state;
      });
    });

    on<AppFetchEvent>((event, emit) async {
      final state = this.state;
      if (state is AppLoaded) {
        emit(state.copyWith(
          status: AppStatus.loading,
        ));
        final data = await repo.terminals;
        emit(state.copyWith(
          status: AppStatus.success,
          data: data,
        ));
      }
    });

    on<AppMoveMeEvent>((event, emit) async {
      final location = await repo.location;
      add(AppMoveEvent(location.latLng));
    });

    on<AppMoveEvent>((event, emit) {
      final state = this.state;
      if (state is AppLoaded) {
        emit(AppMoved(event.center));
        emit(state);
      }
    });
  }
}
