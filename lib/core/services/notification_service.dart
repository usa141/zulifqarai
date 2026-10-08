import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationLogItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category; // 'Signal', 'PriceAlert', 'Risk'

  NotificationLogItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
  });
}

class NotificationService extends ChangeNotifier {
  bool _signalAlertsEnabled = true;
  bool _priceTargetAlertsEnabled = true;
  bool _riskAlertsEnabled = true;

  final List<NotificationLogItem> _notificationHistory = [];

  bool get signalAlertsEnabled => _signalAlertsEnabled;
  bool get priceTargetAlertsEnabled => _priceTargetAlertsEnabled;
  bool get riskAlertsEnabled => _riskAlertsEnabled;
  List<NotificationLogItem> get notificationHistory => _notificationHistory;

  NotificationService() {
    _loadPreferences();
    _initSampleHistory();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _signalAlertsEnabled = prefs.getBool('notif_signals') ?? true;
      _priceTargetAlertsEnabled = prefs.getBool('notif_targets') ?? true;
      _riskAlertsEnabled = prefs.getBool('notif_risk') ?? true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notification preferences: $e');
      }
    }
  }

  void _initSampleHistory() {
    _notificationHistory.addAll([
      NotificationLogItem(
        id: 'notif_1',
        title: '🎯 High-Confidence Signal Detected',
        body: 'BTC/USDT LONG signal generated with 88% confidence score. Target: \$93,500.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        category: 'Signal',
      ),
      NotificationLogItem(
        id: 'notif_2',
        title: '📈 Take-Profit Target Approaching',
        body: 'ETH/USDT position is within 1% of TP1 (\$3,450).',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        category: 'PriceAlert',
      ),
      NotificationLogItem(
        id: 'notif_3',
        title: '⚠️ Risk Management Notice',
        body: 'Daily portfolio P&L is +5.25%. Risk trailing stop-loss activated.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        category: 'Risk',
      ),
    ]);
  }

  Future<void> toggleSignalAlerts(bool enabled) async {
    _signalAlertsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_signals', enabled);
  }

  Future<void> togglePriceTargetAlerts(bool enabled) async {
    _priceTargetAlertsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_targets', enabled);
  }

  Future<void> toggleRiskAlerts(bool enabled) async {
    _riskAlertsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_risk', enabled);
  }

  void sendPushNotification(String title, String body, String category) {
    if ((category == 'Signal' && !_signalAlertsEnabled) ||
        (category == 'PriceAlert' && !_priceTargetAlertsEnabled) ||
        (category == 'Risk' && !_riskAlertsEnabled)) {
      return;
    }

    final item = NotificationLogItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      category: category,
    );

    _notificationHistory.insert(0, item);
    notifyListeners();
  }
}
