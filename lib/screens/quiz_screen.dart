import 'dart:convert'; // JSONデータをDartのリストやマップに変換・逆変換するためのパッケージ
import 'dart:math' as math; // ランダムな数字を作ったり、画像を反転（回転）させるための数学用パッケージ
import 'package:flutter/material.dart'; // Flutterの基本的なUIパーツ群
import 'package:flutter/services.dart'; // アプリ内にバンドルされたアセットファイル（JSONなど）を読み込むため
import 'package:flutter_tts/flutter_tts.dart'; // テキストを音声で読み上げる（Text-To-Speech）ためのパッケージ
import 'package:google_fonts/google_fonts.dart'; // Googleフォントを簡単に使うためのパッケージ
import 'package:shared_preferences/shared_preferences.dart'; // スマホのローカルストレージにスコアを保存するためのパッケージ
import '../models/quiz_model.dart'; // クイズ1問分のデータ構造を定義したモデルクラス（別途定義されている想定）

// クイズ画面の本体。画面の状態（今何問目か、正解したかなど）が変わるためStatefulWidgetを使う
class QuizScreen extends StatefulWidget {
  final int blockNumber; // どのブロック番号（例：Block 1）が選ばれたかを受け取る変数
  const QuizScreen({super.key, required this.blockNumber});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts(); // 音声読み上げエンジンのインスタンスを作成
  late Future<List<Quiz>> _quizFuture; // クイズデータを非同期（裏側）で読み込むための箱
  
  // クイズの進行状態を管理する変数たち
  int _currentIndex = 0; // 現在表示している問題のインデックス（0からスタート）
  bool _isAnswered = false; // ユーザーが選択肢をタップして解答済みかどうか
  int? _selectedIndex; // ユーザーが選んだ選択肢のインデックス（まだ選んでない時はnull）
  int _score = 0; // 現在の正解数
  bool _isFinished = false; // 1ブロック（6問）すべて解き終わったかどうか

  // 現在表示するキャラクター画像のパス（初期値は仮設定。initStateでランダムに決まる）
  String _currentImagePath = '';
  // 💡 今出題時に選ばれた「基本キャラクター」がどっちなのかを覚えておくための変数
  bool _isSantaMode = false; // trueならお母さんサンタ（claussan）、falseならトナカイコンビ（lauschan_tonakaikun）

  // アニメーション関連の変数
  late bool _isFlipped; // 画像を左右反転させるかどうかのフラグ
  late AnimationController _floatController; // キャラクターをフワフワ上下に動かすタイマー
  late Animation<double> _floatAnimation; // 実際の移動量（0〜15ピクセル）を計算するもの

  @override
  void initState() {
    super.initState();
    // 音声読み上げの設定（ベトナム語、少しゆっくりめの速度）
    _tts.setLanguage("vi-VN");
    _tts.setSpeechRate(0.5);
    
    // JSONファイルから指定されたブロックの問題を読み込み開始
    _quizFuture = _loadQuizData();
    
    // 💡 最初（1問目）は右側（反転なし）にキャラクターを表示する設定
    _isFlipped = false; 

    // 💡 1問目のキャラクター（考え中の姿）を抽選してセットする
    _pickConsideringImage();

    // フワフワアニメーションの設定（3秒かけて行ったり来たりを永遠に繰り返す）
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // 0から15の間を、滑らかなカーブ（easeInOut）を描いて変化させるアニメーションを作成
    _floatAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // 画面を閉じるときは、メモリリークを防ぐためにタイマーと音声エンジンを停止・破棄する
    _floatController.dispose();
    _tts.stop();
    super.dispose();
  }

  // 💡 問題の選択肢画面（考え中）の画像を抽選するメソッド
  void _pickConsideringImage() {
    final int rand = math.Random().nextInt(100); // 0から99までのランダムな数字を生成
    if (rand < 85) {
      // 85%の確率で「トナカイコンビ」
      _isSantaMode = false;
      _currentImagePath = 'assets/images/lauschan_tonakaikun_considering.png';
    } else {
      // 15%の確率で「お母さんサンタ」
      _isSantaMode = true;
      _currentImagePath = 'assets/images/claussan_normal.png';
    }
  }

