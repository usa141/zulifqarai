import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneToolsService extends ChangeNotifier {
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  String _networkStatus = 'Connected';

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  String get networkStatus => _networkStatus;

  PhoneToolsService() {
    _initDeviceStats();
  }

  Future<void> _initDeviceStats() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;

      _battery.onBatteryStateChanged.listen((state) {
        _batteryState = state;
        notifyListeners();
      });

      final connectivityResults = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResults);

      _connectivity.onConnectivityChanged.listen((results) {
        _updateConnectivityStatus(results);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing device tools: $e');
      }
    }
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      _networkStatus = 'Wi-Fi Connected';
    } else if (results.contains(ConnectivityResult.mobile)) {
      _networkStatus = 'Cellular Data Connected';
    } else if (results.contains(ConnectivityResult.none)) {
      _networkStatus = 'Offline';
    } else {
      _networkStatus = 'Connected';
    }
    notifyListeners();
  }

  Future<void> refreshDeviceStats() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  Future<bool> launchWebUrl(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching web URL: $e');
      }
    }
    return false;
  }

  Future<bool> launchGoogleSearch(String query) async {
    final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    return await launchWebUrl(searchUrl);
  }

  Future<bool> openDialer(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching dialer: $e');
      }
    }
    return false;
  }

  Future<bool> openSystemSettings(String action) async {
    try {
      final uri = Uri.parse('action:$action');
      return await launchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}
