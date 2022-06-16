import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class NuvizaTerminal extends Equatable implements Comparable<NuvizaTerminal> {
  final double lon;
  final String ward;
  final String village;
  final String timestamp;
  final int number;
  final int remaining;
  final double lat;
  final String address;
  final String name;
  final double distance;

  const NuvizaTerminal({
    required this.lon,
    required this.ward,
    required this.village,
    required this.timestamp,
    required this.number,
    required this.remaining,
    required this.lat,
    required this.address,
    required this.name,
    required this.distance,
  });

  LatLng get latLng => LatLng(lat, lon);

  @override
  List<Object?> get props => [
        lon,
        ward,
        village,
        timestamp,
        number,
        remaining,
        lat,
        address,
        name,
        distance,
      ];

  @override
  int compareTo(NuvizaTerminal other) {
    if (distance == other.distance) return 0;
    return distance < other.distance ? -1 : 1;
  }
}
