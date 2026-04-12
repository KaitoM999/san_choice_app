import 'dart:convert'; // JSON形式のデータをDartで扱えるようにするためのパッケージ
import 'package:flutter/material.dart'; // Flutterの基本UIパーツ（Widget）を使うためのパッケージ
import 'package:flutter/services.dart'; // rootBundleを使って、アプリ内のファイル（JSONなど）を読み込むためのパッケージ
import 'package:google_fonts/google_fonts.dart'; // Googleフォント（Noto SansやM PLUS 1pなど）を使うためのパッケージ
import 'package:shared_preferences/shared_preferences.dart'; // 端末にスコアなどのデータを保存・読み込みするためのパッケージ
import 'quiz_screen.dart'; // クイズ画面へ遷移するためにインポート

// ブロック選択画面の土台となるStatefulWidget（画面の状態が変化するWidget）
class BlockSelectionScreen extends StatefulWidget {
  const BlockSelectionScreen({super.key});

  @override
  State<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
}

// 実際の画面の動きや見た目を作るStateクラス
class _BlockSelectionScreenState extends State<BlockSelectionScreen> with SingleTickerProviderStateMixin {
  
  // 各ブロックの「過去の最高スコア」を保存する辞書（キーがブロック番号、値がスコア）
  Map<int, int> _scores = {};
  
  // 右下にいるキャラクターをフワフワ動かすためのコントローラー
  late AnimationController _thinkingController;
  
  int _totalBlocks = 0; // JSONから計算した、全体のブロック数
  bool _isLoading = true; // データを読み込み中かどうかを判定するフラグ

  // 💡 追加：出題形式を管理する変数（true: ベトナム語→日本語, false: 日本語→ベトナム語）
  bool _isVietToJpn = true;

  // 画面が表示される「最初の一度だけ」実行されるメソッド
  @override
  void initState() {
    super.initState();
    
    // データの読み込みを開始
    _initializeData(); 
    
    // キャラクターのフワフワアニメーションの設定
    _thinkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); 
  }

  // 画面が閉じられるときに実行される「お片付け」メソッド
  @override
  void dispose() {
    _thinkingController.dispose(); 
    super.dispose();
  }

  // データ読み込みの全体を管理するメソッド
  Future<void> _initializeData() async {
    await _loadTotalBlocks(); 
    await _loadScores();      
    
    if (mounted) {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  // JSONファイルから全問題数を取得し、ブロック数を計算するメソッド
  Future<void> _loadTotalBlocks() async {
    try {
      final String response = await rootBundle.loadString('assets/data/quiz_data.json');
      final List<dynamic> data = json.decode(response);
      final int totalQuestions = data.length;
      _totalBlocks = (totalQuestions / 6).ceil();
    } catch (e) {
      debugPrint("データの読み込みエラー: $e");
      _totalBlocks = 0; 
    }
  }

  // スマホ本体に保存されている過去のスコアを読み込むメソッド
  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance(); 
    Map<int, int> tempScores = {};
    
    for (int i = 1; i <= _totalBlocks; i++) {
      int? score = prefs.getInt('score_$i');
      if (score != null) {
        tempScores[i] = score; 
      }
    }
    _scores = tempScores; 
  }

  // 実際の画面のレイアウトを構築するメソッド
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
            // 背景の雪の結晶
            ..._buildSnowflakes(),

            SafeArea(
              child: Column(
                children: [
                  // 💡 上部のヘッダー（切り替えボタンもここに含まれます）
                  _buildHeader(context),

                  // メインのリスト部分
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 220),
                          itemCount: _totalBlocks, 
                          itemBuilder: (context, index) => _buildBlockCard(index),
                        ),
                  ),
                ],
              ),
            ),

            // 右下に表示されるキャラクターの画像
            Positioned(
              bottom: -270, 
              right: -240,  
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _thinkingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * _thinkingController.value),
                      child: Image.asset(
                        'assets/images/lauschan_tonakaikun_thinking.png',
                        width: MediaQuery.of(context).size.width * 1.6, 
                        height: MediaQuery.of(context).size.height * 1.0, 
                        fit: BoxFit.contain, 
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
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

  // --- 以下は画面を構成する「部品（メソッド）」の集まり ---

  // 上部のヘッダーを作る部品
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          // 💡 Expandedで囲むことで、画面が小さくてもボタンと文字が被らないようにする
          Expanded(
            child: Text(
              'ブロック選択',
              style: GoogleFonts.notoSansJp(
                textStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          // 💡 追加した切り替えボタンを右端に配置
          _buildModeToggleButton(),
        ],
      ),
    );
  }

  // 💡 追加：出題形式を切り替えるトグルボタンの部品
  Widget _buildModeToggleButton() {
    return GestureDetector(
      onTap: () {
        // タップされたら、trueとfalseをひっくり返す
        setState(() {
          _isVietToJpn = !_isVietToJpn;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), // 半透明の背景
          borderRadius: BorderRadius.circular(20), // 角丸
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), // 白い枠線
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // 現在の状態に合わせて表示するテキストを変更
              _isVietToJpn ? '🇻🇳 ➔ 🇯🇵' : '🇯🇵 ➔ 🇻🇳',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.autorenew, color: Colors.white, size: 20), // くるくる回る矢印アイコン
          ],
        ),
      ),
    );
  }

  // 1つのブロックカードを作る部品
  Widget _buildBlockCard(int index) {
    final int blockNum = index + 1; 
    final int? currentScore = _scores[blockNum]; 

    return Card(
      color: Colors.white.withOpacity(0.12), 
      elevation: 0, 
      margin: const EdgeInsets.only(bottom: 20), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1), 
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
        leading: CircleAvatar(
          radius: 28, 
          backgroundColor: const Color(0xFF2E7D32), 
          child: Text(
            '$blockNum', 
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
          ),
        ),
        title: Text(
          'Block $blockNum',
          style: GoogleFonts.mPlus1p(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28, 
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            currentScore != null ? '前回スコア: $currentScore / 6' : '未挑戦 🎁',
            style: TextStyle(
              color: currentScore != null ? Colors.amberAccent : Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
        onTap: () async {
          // 💡 本来ならここで _isVietToJpn の状態を QuizScreen に渡す必要があります！
          // 例: QuizScreen(blockNumber: blockNum, isVietToJpn: _isVietToJpn)
          await Navigator.push(
            
            context, 
            MaterialPageRoute(builder: (context) => QuizScreen(blockNumber: blockNum, isVietToJpn: _isVietToJpn))
          );
          _initializeData(); 
        },
      ),
    );
  }

  // 背景に散りばめる雪の結晶をリストにして返す部品
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 80, left: 40, size: 45),
      _p(top: 180, right: 60, size: 35),
      _p(top: 350, left: 20, size: 120, opacity: 0.1), 
      _p(bottom: 150, right: 30, size: 80),
    ];
  }

  // 雪の結晶アイコン1つを配置するための補助部品
  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}