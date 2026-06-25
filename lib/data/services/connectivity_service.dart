import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction for network type checks (low-data WiFi gate).
abstract class ConnectivityService {
  Future<bool> isOnWifi();
}

/// Production implementation using connectivity_plus.
class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> isOnWifi() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}

/// Test/dev stub — always reports WiFi available.
class AlwaysWifiConnectivityService implements ConnectivityService {
  const AlwaysWifiConnectivityService();

  @override
  Future<bool> isOnWifi() async => true;
}

/// Test stub — simulates cellular-only connectivity.
class CellularOnlyConnectivityService implements ConnectivityService {
  const CellularOnlyConnectivityService();

  @override
  Future<bool> isOnWifi() async => false;
}
