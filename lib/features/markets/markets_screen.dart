import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/models/trading_models.dart';
import '../../core/services/mock_trading_service.dart';
import '../analysis/coin_analysis_screen.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({Key? key}) : super(key: key);

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  void _showTradeOrderSheet(BuildContext context, MarketAsset asset, MockTradingService service) {
    double size = 0.1;
    double leverage = 10.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trade ${asset.symbol}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Live Price: \$${asset.price.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Position Leverage:', style: TextStyle(color: AppTheme.textSecondary)),
                  Text('${leverage.toInt()}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningOrange)),
                ],
              ),
              Slider(
                value: leverage,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: AppTheme.primaryCyan,
                onChanged: (val) => setModalState(() => leverage = val),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Position Size:', style: TextStyle(color: AppTheme.textSecondary)),
                  Text('${size.toStringAsFixed(2)} Units', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: size,
                min: 0.01,
                max: 2.0,
                activeColor: AppTheme.primaryCyan,
                onChanged: (val) => setModalState(() => size = val),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.profitGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        service.openPosition(
                          symbol: asset.symbol,
                          type: 'LONG',
                          entryPrice: asset.price,
                          size: size,
                          leverage: leverage,
                          stopLoss: asset.price * 0.97,
                          takeProfit: asset.price * 1.05,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('OPENED LONG Position for ${asset.symbol}'),
                            backgroundColor: AppTheme.profitGreen,
                          ),
                        );
                      },
                      child: const Text('OPEN LONG', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lossRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        service.openPosition(
                          symbol: asset.symbol,
                          type: 'SHORT',
                          entryPrice: asset.price,
                          size: size,
                          leverage: leverage,
                          stopLoss: asset.price * 1.03,
                          takeProfit: asset.price * 0.95,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('OPENED SHORT Position for ${asset.symbol}'),
                            backgroundColor: AppTheme.lossRed,
                          ),
                        );
                      },
                      child: const Text('OPEN SHORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final allAssets = tradingService.assets;

    final filteredAssets = allAssets.where((asset) {
      final matchesCategory = _selectedCategory == 'All' || asset.category == _selectedCategory;
      final matchesSearch = asset.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          asset.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets & Exchanges', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Search assets (e.g. BTC, ETH, SOL)',
                    prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['All', 'Crypto', 'Stocks', 'Forex'].map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryCyan,
                        backgroundColor: AppTheme.surfaceDark,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.backgroundDark : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredAssets.length,
              itemBuilder: (context, index) {
                final asset = filteredAssets[index];
                final isUp = asset.isPriceUp;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUp ? AppTheme.profitGreen.withOpacity(0.5) : AppTheme.lossRed.withOpacity(0.5),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CoinAnalysisScreen(asset: asset)),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.surfaceLight,
                      child: Text(
                        asset.symbol.substring(0, 3),
                        style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(asset.marketBias, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ),
                      ],
                    ),
                    subtitle: Text('${asset.name} • Vol \$${(asset.volume24h / 1e9).toStringAsFixed(1)}B',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${asset.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              '${asset.change24h >= 0 ? '+' : ''}${asset.change24h.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: asset.change24h >= 0 ? AppTheme.profitGreen : AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.flash_on, color: AppTheme.primaryCyan, size: 20),
                          tooltip: 'Quick Trade Order',
                          onPressed: () => _showTradeOrderSheet(context, asset, tradingService),
                        ),
                      ],
                    ),
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
