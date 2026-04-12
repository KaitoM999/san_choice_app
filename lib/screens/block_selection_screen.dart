import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/quiz_model.dart'; // 💡 Quizモデルをインポート（データを取り出すため）
import 'quiz_screen.dart'; 

class BlockSelectionScreen extends StatefulWidget {
  const BlockSelectionScreen({super.key});

  @override
  State<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
}

class _BlockSelectionScreenState extends State<BlockSelectionScreen> with SingleTickerProviderStateMixin {
  
  Map<int, int> _scores = {};
  late AnimationController _thinkingController;
  
  int _totalBlocks = 0; 
  bool _isLoading = true; 
  bool _isVietToJpn = true;

  // 💡 追加：全クイズデータを保持するリスト
  List<Quiz> _allQuizzes = [];

  @override
  void initState() {
    super.initState();
    _initializeData(); 
    
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

  Future<void> _initializeData() async {
    await _loadTotalBlocks(); 
    await _loadScores();      
    
    if (mounted) {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  // 💡 修正：JSONからクイズデータをすべて読み込んで保持する
  Future<void> _loadTotalBlocks() async {
    try {
      final String response = await rootBundle.loadString('assets/data/quiz_data.json');
      final List<dynamic> data = json.decode(response);
      
      // JSONデータをQuizモデルのリストに変換
      _allQuizzes = data.map((json) => Quiz.fromJson(json)).toList();
      _totalBlocks = (_allQuizzes.length / 6).ceil();
    } catch (e) {
      debugPrint("データの読み込みエラー: $e");
      _totalBlocks = 0; 
    }
  }

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
            ..._buildSnowflakes(),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),

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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'ブロック選択',
              style: GoogleFonts.notoSansJp(
                textStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          _buildModeToggleButton(),
        ],
      ),
    );
  }

  Widget _buildModeToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isVietToJpn = !_isVietToJpn;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), 
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isVietToJpn ? '🇻🇳 ➔ 🇯🇵' : '🇯🇵 ➔ 🇻🇳',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.autorenew, color: Colors.white, size: 20), 
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard(int index) {
    final int blockNum = index + 1; 
    final int? currentScore = _scores[blockNum]; 
    
    // 💡 ブロックの最初の問題のインデックスを計算
    final int firstQuestionIndex = index * 6;
    
    // 💡 タイトルに表示する文字を決定
    String blockTitle = 'Block $blockNum';
    if (firstQuestionIndex < _allQuizzes.length) {
      final quiz = _allQuizzes[firstQuestionIndex];
      // 現在のモードに合わせて、ベトナム語か日本語（正解の選択肢の意味）を取得
      blockTitle = _isVietToJpn 
          ? quiz.question.text 
          : quiz.options[quiz.correctIndex].meaning;
    }

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
          blockTitle, // 💡 ここを計算した単語に変更
          maxLines: 1, // 💡 単語が長すぎた場合に1行に収める
          overflow: TextOverflow.ellipsis, // 💡 はみ出た部分は「...」で省略
          style: GoogleFonts.mPlus1p(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24, // 💡 文字が長いことを考慮して少しだけ小さく調整 (28 -> 24)
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
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
        onTap: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                blockNumber: blockNum, 
                isVietToJpn: _isVietToJpn // 現在のモードをクイズ画面に渡す
              )
            )
          );
          _initializeData(); 
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