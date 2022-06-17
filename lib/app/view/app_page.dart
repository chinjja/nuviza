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
          AppBloc(context.read<NuvizaRepository>())..add(const InitAppEvent()),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(tertiary: Colors.blue),
        ),
        home: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppLoaded) {
            return const MapView();
          } else {
            return const LoadingView();
          }
        },
      ),
      drawer: const Drawer(
        child: DrawerView(),
      ),
    );
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
  void initState() {
    super.initState();
    controller.mapEventStream.listen((event) {
      context.read<AppBloc>().add(ZoomAppEvent(event.zoom));
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppCameraChanged) {
          controller.move(state.point, state.zoom ?? controller.zoom);
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
                  zoom: AppBloc.defaultZoom,
                  minZoom: 1.0,
                  maxZoom: 18.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: state.data
                        .map((e) => _terminalMarker(
                              e,
                              state.showInfomation,
                              state.showRemaining,
                            ))
                        .toList(),
                  ),
                  CircleLayerOptions(circles: [
                    CircleMarker(
                      point: state.location.latLng,
                      radius: 8,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    CircleMarker(
                      point: state.location.latLng,
                      radius: state.location.accuracy,
                      color:
                          Theme.of(context).colorScheme.tertiary.withAlpha(50),
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

  Marker _terminalMarker(
      NuvizaTerminal terminal, bool showInfomation, bool showRemaining) {
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
            if (showRemaining)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.background.withAlpha(140),
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  children: [
                    if (showInfomation)
                      Text(terminal.name, overflow: TextOverflow.ellipsis),
                    if (showInfomation)
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
          onPressed: () => bloc.add(const FetchAppEvent()),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => bloc.add(const MyLocationAppEvent()),
          child: const Icon(Icons.my_location),
        ),
      ],
    );
  }
}

class DrawerView extends StatelessWidget {
  const DrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).viewPadding.top;
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '누비자 정류장',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state is AppLoaded) {
                  return ListView.builder(
                    itemCount: state.data.length,
                    itemBuilder: (context, index) {
                      final terminal = state.data[index];
                      return ListTile(
                        title: Text(terminal.name),
                        subtitle: Text('보관대수: ${terminal.remaining}'),
                        trailing:
                            Text('${terminal.distance.toStringAsFixed(1)}m'),
                        onTap: () {
                          context
                              .read<AppBloc>()
                              .add(ShowTerminalAppEvent(terminal));
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
