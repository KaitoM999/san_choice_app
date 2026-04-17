import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/snowy_background.dart'; // 💡 共通背景をインポート

// キャラクター紹介画面の土台
class CharacterIntroScreen extends StatelessWidget {
  const CharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), // 💡 背景のベースカラー
      // 💡 共通部品のSnowyBackgroundで全体を包む
      body: SnowyBackground(
        child: SafeArea(
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
                      imageScale: 2, 
                    ),
                    const SizedBox(height: 20),
                    
                    // トナカイくんのカード
                    _buildCharacterCard(
                      name: 'トナカイくん',
                      role: '食いしん坊な相棒',
                      description: 'ロースちゃんといつも一緒にいる相棒！いつも元気いっぱいでロースちゃんをサポートするけど結構なおっちょこちょいのスカポンタン！怒ると肉食になるよ！クリスマスの日も肉食になるよ！',
                      imagePath: 'assets/images/tonakaikun_happy.png',
                      isImage: true,
                      imageScale: 2, 
                    ),
                    const SizedBox(height: 20),
                    
                    // ターキー博士のカード
                    _buildCharacterCard(
                      name: 'ターキー博士',
                      role: 'ロースちゃんの恩師',
                      description: '享年：去年 命日：12/24 \nロースちゃんの恩師。なんでも知っている大博士だよ！彼の死についてロースちゃんはまだ何も知らないよ！でも彼の残した言葉や教えは今もロースちゃんの心に生き続けているよ！',
                      imagePath: 'assets/images/dr_turkey.png', 
                      isImage: true,
                      imageScale: 1.3, 
                    ),
                    const SizedBox(height: 20),
                    
                    // クロスさん（お母さん）のカード
                    _buildCharacterCard(
                      name: 'クロスさん',
                      role: 'ロースちゃんのお母さん',
                      description: 'ロースちゃんを優しく見守るお母さんサンタ（元一流の３択ロース）。ロースちゃんのことを陰ながら見守ってるよ！お料理が大好きでクリスマスはいつも奮発してロースちゃんにご馳走を作ってくれるよ！',
                      imagePath: 'assets/images/claussan_sit.png',
                      isImage: true,
                      imageScale: 2, 
                    ),
                    const SizedBox(height: 40), // 一番下の余白
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- キャラクターのプロフィールカード1枚分を作る部品（メソッド） ---
  Widget _buildCharacterCard({
    required String name,
    required String role,
    required String description,
    required String imagePath,
    required bool isImage, 
    double imageScale = 1.0, 
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), 
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 220, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100], 
                borderRadius: BorderRadius.circular(15),
              ),
              child: isImage
                  ? Transform.scale(
                      scale: imageScale,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    )
                  : Center(
                      child: Text(imagePath, style: const TextStyle(fontSize: 100)), 
                    ),
            ),
            const SizedBox(height: 20),
            
            Text(
              role,
              style: TextStyle(fontSize: 16, color: Colors.green[700], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            
            Text(
              name,
              style: GoogleFonts.mPlus1p(
                textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
            ),
            
            const Divider(height: 30, thickness: 2, color: Colors.black12),
            
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}