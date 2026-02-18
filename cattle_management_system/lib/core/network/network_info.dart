import 'package:connectivity_plus/connectivity_plus.dart';

/// Network Info - Checks internet connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfoImpl(this.connectivity);
  
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnectedResult(result.first);
  }
  
  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((results) {
      return _isConnectedResult(results.first);
    });
  }
  
  bool _isConnectedResult(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }
}
