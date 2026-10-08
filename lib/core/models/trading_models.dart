class MarketAsset {
  final String symbol;
  final String name;
  final String category;
  double price;
  double change24h;
  double volume24h;
  double high24h;
  double low24h;
  String marketBias; // Bullish, Bearish, Neutral
  double rsi;
  double macd;
  List<double> sparkline;

  MarketAsset({
    required this.symbol,
    required this.name,
    required this.category,
    required this.price,
    required this.change24h,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.marketBias,
    required this.rsi,
    required this.macd,
    required this.sparkline,
  });
}

class Position {
  final String id;
  final String symbol;
  final String type; // LONG or SHORT
  final double entryPrice;
  final double currentPrice;
  final double size;
  final double leverage;
  final double pnl;
  final double pnlPercentage;
  final double stopLoss;
  final double takeProfit;

  Position({
    required this.id,
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.currentPrice,
    required this.size,
    required this.leverage,
    required this.pnl,
    required this.pnlPercentage,
    required this.stopLoss,
    required this.takeProfit,
  });
}

class TradingSignal {
  final String id;
  final String asset;
  final String direction; // LONG or SHORT
  final String timeframe;
  final double entryMin;
  final double entryMax;
  final double stopLoss;
  final List<double> takeProfits;
  final int confidence; // e.g. 84%
  final String strategy;
  final DateTime timestamp;
  final String explanation;

  TradingSignal({
    required this.id,
    required this.asset,
    required this.direction,
    required this.timeframe,
    required this.entryMin,
    required this.entryMax,
    required this.stopLoss,
    required this.takeProfits,
    required this.confidence,
    required this.strategy,
    required this.timestamp,
    required this.explanation,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String sentiment; // Positive, Negative, Neutral
  final String impact; // High, Medium, Low

  NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.sentiment,
    required this.impact,
  });
}

class AlertItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isRead;

  AlertItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
  });
}

class PortfolioSummary {
  final double totalValue;
  final double availableBalance;
  final double dailyPnl;
  final double dailyPnlPercentage;
  final bool isPaperTrading;

  PortfolioSummary({
    required this.totalValue,
    required this.availableBalance,
    required this.dailyPnl,
    required this.dailyPnlPercentage,
    required this.isPaperTrading,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.metadata,
  });
}
