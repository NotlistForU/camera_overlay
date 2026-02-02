import 'package:geolocator/geolocator.dart';
import '../model/localizacao.dart' as model;

Stream<model.Localizacao> emTempoReal() {
  return Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).map(
    (pos) => model.Localizacao(
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
    ),
  );
}
