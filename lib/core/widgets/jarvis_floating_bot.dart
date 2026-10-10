import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/market_api_service.dart';
import '../services/mock_trading_service.dart';
import 'sword_logo.dart';

class JarvisFloatingBot extends StatefulWidget {
  final Widget child;

  const JarvisFloatingBot({Key? key, required this.child}) : super(key: key);

  @override
  State<JarvisFloatingBot> createState() => _JarvisFloatingBotState();
}

class _JarvisFloatingBotState extends State<JarvisFloatingBot> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Offset _bubblePosition = const Offset(20, 120);
  bool _isPanelOpen = false;
  bool _isVoiceListening = false;
  bool _isConfigOpen = false;

  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _promptController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submitQuery(
    String query,
    MockTradingService tradingService,
    GeminiAiService geminiService,
    MarketApiService marketService,
  ) async {
    if (query.trim().isEmpty) return;
    _promptController.clear();

    final portfolioSummary =
        "Total Value: \$${tradingService.portfolio.totalValue.toStringAsFixed(2)}, Daily P&L: \$${tradingService.portfolio.dailyPnl.toStringAsFixed(2)}";

    final response = await geminiService.queryJarvis(
      userPrompt: query,
      liveTickers: marketService.liveTickers,
      userPortfolioContext: portfolioSummary,
    );

    tradingService.addChatMessage(query, response);
  }

  void _toggleVoiceMode() {
    setState(() => _isVoiceListening = !_isVoiceListening);

    if (_isVoiceListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.mic, color: AppTheme.primaryCyan),
              SizedBox(width: 8),
              Text('Zulfiqar AI Listening... Speak market query now'),
            ],
          ),
          backgroundColor: AppTheme.surfaceDark,
          duration: Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isVoiceListening) {
          setState(() {
            _promptController.text = "Analyze Bitcoin BTC resistance and targets";
            _isVoiceListening = false;
          });
        }
      });
    }
  }

  void _saveApiKey(GeminiAiService geminiService, AuthService authService) {
    final key = _apiKeyController.text.trim();
    if (key.isNotEmpty) {
      geminiService.setApiKey(key);
      authService.saveApiKeys(geminiKey: key);
      setState(() => _isConfigOpen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gemini API Key Saved Successfully in Zulfiqar Bot!'),
          backgroundColor: AppTheme.profitGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tradingService = Provider.of<MockTradingService>(context);
    final geminiService = Provider.of<GeminiAiService>(context);
    final marketService = Provider.of<MarketApiService>(context);
    final authService = Provider.of<AuthService>(context);
    final chatHistory = tradingService.chatHistory;

    return Stack(
      children: [
        widget.child,

        // Expandable Cyber Zulfiqar Bot Panel Overlay
        if (_isPanelOpen)
          Positioned(
            left: 16,
            right: 16,
            bottom: 80,
            top: MediaQuery.of(context).padding.top + 50,
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark.withOpacity(0.97),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryCyan, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCyan.withOpacity(0.35),
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Panel Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Row(
                        children: [
                          const SwordLogo(size: 26),
                          const SizedBox(width: 10),
                          const Text(
                            'ZULFIQAR AI ASSISTANT',
                            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.8),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              _isConfigOpen ? Icons.chat : Icons.key,
                              color: AppTheme.primaryCyan,
                            ),
                            tooltip: 'API Keys Configuration',
                            onPressed: () {
                              setState(() {
                                _isConfigOpen = !_isConfigOpen;
                                if (geminiService.apiKey != null) {
                                  _apiKeyController.text = geminiService.apiKey!;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _isVoiceListening ? Icons.mic : Icons.mic_none,
                              color: _isVoiceListening ? AppTheme.lossRed : AppTheme.primaryCyan,
                            ),
                            onPressed: _toggleVoiceMode,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                            onPressed: () => setState(() => _isPanelOpen = false),
                          ),
                        ],
                      ),
                    ),

                    // API Key Config Panel Tab
                    if (_isConfigOpen)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppTheme.surfaceDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚙️ Configure Zulfiqar Bot API Keys',
                              style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _apiKeyController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Enter Gemini API Key (AIzaSy...)',
                                labelText: 'Google Gemini API Key',
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryCyan,
                                  foregroundColor: AppTheme.backgroundDark,
                                ),
                                icon: const Icon(Icons.save),
                                label: const Text('SAVE API KEY IN BOT', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () => _saveApiKey(geminiService, authService),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Active Feed Status Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppTheme.surfaceLight.withOpacity(0.5),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record, color: AppTheme.profitGreen, size: 10),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                marketService.isConnected
                                    ? 'Zulfiqar Bot Live • Binance Stream Active'
                                    : 'Zulfiqar Bot Live • Market Engine Ready',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ),
                            if (geminiService.isProcessing)
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryCyan),
                              ),
                          ],
                        ),
                      ),

                      // Chat Stream
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: chatHistory.length,
                          itemBuilder: (context, index) {
                            final msg = chatHistory[index];
                            return Align(
                              alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(maxWidth: screenSize.width * 0.72),
                                decoration: BoxDecoration(
                                  color: msg.isUser ? AppTheme.primaryCyan.withOpacity(0.2) : AppTheme.surfaceDark,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: msg.isUser ? AppTheme.primaryCyan : AppTheme.borderColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!msg.isUser)
                                      Row(
                                        children: const [
                                          SwordLogo(size: 14),
                                          SizedBox(width: 6),
                                          Text('ZULFIQAR BOT', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, fontSize: 10)),
                                        ],
                                      ),
                                    if (!msg.isUser) const SizedBox(height: 4),
                                    Text(msg.text, style: const TextStyle(fontSize: 13, height: 1.35)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Prompt Suggestions Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            _buildPromptChip('Analyze BTC', tradingService, geminiService, marketService),
                            _buildPromptChip('ETH Targets', tradingService, geminiService, marketService),
                            _buildPromptChip('Find Signals', tradingService, geminiService, marketService),
                          ],
                        ),
                      ),

                      // Input Field Bar
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promptController,
                                onSubmitted: (val) => _submitQuery(val, tradingService, geminiService, marketService),
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Ask Zulfiqar AI anything...',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                              onPressed: () => _submitQuery(_promptController.text, tradingService, geminiService, marketService),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

        // Draggable Floating AI Zulfiqar Sword Badge
        Positioned(
          left: _bubblePosition.dx,
          top: _bubblePosition.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                double newX = _bubblePosition.dx + details.delta.dx;
                double newY = _bubblePosition.dy + details.delta.dy;
                newX = newX.clamp(10, screenSize.width - 70);
                newY = newY.clamp(80, screenSize.height - 120);
                _bubblePosition = Offset(newX, newY);
              });
            },
            onTap: () {
              setState(() => _isPanelOpen = !_isPanelOpen);
            },
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 66,
                height: 66,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.surfaceDark, AppTheme.surfaceLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryCyan, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCyan.withOpacity(0.6),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SwordLogo(size: 48),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: geminiService.isProcessing ? AppTheme.warningOrange : AppTheme.profitGreen,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptChip(
    String label,
    MockTradingService tradingService,
    GeminiAiService geminiService,
    MarketApiService marketService,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        backgroundColor: AppTheme.surfaceLight,
        label: Text(label, style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 11)),
        onPressed: () => _submitQuery(label, tradingService, geminiService, marketService),
      ),
    );
  }
}
