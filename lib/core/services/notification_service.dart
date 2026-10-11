import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _signalAlertsEnabled = true;
  bool _priceTargetAlertsEnabled = true;
  bool _riskAlertsEnabled = true;
  String? _fcmToken;

  final List<NotificationLogItem> _notificationHistory = [];

  bool get signalAlertsEnabled => _signalAlertsEnabled;
  bool get priceTargetAlertsEnabled => _priceTargetAlertsEnabled;
  bool get riskAlertsEnabled => _riskAlertsEnabled;
  String? get fcmToken => _fcmToken;
  List<NotificationLogItem> get notificationHistory => _notificationHistory;

  NotificationService() {
    _loadPreferences();
    _initNotifications();
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
        debugPrint('Error loading notification preferences: $e');
      }
    }
  }

  Future<void> _initNotifications() async {
    try {
      // 1. Initialize Local Device Push Notifications
      const androidInit = AndroidInitializationSettings('@drawable/ic_launcher_sword');
      const initSettings = InitializationSettings(android: androidInit);

      await _localNotifications.initialize(initSettings);

      // 2. Initialize Firebase Cloud Messaging (FCM)
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _fcmToken = await messaging.getToken();
        notifyListeners();

        // Handle FCM Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          if (notification != null) {
            sendPushNotification(
              notification.title ?? 'Zulfiqar AI Alert',
              notification.body ?? 'New market signal update received',
              'Signal',
            );
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Notification initialization fallback: $e');
      }
    }
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

  Future<void> sendPushNotification(String title, String body, String category) async {
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

    try {
      const androidDetails = AndroidNotificationDetails(
        'zulfiqar_signals_channel',
        'Zulfiqar Signals & Alerts',
        channelDescription: 'Real-time push notifications for trading signals and price alerts',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF00E5FF),
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error showing local notification: $e');
      }
    }
  }
}
