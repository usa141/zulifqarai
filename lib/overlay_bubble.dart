import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'core/config/app_theme.dart';
import 'core/widgets/sword_logo.dart';

class OverlayBubble extends StatefulWidget {
  const OverlayBubble({Key? key}) : super(key: key);

  @override
  State<OverlayBubble> createState() => _OverlayBubbleState();
}

class _OverlayBubbleState extends State<OverlayBubble> {
  bool _serviceOn = false;

  void _onTap() {
    setState(() => _serviceOn = !_serviceOn);
    FlutterOverlayWindow.shareData(_serviceOn ? 'START_SERVICE' : 'STOP_SERVICE');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceDark,
              border: Border.all(
                color: _serviceOn ? AppTheme.profitGreen : AppTheme.primaryCyan,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_serviceOn ? AppTheme.profitGreen : AppTheme.primaryCyan).withOpacity(0.6),
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
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _serviceOn ? AppTheme.profitGreen : AppTheme.primaryCyan,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
