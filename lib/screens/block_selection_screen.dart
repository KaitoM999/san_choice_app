import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_screen.dart';

class BlockSelectionScreen extends StatefulWidget {
  const BlockSelectionScreen({super.key});

  @override
  State<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
}

class _BlockSelectionScreenState extends State<BlockSelectionScreen> with SingleTickerProviderStateMixin {
  Map<int, int> _scores = {};
  late AnimationController _thinkingController;

  @override
  void initState() {
    super.initState();
    _loadScores();
    _thinkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _thinkingController.dispose();
    super.dispose();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, int> tempScores = {};
    for (int i = 1; i <= 200; i++) {
      int? score = prefs.getInt('score_$i');
      if (score != null) tempScores[i] = score;
    }
    if (mounted) setState(() => _scores = tempScores);
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
            // 背景の雪
            ..._buildSnowflakes(),

            SafeArea(
              child: Column(
                children: [
                  // ヘッダー
                  _buildHeader(context),

                  // リスト部分
                  Expanded(
                    child: ListView.builder(
                      // 下に画像が重なるので、リストの最後に大きな余白(200px)を空ける
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 220),
                      itemCount: 200,
                      itemBuilder: (context, index) => _buildBlockCard(index),
                    ),
                  ),
                ],
              ),
            ),

            // --- 💡 修正のキモ：画像を大きく、大胆に右下へ ---
            Positioned(
              // 1. 画像全体を包む Container の height: 250 を取り払います。
              // 代わりに Positioned の top を指定して、高さを確保します。
              // bottom と right の負の値を大きくします（画面外へ深く食い込ませる）。
              bottom: -270, // 以前の -10 から -90 へ大幅ダウン。さらに下へ。
              right: -240,  // 以前の -10 から -30 へ大幅ダウン。さらに右へ。
              child: IgnorePointer( // 画像がリストのクリックを邪魔しないようにする
                child: AnimatedBuilder(
                  animation: _thinkingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * _thinkingController.value),
                      child: Container(
                        // 2. Container の height を削除！
                        // 3. Container の decoration も削除（白い箱の原因になり得る）！

                        // 4. Image.asset の width と height を大きく指定！
                        child: Image.asset(
                          'assets/images/lauschan_tonakaikun_thinking.png',
                          // widthは指定せず、高さに合わせて自動調整（アスペクト比維持）
                          width: MediaQuery.of(context).size.width * 1.6, // 以前の1.3から大幅アップ
                          height: MediaQuery.of(context).size.height * 1.0, // 以前の1.3から大幅アップ
                          fit: BoxFit.contain, // イラストが歪まないように収める
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 部品化してコードをスッキリ ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Text(
            '学習ブロック選択',
            style: GoogleFonts.notoSansJp(
              textStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

// --- 💡 このメソッドをまるごと差し替えてください ---
  Widget _buildBlockCard(int index) {
    final int blockNum = index + 1;
    final int? currentScore = _scores[blockNum];

    return Card(
      color: Colors.white.withOpacity(0.12),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20), // カードの間隔も少し広げました
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // 上下の幅を広く
        leading: CircleAvatar(
          radius: 28, // 左の丸も一回り大きく
          backgroundColor: const Color(0xFF2E7D32),
          child: Text(
            '$blockNum', 
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
          ),
        ),
        // 💡 Block 1 の文字を大きく
        title: Text(
          'Block $blockNum',
          style: GoogleFonts.mPlus1p(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28, // 18前後から28へ大幅アップ！
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        // 💡 未挑戦 / スコア の文字を大きく
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            currentScore != null ? '前回スコア: $currentScore / 6' : '未挑戦 🎁',
            style: TextStyle(
              color: currentScore != null ? Colors.amberAccent : Colors.white, // 未挑戦を白にして見やすく
              fontSize: 22, // 14前後から22へアップ！
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 右側の再生ボタンも少し大きく
        trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
        onTap: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => QuizScreen(blockNumber: blockNum))
          );
          _loadScores();
        },
      ),
    );
  }

  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 80, left: 40, size: 45),
      _p(top: 180, right: 60, size: 35),
      _p(top: 350, left: 20, size: 120, opacity: 0.1),
      _p(bottom: 150, right: 30, size: 80),
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}