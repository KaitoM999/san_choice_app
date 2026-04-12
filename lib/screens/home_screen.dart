import 'dart:math' as math; // 💡 フワフワ動く計算（サイン波）のために必要
import 'package:flutter/material.dart'; // Flutterの基本パーツ
import 'package:google_fonts/google_fonts.dart'; // フォント用
import 'block_selection_screen.dart'; // 移動先
import 'character_intro_screen.dart'; // 移動先

// ホーム画面の本体
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
    // 💡 2秒かけて1往復するアニメーションの設定
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 永遠に繰り返す
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 💡 謎の青い枠対策：Scaffold自体の背景を濃い赤にする
      backgroundColor: const Color(0xFF8B0000), 
      
      body: Container(
        // 💡 画面の端から端までグラデーションを広げる
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

            // 1. --- 左側のツリー画像 ---
            Positioned(
              left: -400, 
              bottom: 150, 
              child: Image.asset(
                'assets/images/home_screen_left.png',
                width: MediaQuery.of(context).size.width * 2, 
                fit: BoxFit.contain,
              ),
            ),

            // 2. --- 右側の家画像 ---
            Positioned(
              right: -400, 
              bottom: 150, 
              child: Image.asset(
                'assets/images/home_screen_right.png',
                width: MediaQuery.of(context).size.width * 2,
                fit: BoxFit.contain,
              ),
            ),

            // 3. --- 中央のロースちゃん ＆ トナカイくん（巨大化 ＆ 光） ---
            Positioned(
              // 💡 巨大化した画像を画面中央に持ってくる計算
              left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 2.5)) / 2,
              bottom: 50, 
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = math.sin(_controller.value * 2 * math.pi) * 15;
                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 💡 ぼんやりとした「後光」
                        Container(
                          width: MediaQuery.of(context).size.width * 1.5,
                          height: MediaQuery.of(context).size.width * 1.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amberAccent.withOpacity(0.4),
                                blurRadius: 100,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        // 💡 ロースちゃん本体（巨大！）
                        Image.asset(
                          'assets/images/home_screen_center.png',
                          width: MediaQuery.of(context).size.width * 2.5, 
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 4. --- 前景のタイトルとボタン ---
            SafeArea(
              child: SizedBox(
                width: double.infinity, // 💡 これが重要！ボタンの土台を画面いっぱいに広げる
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // 💡 左右中央に揃える
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'Merry Learning! 🎄',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.greatVibes(
                          textStyle: const TextStyle(color: Colors.white, fontSize: 32), 
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'ベトナム語クイズ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansJp(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 38, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [Shadow(color: Colors.black54, offset: Offset(2, 4), blurRadius: 10)],
                          ),
                        ),
                      ),
                      Text(
                        '3択ロース',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansJp(
                          textStyle: const TextStyle(
                            color: Colors.amberAccent, 
                            fontSize: 42, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            shadows: [Shadow(color: Colors.black54, offset: Offset(2, 4), blurRadius: 10)],
                          ),
                        ),
                      ),
                      const Spacer(), 
                      
                      // 学習をはじめるボタン
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 65, 
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
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                              side: const BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🎁', style: TextStyle(fontSize: 26)), 
                              SizedBox(width: 15),
                              Text(
                                '学習をはじめる',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // キャラクター紹介ボタン
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 55, 
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CharacterIntroScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9), 
                            foregroundColor: const Color(0xFF2E7D32),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('📖', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 15),
                              Text(
                                'キャラクター紹介',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 雪の結晶パーツ ---
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 80, left: 40, size: 80, opacity: 0.2), 
      _p(top: 180, right: 60, size: 70, opacity: 0.2),
      _p(top: 350, left: 20, size: 120, opacity: 0.1), 
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom, 
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}