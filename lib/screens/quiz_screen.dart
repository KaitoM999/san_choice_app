import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 💡 共通背景と新しいモデルをインポート
import '../widgets/snowy_background.dart';
import '../models/word_model.dart';
import '../models/quiz_model.dart';
import '../models/language_config.dart'; // 💡 ルールブックをインポート
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int blockNumber; 
  final bool isVietToJpn; 
  final LanguageConfig currentLanguage; // 💡 選択中の言語を受け取る

  const QuizScreen({
    super.key, 
    required this.blockNumber, 
    required this.isVietToJpn,
    required this.currentLanguage, // 💡 追加
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts(); 
  
  bool _isLoading = true;
  List<Quiz> _quizList = [];
  
  int _currentIndex = 0; 
  bool _isAnswered = false; 
  int? _selectedIndex; 
  int _score = 0; 

  String _currentImagePath = '';
  bool _isSantaMode = false; 

  late bool _isFlipped; 
  late AnimationController _floatController; 
  late Animation<double> _floatAnimation; 

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  final String interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8282996158486757/6242269475'
      : 'ca-app-pub-8282996158486757/2891228159';

  @override
  void initState() {
    super.initState();
    // 💡 受け取った言語のTTSコードをセット！
    _tts.setLanguage(widget.currentLanguage.ttsCode);
    _tts.setSpeechRate(0.5);
    _isFlipped = false; 
    _pickConsideringImage();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _initQuizData();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose(); 
              _navigateToResult(); 
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _navigateToResult(); 
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('⚠️ 全画面広告の読み込み失敗: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose(); 
    _floatController.dispose();
    _tts.stop(); 
    super.dispose();
  }

  Future<void> _navigateToResult() async {
    _tts.stop();
    final currentScore = _score;
    final currentTotal = _quizList.length;

    await _saveScore();
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: currentScore,
          totalQuestions: currentTotal,
        ),
      ),
    );
  }

  Future<void> _initQuizData() async {
    // 💡 選ばれている言語のJSONファイルを読み込む！
    final String response = await rootBundle.loadString('assets/data/${widget.currentLanguage.jsonFileName}');
    final List<dynamic> data = json.decode(response);
    List<Word> allWords = data.map((json) => Word.fromJson(json)).toList();
    
    int start = (widget.blockNumber - 1) * 6;
    int end = (start + 6 > allWords.length) ? allWords.length : start + 6;
    List<Word> targetWords = allWords.sublist(start, end);

    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    List<Quiz> generatedQuizzes = [];

    for (var targetWord in targetWords) {
      List<Word> samePosWords = allWords.where((w) => 
        w.partOfSpeech == targetWord.partOfSpeech && w.text != targetWord.text
      ).toList();

      samePosWords.shuffle(random);
      List<Word> dummies = [];
      
      if (samePosWords.length >= 2) {
        dummies = samePosWords.take(2).toList();
      } else {
        List<Word> anyOtherWords = allWords.where((w) => w.text != targetWord.text).toList();
        anyOtherWords.shuffle(random);
        dummies = anyOtherWords.take(2).toList();
      }

      List<Word> options = [targetWord, ...dummies];
      options.shuffle(random);

      int correctIndex = options.indexOf(targetWord);

      generatedQuizzes.add(Quiz(
        question: targetWord,
        options: options,
        correctIndex: correctIndex,
      ));
    }

    if (mounted) {
      setState(() {
        _quizList = generatedQuizzes;
        _isLoading = false;
      });
    }
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
    // 💡 言語ごとにスコアを分けて保存 (例: score_vi_1)
    await prefs.setInt('score_${widget.currentLanguage.id}_${widget.blockNumber}', _score);
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF8B0000),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final quiz = _quizList[_currentIndex];

    final bool isCorrect = _isAnswered && _selectedIndex == quiz.correctIndex;
    final String displayQuestionText = widget.isVietToJpn 
        ? quiz.question.text 
        : quiz.question.meaning; 
    
    // 💡 ベトナム語固定から、現在の言語のTTSコードに変更
    final String questionTtsLang = widget.isVietToJpn ? widget.currentLanguage.ttsCode : "ja-JP";

    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      body: SnowyBackground(
        child: Stack(
          children: [
            if (!_isAnswered) _buildCharacter(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
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
                                // 💡 ここも動的言語に
                                _tts.setLanguage(widget.currentLanguage.ttsCode); 
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
              SafeArea(child: _buildFeedbackModal(quiz, isCorrect)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Block ${widget.blockNumber}  [${_currentIndex + 1}/${_quizList.length}]',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFeedbackModal(Quiz quiz, bool isCorrect) {
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
                        margin: const EdgeInsets.only(bottom: 12),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(word.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          word.partOfSpeech, 
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 35, 48)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    // 💡 ここも動的言語に
                                    _tts.setLanguage(widget.currentLanguage.ttsCode);
                                    _tts.speak(word.text);
                                  },
                                  icon: const Icon(Icons.volume_up, size: 26, color: Colors.blueAccent),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('意味: ${word.meaning}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                            
                            const Divider(height: 16, thickness: 1),
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('例文:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(word.example, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              // 💡 ここも動的言語に
                                              _tts.setLanguage(widget.currentLanguage.ttsCode);
                                              _tts.speak(word.example);
                                            },
                                            icon: const Icon(Icons.volume_up, size: 20, color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(word.exampleMeaning, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                      if (_currentIndex < _quizList.length - 1) {
                        setState(() {
                          _currentIndex++;
                          _isAnswered = false;
                          _selectedIndex = null;
                          _isFlipped = !_isFlipped; 
                          _pickConsideringImage();
                        });
                      } else {
                        if (_isInterstitialAdReady && _interstitialAd != null) {
                          _interstitialAd!.show();
                        } else {
                          await _navigateToResult();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      _currentIndex < _quizList.length - 1 ? '次の問題へ' : '結果を見る',
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

  List<Widget> _buildStars() => [_pStar(top: 80, left: 50, size: 30), _pStar(top: 150, right: 60, size: 45), _pStar(bottom: 200, left: 80, size: 35), _pStar(bottom: 300, right: 40, size: 50)];
  Widget _pStar({double? top, double? left, double? right, double? bottom, required double size}) => Positioned(top: top, left: left, right: right, bottom: bottom, child: Icon(Icons.star, color: Colors.amberAccent, size: size));
}