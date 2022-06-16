import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nuviza/app/bloc/app_bloc.dart';
import 'package:nuviza/repository/nuviza_repository.dart';
import 'package:nuviza/repository/nuviza_terminal.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AppBloc(context.read<NuvizaRepository>())..add(const AppInitEvent()),
      child: const MaterialApp(home: AppView()),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Flutter Map")),
        body: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppLoaded) {
              return const MapView();
            } else {
              return const LoadingView();
            }
          },
        ));
  }
}

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final controller = MapController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppMoved) {
          controller.move(state.center, controller.zoom);
        }
      },
      builder: (context, state) {
        if (state is AppLoaded) {
          return Stack(
            children: [
              FlutterMap(
                mapController: controller,
                options: MapOptions(
                  center: state.location.latLng,
                  zoom: 16.0,
                  maxZoom: 18.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: state.data.map((e) => _terminalMarker(e)).toList(),
                  ),
                  CircleLayerOptions(circles: [
                    CircleMarker(
                      point: state.location.latLng,
                      radius: 8,
                      color: Colors.blue,
                    ),
                    CircleMarker(
                      point: state.location.latLng,
                      radius: state.location.accuracy,
                      color: Colors.blue.withAlpha(50),
                      useRadiusInMeter: true,
                    ),
                  ]),
                ],
                nonRotatedChildren: const [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ControlView(),
                    ),
                  ),
                ],
              ),
              if (state.status == AppStatus.loading) const LoadingView(),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Marker _terminalMarker(NuvizaTerminal terminal) {
    return Marker(
      width: 150,
      height: 100,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      point: terminal.latLng,
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white.withAlpha(127),
              child: Column(
                children: [
                  Text(terminal.name, overflow: TextOverflow.ellipsis),
                  Text('${terminal.distance.toStringAsFixed(1)}m'),
                  Text('보관대수: ${terminal.remaining}'),
                ],
              ),
            ),
            const Icon(
              Icons.push_pin,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ControlView extends StatelessWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => bloc.add(const AppFetchEvent()),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => bloc.add(const AppMoveMeEvent()),
          child: const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
