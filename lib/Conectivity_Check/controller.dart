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
      if (Get.isDialogOpen != true) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            // Prevents back button from closing it
            child: Scaffold(
              backgroundColor: Colors.black.withOpacity(0.8),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 80,
                        color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please check your internet connection.",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    else {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}