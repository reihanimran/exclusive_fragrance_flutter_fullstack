import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription<ConnectivityResult>? _subscription;

  NetworkProvider() {
    init();
  }

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final oldStatus = _isOnline;
        _isOnline = result != ConnectivityResult.none;
        if (_isOnline != oldStatus) {
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Connectivity stream error: $error');
      },
    );

    // Initial check
    Connectivity().checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    }).catchError((error) {
      debugPrint('Connectivity check error: $error');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
