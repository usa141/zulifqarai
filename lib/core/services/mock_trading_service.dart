import 'package:flutter/foundation.dart';
import '../models/trading_models.dart';
import 'market_api_service.dart';

class MockTradingService extends ChangeNotifier {
  PortfolioSummary _portfolio = PortfolioSummary(
    totalValue: 24850.75,
    availableBalance: 8420.50,
    dailyPnl: 1240.30,
    dailyPnlPercentage: 5.25,
    isPaperTrading: true,
  );

  List<MarketAsset> _assets = [
    MarketAsset(
      symbol: 'BTC/USDT',
      name: 'Bitcoin',
      category: 'Crypto',
      price: 91450.00,
      change24h: 3.45,
      volume24h: 42100000000.0,
      high24h: 92100.00,
      low24h: 88500.00,
      marketBias: 'Bullish',
      rsi: 64.2,
      macd: 342.5,
      sparkline: [88500, 89200, 88900, 90100, 91200, 90800, 91450],
    ),
    MarketAsset(
      symbol: 'ETH/USDT',
      name: 'Ethereum',
      category: 'Crypto',
      price: 3380.50,
      change24h: 4.82,
      volume24h: 21400000000.0,
      high24h: 3420.00,
      low24h: 3210.00,
      marketBias: 'Bullish',
      rsi: 68.5,
      macd: 45.2,
      sparkline: [3210, 3250, 3240, 3310, 3350, 3330, 3380.5],
    ),
    MarketAsset(
      symbol: 'SOL/USDT',
      name: 'Solana',
      category: 'Crypto',
      price: 212.40,
      change24h: -1.20,
      volume24h: 7800000000.0,
      high24h: 218.00,
      low24h: 208.50,
      marketBias: 'Neutral',
      rsi: 52.1,
      macd: 2.1,
      sparkline: [218, 215, 216, 210, 211, 209, 212.4],
    ),
    MarketAsset(
      symbol: 'NVDA',
      name: 'NVIDIA Corp',
      category: 'Stocks',
      price: 138.20,
      change24h: 2.15,
      volume24h: 14500000000.0,
      high24h: 139.50,
      low24h: 135.80,
      marketBias: 'Bullish',
      rsi: 61.0,
      macd: 1.8,
      sparkline: [135, 136, 135.5, 137, 138.2],
    ),
    MarketAsset(
      symbol: 'EUR/USD',
      name: 'Euro / US Dollar',
      category: 'Forex',
      price: 1.0542,
      change24h: -0.15,
      volume24h: 53000000000.0,
      high24h: 1.0580,
      low24h: 1.0530,
      marketBias: 'Bearish',
      rsi: 41.5,
      macd: -0.0012,
      sparkline: [1.058, 1.057, 1.055, 1.0542],
    ),
  ];

  List<Position> _positions = [
    Position(
      id: 'pos_1',
      symbol: 'BTC/USDT',
      type: 'LONG',
      entryPrice: 89800.00,
      currentPrice: 91450.00,
      size: 0.15,
      leverage: 10,
      pnl: 247.50,
      pnlPercentage: 18.39,
      stopLoss: 88900.00,
      takeProfit: 93500.00,
    ),
    Position(
      id: 'pos_2',
      symbol: 'ETH/USDT',
      type: 'LONG',
      entryPrice: 3310.00,
      currentPrice: 3380.50,
      size: 1.5,
      leverage: 5,
      pnl: 105.75,
      pnlPercentage: 10.66,
      stopLoss: 3260.00,
      takeProfit: 3500.00,
    ),
  ];

  final List<TradingSignal> _signals = [
    TradingSignal(
      id: 'sig_1',
      asset: 'BTC/USDT',
      direction: 'LONG',
      timeframe: '4H',
      entryMin: 90800.00,
      entryMax: 91200.00,
      stopLoss: 89700.00,
      takeProfits: [92800.00, 94500.00, 96000.00],
      confidence: 84,
      strategy: 'Liquidity Sweep + Trend Alignment',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      explanation: 'Break of structure confirmed on 4H chart following a liquidity sweep below \$89.5k support. Volume expansion and positive MACD crossover indicate strong continuation.',
    ),
    TradingSignal(
      id: 'sig_2',
      asset: 'ETH/USDT',
      direction: 'LONG',
      timeframe: '1H',
      entryMin: 3350.00,
      entryMax: 3375.00,
      stopLoss: 3290.00,
      takeProfits: [3450.00, 3550.00],
      confidence: 79,
      strategy: 'EMA Ribbon Bounce + VWAP Support',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      explanation: 'ETH tested 20 EMA and bounced cleanly with surging buy volume. RSI is rebounding from neutral 50 level.',
    ),
  ];

