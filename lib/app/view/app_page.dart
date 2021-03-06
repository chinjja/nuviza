import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          extensions: const [LocationTheme()],
        ),
        home: const AppView(),
      ),
    );
  }
}

class LocationTheme extends ThemeExtension<LocationTheme> {
  final Color location;

  const LocationTheme({this.location = Colors.blue});

  @override
  ThemeExtension<LocationTheme> copyWith() {
    return LocationTheme(location: location);
  }

  @override
  ThemeExtension<LocationTheme> lerp(
      ThemeExtension<LocationTheme>? other, double t) {
    if (other is! LocationTheme) return this;
    return LocationTheme(
        location: Color.lerp(location, other.location, t) ?? location);
  }
}

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
    final locationTheme = Theme.of(context).extension<LocationTheme>()!;
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppCameraChanged) {
          controller.moveAndRotate(
            state.point,
            state.zoom ?? controller.zoom,
            0,
          );
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
                      color: locationTheme.location,
                    ),
                    CircleMarker(
                      point: state.location.latLng,
                      radius: state.location.accuracy,
                      color: locationTheme.location.withAlpha(50),
                      useRadiusInMeter: true,
                    ),
                  ]),
                ],
                nonRotatedChildren: const [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ControlView(),
                      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final ts = TextStyle(color: colorScheme.onSurface);
    return Marker(
      width: 150,
      height: 100,
      rotate: true,
      rotateAlignment: Alignment.bottomCenter,
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
                  color: colorScheme.surface.withAlpha(160),
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  children: [
                    if (showInfomation)
                      Text(
                        terminal.name,
                        overflow: TextOverflow.ellipsis,
                        style: ts,
                      ),
                    if (showInfomation)
                      Text(
                        '${terminal.distance.toStringAsFixed(1)}m',
                        style: ts,
                      ),
                    Text(
                      '????????????: ${terminal.remaining}',
                      style: ts,
                    ),
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
        FloatingActionButton(
          onPressed: () => bloc.add(const FetchAppEvent()),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
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
    final viewPadding = MediaQuery.of(context).viewPadding;
    return Padding(
      padding: EdgeInsets.only(top: viewPadding.top),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.directions_bus),
                const SizedBox(width: 8),
                Text(
                  '????????? ?????????',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                if (state is AppLoaded) {
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: viewPadding.bottom),
                    itemCount: state.data.length,
                    itemBuilder: (context, index) {
                      final terminal = state.data[index];
                      return ListTile(
                        title: Text(terminal.name),
                        subtitle: Text('????????????: ${terminal.remaining}'),
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
