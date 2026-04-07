import 'dart:math' as math; // 数学ロジック用にインポート
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'block_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFE53935), Color(0xFF8B0000)],
          ),
        ),
        child: Stack(
          children: [
            // 1. 特大サイズの雪（賑やかし強化！）
            ..._buildSnowflakes(),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // サブタイトル
                    Text(
                      'Merry Learning! 🎄',
                      style: GoogleFonts.greatVibes(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    // タイトル上段
                    Text(
                      'ベトナム語クイズ',
                      style: GoogleFonts.notoSansJp(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),

                    // タイトル下段
                    Text(
                      '3択ロース',
                      style: GoogleFonts.notoSansJp(
                        textStyle: const TextStyle(
                          color: Colors.amberAccent, 
                          fontSize: 48, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10), // タイトルと画像の間を詰める

                    // 2. ロースちゃんの複合アニメーション（もっとドーンと大きく！）
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        // 上下の動き幅を少し広げる
                        final offset = math.sin(_controller.value * 2 * math.pi) * 15; // ±15ピクセルの移動
                        return Transform.translate(
                          offset: Offset(0, offset), 
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 背後のハロー（後光）エフェクト
                              Container(
                                width: 300, // 後光も大きく
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellowAccent.withOpacity(0.3),
                                      blurRadius: 70,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/images/lauschan_tonakaikun.png',
                                width: MediaQuery.of(context).size.width * 0.98, // 画面幅の98%（ほぼいっぱい）
                                height: 480, // 以前の350から大幅アップ
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 10), // 画像とボタンの間を詰める

                    // ボタン
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BlockSelectionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 75), // ボタンも少し太く
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                            side: const BorderSide(color: Colors.white30, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 28)), // アイコンも大きく
                            const SizedBox(width: 15),
                            Text(
                              '学習をはじめる',
                              style: GoogleFonts.mPlus1p(
                                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ❄️ 3. 雪の結晶描画（全体的にサイズアップ！）
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 80, left: 40, size: 80), // 以前の24から45へ大幅アップ
      _p(top: 180, right: 60, size: 70),
      _p(top: 350, left: 20, size: 120, opacity: 0.15), // 特大の結晶
      _p(bottom: 150, right: 30, size: 80),
      _p(bottom: 80, left: 90, size: 60),
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}