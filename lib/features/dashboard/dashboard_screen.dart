import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/services/mock_trading_service.dart';
import '../analysis/coin_analysis_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final portfolio = tradingService.portfolio;
    final assets = tradingService.assets;
    final signals = tradingService.signals;
    final news = tradingService.news;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: AppTheme.primaryCyan, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('TradeJARVIS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: portfolio.isPaperTrading ? AppTheme.warningOrange.withOpacity(0.2) : AppTheme.profitGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: portfolio.isPaperTrading ? AppTheme.warningOrange : AppTheme.profitGreen,
                  width: 1,
                ),
              ),
              child: Text(
                portfolio.isPaperTrading ? 'SIMULATION' : 'LIVE',
                style: TextStyle(
                  color: portfolio.isPaperTrading ? AppTheme.warningOrange : AppTheme.profitGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF131B2E), Color(0xFF1D2840)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PORTFOLIO VALUE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      Icon(Icons.visibility_outlined, color: AppTheme.textSecondary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${portfolio.totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.profitGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_upward, color: AppTheme.profitGreen, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '+\$${portfolio.dailyPnl.toStringAsFixed(2)} (+${portfolio.dailyPnlPercentage}%)',
                              style: const TextStyle(color: AppTheme.profitGreen, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('24h Profit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Balance', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('\$${portfolio.availableBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Open Positions', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          const Text('2 Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryCyan)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // JARVIS Quick Prompt Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: AppTheme.primaryCyan, size: 18),
                      SizedBox(width: 8),
                      Text('JARVIS AI COMMAND', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ask JARVIS (e.g. "Analyze BTC", "Find setups")',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      _buildQuickPromptChip(context, 'Analyze BTC'),
                      _buildQuickPromptChip(context, 'Why is ETH moving?'),
                      _buildQuickPromptChip(context, 'Find high-quality setups'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Top Signals Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Top Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(color: AppTheme.primaryCyan)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Signal Cards
            ...signals.map((sig) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
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
                          Text(sig.asset, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sig.direction == 'LONG' ? AppTheme.profitGreen.withOpacity(0.2) : AppTheme.lossRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sig.direction,
                              style: TextStyle(
                                color: sig.direction == 'LONG' ? AppTheme.profitGreen : AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${sig.confidence}% Confidence',
                          style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(sig.strategy, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Entry: \$${sig.entryMin} - \$${sig.entryMax}', style: const TextStyle(fontSize: 13)),
                      Text('Stop Loss: \$${sig.stopLoss}', style: const TextStyle(color: AppTheme.lossRed, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),

            // Watchlist Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Watchlist Markets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Markets', style: TextStyle(color: AppTheme.primaryCyan)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...assets.map((asset) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoinAnalysisScreen(asset: asset)),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.surfaceLight,
                          child: Text(asset.symbol.substring(0, 3), style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(asset.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${asset.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          '${asset.change24h >= 0 ? '+' : ''}${asset.change24h}%',
                          style: TextStyle(
                            color: asset.change24h >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),

            // Important News Section
            const Text('Market Intelligence & News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...news.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.source, style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(item.timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPromptChip(BuildContext context, String prompt) {
    return ActionChip(
      backgroundColor: AppTheme.surfaceLight,
      label: Text(prompt, style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 12)),
      onPressed: () {
        // Trigger quick AI query
      },
    );
  }
}
