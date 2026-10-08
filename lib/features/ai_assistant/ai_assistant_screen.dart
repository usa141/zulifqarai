import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../../core/services/gemini_ai_service.dart';
import '../../core/services/market_api_service.dart';
import '../../core/services/mock_trading_service.dart';
import '../../core/widgets/sword_logo.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isVoiceListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(
    MockTradingService tradingService,
    GeminiAiService geminiService,
    MarketApiService marketService,
  ) async {
    if (_controller.text.trim().isEmpty) return;
    final query = _controller.text.trim();
    _controller.clear();

    final portfolioSummary =
        "Total Value: \$${tradingService.portfolio.totalValue.toStringAsFixed(2)}, Daily P&L: \$${tradingService.portfolio.dailyPnl.toStringAsFixed(2)} (${tradingService.portfolio.dailyPnlPercentage}%)";

    final response = await geminiService.queryJarvis(
      userPrompt: query,
      liveTickers: marketService.liveTickers,
      userPortfolioContext: portfolioSummary,
    );

    tradingService.addChatMessage(query, response);
  }

  void _toggleVoiceListening() {
    setState(() {
      _isVoiceListening = !_isVoiceListening;
    });

    if (_isVoiceListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.mic, color: AppTheme.primaryCyan),
              SizedBox(width: 8),
              Text('Zulfiqar Voice Recognition Active... Speak now'),
            ],
          ),
          backgroundColor: AppTheme.surfaceDark,
          duration: Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isVoiceListening) {
          setState(() {
            _controller.text = "Analyze Bitcoin BTC market structure and targets";
            _isVoiceListening = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradingService = Provider.of<MockTradingService>(context);
    final geminiService = Provider.of<GeminiAiService>(context);
    final marketService = Provider.of<MarketApiService>(context);
    final chatHistory = tradingService.chatHistory;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            SwordLogo(size: 28),
            SizedBox(width: 10),
            Text('JARVIS Command Center', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceListening ? Icons.mic : Icons.mic_none,
              color: _isVoiceListening ? AppTheme.lossRed : AppTheme.primaryCyan,
            ),
            tooltip: 'Voice Command Mode',
            onPressed: _toggleVoiceListening,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceDark,
            child: Row(
              children: [
                const Icon(Icons.fiber_manual_record, color: AppTheme.profitGreen, size: 12),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    marketService.isConnected
                        ? 'Zulfiqar Neural Link Active • Binance WebSocket Stream'
                        : 'Zulfiqar Neural Link Active • Local Market Engine',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
                if (geminiService.isProcessing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCyan),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final msg = chatHistory[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppTheme.primaryCyan.withOpacity(0.15) : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: msg.isUser ? AppTheme.primaryCyan.withOpacity(0.4) : AppTheme.borderColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!msg.isUser)
                          Row(
                            children: const [
                              SwordLogo(size: 16),
                              SizedBox(width: 6),
                              Text('ZULFIQAR JARVIS AI', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        if (!msg.isUser) const SizedBox(height: 6),
                        Text(msg.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.surfaceDark,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isVoiceListening ? Icons.mic : Icons.mic_none,
                    color: _isVoiceListening ? AppTheme.lossRed : AppTheme.primaryCyan,
                  ),
                  onPressed: _toggleVoiceListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(tradingService, geminiService, marketService),
                    decoration: const InputDecoration(
                      hintText: 'Ask Zulfiqar JARVIS for setups, RSI, targets...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                  onPressed: () => _sendMessage(tradingService, geminiService, marketService),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
