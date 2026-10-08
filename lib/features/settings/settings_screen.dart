import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/gemini_ai_service.dart';
import '../../core/services/mock_trading_service.dart';
import '../../core/services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showApiKeyDialog(BuildContext context, GeminiAiService geminiService, AuthService authService) {
    final controller = TextEditingController(text: geminiService.apiKey ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Row(
          children: const [
            Icon(Icons.key, color: AppTheme.primaryCyan),
            SizedBox(width: 8),
            Text('Configure Gemini API Key', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API key to enable live AI market analysis and real-time prompt generation.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'AIzaSy...',
                labelText: 'Gemini API Key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan, foregroundColor: AppTheme.backgroundDark),
            onPressed: () {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                geminiService.setApiKey(key);
                authService.saveApiKeys(geminiKey: key);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Key'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final authService = Provider.of<AuthService>(context);
    final geminiService = Provider.of<GeminiAiService>(context);
    final notifService = Provider.of<NotificationService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Card
          if (user != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryCyan.withOpacity(0.2),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.lossRed),
                      tooltip: 'Logout',
                      onPressed: () => authService.logout(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          const Text('Cloud & Backend Services', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_fire_department, color: AppTheme.warningOrange),
                  title: const Text('Firebase Auth & Firestore'),
                  subtitle: Text(authService.isFirebaseInitialized
                      ? 'Firebase Backend Active & Synchronized'
                      : 'Firebase SDK Ready (Add google-services.json)'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: authService.isFirebaseInitialized
                          ? AppTheme.profitGreen.withOpacity(0.2)
                          : AppTheme.primaryCyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      authService.isFirebaseInitialized ? 'Active' : 'Ready',
                      style: TextStyle(
                        color: authService.isFirebaseInitialized ? AppTheme.profitGreen : AppTheme.primaryCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(color: AppTheme.borderColor, height: 1),
                ListTile(
                  leading: const Icon(Icons.psychology, color: AppTheme.primaryCyan),
                  title: const Text('Google Gemini AI Key'),
                  subtitle: Text(geminiService.apiKey != null && geminiService.apiKey!.isNotEmpty
                      ? 'Key Configured & Active'
                      : 'Tap to configure Gemini API Key'),
                  trailing: Icon(
                    geminiService.apiKey != null && geminiService.apiKey!.isNotEmpty ? Icons.check_circle : Icons.add_circle_outline,
                    color: geminiService.apiKey != null && geminiService.apiKey!.isNotEmpty ? AppTheme.profitGreen : AppTheme.primaryCyan,
                  ),
                  onTap: () => _showApiKeyDialog(context, geminiService, authService),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Push Notifications & Alerts', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('AI Signal Notifications'),
                  subtitle: const Text('Push alerts when high-confidence signals generate'),
                  activeThumbColor: AppTheme.primaryCyan,
                  value: notifService.signalAlertsEnabled,
                  onChanged: (val) => notifService.toggleSignalAlerts(val),
                ),
                const Divider(color: AppTheme.borderColor, height: 1),
                SwitchListTile(
                  title: const Text('Price Target & Stop-Loss Alerts'),
                  subtitle: const Text('Notify when position approaches TP or SL'),
                  activeThumbColor: AppTheme.primaryCyan,
                  value: notifService.priceTargetAlertsEnabled,
                  onChanged: (val) => notifService.togglePriceTargetAlerts(val),
                ),
                const Divider(color: AppTheme.borderColor, height: 1),
                SwitchListTile(
                  title: const Text('Risk Management Alerts'),
                  subtitle: const Text('Alert on high volatility and margin limits'),
                  activeThumbColor: AppTheme.primaryCyan,
                  value: notifService.riskAlertsEnabled,
                  onChanged: (val) => notifService.toggleRiskAlerts(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Trading Environment', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              title: const Text('Paper Trading Simulation Mode'),
              subtitle: const Text('Trade with virtual funds before using live APIs'),
              activeThumbColor: AppTheme.primaryCyan,
              value: tradingService.portfolio.isPaperTrading,
              onChanged: (val) {
                tradingService.togglePaperTrading();
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('Security & Biometrics', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              title: const Text('Biometric / Face ID Unlock'),
              subtitle: const Text('Require biometric authentication on launch'),
              activeThumbColor: AppTheme.primaryCyan,
              value: user?.biometricEnabled ?? false,
              onChanged: (val) {
                authService.toggleBiometric(val);
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('Exchange Connections', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_bitcoin, color: AppTheme.primaryCyan),
                  title: const Text('Binance Futures / Spot'),
                  subtitle: const Text('Connected via WebSocket & REST API'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.profitGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Connected', style: TextStyle(color: AppTheme.profitGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button at bottom
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => authService.logout(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lossRed,
                side: const BorderSide(color: AppTheme.lossRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT TERMINAL', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
