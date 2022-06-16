import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class NuvizaApi {
  static const baseUrl = 'https://api.odcloud.kr/api';
  static const apiKey =
      '/+EYoLYznXVfrM4lp3a5EgUC4WoiQ33SucrVmXhk1CMjmEah0crffOrXQf9pthDNpSJZm2okC0loDLvGxagRig==';

  final Dio dio;

  NuvizaApi([Dio? dio])
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {
                'Authorization': 'Infuser $apiKey',
              },
            ));

  Future<Nuviza> get({int? page, int? perPage}) async {
    final res = await dio.get(
      '/15000545/v1/uddi:lgt2dy2p-wwh7-jrxr-o85n-fxxskri7gpjs_201912181628',
      queryParameters: {
        'page': page,
        'perPage': perPage,
      },
    );
    return Nuviza.fromJson(res.data);
  }
}

class Terminal extends Equatable {
  final double lon;
  final String ward;
  final String village;
  final String timestamp;
  final int number;
  final int remaining;
  final double lat;
  final String address;
  final String name;

  const Terminal({
    required this.lon,
    required this.ward,
    required this.village,
    required this.timestamp,
    required this.number,
    required this.remaining,
    required this.lat,
    required this.address,
    required this.name,
  });

  LatLng get latLng => LatLng(lat, lon);

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      lon: double.parse(json['경도']),
      ward: json['구'],
      village: json['동'],
      timestamp: json['등록일자'],
      number: json['번호'],
      remaining: json['보관대수'],
      lat: double.parse(json['위도']),
      address: json['주소'],
      name: json['터미널명'],
    );
  }

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
      ];
}

class Nuviza extends Equatable {
  final int currentCount;
  final int matchCount;
  final int page;
  final int perPage;
  final List<Terminal> data;

  const Nuviza({
    required this.currentCount,
    required this.matchCount,
    required this.page,
    required this.perPage,
    required this.data,
  });

  factory Nuviza.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> data = List.castFrom(json['data']);
    return Nuviza(
      currentCount: json['currentCount'],
      matchCount: json['matchCount'],
      page: json['page'],
      perPage: json['perPage'],
      data: data.map((e) => Terminal.fromJson(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [currentCount, matchCount, page, perPage, data];
}
