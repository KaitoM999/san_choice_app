import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_model.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int blockNumber; 
  final bool isVietToJpn; 

  const QuizScreen({super.key, required this.blockNumber, required this.isVietToJpn});

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

  String _currentImagePath = '';
  bool _isSantaMode = false; 

  late bool _isFlipped; 
  late AnimationController _floatController; 
  late Animation<double> _floatAnimation; 

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("vi-VN");
    _tts.setSpeechRate(0.5);
    _quizFuture = _loadQuizData();
    _isFlipped = false; 
    _pickConsideringImage();

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

  void _pickConsideringImage() {
    final int rand = math.Random().nextInt(100);
    if (rand < 85) {
      _isSantaMode = false;
      _currentImagePath = 'assets/images/lauschan_tonakaikun_considering.png';
    } else {
      _isSantaMode = true;
      _currentImagePath = 'assets/images/claussan_normal.png';
    }
  }

  void _setReactionImage(bool isCorrect) {
    if (!mounted) return;
    setState(() {
      if (_isSantaMode) {
        if (isCorrect) {
          _currentImagePath = 'assets/images/claussan_happy.png';
        } else {
          _currentImagePath = math.Random().nextBool() 
            ? 'assets/images/claussan_angry.png' 
            : 'assets/images/claussan_araara.png';
        }
      } else {
        if (isCorrect) {
          _currentImagePath = 'assets/images/lauschan_tonakaikun_happy.png';
        } else {
          _currentImagePath = math.Random().nextBool() 
            ? 'assets/images/lauschan_tonakaikun_sad.png' 
            : 'assets/images/lauschan_tonakaikun_angry.png';
        }
      }
    });
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score_${widget.blockNumber}', _score);
  }

  Future<List<Quiz>> _loadQuizData() async {
    final String response = await rootBundle.loadString('assets/data/quiz_data.json');
    final List<dynamic> data = json.decode(response);
    List<Quiz> quizzes = data.map((json) => Quiz.fromJson(json)).toList();
    int start = (widget.blockNumber - 1) * 6;
    int end = (start + 6 > quizzes.length) ? quizzes.length : start + 6;
    return quizzes.sublist(start, end);
  }

  Widget _buildCharacter() {
    return Positioned(
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
                  _currentImagePath,
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
    );
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
        final quiz = quizList[_currentIndex];
        final bool isCorrect = _isAnswered && _selectedIndex == quiz.correctIndex;
        final String displayQuestionText = widget.isVietToJpn 
            ? quiz.question.text 
            : quiz.options[quiz.correctIndex].meaning;
        final String questionTtsLang = widget.isVietToJpn ? "vi-VN" : "ja-JP";

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
                if (!_isAnswered) _buildCharacter(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(quizList),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              displayQuestionText, 
                              style: GoogleFonts.notoSansJp(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  shadows: [Shadow(color: Colors.black45, blurRadius: 15)],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              onPressed: () {
                                _tts.setLanguage(questionTtsLang); 
                                _tts.speak(displayQuestionText);
                              },
                              icon: const Icon(Icons.volume_up, color: Colors.white, size: 50),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: List.generate(quiz.options.length, (index) {
                            final isCorrectBtn = index == quiz.correctIndex;
                            final isSelectedBtn = index == _selectedIndex;
                            final String displayOptionText = widget.isVietToJpn
                                ? quiz.options[index].meaning 
                                : quiz.options[index].text;

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
                                      if (index == quiz.correctIndex) {
                                        _score++;
                                        _setReactionImage(true);
                                      } else {
                                        _setReactionImage(false);
                                      }
                                    });
                                    _tts.setLanguage("vi-VN"); 
                                    _tts.speak(quiz.options[index].text);
                                  },
                                  child: Text(
                                    displayOptionText,
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
                if (_isAnswered) ...[
                  Positioned.fill(child: Container(color: Colors.black54)), 
                  if (isCorrect) ..._buildStars(),
                  _buildCharacter(),
                  SafeArea(child: _buildFeedbackModal(quiz, isCorrect, quizList)),
                ],
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

  Widget _buildFeedbackModal(Quiz quiz, bool isCorrect, List<Quiz> quizList) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(
          isCorrect ? '⭕️ 正解！' : '❌ 不正解...',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: isCorrect ? Colors.greenAccent : Colors.redAccent,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 260),
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: index == quiz.correctIndex ? Colors.green.withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: index == quiz.correctIndex ? Colors.green : Colors.transparent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(word.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () {
                                    _tts.setLanguage("vi-VN");
                                    _tts.speak(word.text);
                                  },
                                  icon: const Icon(Icons.volume_up, size: 22),
                                ),
                              ],
                            ),
                            Text('意味: ${word.meaning}', style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentIndex < quizList.length - 1) {
                        setState(() {
                          _currentIndex++;
                          _isAnswered = false;
                          _selectedIndex = null;
                          _isFlipped = !_isFlipped; 
                          _pickConsideringImage();
                        });
                      } else {
                        // 1. 準備
                        _tts.stop();
                        final navigator = Navigator.of(context); // 💡 事前に確保
                        final currentScore = _score;
                        final currentTotal = quizList.length;

                        await _saveScore();
                        
                        // 2. 💡 Async Gap 対策とエンジンの安定待ち
                        if (!context.mounted) return;
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (!context.mounted) return;

                        // 3. 💡 Navigatorを呼び出す（あえて標準のアニメーションを少し残す）
                        navigator.pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ResultScreen(
                              score: currentScore,
                              totalQuestions: currentTotal,
                            ),
                          ),
                        );
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
      ],
    );
  }

  List<Widget> _buildSnowflakes() => [_p(top: 100, left: 30, size: 40), _p(top: 250, right: 40, size: 60, opacity: 0.1), _p(bottom: 100, left: 20, size: 50)];
  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.3}) => Positioned(top: top, left: left, right: right, bottom: bottom, child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size));
  List<Widget> _buildStars() => [_pStar(top: 80, left: 50, size: 30), _pStar(top: 150, right: 60, size: 45), _pStar(bottom: 200, left: 80, size: 35), _pStar(bottom: 300, right: 40, size: 50)];
  Widget _pStar({double? top, double? left, double? right, double? bottom, required double size}) => Positioned(top: top, left: left, right: right, bottom: bottom, child: Icon(Icons.star, color: Colors.amberAccent, size: size));
}