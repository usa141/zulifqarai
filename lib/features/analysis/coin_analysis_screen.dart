import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/config/app_theme.dart';
import '../../core/models/trading_models.dart';
import '../../core/services/market_api_service.dart';
import '../../core/services/mock_trading_service.dart';

class CoinAnalysisScreen extends StatefulWidget {
  final MarketAsset asset;

  const CoinAnalysisScreen({Key? key, required this.asset}) : super(key: key);

  @override
  State<CoinAnalysisScreen> createState() => _CoinAnalysisScreenState();
}

class _CoinAnalysisScreenState extends State<CoinAnalysisScreen> {
  String _selectedTimeframe = '1H';
  List<double> _chartKlines = [];
  bool _isLoadingKlines = false;

  @override
  void initState() {
    super.initState();
    _fetchKlines();
  }

  Future<void> _fetchKlines() async {
    setState(() => _isLoadingKlines = true);
    final marketApi = Provider.of<MarketApiService>(context, listen: false);

    final String binanceInterval = _selectedTimeframe.toLowerCase();
    final klines = await marketApi.fetchKlines(widget.asset.symbol, interval: binanceInterval, limit: 30);

    if (mounted) {
      setState(() {
        _chartKlines = klines.isNotEmpty ? klines : widget.asset.sparkline;
        _isLoadingKlines = false;
      });
    }
  }

  void _executeOrder(String type, MockTradingService tradingService) {
    tradingService.openPosition(
      symbol: widget.asset.symbol,
      type: type,
      entryPrice: widget.asset.price,
      size: 0.1,
      leverage: 10,
      stopLoss: type == 'LONG' ? widget.asset.price * 0.97 : widget.asset.price * 1.03,
      takeProfit: type == 'LONG' ? widget.asset.price * 1.05 : widget.asset.price * 0.95,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OPENED $type Position for ${widget.asset.symbol} @ \$${widget.asset.price.toStringAsFixed(2)}'),
        backgroundColor: type == 'LONG' ? AppTheme.profitGreen : AppTheme.lossRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final currentAsset = tradingService.assets.firstWhere(
      (a) => a.symbol == widget.asset.symbol,
      orElse: () => widget.asset,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(currentAsset.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: currentAsset.marketBias == 'Bullish'
                    ? AppTheme.profitGreen.withOpacity(0.2)
                    : AppTheme.lossRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                currentAsset.marketBias,
                style: TextStyle(
                  color: currentAsset.marketBias == 'Bullish' ? AppTheme.profitGreen : AppTheme.lossRed,
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
            // Price & Live Header
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
                      Text(currentAsset.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('\$${currentAsset.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('24h Change', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${currentAsset.change24h >= 0 ? '+' : ''}${currentAsset.change24h.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: currentAsset.change24h >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timeframe Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['15m', '1h', '4h', '1d'].map((tf) {
                final isSelected = _selectedTimeframe.toLowerCase() == tf;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          tf.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? AppTheme.backgroundDark : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryCyan,
                      backgroundColor: AppTheme.surfaceDark,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTimeframe = tf.toUpperCase());
                          _fetchKlines();
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Real Chart Visualization
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: _isLoadingKlines
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryCyan))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartKlines.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: true,
                            color: currentAsset.change24h >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: (currentAsset.change24h >= 0 ? AppTheme.profitGreen : AppTheme.lossRed).withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // AI Reasoning Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                          Text('JARVIS AI SETUP ANALYSIS',
                              style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('88% Confidence',
                            style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  _buildAnalysisRow('Market Bias', currentAsset.marketBias, AppTheme.profitGreen),
                  _buildAnalysisRow('Entry Zone', '\$${(currentAsset.price * 0.995).toStringAsFixed(2)} – \$${(currentAsset.price * 1.002).toStringAsFixed(2)}', AppTheme.textPrimary),
                  _buildAnalysisRow('Stop-Loss Area', '\$${(currentAsset.price * 0.975).toStringAsFixed(2)}', AppTheme.lossRed),
                  _buildAnalysisRow('Take-Profit 1', '\$${(currentAsset.price * 1.035).toStringAsFixed(2)}', AppTheme.profitGreen),
                  _buildAnalysisRow('Take-Profit 2', '\$${(currentAsset.price * 1.065).toStringAsFixed(2)}', AppTheme.profitGreen),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Execution Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.profitGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _executeOrder('LONG', tradingService),
                    child: const Text('BUY / LONG POSITION',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lossRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _executeOrder('SHORT', tradingService),
                    child: const Text('SELL / SHORT POSITION',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
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
}
