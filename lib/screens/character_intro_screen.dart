import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// キャラクター紹介画面の土台
class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // ホーム画面と同じ、深い赤のグラデーション背景
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFE53935), Color(0xFF8B0000)],
          ),
        ),
        child: Stack(
          children: [
            // 背景の雪の結晶
            ..._buildSnowflakes(),

            SafeArea(
              child: Column(
                children: [
                  // 上部のヘッダー（戻るボタンとタイトル）
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context), // 前の画面（ホーム）に戻る
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'キャラクター紹介',
                          style: GoogleFonts.notoSansJp(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // キャラクターのカードを縦にスクロールして表示するエリア
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      // ここにキャラクターのプロフィールカードを順番に並べる
                      children: [
                        // ロースちゃんのカード
                        _buildCharacterCard(
                          name: 'ロースちゃん',
                          role: '3択ロース見習い',
                          description: '一流の3択ロースを目指している、元気で無邪気な女の子。おっちょこちょいで慌てん坊なのが玉に瑕！去年突然失踪した恩師のターキー博士を探してるよ！大好物はお母さんのクリスマス料理！',
                          imagePath: 'assets/images/lauschan_happy_2.png',
                          isImage: true,
                          imageScale: 2, // 💡 ここで大きさを調整！1.0が基本、1.2なら少し大きめ
                        ),
                        const SizedBox(height: 20),
                        
                        // トナカイくんのカード
                        _buildCharacterCard(
                          name: 'トナカイくん',
                          role: '食いしん坊な相棒',
                          description: 'ロースちゃんといつも一緒にいる相棒！いつも元気いっぱいでロースちゃんをサポートするけど結構なおっちょこちょいのスカポンタン！怒ると肉食になるよ！クリスマスの日も肉食になるよ！',
                          imagePath: 'assets/images/tonakaikun_happy.png',
                          isImage: true,
                          imageScale: 2, // 💡 ここで大きさを調整！
                        ),
                        const SizedBox(height: 20),
                        
                        // ターキー博士のカード
                        _buildCharacterCard(
                          name: 'ターキー博士',
                          role: 'ロースちゃんの恩師',
                          description: '享年：去年 命日：12/24 \nロースちゃんの恩師。なんでも知っている大博士だよ！彼の死についてロースちゃんはまだ何も知らないよ！でも彼の残した言葉や教えは今もロースちゃんの心に生き続けているよ！',
                          imagePath: 'assets/images/dr_turkey.png', 
                          isImage: true,
                          imageScale: 1.3, // 💡 ターキー博士は少し大きめにするなど、個別に設定可能です
                        ),
                        const SizedBox(height: 20),
                        
                        // クロスさん（お母さん）のカード
                        _buildCharacterCard(
                          name: 'クロスさん',
                          role: 'ロースちゃんのお母さん',
                          description: 'ロースちゃんを優しく見守るお母さんサンタ（元一流の３択ロース）。ロースちゃんのことを陰ながら見守ってるよ！お料理が大好きでクリスマスはいつも奮発してロースちゃんにご馳走を作ってくれるよ！',
                          imagePath: 'assets/images/claussan_sit.png',
                          isImage: true,
                          imageScale: 2, // 💡 ここで大きさを調整！
                        ),
                        const SizedBox(height: 40), // 一番下の余白
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- キャラクターのプロフィールカード1枚分を作る部品（メソッド） ---
  // 💡 パラメータに imageScale を追加し、初期値を 1.0 に設定
  Widget _buildCharacterCard({
    required String name,
    required String role,
    required String description,
    required String imagePath,
    required bool isImage, 
    double imageScale = 1.0, // 💡 追加：画像のズーム倍率
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // 少し透けた白色のカード
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // キャラクターの画像（または絵文字）
            Container(
              height: 220, // 💡 背景のグレーの箱自体も少し大きくしました（180 → 220）
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100], // 画像の後ろの薄いグレーの背景
                borderRadius: BorderRadius.circular(15),
              ),
              child: isImage
                  // 💡 ここに Transform.scale を追加して、パラメータの imageScale を適用
                  ? Transform.scale(
                      scale: imageScale,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        // もし画像が見つからなかった時のための予備表示
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    )
                  : Center(
                      child: Text(imagePath, style: const TextStyle(fontSize: 100)), // ターキー博士の絵文字用（今は画像なので使われないはずです）
                    ),
            ),
            const SizedBox(height: 20),
            
            // 役職・肩書き（例：食いしん坊コンビ）
            Text(
              role,
              style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            
            // キャラクター名
            Text(
              name,
              style: GoogleFonts.mPlus1p(
                textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
            ),
            
            // 区切り線
            const Divider(height: 30, thickness: 2, color: Colors.black12),
            
            // キャラクターの説明文
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // --- 背景の雪の結晶リスト ---
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 50, left: 30, size: 40),
      _p(top: 150, right: 40, size: 60, opacity: 0.1),
      _p(top: 400, left: 10, size: 80, opacity: 0.15),
      _p(bottom: 200, right: 20, size: 50),
      _p(bottom: 50, left: 60, size: 70),
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.3}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}