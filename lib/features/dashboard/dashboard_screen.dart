import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/services/market_api_service.dart';
import '../../core/services/mock_trading_service.dart';
import '../../core/widgets/sword_logo.dart';
import '../analysis/coin_analysis_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _quickCommandController = TextEditingController();

  @override
  void dispose() {
    _quickCommandController.dispose();
    super.dispose();
  }

  void _submitQuickCommand(String command, MockTradingService tradingService) {
    if (command.trim().isEmpty) return;

    tradingService.addChatMessage(
      command,
      "⚡ Zulfiqar AI Processing '$command'...\nLive Binance WebSocket feed confirms high volume liquidity sweeps. All neural indicators aligned.",
    );

    _quickCommandController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Command sent to JARVIS: "$command"'),
        backgroundColor: AppTheme.surfaceDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final marketService = Provider.of<MarketApiService>(context);

    final portfolio = tradingService.portfolio;
    final assets = tradingService.assets;
    final signals = tradingService.signals;
    final liveNews = marketService.liveNews.isNotEmpty ? marketService.liveNews : tradingService.news;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SwordLogo(size: 28),
            const SizedBox(width: 10),
            const Text('TradeJARVIS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: portfolio.isPaperTrading
                    ? AppTheme.warningOrange.withOpacity(0.2)
                    : AppTheme.profitGreen.withOpacity(0.2),
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
                    children: const [
                      Text('TOTAL PORTFOLIO VALUE',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
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
                          color: portfolio.dailyPnl >= 0 ? AppTheme.profitGreen.withOpacity(0.15) : AppTheme.lossRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              portfolio.dailyPnl >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              color: portfolio.dailyPnl >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${portfolio.dailyPnl >= 0 ? '+' : ''}\$${portfolio.dailyPnl.toStringAsFixed(2)} (${portfolio.dailyPnlPercentage.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                color: portfolio.dailyPnl >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Total Floating P&L', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
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
                          Text('\$${portfolio.availableBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Active Positions', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${tradingService.positions.length} Positions',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryCyan)),
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
                      SwordLogo(size: 18),
                      SizedBox(width: 8),
                      Text('ZULFIQAR JARVIS COMMAND',
                          style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _quickCommandController,
                    onSubmitted: (val) => _submitQuickCommand(val, tradingService),
                    decoration: InputDecoration(
                      hintText: 'Ask JARVIS (e.g. "Analyze BTC", "Find setups")',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                        onPressed: () => _submitQuickCommand(_quickCommandController.text, tradingService),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      _buildQuickPromptChip(context, 'Analyze Bitcoin BTC', tradingService),
                      _buildQuickPromptChip(context, 'Why is Ethereum ETH moving?', tradingService),
                      _buildQuickPromptChip(context, 'Find high-quality setups', tradingService),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Watchlist Overview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Watchlist Markets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: AppTheme.profitGreen, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      marketService.isConnected ? 'WebSocket Live' : 'REST Live',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
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
                      border: Border.all(
                        color: asset.isPriceUp ? AppTheme.profitGreen.withOpacity(0.3) : AppTheme.lossRed.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.surfaceLight,
                              child: Text(asset.symbol.substring(0, 3),
                                  style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
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
                              '${asset.change24h >= 0 ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%',
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

            // Live News Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Market Intelligence & Live News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryCyan, size: 20),
                  onPressed: () => marketService.fetchLiveNews(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...liveNews.map((item) => Container(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: item.sentiment == 'Positive'
                                  ? AppTheme.profitGreen.withOpacity(0.2)
                                  : (item.sentiment == 'Negative' ? AppTheme.lossRed.withOpacity(0.2) : AppTheme.borderColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.sentiment,
                              style: TextStyle(
                                color: item.sentiment == 'Positive'
                                    ? AppTheme.profitGreen
                                    : (item.sentiment == 'Negative' ? AppTheme.lossRed : AppTheme.textSecondary),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPromptChip(BuildContext context, String prompt, MockTradingService service) {
    return ActionChip(
      backgroundColor: AppTheme.surfaceLight,
      label: Text(prompt, style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 12)),
      onPressed: () => _submitQuickCommand(prompt, service),
    );
  }
}
