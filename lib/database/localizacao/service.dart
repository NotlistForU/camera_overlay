import 'package:geolocator/geolocator.dart';
import 'package:sipam_foto/model/localizacao.dart' as model;

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
