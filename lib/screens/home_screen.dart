import 'dart:math' as math; // キャラクターをフワフワ上下に動かすための「サイン波（math.sin）」を使うためにインポート
import 'package:flutter/material.dart'; // Flutterの基本的なUIパーツ群
import 'package:google_fonts/google_fonts.dart'; // アプリのタイトルやボタンのフォントをおしゃれにするためのパッケージ
import 'block_selection_screen.dart'; // 「学習をはじめる」ボタンを押したときの移動先（次の画面）

// アプリを起動して最初に表示される「ホーム画面」の土台（StatefulWidget）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 実際のホーム画面の動きや見た目を作るStateクラス
// SingleTickerProviderStateMixin は、アニメーションを滑らかに動かすための「タイマー」の役割
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
            // 一番奥：背景に散りばめる雪の結晶を描画（...はリストの中身を展開する書き方）
            ..._buildSnowflakes(),

            // 真ん中：スマホのステータスバー（時計や電池）などに被らないようにする安全地帯(SafeArea)
            SafeArea(
              child: Center(
                // 画面の中央に、上から下へ順番に要素を並べる
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 縦方向の真ん中に寄せる
                  children: [
                    // 英語のオシャレなサブタイトル
                    Text(
                      'Merry Learning! 🎄',
                      style: GoogleFonts.greatVibes(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 5), // 少しだけ隙間を空ける
                    
                    // アプリのメインタイトル（上段）
                    Text(
                      'ベトナム語クイズ',
                      style: GoogleFonts.notoSansJp(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2, // 文字と文字の間隔を少し広げる
                          // 文字をくっきり見せるための黒い影（ドロップシャドウ）
                          shadows: [
                            Shadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),

                    // アプリのメインタイトル（下段）
                    Text(
                      '3択ロース',
                      style: GoogleFonts.notoSansJp(
                        textStyle: const TextStyle(
                          color: Colors.amberAccent, // ここだけ目立つ黄色
                          fontSize: 48, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4, // ベトナム語クイズよりもさらに文字間隔を広げる
                          shadows: [
                            Shadow(color: Colors.black45, offset: Offset(2, 4), blurRadius: 10),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10), // タイトルと画像の間を少し空ける

                    // メインキャラクター（ニョッキとカルビ）の画像＆アニメーション
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        // 💡 サイン波（math.sin）を使って、滑らかな「波」のような動きを作る
                        // ±15ピクセルの範囲で、フワ〜ッ、フワ〜ッと上下に移動する
                        final offset = math.sin(_controller.value * 2 * math.pi) * 15; 
                        
                        return Transform.translate(
                          // 計算した移動量（offset）をY軸（上下方向）に適用する
                          offset: Offset(0, offset), 
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 💡 画像の後ろで光る「後光（ハロー）」のエフェクト
                              Container(
                                width: 300, 
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, // 丸い形
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellowAccent.withOpacity(0.3), // 薄い黄色
                                      blurRadius: 70, // ぼかしを強くして、光がぼんやり広がるようにする
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              // 💡 実際のキャラクター画像
                              Image.asset(
                                'assets/images/lauschan_tonakaikun.png',
                                width: MediaQuery.of(context).size.width * 0.98, // 画面幅いっぱいに大きく表示
                                height: 480,
                                fit: BoxFit.cover, // 画像を枠に合わせていい感じに表示
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 10), // 画像とスタートボタンの間を少し空ける

                    // スタートボタン（「学習をはじめる」）
                    Padding(
                      // ボタンの両端に少し余白を作る
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: ElevatedButton(
                        // ボタンが押された時の処理
                        onPressed: () {
                          // ブロック選択画面（BlockSelectionScreen）へ移動する
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BlockSelectionScreen()),
                          );
                        },
                        // ボタンの見た目の設定
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32), // クリスマスっぽい深い緑色
                          foregroundColor: Colors.white, // 文字色は白
                          minimumSize: const Size(double.infinity, 75), // 横幅いっぱい、高さ75の大きなボタン
                          elevation: 12, // 影を強くして、ボタンが浮いているように見せる
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35), // ボタンの角をすごく丸くする
                            side: const BorderSide(color: Colors.white30, width: 2), // ボタンの周りに薄い白い枠線をつける
                          ),
                        ),
                        // ボタンの中身（横並び）
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // 真ん中に寄せる
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 28)), // 左側のプレゼントの絵文字
                            const SizedBox(width: 15), // 絵文字と文字の隙間
                            // 「学習をはじめる」の文字
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
                    const SizedBox(height: 20), // 画面の一番下に少し余白を作る
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
      _p(top: 350, left: 20, size: 120, opacity: 0.15), // とても大きくて薄い、遠くにあるような雪
      _p(bottom: 150, right: 30, size: 80),
      _p(bottom: 80, left: 90, size: 60),
    ];
  }

  // 雪の結晶アイコン1つを好きな位置（上下左右）に配置するための補助部品
  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom, // 指定された位置に配置
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size), // 雪の結晶アイコン
    );
  }
}