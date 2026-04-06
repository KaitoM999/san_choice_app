import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import '../models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final int blockNumber;
  const QuizScreen({super.key, required this.blockNumber});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FlutterTts _tts = FlutterTts();
  late Future<List<Quiz>> _quizFuture;
  int _currentIndex = 0;
  bool _isAnswered = false;
  int? _selectedIndex;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("vi-VN");
    _tts.setSpeechRate(0.5);
    _quizFuture = _loadQuizData();
  }

  // 追加：端末のストレージにスコアを保存するロジック
  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    // キー名を "score_1", "score_2" のようにして、ブロックごとに保存
    await prefs.setInt('score_${widget.blockNumber}', _score);
    print('Saved score: $_score for block ${widget.blockNumber}'); // デバッグ用
  }

  Future<List<Quiz>> _loadQuizData() async {
    final String response = await rootBundle.loadString('assets/data/quiz_data.json');
    final List<dynamic> data = json.decode(response);
    List<Quiz> allQuizzes = data.map((json) => Quiz.fromJson(json)).toList();

    int start = (widget.blockNumber - 1) * 6;
    int end = start + 6;
    if (end > allQuizzes.length) end = allQuizzes.length;
    
    return allQuizzes.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Quiz>>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A237E),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('データの読み込みに失敗しました')),
          );
        }

        final quizList = snapshot.data!;
        if (_isFinished) return _buildResultScreen(quizList);

        final quiz = quizList[_currentIndex];
        final bool isCorrect = _selectedIndex == quiz.correctIndex;

        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          appBar: AppBar(
            title: Text('Block ${widget.blockNumber} (${_currentIndex + 1}/${quizList.length})'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(quiz.question.text, style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => _tts.speak(quiz.question.text),
                          icon: const Icon(Icons.volume_up, color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: List.generate(quiz.options.length, (index) {
                        final isCorrectBtn = index == quiz.correctIndex;
                        final isSelectedBtn = index == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                          child: SizedBox(
                            width: double.infinity, height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isAnswered
                                    ? (isCorrectBtn ? Colors.green.withOpacity(0.8) : (isSelectedBtn ? Colors.red.withOpacity(0.8) : Colors.white10))
                                    : Colors.white10,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                if (_isAnswered) return;
                                setState(() {
                                  _selectedIndex = index;
                                  _isAnswered = true;
                                  if (index == quiz.correctIndex) _score++;
                                });
                                _tts.speak(quiz.question.text);
                              },
                              child: Text(quiz.options[index].meaning, style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              if (_isAnswered) _buildFeedbackOverlay(quiz, isCorrect, quizList),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackOverlay(Quiz quiz, bool isCorrect, List<Quiz> quizList) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Text(isCorrect ? '⭕️ 正解！' : '❌ 不正解...',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
              const SizedBox(height: 10),
              Icon(isCorrect ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied, size: 80, color: Colors.orange),
              const Divider(height: 30),
              const Text('【 選択肢の解説 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: quiz.options.length,
                  itemBuilder: (context, index) {
                    final word = quiz.options[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: index == quiz.correctIndex ? Colors.green.withOpacity(0.05) : Colors.grey[50],
                        border: Border.all(color: index == quiz.correctIndex ? Colors.green : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(word.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text('[${word.partOfSpeech}]', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const Spacer(),
                              IconButton(onPressed: () => _tts.speak(word.text), icon: const Icon(Icons.volume_up, size: 20)),
                            ],
                          ),
                          Text('意味: ${word.meaning}'),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(child: Text(word.example, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic))),
                              IconButton(onPressed: () => _tts.speak(word.example), icon: const Icon(Icons.play_circle_outline, size: 18)),
                            ],
                          ),
                          Text(word.exampleMeaning, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async { // async を追加
                    if (_currentIndex < quizList.length - 1) {
                      setState(() {
                        _currentIndex++;
                        _isAnswered = false;
                        _selectedIndex = null;
                      });
                    } else {
                      // 最終問題の解説を閉じるときに保存
                      await _saveScore();
                      setState(() {
                        _isFinished = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                  child: Text(_currentIndex < quizList.length - 1 ? '次の問題へ' : '結果を見る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(List<Quiz> quizList) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text('ブロック終了！', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('${quizList.length}問中 $_score 問正解',
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('ブロック選択画面へ戻る', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}