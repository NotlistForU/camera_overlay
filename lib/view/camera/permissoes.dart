import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraAndLocationPermissions() async {
  // 1. pedir permissão de câmera
  final cameraStatus = await Permission.camera.status;
  if (!cameraStatus.isGranted) {
    final result = await Permission.camera.request();
    if (!result.isGranted) {
      if (result.isPermanentlyDenied) {
        // usuário bloqueou permanentemente: sugerir abrir configurações
        return false;
      }
      return false;
    }
  }

  // 2. pedir permissão de localização (quando em uso)
  final locStatus = await Permission.locationWhenInUse.status;
  if (!locStatus.isGranted) {
    final result = await Permission.locationWhenInUse.request();
    if (!result.isGranted) {
      if (result.isPermanentlyDenied) {
        return false;
      }
      return false;
    }
  }

  // 3. checar se o serviço de localização está ativo (Geolocator)
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // serviço de localização desativado no dispositivo
    return false;
  }

  return true; // ambas permissões concedidas e serviço ativo
}
