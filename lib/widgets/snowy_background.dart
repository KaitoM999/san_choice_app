import 'package:flutter/material.dart';

class SnowyBackground extends StatelessWidget {
  // 各画面のメインコンテンツ（リストやクイズ画面など）を受け取る
  final Widget child;

  const SnowyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFFE53935), Color(0xFF8B0000)],
        ),
      ),
      child: Stack(
        children: [
          // 背景に降る雪の結晶
          ..._buildSnowflakes(),
          
          // その上に各画面のコンテンツを重ねる
          child,
        ],
      ),
    );
  }

  // --- 雪の結晶パーツ ---
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 50, left: 20, size: 60, opacity: 0.2), 
      _p(top: 150, right: 30, size: 50, opacity: 0.2),
      _p(bottom: 100, left: 30, size: 70, opacity: 0.1),
      _p(bottom: 200, right: 50, size: 60, opacity: 0.1),
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom, 
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}