  final List<NewsItem> _news = [
    NewsItem(
      id: 'news_1',
      title: 'Bitcoin Surges Past \$91K as Institutional Inflows Hit New Weekly Record',
      source: 'Bloomberg Crypto',
      timeAgo: '15m ago',
      sentiment: 'Positive',
      impact: 'High',
    ),
    NewsItem(
      id: 'news_2',
      title: 'Ethereum Layer 2 TVL Reaches All-Time High Amid DeFi Expansion',
      source: 'CoinDesk',
      timeAgo: '1h ago',
      sentiment: 'Positive',
      impact: 'Medium',
    ),
    NewsItem(
      id: 'news_3',
      title: 'Global Markets Steady Ahead of Upcoming US Inflation Data Release',
      source: 'Reuters',
      timeAgo: '3h ago',
      sentiment: 'Neutral',
      impact: 'High',
    ),
  ];

  final List<AlertItem> _alerts = [
    AlertItem(
      id: 'alt_1',
      title: 'Take-Profit Target Approaching',
      description: 'BTC/USDT position is within 1% of TP1 (\$92,800).',
      time: '5m ago',
      isRead: false,
    ),
    AlertItem(
      id: 'alt_2',
      title: 'High Volatility Warning',
      description: 'SOL/USDT experiencing rapid order book shifts.',
      time: '1h ago',
      isRead: true,
    ),
  ];

  final List<ChatMessage> _chatHistory = [
    ChatMessage(
      text: "JARVIS online. All market feeds connected. How may I assist your trading operations today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  PortfolioSummary get portfolio => _portfolio;
  List<MarketAsset> get assets => _assets;
  List<Position> get positions => _positions;
  List<TradingSignal> get signals => _signals;
  List<NewsItem> get news => _news;
  List<AlertItem> get alerts => _alerts;
  List<ChatMessage> get chatHistory => _chatHistory;

  void updateWithLiveTickers(Map<String, LiveTicker> tickers) {
    bool hasChanges = false;

    _assets = _assets.map((asset) {
      if (tickers.containsKey(asset.symbol)) {
        final ticker = tickers[asset.symbol]!;
        hasChanges = true;
        final updatedSparkline = List<double>.from(asset.sparkline)..add(ticker.price);
        if (updatedSparkline.length > 20) {
          updatedSparkline.removeAt(0);
        }

        return MarketAsset(
          symbol: asset.symbol,
          name: asset.name,
          category: asset.category,
          price: ticker.price,
          change24h: ticker.change24h,
          volume24h: ticker.volume24h,
          high24h: ticker.high24h,
          low24h: ticker.low24h,
          marketBias: ticker.change24h >= 0 ? 'Bullish' : 'Bearish',
          rsi: asset.rsi,
          macd: asset.macd,
          sparkline: updatedSparkline,
        );
      }
      return asset;
    }).toList();

    _positions = _positions.map((pos) {
      if (tickers.containsKey(pos.symbol)) {
        final ticker = tickers[pos.symbol]!;
        final price = ticker.price;
        final pnl = (pos.type == 'LONG')
            ? (price - pos.entryPrice) * pos.size * pos.leverage
            : (pos.entryPrice - price) * pos.size * pos.leverage;
        final pnlPercent = ((price - pos.entryPrice) / pos.entryPrice) * 100 * pos.leverage;

        hasChanges = true;
        return Position(
          id: pos.id,
          symbol: pos.symbol,
          type: pos.type,
          entryPrice: pos.entryPrice,
          currentPrice: price,
          size: pos.size,
          leverage: pos.leverage,
          pnl: pnl,
          pnlPercentage: pnlPercent,
          stopLoss: pos.stopLoss,
          takeProfit: pos.takeProfit,
        );
      }
      return pos;
    }).toList();

    if (hasChanges) {
      notifyListeners();
    }
  }

  void addChatMessage(String query, String response) {
    _chatHistory.add(ChatMessage(text: query, isUser: true, timestamp: DateTime.now()));
    _chatHistory.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
    notifyListeners();
  }

  void togglePaperTrading() {
    _portfolio = PortfolioSummary(
      totalValue: _portfolio.totalValue,
      availableBalance: _portfolio.availableBalance,
      dailyPnl: _portfolio.dailyPnl,
      dailyPnlPercentage: _portfolio.dailyPnlPercentage,
      isPaperTrading: !_portfolio.isPaperTrading,
    );
    notifyListeners();
  }
}
