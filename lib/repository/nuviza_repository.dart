import 'package:nuviza/provider/geo_api.dart';
import 'package:nuviza/provider/nuviza_api.dart';
import 'package:nuviza/repository/nuviza_terminal.dart';

class NuvizaRepository {
  final NuvizaApi nuviza;
  final GeoApi geo;

  NuvizaRepository({NuvizaApi? nuviza, GeoApi? geo})
      : nuviza = nuviza ?? NuvizaApi(),
        geo = geo ?? GeoApi();

  Future<List<NuvizaTerminal>> fetchTerminals() async {
    final data = await nuviza.get(perPage: 1000);
    final location = await geo.location;
    final list = data.data.map((e) {
      final dist = geo.distance(location.latLng, e.latLng);
      return NuvizaTerminal(
        address: e.address,
        lat: e.lat,
        lon: e.lon,
        name: e.name,
        number: e.number,
        remaining: e.remaining,
        timestamp: e.timestamp,
        village: e.village,
        ward: e.ward,
        distance: dist,
      );
    }).toList();
    list.sort();
    return list;
  }

  Future<Location> fetchLocation() => geo.location;

  Stream<Location> get onLocation => geo.onLocation;
}
