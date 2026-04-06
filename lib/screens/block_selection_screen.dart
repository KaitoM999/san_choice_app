import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 保存・読み込み用
import 'quiz_screen.dart';

// 1. StatefulWidgetに変更（Stateを持てるようにする）
class BlockSelectionScreen extends StatefulWidget {
  const BlockSelectionScreen({super.key});

  @override
  State<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
}

class _BlockSelectionScreenState extends State<BlockSelectionScreen> {
  // スコアを保持するMap (Key: ブロック番号, Value: スコア)
  Map<int, int> _scores = {};

  @override
  void initState() {
    super.initState();
    _loadScores(); // 画面が表示されたときにスコアを読み込む
  }

  // 保存されているスコアを読み込むメソッド
  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, int> tempScores = {};
    
    // 1〜200ブロック分ループして読み込み
    for (int i = 1; i <= 200; i++) {
      int? score = prefs.getInt('score_$i');
      if (score != null) {
        tempScores[i] = score;
      }
    }
    
    // 2. setStateを呼ぶことで、画面が再描画されスコアが表示される
    setState(() {
      _scores = tempScores;
    });
  }

  @override
  Widget build(BuildContext context) {
    const int totalBlocks = 200;
    const int questionsPerBlock = 6;

    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        title: const Text(
          '学習ブロック選択 (全200)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: totalBlocks,
        itemBuilder: (context, index) {
          final int blockNum = index + 1;
          final int startWord = (index * questionsPerBlock) + 1;
          final int endWord = (index + 1) * questionsPerBlock;
          
          // このブロックのスコアがあるか確認
          final int? currentScore = _scores[blockNum];

          return Card(
            color: Colors.white.withOpacity(0.1),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE53935),
                child: Text(
                  '$blockNum',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              title: Text(
                'ブロック $blockNum',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // --- ここでスコアを表示 ---
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '単語番号: $startWord 〜 $endWord',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    currentScore != null ? '前回スコア: $currentScore / 6' : '未挑戦',
                    style: TextStyle(
                      color: currentScore != null ? Colors.amberAccent : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.play_arrow, color: Colors.white54),
              onTap: () async {
                // 3. awaitを付けてクイズが終わるのを待つ
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(blockNumber: blockNum),
                  ),
                );
                
                // 4. クイズから戻ってきたら再度スコアを読み込み直す
                _loadScores();
              },
            ),
          );
        },
      ),
    );
  }
}