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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
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
                      const Text('PORTFOLIO VALUE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                      Switch(
                        value: portfolio.isPaperTrading,
                        activeColor: AppTheme.warningOrange,
                        onChanged: (val) {
                          tradingService.togglePaperTrading();
                        },
                      ),
                    ],
                  ),
                  Text('\$${portfolio.totalValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${portfolio.dailyPnl >= 0 ? '+' : ''}\$${portfolio.dailyPnl.toStringAsFixed(2)} (${portfolio.dailyPnlPercentage}%)',
                        style: TextStyle(color: portfolio.dailyPnl >= 0 ? AppTheme.profitGreen : AppTheme.lossRed, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Text('Today', style: TextStyle(color: AppTheme.textSecondary)),
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
                          const Text('Mode', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(portfolio.isPaperTrading ? 'Paper Trading' : 'Live Trading', style: TextStyle(color: portfolio.isPaperTrading ? AppTheme.warningOrange : AppTheme.profitGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Open Positions Header
            const Text('Open Positions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

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
                              color: pos.type == 'LONG' ? AppTheme.profitGreen.withOpacity(0.2) : AppTheme.lossRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(pos.type, style: TextStyle(color: pos.type == 'LONG' ? AppTheme.profitGreen : AppTheme.lossRed, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          const SizedBox(width: 6),
                          Text('${pos.leverage}x', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      Text(
                        '${pos.pnl >= 0 ? '+' : ''}\$${pos.pnl.toStringAsFixed(2)} (${pos.pnlPercentage >= 0 ? '+' : ''}${pos.pnlPercentage}%)',
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
                      Text('Entry: \$${pos.entryPrice}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('Current: \$${pos.currentPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SL: \$${pos.stopLoss}', style: const TextStyle(color: AppTheme.lossRed, fontSize: 12)),
                      Text('TP: \$${pos.takeProfit}', style: const TextStyle(color: AppTheme.profitGreen, fontSize: 12)),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.lossRed,
                          side: const BorderSide(color: AppTheme.lossRed),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                        onPressed: () {},
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
