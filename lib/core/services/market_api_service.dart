import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/trading_models.dart';

class LiveTicker {
  final String symbol;
  final double price;
  final double previousPrice;
  final double change24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  final DateTime lastTick;

  LiveTicker({
    required this.symbol,
    required this.price,
    this.previousPrice = 0.0,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    DateTime? lastTick,
  }) : lastTick = lastTick ?? DateTime.now();

  bool get isUp => price >= previousPrice;
}

class MarketApiService extends ChangeNotifier {
  static const String binanceBaseUrl = 'https://api.binance.com/api/v3';
  static const String binanceWsUrl = 'wss://stream.binance.com:9443/ws/!miniTicker@arr';
  static const String newsApiUrl = 'https://min-api.cryptocompare.com/data/v2/news/?lang=EN';

  final Map<String, LiveTicker> _liveTickers = {};
  List<NewsItem> _liveNews = [];
  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSubscription;
  Timer? _newsTimer;
  bool _isConnected = false;
  bool _isLoading = false;

  Map<String, LiveTicker> get liveTickers => _liveTickers;
  List<NewsItem> get liveNews => _liveNews;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;

  MarketApiService() {
    initLivePrices();
  }

  Future<void> initLivePrices() async {
    _isLoading = true;
    notifyListeners();

    await fetchRestTickers();
    await fetchLiveNews();
    _connectWebSocket();

    // Auto-refresh news every 30 seconds
    _newsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchLiveNews();
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRestTickers() async {
    try {
      final response = await http
          .get(Uri.parse('$binanceBaseUrl/ticker/24hr'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        for (var item in data) {
          final String symbol = item['symbol'];
          if (symbol == 'BTCUSDT' ||
              symbol == 'ETHUSDT' ||
              symbol == 'SOLUSDT' ||
              symbol == 'BNBUSDT' ||
              symbol == 'XRPUSDT' ||
              symbol == 'ADAUSDT' ||
              symbol == 'DOGEUSDT' ||
              symbol == 'AVAXUSDT') {
            final formattedSymbol = '${symbol.replaceAll('USDT', '')}/USDT';
            final lastP = double.tryParse(item['lastPrice'].toString()) ?? 0.0;
            final current = _liveTickers[formattedSymbol];

            _liveTickers[formattedSymbol] = LiveTicker(
              symbol: formattedSymbol,
              price: lastP,
              previousPrice: current?.price ?? lastP,
              change24h: double.tryParse(item['priceChangePercent'].toString()) ?? 0.0,
              high24h: double.tryParse(item['highPrice'].toString()) ?? 0.0,
              low24h: double.tryParse(item['lowPrice'].toString()) ?? 0.0,
              volume24h: double.tryParse(item['quoteVolume'].toString()) ?? 0.0,
            );
          }
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching REST tickers: $e');
      }
    }
  }

  Future<void> fetchLiveNews() async {
    try {
      final response = await http
          .get(Uri.parse(newsApiUrl))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List newsData = data['Data'] ?? [];
        final List<NewsItem> items = [];

        for (var i = 0; i < newsData.length && i < 10; i++) {
          final item = newsData[i];
          final String title = item['title'] ?? 'Market Updates';
          final String source = item['source_info']?['name'] ?? 'CryptoNews';
          final String body = item['body'] ?? '';
          final String categories = (item['categories'] ?? '').toString().toLowerCase();

          String sentiment = 'Neutral';
          if (categories.contains('bull') || title.toLowerCase().contains('surge') || title.toLowerCase().contains('high')) {
            sentiment = 'Positive';
          } else if (categories.contains('bear') || title.toLowerCase().contains('drop') || title.toLowerCase().contains('fall')) {
            sentiment = 'Negative';
          }

          items.add(NewsItem(
            id: 'news_${item['id']}',
            title: title,
            source: source,
            timeAgo: 'Just now',
            sentiment: sentiment,
            impact: body.length > 200 ? 'High' : 'Medium',
            url: item['url'],
          ));
        }

        if (items.isNotEmpty) {
          _liveNews = items;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching live news: $e');
      }
    }
  }

  void _connectWebSocket() {
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(binanceWsUrl));
      _isConnected = true;

      _wsSubscription = _wsChannel?.stream.listen(
        (message) {
          try {
            final List data = jsonDecode(message);
            bool updated = false;

            for (var item in data) {
              final String symbol = item['s'] ?? '';
              if (symbol == 'BTCUSDT' ||
                  symbol == 'ETHUSDT' ||
                  symbol == 'SOLUSDT' ||
                  symbol == 'BNBUSDT' ||
                  symbol == 'XRPUSDT' ||
                  symbol == 'ADAUSDT' ||
                  symbol == 'DOGEUSDT' ||
                  symbol == 'AVAXUSDT') {
                final formattedSymbol = '${symbol.replaceAll('USDT', '')}/USDT';
                final current = _liveTickers[formattedSymbol];

                final closePrice = double.tryParse(item['c'].toString()) ?? (current?.price ?? 0.0);
                final openPrice = double.tryParse(item['o'].toString()) ?? closePrice;
                final change24h = openPrice != 0 ? ((closePrice - openPrice) / openPrice) * 100 : 0.0;

                _liveTickers[formattedSymbol] = LiveTicker(
                  symbol: formattedSymbol,
                  price: closePrice,
                  previousPrice: current?.price ?? closePrice,
                  change24h: change24h,
                  high24h: double.tryParse(item['h'].toString()) ?? (current?.high24h ?? closePrice),
                  low24h: double.tryParse(item['l'].toString()) ?? (current?.low24h ?? closePrice),
                  volume24h: double.tryParse(item['v'].toString()) ?? (current?.volume24h ?? 0.0),
                );
                updated = true;
              }
            }

            if (updated) {
              notifyListeners();
            }
          } catch (e) {
            // Message parse error
          }
        },
        onError: (error) {
          _isConnected = false;
          notifyListeners();
          _reconnectWebSocket();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _connectWebSocket();
      }
    });
  }

  Future<List<double>> fetchKlines(String symbol, {String interval = '1h', int limit = 24}) async {
    final binanceSymbol = symbol.replaceAll('/', '').toUpperCase();
    try {
      final response = await http.get(
        Uri.parse('$binanceBaseUrl/klines?symbol=$binanceSymbol&interval=$interval&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((kline) => double.tryParse(kline[4].toString()) ?? 0.0).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching klines: $e');
      }
    }
    return [100.0, 102.5, 101.8, 104.2, 103.9, 106.1];
  }

  @override
  void dispose() {
    _newsTimer?.cancel();
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }
}