  // 💡 解答後のリアクション画像をセットするメソッド（正解/不正解で分岐）
  void _setReactionImage(bool isCorrect) {
    setState(() {
      if (_isSantaMode) {
        // --- 🎅 お母さんサンタモードの場合 ---
        if (isCorrect) {
          // 正解
          _currentImagePath = 'assets/images/claussan_happy.png';
        } else {
          // 不正解（angry と araara を半々）
          _currentImagePath = math.Random().nextBool() 
            ? 'assets/images/claussan_angry.png' 
            : 'assets/images/claussan_araara.png';
        }
      } else {
        // --- 🦌 トナカイコンビモードの場合 ---
        if (isCorrect) {
          // 正解
          _currentImagePath = 'assets/images/lauschan_tonakaikun_happy.png';
        } else {
          // 不正解（sad と angry を半々）
          _currentImagePath = math.Random().nextBool() 
            ? 'assets/images/lauschan_tonakaikun_sad.png' 
            : 'assets/images/lauschan_tonakaikun_angry.png';
        }
      }
    });
  }

  // 1ブロック解き終わった時に、スコアをスマホ本体に保存するメソッド
  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    // 例：Block 1 なら 'score_1' というキーで点数を保存する
    await prefs.setInt('score_${widget.blockNumber}', _score);
  }

  // JSONファイルから全クイズデータを読み込み、今のブロックに必要な6問だけを切り出すメソッド
  Future<List<Quiz>> _loadQuizData() async {
    final String response = await rootBundle.loadString('assets/data/quiz_data.json');
    final List<dynamic> data = json.decode(response);
    
    // JSONの生データを、Dartの扱いやすいQuizモデルのリストに変換
    List<Quiz> allQuizzes = data.map((json) => Quiz.fromJson(json)).toList();
    
    // 選ばれたブロック番号から、必要な問題の「開始位置」と「終了位置」を計算
    int start = (widget.blockNumber - 1) * 6;
    int end = (start + 6 > allQuizzes.length) ? allQuizzes.length : start + 6;
    
    return allQuizzes.sublist(start, end);
  }

  // 画面下部にキャラクターを表示するための部品（メソッド）
  Widget _buildCharacter() {
    return Positioned(
      bottom: -70, // 画面の下にはみ出させて配置
      // _isFlipped が true なら左寄り、false なら右寄りに配置する
      left: _isFlipped ? -270 : null,
      right: _isFlipped ? null : -270,
      // IgnorePointer: 画像の透明部分をタップしても、後ろのボタンが反応するようにする
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            // アニメーションの値に合わせて、画像をY軸（上下）に動かす
            return Transform.translate(
              offset: Offset(0, -_floatAnimation.value),
              child: Transform(
                alignment: Alignment.center,
                // _isFlipped が true なら、画像をY軸を中心に180度（math.pi）回転（＝左右反転）させる
                transform: Matrix4.rotationY(_isFlipped ? math.pi : 0),
                child: Image.asset(
                  _currentImagePath, // 今設定されている画像パスを表示
                  width: MediaQuery.of(context).size.width * 1.8, // 画面幅の1.8倍の巨大サイズ
                  height: 400,
                  fit: BoxFit.contain, // 縦横比を崩さずに枠内に収める
                  gaplessPlayback: true, // 画像が切り替わる一瞬のチラつき（白トビ）を防ぐおまじない
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
    // FutureBuilder: データの読み込み状態（ローディング中、エラー、完了）に応じて画面を出し分ける便利なWidget
    return FutureBuilder<List<Quiz>>(
      future: _quizFuture,
      builder: (context, snapshot) {
        // 読み込み中なら、真っ赤な背景に白いクルクルを表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF8B0000),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        
        // エラー発生、またはデータが空っぽならエラーメッセージを表示
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('データの読み込みに失敗しました')));
        }

        final quizList = snapshot.data!;
        
        // 6問すべて解き終わっていたら、結果発表画面を表示してここで終了
        if (_isFinished) return _buildResultScreen(quizList);

        // 現在表示すべき1問分のデータを取得
        final quiz = quizList[_currentIndex];
        // 自分が選んだ選択肢が、正解のインデックスと一致しているか判定
        final bool isCorrect = _selectedIndex == quiz.correctIndex;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFFE53935), Color(0xFF8B0000)], // 赤色のグラデーション背景
              ),
            ),
            child: Stack( // 背景、キャラクター、問題文、解説画面などを重ねて表示するためのStack
              children: [
                ..._buildSnowflakes(), // 背景の雪

                // 解答「前」は、問題文や選択肢の「裏側」にキャラクターを配置する
                if (!_isAnswered) _buildCharacter(),

                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(quizList), // 「Block 1 [1/6]」などの上部ヘッダー
                      
                      // 問題文エリア（画面上部のスペースを4の割合で使う）
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ベトナム語などの問題テキストを大きく表示
                            Text(
                              quiz.question.text,
                              style: GoogleFonts.notoSansJp(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  shadows: [Shadow(color: Colors.black45, blurRadius: 15)], // 見やすくするためのドロップシャドウ
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 音声再生ボタン
                            IconButton(
                              onPressed: () => _tts.speak(quiz.question.text),
                              icon: const Icon(Icons.volume_up, color: Colors.white, size: 50),
                            ),
                          ],
                        ),
                      ),

                      // 選択肢エリア（画面下部のスペースを5の割合で使う）
                      Expanded(
                        flex: 5,
                        child: Column(
                          // 問題が持つ選択肢の数（基本は3つ）だけボタンを作るループ
                          children: List.generate(quiz.options.length, (index) {
                            final isCorrectBtn = index == quiz.correctIndex; // このボタンが正解のボタンかどうか
                            final isSelectedBtn = index == _selectedIndex; // このボタンをユーザーがタップしたかどうか
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                              child: SizedBox(
                                width: double.infinity, // 横幅いっぱい
                                height: 75, // ボタンの高さ
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // 解答後のボタンの色分けロジック
                                    backgroundColor: _isAnswered
                                        // 答えた後：正解ボタンは緑、自分が選んだ間違いボタンは赤、選ばなかった間違いボタンは薄い白
                                        ? (isCorrectBtn ? Colors.green : (isSelectedBtn ? Colors.red : Colors.white12))
                                        // 答える前：全部少し透けた白色
                                        : Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white, // 文字色は常に白
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    if (_isAnswered) return; // すでに答えた後なら、ボタンを押しても何もしない
                                    
                                    // setStateを呼ぶことで、画面の表示を更新する
                                    setState(() {
                                      _selectedIndex = index; // 選んだボタンの番号を記録
                                      _isAnswered = true; // 解答済みフラグを立てる
                                      
                                      if (index == quiz.correctIndex) {
                                        // 正解だった場合
                                        _score++; // スコアを＋1
                                        _setReactionImage(true); // 💡 正解時のリアクション画像をセット
                                      } else {
                                        // 不正解だった場合
                                        _setReactionImage(false); // 💡 不正解時のリアクション画像をセット
                                      }
                                    });
                                    // 選んだ選択肢の「意味（ベトナム語）」を音声で読み上げる
                                    _tts.speak(quiz.options[index].text);
                                  },
                                  child: Text(
                                    quiz.options[index].meaning, // 選択肢のテキスト（日本語の意味など）
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

                // 解答「後」の特別なレイアウト（Stackの手前側に被せる）
                if (_isAnswered) ...[
                  // 1. 画面全体を暗くする半透明の黒いフィルター
                  Positioned.fill(
                    child: Container(color: Colors.black54), 
                  ),
                  // 2. 暗いフィルターの「手前」にキャラクターを描画（浮き出て見える）
                  _buildCharacter(),
                  // 3. 一番手前に、解説ボックス（白い箱）を表示
                  SafeArea(
                    child: _buildFeedbackModal(quiz, isCorrect, quizList),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // 画面一番上の「×ボタン」や「現在何問目か」を表示する部品
  Widget _buildHeader(List<Quiz> quizList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context), // ×を押すと強制終了して前の画面に戻る
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
          Text(
            'Block ${widget.blockNumber}  [${_currentIndex + 1}/${quizList.length}]', // 例：Block 1 [1/6]
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // タイトルを中央に寄せるための見えない余白
        ],
      ),
    );
  }

  // 解答後に手前に表示される、解説入りの白いモーダル（小窓）部品
  Widget _buildFeedbackModal(Quiz quiz, bool isCorrect, List<Quiz> quizList) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // ドーンと大きく「正解！」「不正解…」を表示
        Text(
          isCorrect ? '⭕️ 正解！' : '❌ 不正解...',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: isCorrect ? Colors.greenAccent : Colors.redAccent,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 10)], // 後ろが少し暗いので、文字に影をつけて目立たせる
          ),
        ),
        const SizedBox(height: 15),
        // 解説が書かれた白いボックス
        Expanded(
          child: Container(
            // 下の margin を大きく（260）空けることで、キャラクターの姿を隠さないようにする！
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 260),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95), // ほぼ真っ白だけど、ほんの少しだけ透かす
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const Text('【 解説 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                // 選択肢の数だけ、詳細な解説（単語＋意味＋音声ボタン）のリストを作る
                Expanded(
                  child: ListView.builder(
                    itemCount: quiz.options.length,
                    itemBuilder: (context, index) {
                      final word = quiz.options[index];
                      final isCorrectOption = index == quiz.correctIndex; // この項目が「正解の単語」かどうか
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // 正解の単語は薄い緑背景、ダミーの単語は薄いグレー背景にする
                          color: isCorrectOption ? Colors.green.withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          // 正解の単語にだけ、緑色の枠線をつける
                          border: Border.all(color: isCorrectOption ? Colors.green : Colors.transparent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // 左揃え
                          children: [
                            Row(
                              children: [
                                Text(word.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                // 🔊 アイコンを押すとベトナム語を読み上げる
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
                const SizedBox(height: 10),
                // 「次の問題へ」または「結果を見る」ボタン
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentIndex < quizList.length - 1) {
                        // まだ次の問題がある場合
                        setState(() {
                          _currentIndex++; // 問題の番号を次に進める
                          _isAnswered = false; // 解答状態をリセット
                          _selectedIndex = null; // 選択状態をリセット
                          
                          // 次の問題へ行くときに、キャラクターの左右（反転）フラグをひっくり返す
                          _isFlipped = !_isFlipped; 
                          
                          // 💡 次の問題用のキャラクター（考え中の姿）を再度抽選する
                          _pickConsideringImage();
                        });
                      } else {
                        // 最後の問題を解き終わった場合
                        await _saveScore(); // スコアを保存して…
                        setState(() => _isFinished = true); // 「終了フラグ」を立てて、結果画面へ切り替える
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

  // 1ブロックすべて終わったあとに表示される「結果発表」画面
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
            const Icon(Icons.emoji_events, size: 120, color: Colors.amberAccent), // 大きなトロフィーアイコン
            const SizedBox(height: 20),
            Text(
              'ブロック終了！',
              style: GoogleFonts.notoSansJp(
                textStyle: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${quizList.length}問中 $_score 問正解', // 例：6問中 4 問正解
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            // ブロック選択画面へ戻るボタン
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

  // 背景に散りばめる雪の結晶リストを作る部品
  List<Widget> _buildSnowflakes() {
    return [
      _p(top: 100, left: 30, size: 40),
      _p(top: 250, right: 40, size: 60, opacity: 0.1),
      _p(bottom: 100, left: 20, size: 50),
    ];
  }

  // 雪の結晶アイコン1つを配置するための補助部品
  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.3}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}