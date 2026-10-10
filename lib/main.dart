import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/gemini_ai_service.dart';
import 'core/services/market_api_service.dart';
import 'core/services/mock_trading_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/signal_detector_service.dart';
import 'core/widgets/sword_logo.dart';
import 'features/auth/login_screen.dart';
import 'features/shell_screen.dart';
import 'overlay_bubble.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TradeJarvisApp());
}

// IMPORTANT: Entry point required for System Floating Overlay Window outside the app
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayBubble(),
  ));
}

class TradeJarvisApp extends StatelessWidget {
  const TradeJarvisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MarketApiService()),
        ChangeNotifierProvider(create: (_) => GeminiAiService()),
        ChangeNotifierProvider(create: (_) => SignalDetectorService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProxyProvider<MarketApiService, MockTradingService>(
          create: (_) => MockTradingService(),
          update: (_, marketApi, tradingService) {
            final service = tradingService ?? MockTradingService();
            if (marketApi.liveTickers.isNotEmpty) {
              service.updateWithLiveTickers(marketApi.liveTickers);
            }
            return service;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Zulfiqar TradeJARVIS AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const TradeJarvisRoot(),
      ),
    );
  }
}

class TradeJarvisRoot extends StatelessWidget {
  const TradeJarvisRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SwordLogo(size: 80),
                  SizedBox(height: 24),
                  CircularProgressIndicator(color: AppTheme.primaryCyan),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Zulfiqar AI Core...',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }

        return const ShellScreen();
      },
    );
  }
}
