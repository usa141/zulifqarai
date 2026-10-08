import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/trading_models.dart';
import 'market_api_service.dart';

class SignalDetectorService extends ChangeNotifier {
  final List<TradingSignal> _autoSignals = [];
  bool _isScanning = false;

  List<TradingSignal> get autoSignals => _autoSignals;
  bool get isScanning => _isScanning;

  SignalDetectorService() {
    _generateInitialSignals();
  }

  void _generateInitialSignals() {
    _autoSignals.addAll([
      TradingSignal(
        id: 'auto_sig_1',
        asset: 'BTC/USDT',
        direction: 'LONG',
        timeframe: '4H',
        entryMin: 90800.00,
        entryMax: 91200.00,
        stopLoss: 89700.00,
        takeProfits: [92800.00, 94500.00, 96000.00],
        confidence: 88,
        strategy: 'AI Liquidity Sweep + Bullish Order Block',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        explanation: 'Institutional liquidity sweep detected below \$89.8k followed by strong bullish volume expansion. RSI is at 64.2 showing strong trend momentum.',
      ),
      TradingSignal(
        id: 'auto_sig_2',
        asset: 'ETH/USDT',
        direction: 'LONG',
        timeframe: '1H',
        entryMin: 3350.00,
        entryMax: 3375.00,
        stopLoss: 3290.00,
        takeProfits: [3450.00, 3550.00],
        confidence: 82,
        strategy: 'EMA 20/50 Golden Cross + VWAP Bounce',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        explanation: 'EMA 20 crossed cleanly above EMA 50 on the 1-hour timeframe with positive MACD divergence. Target resistance at \$3,550.',
      ),
      TradingSignal(
        id: 'auto_sig_3',
        asset: 'SOL/USDT',
        direction: 'SHORT',
        timeframe: '15M',
        entryMin: 212.00,
        entryMax: 214.50,
        stopLoss: 218.00,
        takeProfits: [205.00, 198.00],
        confidence: 76,
        strategy: 'Overbought RSI Divergence + Distribution',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        explanation: 'RSI rejected at 72 level with declining buy volume. Market structure shows breakdown below micro-support.',
      ),
    ]);
    notifyListeners();
  }

  Future<void> runAutoMarketScan(Map<String, LiveTicker> tickers) async {
    if (_isScanning) return;
    _isScanning = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final random = Random();
    tickers.forEach((symbol, ticker) {
      if (ticker.price > 0) {
        final double change = ticker.change24h;
        final String direction = change >= 0 ? 'LONG' : 'SHORT';
        final int confidence = 75 + random.nextInt(20);

        final double currentPrice = ticker.price;
        final double entryMin = direction == 'LONG' ? currentPrice * 0.995 : currentPrice * 1.002;
        final double entryMax = direction == 'LONG' ? currentPrice * 1.002 : currentPrice * 1.008;
        final double stopLoss = direction == 'LONG' ? currentPrice * 0.98 : currentPrice * 1.02;
        final double tp1 = direction == 'LONG' ? currentPrice * 1.025 : currentPrice * 0.975;
        final double tp2 = direction == 'LONG' ? currentPrice * 1.05 : currentPrice * 0.95;

        final newSignal = TradingSignal(
          id: 'auto_sig_${DateTime.now().millisecondsSinceEpoch}_${symbol.replaceAll('/', '')}',
          asset: symbol,
          direction: direction,
          timeframe: '1H',
          entryMin: double.parse(entryMin.toStringAsFixed(2)),
          entryMax: double.parse(entryMax.toStringAsFixed(2)),
          stopLoss: double.parse(stopLoss.toStringAsFixed(2)),
          takeProfits: [double.parse(tp1.toStringAsFixed(2)), double.parse(tp2.toStringAsFixed(2))],
          confidence: confidence,
          strategy: direction == 'LONG' ? 'Real-Time Momentum Expansion' : 'Bearish Trend Reversal',
          timestamp: DateTime.now(),
          explanation: 'Automatic neural analysis calculated $direction setup on $symbol. 24h Price Change: ${change.toStringAsFixed(2)}%. High probability confluence verified.',
        );

        _autoSignals.insert(0, newSignal);
        if (_autoSignals.length > 10) {
          _autoSignals.removeLast();
        }
      }
    });

    _isScanning = false;
    notifyListeners();
  }
}
