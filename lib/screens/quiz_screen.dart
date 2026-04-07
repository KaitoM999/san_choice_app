import 'dart:convert';
import 'dart:math' as math; // ランダムと反転用
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final int blockNumber;
  const QuizScreen({super.key, required this.blockNumber});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late Future<List<Quiz>> _quizFuture;
  int _currentIndex = 0;
  bool _isAnswered = false;
  int? _selectedIndex;
  int _score = 0;
  bool _isFinished = false;

  // 💡 ランダム配置・アニメーション用の変数
  late bool _isFlipped; 
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("vi-VN");
    _tts.setSpeechRate(0.5);
    _quizFuture = _loadQuizData();
    
    // 💡 画面起動時に左右どちらに置くかランダム決定
    _isFlipped = math.Random().nextBool();

    // 💡 ふわふわ浮遊アニメーションの設定
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score_${widget.blockNumber}', _score);
  }

  Future<List<Quiz>> _loadQuizData() async {
    final String response = await rootBundle.loadString('assets/data/quiz_data.json');
    final List<dynamic> data = json.decode(response);
    List<Quiz> allQuizzes = data.map((json) => Quiz.fromJson(json)).toList();
    
    int start = (widget.blockNumber - 1) * 6;
    int end = (start + 6 > allQuizzes.length) ? allQuizzes.length : start + 6;
    
    return allQuizzes.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quiz>>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF8B0000),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('データの読み込みに失敗しました')));
        }

        final quizList = snapshot.data!;
        if (_isFinished) return _buildResultScreen(quizList);

        final quiz = quizList[_currentIndex];
        final bool isCorrect = _selectedIndex == quiz.correctIndex;

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
                ..._buildSnowflakes(), // 背景の雪

                // 💡 特大ロースちゃんの浮遊配置
                Positioned(
                  bottom: -70,
                  left: _isFlipped ? -270 : null,
                  right: _isFlipped ? null : -270,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_floatAnimation.value),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(_isFlipped ? math.pi : 0),
                            child: Image.asset(
                              'assets/images/lauschan_tonakaikun_considering.png',
                              width: MediaQuery.of(context).size.width * 1.8,
                              height: 400,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(quizList),
                      
                      // 問題文エリア
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              quiz.question.text,
                              style: GoogleFonts.notoSansJp(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64, // 💡 文字を大きく
                                  fontWeight: FontWeight.w900,
                                  shadows: [Shadow(color: Colors.black45, blurRadius: 15)],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              onPressed: () => _tts.speak(quiz.question.text),
                              icon: const Icon(Icons.volume_up, color: Colors.white, size: 50),
                            ),
                          ],
                        ),
                      ),

                      // 選択肢エリア
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: List.generate(quiz.options.length, (index) {
                            final isCorrectBtn = index == quiz.correctIndex;
                            final isSelectedBtn = index == _selectedIndex;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                height: 75,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isAnswered
                                        ? (isCorrectBtn ? Colors.green : (isSelectedBtn ? Colors.red : Colors.white12))
                                        : Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    if (_isAnswered) return;
                                    setState(() {
                                      _selectedIndex = index;
                                      _isAnswered = true;
                                      if (index == quiz.correctIndex) _score++;
                                    });
                                    _tts.speak(quiz.options[index].meaning);
                                  },
                                  child: Text(
                                    quiz.options[index].meaning,
                                    style: GoogleFonts.mPlus1p(
                                      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isAnswered) _buildFeedbackOverlay(quiz, isCorrect, quizList),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(List<Quiz> quizList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
          Text(
            'Block ${widget.blockNumber}  [${_currentIndex + 1}/${quizList.length}]',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverlay(Quiz quiz, bool isCorrect, List<Quiz> quizList) {
    return Container(
      color: Colors.black87,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            isCorrect ? '⭕️ 正解！' : '❌ 不正解...',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: isCorrect ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Text('【 解説 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: quiz.options.length,
                      itemBuilder: (context, index) {
                        final word = quiz.options[index];
                        final isCorrectOption = index == quiz.correctIndex;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrectOption ? Colors.green.withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: isCorrectOption ? Colors.green : Colors.transparent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(word.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  IconButton(onPressed: () => _tts.speak(word.text), icon: const Icon(Icons.volume_up, size: 22)),
                                ],
                              ),
                              Text('意味: ${word.meaning}', style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentIndex < quizList.length - 1) {
                          setState(() {
                            _currentIndex++;
                            _isAnswered = false;
                            _selectedIndex = null;
                            _isFlipped = math.Random().nextBool(); // 次の問題で向きを再抽選
                          });
                        } else {
                          await _saveScore();
                          setState(() => _isFinished = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        _currentIndex < quizList.length - 1 ? '次の問題へ' : '結果を見る',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResultScreen(List<Quiz> quizList) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFE53935), Color(0xFF8B0000)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 120, color: Colors.amberAccent),
            const SizedBox(height: 20),
            Text(
              'ブロック終了！',
              style: GoogleFonts.notoSansJp(
                textStyle: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${quizList.length}問中 $_score 問正解',
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
              child: const Text('戻る', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 100, left: 30, size: 40),
      _p(top: 250, right: 40, size: 60, opacity: 0.1),
      _p(bottom: 100, left: 20, size: 50),
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.3}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}