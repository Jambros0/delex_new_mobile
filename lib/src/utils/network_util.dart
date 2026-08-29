import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class NetworkUtils {
  static final NetworkUtils _instance = NetworkUtils._internal();
  factory NetworkUtils() => _instance;
  NetworkUtils._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isNetworkAvailable = false;

  Future<void> init() async {
    _isNetworkAvailable = await _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((status) async {
      _isNetworkAvailable = await _checkConnectivity();
    });
  }

  bool get isNetworkAvailable => _isNetworkAvailable;

  Future<bool> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (!result.contains(ConnectivityResult.none)) {
      if (kIsWeb) {
        return true;
      }
      try {
        final internetCheck = await InternetAddress.lookup('example.com');
        return internetCheck.isNotEmpty && internetCheck[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
