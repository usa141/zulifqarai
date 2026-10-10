import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/services/mock_trading_service.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final portfolio = tradingService.portfolio;
    final positions = tradingService.positions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio & Positions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (positions.isNotEmpty)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppTheme.lossRed),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Close All', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                tradingService.closeAllPositions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All open positions closed successfully'),
                    backgroundColor: AppTheme.lossRed,
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary Card
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
                      const Text('PORTFOLIO VALUE',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            portfolio.isPaperTrading ? 'Paper Trading' : 'Live Mode',
                            style: TextStyle(
                              color: portfolio.isPaperTrading ? AppTheme.warningOrange : AppTheme.profitGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: portfolio.isPaperTrading,
                            activeColor: AppTheme.warningOrange,
                            onChanged: (val) {
                              tradingService.togglePaperTrading();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '\$${portfolio.totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${portfolio.dailyPnl >= 0 ? '+' : ''}\$${portfolio.dailyPnl.toStringAsFixed(2)} (${portfolio.dailyPnlPercentage.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: portfolio.dailyPnl >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                          const Text('Available Margin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('\$${portfolio.availableBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Open Positions', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${positions.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryCyan)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Open Positions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Positions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${positions.length} Positions', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),

            if (positions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.query_stats, color: AppTheme.textSecondary, size: 48),
                    SizedBox(height: 12),
                    Text('No Active Positions Open', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Tap Markets or Signals tab to open a position', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            else
              ...positions.map((pos) => Container(
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
                                Text(pos.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: pos.type == 'LONG'
                                        ? AppTheme.profitGreen.withOpacity(0.2)
                                        : AppTheme.lossRed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    pos.type,
                                    style: TextStyle(
                                      color: pos.type == 'LONG' ? AppTheme.profitGreen : AppTheme.lossRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('${pos.leverage.toInt()}x', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                            Text(
                              '${pos.pnl >= 0 ? '+' : ''}\$${pos.pnl.toStringAsFixed(2)} (${pos.pnlPercentage >= 0 ? '+' : ''}${pos.pnlPercentage.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                color: pos.pnl >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Entry: \$${pos.entryPrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            Text('Current: \$${pos.currentPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SL: \$${pos.stopLoss.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.lossRed, fontSize: 12)),
                            Text('TP: \$${pos.takeProfit.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.profitGreen, fontSize: 12)),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.lossRed,
                                side: const BorderSide(color: AppTheme.lossRed),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              ),
                              onPressed: () {
                                tradingService.closePosition(pos.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Closed position for ${pos.symbol}'),
                                    backgroundColor: AppTheme.surfaceDark,
                                  ),
                                );
                              },
                              child: const Text('Close', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
