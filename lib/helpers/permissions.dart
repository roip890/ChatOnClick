
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Permissions {

  static void checkServiceStatus(BuildContext context, PermissionGroup permission) {
    PermissionHandler()
        .checkServiceStatus(permission)
        .then((ServiceStatus serviceStatus) {
      final SnackBar snackBar =
      SnackBar(content: Text(serviceStatus.toString()));

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  static Future<PermissionStatus> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
      await PermissionHandler().requestPermissions(permissions);

    return permissionRequestResult[permission];
  }

}
