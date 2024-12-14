import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<PermissionResponse?> handlePermissions(
    InAppWebViewController webviewController,
    PermissionRequest permissionRequest) async {
  final resourceToPermission = {
    PermissionResourceType.MICROPHONE: Permission.microphone,
    PermissionResourceType.CAMERA: Permission.camera,
    PermissionResourceType.CAMERA_AND_MICROPHONE: [
      Permission.camera,
      Permission.microphone
    ],
    PermissionResourceType.GEOLOCATION: Permission.location,
  };
  List<PermissionResourceType> grantedResources = [];

  for (var resource in permissionRequest.resources) {
    final permissions = resourceToPermission[resource];
    if (permissions is Permission) {
      if (await permissions.request().isGranted) {
        grantedResources.add(resource);
      }
    } else if (permissions is List<Permission>) {
      final results = await Future.wait(permissions.map((p) => p.request()));
      if (results.every((result) => result.isGranted)) {
        grantedResources.add(resource);
      }
    }
  }

  if (grantedResources.isNotEmpty) {
    return PermissionResponse(
        action: PermissionResponseAction.GRANT, resources: grantedResources);
  }

  return PermissionResponse(
      action: PermissionResponseAction.DENY, resources: []);
}

final InAppWebViewSettings inAppWebViewSettings = InAppWebViewSettings(
    geolocationEnabled: true,
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    allowBackgroundAudioPlaying: true,
    allowContentAccess: true,
    allowFileAccess: true,
    cacheEnabled: true,
    domStorageEnabled: true,
    hardwareAcceleration: true,
    databaseEnabled: true,
    transparentBackground: true,
    safeBrowsingEnabled: true,
    isFraudulentWebsiteWarningEnabled: true);
