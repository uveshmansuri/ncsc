import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChanged);
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      if (Get.overlayContext == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.overlayContext != null) {
            Get.rawSnackbar(
              title: 'No Internet',
              message: 'Connect to the Internet',
              isDismissible: true,
              duration: const Duration(days: 365),
              shouldIconPulse: true,
              icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
            );
          }
        });
      }
      else {
        Get.rawSnackbar(
          title: 'No Internet',
          message: 'Connect to the Internet',
          isDismissible: true,
          duration: const Duration(days: 365),
          shouldIconPulse: true,
          icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        );
      }
    }
    else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}