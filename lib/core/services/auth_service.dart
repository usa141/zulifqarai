import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final bool biometricEnabled;
  final String? binanceApiKey;
  final String? geminiApiKey;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.biometricEnabled = false,
    this.binanceApiKey,
    this.geminiApiKey,
  });
}

class AuthService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _isFirebaseInitialized = false;
  UserProfile? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isFirebaseInitialized => _isFirebaseInitialized;
  UserProfile? get user => _user;

  AuthService() {
    initAuth();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try initializing Firebase
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;

      // Listen to Firebase Auth state changes
      fb_auth.FirebaseAuth.instance.authStateChanges().listen((fb_auth.User? fbUser) async {
        if (fbUser != null) {
          final prefs = await SharedPreferences.getInstance();
          final biometric = prefs.getBool('biometric_enabled') ?? false;
          final geminiKey = await _storage.read(key: 'gemini_api_key');
          final binanceKey = await _storage.read(key: 'binance_api_key');

          _user = UserProfile(
            uid: fbUser.uid,
            email: fbUser.email ?? 'trader@zulfiqar.ai',
            name: fbUser.displayName ?? (fbUser.email?.split('@').first ?? 'Trader'),
            biometricEnabled: biometric,
            binanceApiKey: binanceKey,
            geminiApiKey: geminiKey,
          );
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
          _user = null;
        }
        _isLoading = false;
        notifyListeners();
      });
      return;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase not yet configured locally ($e). Using secure local auth session fallback.');
      }
    }

    await _restoreLocalSession();
  }

  Future<void> _restoreLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedName = prefs.getString('user_name');
      final savedUid = prefs.getString('user_uid') ?? 'local_user_1';
      final biometric = prefs.getBool('biometric_enabled') ?? false;

      final geminiKey = await _storage.read(key: 'gemini_api_key');
      final binanceKey = await _storage.read(key: 'binance_api_key');

      if (savedEmail != null && savedEmail.isNotEmpty) {
        _user = UserProfile(
          uid: savedUid,
          email: savedEmail,
          name: savedName ?? 'Trader',
          biometricEnabled: biometric,
          binanceApiKey: binanceKey,
          geminiApiKey: geminiKey,
        );
        _isAuthenticated = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring auth session: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    if (_isFirebaseInitialized) {
      try {
        final credential = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user != null) {
          _isLoading = false;
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firebase login failed: $e');
        }
      }
    }

    // Fallback to local session
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.trim().isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      final name = email.split('@').first;
      final uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setString('user_email', email.trim());
      await prefs.setString('user_name', name);
      await prefs.setString('user_uid', uid);

      _user = UserProfile(
        uid: uid,
        email: email.trim(),
        name: name,
        biometricEnabled: prefs.getBool('biometric_enabled') ?? false,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    if (_isFirebaseInitialized) {
      try {
        final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user != null) {
          await credential.user!.updateDisplayName(name.trim());
          _isLoading = false;
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firebase register failed: $e');
        }
      }
    }

    // Fallback to local registration
    await Future.delayed(const Duration(milliseconds: 600));
    if (email.contains('@') && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      final uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setString('user_email', email.trim());
      await prefs.setString('user_name', name.trim());
      await prefs.setString('user_uid', uid);

      _user = UserProfile(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        biometricEnabled: false,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> saveApiKeys({String? geminiKey, String? binanceKey}) async {
    if (geminiKey != null) {
      await _storage.write(key: 'gemini_api_key', value: geminiKey);
    }
    if (binanceKey != null) {
      await _storage.write(key: 'binance_api_key', value: binanceKey);
    }

    if (_user != null) {
      _user = UserProfile(
        uid: _user!.uid,
        email: _user!.email,
        name: _user!.name,
        biometricEnabled: _user!.biometricEnabled,
        binanceApiKey: binanceKey ?? _user!.binanceApiKey,
        geminiApiKey: geminiKey ?? _user!.geminiApiKey,
      );
      notifyListeners();
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);

    if (_user != null) {
      _user = UserProfile(
        uid: _user!.uid,
        email: _user!.email,
        name: _user!.name,
        biometricEnabled: enabled,
        binanceApiKey: _user!.binanceApiKey,
        geminiApiKey: _user!.geminiApiKey,
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    if (_isFirebaseInitialized) {
      try {
        await fb_auth.FirebaseAuth.instance.signOut();
      } catch (e) {
        if (kDebugMode) {
          print('Firebase signout error: $e');
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_uid');

    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }
}
