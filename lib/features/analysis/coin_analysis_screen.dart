import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';
import '../../core/models/trading_models.dart';

class CoinAnalysisScreen extends StatelessWidget {
  final MarketAsset asset;

  const CoinAnalysisScreen({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: asset.marketBias == 'Bullish' ? AppTheme.profitGreen.withOpacity(0.2) : AppTheme.lossRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                asset.marketBias,
                style: TextStyle(
                  color: asset.marketBias == 'Bullish' ? AppTheme.profitGreen : AppTheme.lossRed,
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
            // Price & 24h Change Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('\$${asset.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('24h Change', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${asset.change24h >= 0 ? '+' : ''}${asset.change24h}%',
                        style: TextStyle(
                          color: asset.change24h >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Analysis Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.surfaceDark, AppTheme.surfaceLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryCyan, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.psychology, color: AppTheme.primaryCyan, size: 22),
                          SizedBox(width: 8),
                          Text('JARVIS AI SETUP ANALYSIS', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('84% Confidence', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  _buildAnalysisRow('Market Bias', asset.marketBias, AppTheme.profitGreen),
                  _buildAnalysisRow('Setup Quality', 'Grade A+ (High Probability)', AppTheme.primaryCyan),
                  _buildAnalysisRow('Entry Zone', '\$${(asset.price * 0.99).toStringAsFixed(2)} – \$${asset.price.toStringAsFixed(2)}', AppTheme.textPrimary),
                  _buildAnalysisRow('Invalidation Level', '\$${(asset.price * 0.97).toStringAsFixed(2)}', AppTheme.lossRed),
                  _buildAnalysisRow('Stop-Loss Area', '\$${(asset.price * 0.975).toStringAsFixed(2)}', AppTheme.lossRed),
                  _buildAnalysisRow('Take-Profit Targets', 'TP1: \$${(asset.price * 1.03).toStringAsFixed(2)} | TP2: \$${(asset.price * 1.06).toStringAsFixed(2)}', AppTheme.profitGreen),
                  _buildAnalysisRow('Risk / Reward Ratio', '1 : 2.85', AppTheme.textPrimary),
                  const SizedBox(height: 12),
                  const Text('AI Reasoning:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  const Text(
                    'Price has tested major liquidity pool and formed a bullish change of character on the 4H timeframe. Volume expansion confirms buyer dominance. Trade with strict risk management.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Technical Indicators Grid
            const Text('Technical Indicators', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildIndicatorCard('RSI (14)', '${asset.rsi}', asset.rsi > 70 ? 'Overbought' : (asset.rsi < 30 ? 'Oversold' : 'Neutral')),
                _buildIndicatorCard('MACD', '${asset.macd}', 'Bullish Cross'),
                _buildIndicatorCard('Volume (24h)', '\$${(asset.volume24h / 1000000000).toStringAsFixed(2)}B', 'High Activity'),
                _buildIndicatorCard('Volatility (ATR)', 'High', 'Caution Advised'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
