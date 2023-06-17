import 'package:permission_handler/permission_handler.dart';

//Request permission for notifications
Future<void> notificationPermission() async {
  var statusNotification = await Permission.notification.status;

  if (statusNotification.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    if (await Permission.notification.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    } else {
      await Permission.notification.request();
    }
  }
}

//Request permission for camera
Future<void> cameraPermission() async {
  // We didn't ask for permission yet or the permission has been denied before but not permanently.
  if (await Permission.camera.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.
    openAppSettings();
  } else {
    await Permission.camera.request();
  }
}

//Request permission for storage
Future<void> storagePermission() async {
  // We didn't ask for permission yet or the permission has been denied before but not permanently.
  if (await Permission.storage.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.
    openAppSettings();
  } else {
    await Permission.storage.request();
  }
}
