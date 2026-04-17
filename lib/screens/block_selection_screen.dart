import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

import '../models/word_model.dart'; 
import '../models/language_config.dart'; // 💡 ルールブックをインポート
import '../widgets/snowy_background.dart'; 
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

  List<Word> _allWords = [];
  
  // 💡 現在選択されている言語を入れる箱
  late LanguageConfig _currentLanguage;

  @override
  void initState() {
    super.initState();
    // とりあえずデフォルトをベトナム語にセットしておく
    _currentLanguage = LanguageConfig.supportedLanguages.first; 
    
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
    await _loadCurrentLanguage(); // 💡 まずはスマホに保存されている言語を読み込む
    await _loadTotalBlocks(); 
    await _loadScores();      
    
    if (mounted) {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  // 💡 SharedPreferencesから選択中の言語を取得する処理
  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangId = prefs.getString('selected_language') ?? 'vi'; // 保存されてなければ 'vi'
    
    _currentLanguage = LanguageConfig.supportedLanguages.firstWhere(
      (lang) => lang.id == savedLangId,
      orElse: () => LanguageConfig.supportedLanguages.first,
    );
  }

  Future<void> _loadTotalBlocks() async {
    try {
      // 💡 選択中の言語のJSONファイル名を使って読み込む！
      final String response = await rootBundle.loadString('assets/data/${_currentLanguage.jsonFileName}');
      final List<dynamic> data = json.decode(response);
      
      _allWords = data.map((json) => Word.fromJson(json)).toList();
      _totalBlocks = (_allWords.length / 6).ceil();
    } catch (e) {
      debugPrint("データの読み込みエラー: $e");
      _totalBlocks = 0; 
    }
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance(); 
    Map<int, int> tempScores = {};
    
    for (int i = 1; i <= _totalBlocks; i++) {
      // 💡 言語ごとにスコアを分ける（例: score_vi_1, score_ru_1）
      int? score = prefs.getInt('score_${_currentLanguage.id}_$i');
      if (score != null) {
        tempScores[i] = score; 
      }
    }
    _scores = tempScores; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), 
      body: SnowyBackground(
        child: Stack(
          children: [
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
            // 💡 現在の言語の国旗を動的に表示する！
            Text(
              _isVietToJpn ? '${_currentLanguage.flag} ➔ 🇯🇵' : '🇯🇵 ➔ ${_currentLanguage.flag}',
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
    
    final int firstQuestionIndex = index * 6;
    
    String blockTitle = 'Block $blockNum';
    if (firstQuestionIndex < _allWords.length) {
      final word = _allWords[firstQuestionIndex];
      blockTitle = _isVietToJpn ? word.text : word.meaning;
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
          blockTitle, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis, 
          style: GoogleFonts.mPlus1p(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24, 
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
              // 💡 QuizScreenには、どの言語が選ばれているかも一緒に渡してあげます
              builder: (context) => QuizScreen(
                blockNumber: blockNum, 
                isVietToJpn: _isVietToJpn,
                currentLanguage: _currentLanguage, // ※QuizScreen側も後で受け取れるように修正が必要です
              )
            )
          );
          _initializeData(); 
        },
      ),
    );
  }
}