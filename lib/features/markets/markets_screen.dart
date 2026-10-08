import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
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
                    hintText: 'Search assets (e.g. BTC, ETH, NVDA)',
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
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoinAnalysisScreen(asset: asset)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
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
                                Text('${asset.name} • ${asset.marketBias}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
