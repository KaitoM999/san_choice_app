import 'dart:math' as math; // キャラクターをフワフワ上下に動かすための「サイン波（math.sin）」を使うためにインポート
import 'package:flutter/material.dart'; // Flutterの基本的なUIパーツ群
import 'package:google_fonts/google_fonts.dart'; // アプリのタイトルやボタンのフォントをおしゃれにするためのパッケージ
import 'block_selection_screen.dart'; // 「学習をはじめる」ボタンを押したときの移動先（次の画面）
// キャラクター紹介画面へのインポート
import 'character_intro_screen.dart'; 

// アプリを起動して最初に表示される「ホーム画面」の土台（StatefulWidget）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 実際のホーム画面の動きや見た目を作るStateクラス
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // アニメーションの進行状況（0%から100%など）を管理するコントローラー
  late AnimationController _controller;

  // 画面が表示される「最初の一度だけ」実行されるメソッド
  @override
  void initState() {
    super.initState();
    // アニメーションのタイマー設定（2秒かけて動く）
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 行って戻る（reverse: true）を永遠に繰り返す（repeat）
  }

  // 画面が閉じられるときに実行される「お片付け」メソッド
  @override
  void dispose() {
    _controller.dispose(); // メモリの無駄遣いを防ぐため、アニメーションのタイマーを破棄する
    super.dispose();
  }

  // 実際の画面のレイアウトを構築するメソッド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面全体の背景設定
      body: Container(
        decoration: const BoxDecoration(
          // サンタレッドから暗い赤へと広がる、円形（Radial）のグラデーション
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFE53935), Color(0xFF8B0000)],
          ),
        ),
        // Stackを使って、奥の背景から手前のボタンまで順番に重ねて配置する
        child: Stack(
          children: [
            // 一番奥：背景に散りばめる雪の結晶を描画
            ..._buildSnowflakes(),

            // 真ん中：スマホのステータスバー（時計や電池）などに被らないようにする安全地帯(SafeArea)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 縦方向の真ん中に寄せる
                  children: [
                    const SizedBox(height: 20), // 上部のわずかな余白
                    
                    // --- タイトルエリア ---
                    Text(
                      'Merry Learning! 🎄',
                      style: GoogleFonts.greatVibes(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 28), 
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    Text(
                      '３択ロース',
                      style: GoogleFonts.notoSansJp(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 38, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 10)],
                        ),
                      ),
                    ),

                    Text(
                      'ベトナム語単語',
                      style: GoogleFonts.notoSansJp(
                        textStyle: const TextStyle(
                          color: Colors.amberAccent, 
                          fontSize: 38, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [Shadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 10)],
                        ),
                      ),
                    ),
                    
                    // --- 画像エリア ---
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          // サイン波（math.sin）を使って、滑らかな「波」のような動きを作る
                          final offset = math.sin(_controller.value * 2 * math.pi) * 15; 
                          
                          return Transform.translate(
                            offset: Offset(0, offset), 
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 後光（ハロー）のエフェクト
                                Container(
                                  width: 250, 
                                  height: 250,
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
                                // 💡 画像を「Transform.scale」で囲むことで、レイアウトを崩さずにサイズを微調整できる！
                                Transform.scale(
                                  // 💡 ここの数字を変えると大きさが変わります！
                                  // 1.0が元のサイズ。1.2なら20%大きく、0.8なら20%小さくなります。
                                  // 1.3 や 1.4 など、好きな数字を入れて微調整してみてください。
                                  scale: 3, 
                                  child: Image.asset(
                                    'assets/images/lauschan_tonakaikun.png',
                                    fit: BoxFit.contain, 
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // --- ボタンエリア ---
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85, // 画面幅の85%のサイズ
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
                            side: const BorderSide(color: Colors.white30, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 26)), 
                            const SizedBox(width: 15),
                            Text(
                              '学習をはじめる',
                              style: GoogleFonts.mPlus1p(
                                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 15), // ボタン同士の隙間

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
                          backgroundColor: Colors.white.withOpacity(0.15), 
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.white54, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📖', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 15),
                            Text(
                              'キャラクター紹介',
                              style: GoogleFonts.mPlus1p(
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30), // 画面の一番下に少し余白を作る
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 以下は画面を構成する「部品（メソッド）」 ---

  // 背景に散りばめる雪の結晶をリストにして返す部品
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 80, left: 40, size: 80), 
      _p(top: 180, right: 60, size: 70),
      _p(top: 350, left: 20, size: 120, opacity: 0.15), 
      _p(bottom: 150, right: 30, size: 80),
      _p(bottom: 80, left: 90, size: 60),
    ];
  }

  // 雪の結晶アイコン1つを好きな位置（上下左右）に配置するための補助部品
  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom, 
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}