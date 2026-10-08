import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'markets/markets_screen.dart';
import 'signals/signals_screen.dart';
import 'portfolio/portfolio_screen.dart';
import 'ai_assistant/ai_assistant_screen.dart';
import 'settings/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({Key? key}) : super(key: key);

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MarketsScreen(),
    const SignalsScreen(),
    const PortfolioScreen(),
    const AiAssistantScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            activeIcon: Icon(Icons.trending_up),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Signals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'JARVIS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
