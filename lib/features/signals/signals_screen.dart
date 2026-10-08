import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/services/market_api_service.dart';
import '../../core/services/signal_detector_service.dart';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signalDetector = Provider.of<SignalDetectorService>(context);
    final marketService = Provider.of<MarketApiService>(context);
    final signals = signalDetector.autoSignals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Signal Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: signalDetector.isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCyan),
                  )
                : const Icon(Icons.autorenew, color: AppTheme.primaryCyan),
            tooltip: 'Run Auto Market Scanner',
            onPressed: signalDetector.isScanning
                ? null
                : () {
                    signalDetector.runAutoMarketScan(marketService.liveTickers);
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: AppTheme.primaryCyan, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Autonomous Technical Scanner Active',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: signalDetector.isScanning
                      ? null
                      : () {
                          signalDetector.runAutoMarketScan(marketService.liveTickers);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    foregroundColor: AppTheme.backgroundDark,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  icon: const Icon(Icons.radar, size: 16),
                  label: const Text('AUTO SCAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: signals.length,
              itemBuilder: (context, index) {
                final sig = signals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(sig.asset, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: sig.direction == 'LONG'
                                      ? AppTheme.profitGreen.withOpacity(0.2)
                                      : AppTheme.lossRed.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sig.direction,
                                  style: TextStyle(
                                    color: sig.direction == 'LONG' ? AppTheme.profitGreen : AppTheme.lossRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${sig.confidence}% Confidence',
                              style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Strategy: ${sig.strategy}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const Divider(color: AppTheme.borderColor, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Entry Zone', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('\$${sig.entryMin} - \$${sig.entryMax}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Stop Loss', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('\$${sig.stopLoss}', style: const TextStyle(color: AppTheme.lossRed, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Take-Profit Targets:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        sig.takeProfits.map((tp) => '\$$tp').join('  •  '),
                        style: const TextStyle(color: AppTheme.profitGreen, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sig.explanation,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
