import 'dart:convert'; // 💡 JSON形式のデータをDartで扱えるようにするためのパッケージ
import 'package:flutter/material.dart'; // 💡 Flutterの基本UIパーツ（Widget）を使うためのパッケージ
import 'package:flutter/services.dart'; // 💡 rootBundleを使って、アプリ内のファイル（JSONなど）を読み込むためのパッケージ
import 'package:google_fonts/google_fonts.dart'; // 💡 Googleフォント（Noto SansやM PLUS 1pなど）を使うためのパッケージ
import 'package:shared_preferences/shared_preferences.dart'; // 💡 端末にスコアなどのデータを保存・読み込みするためのパッケージ
import 'quiz_screen.dart'; // 💡 クイズ画面へ遷移するためにインポート

// ブロック選択画面の土台となるStatefulWidget（画面の状態が変化するWidget）
class BlockSelectionScreen extends StatefulWidget {
  const BlockSelectionScreen({super.key});

  @override
  State<BlockSelectionScreen> createState() => _BlockSelectionScreenState();
}

// 実際の画面の動きや見た目を作るStateクラス
// SingleTickerProviderStateMixin は、アニメーションを滑らかに動かすための「タイマー」の役割
class _BlockSelectionScreenState extends State<BlockSelectionScreen> with SingleTickerProviderStateMixin {
  
  // 各ブロックの「過去の最高スコア」を保存する辞書（キーがブロック番号、値がスコア）
  Map<int, int> _scores = {};
  
  // 右下にいるキャラクター（トナカイくんたち）をフワフワ動かすためのコントローラー
  late AnimationController _thinkingController;
  
  // 💡 今回追加した変数
  int _totalBlocks = 0; // JSONから計算した、全体のブロック数（例: 6問なら1、12問なら2）
  bool _isLoading = true; // データを読み込み中かどうかを判定するフラグ（最初は読み込み中なのでtrue）

  // 画面が表示される「最初の一度だけ」実行されるメソッド
  @override
  void initState() {
    super.initState();
    
    // 💡 データの読み込み（ブロック数の計算＆スコアの取得）を開始
    _initializeData(); 
    
    // キャラクターのフワフワアニメーションの設定（3秒かけて動く）
    _thinkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // 行って戻る（reverse: true）を永遠に繰り返す（repeat）
  }

  // 画面が閉じられるときに実行される「お片付け」メソッド
  @override
  void dispose() {
    _thinkingController.dispose(); // アニメーションのタイマーを破棄してメモリの無駄遣いを防ぐ
    super.dispose();
  }

  // 💡 データ読み込みの全体を管理するメソッド
  Future<void> _initializeData() async {
    await _loadTotalBlocks(); // ① まずJSONを見て、全部で何ブロックあるかを計算する
    await _loadScores();      // ② 計算したブロック数に合わせて、保存されたスコアを読み込む
    
    // mounted は「この画面がまだ表示されているか？」を確認するおまじない
    // （読み込み中にユーザーが戻るボタン等で画面を閉じていた場合のエラーを防ぐため）
    if (mounted) {
      setState(() {
        _isLoading = false; // 全部の読み込みが終わったので、ローディングのクルクルを消して画面を表示！
      });
    }
  }

  // 💡 JSONファイルから全問題数を取得し、ブロック数を計算するメソッド
  Future<void> _loadTotalBlocks() async {
    try {
      // assetsフォルダから問題データのJSONファイルを読み込む
      final String response = await rootBundle.loadString('assets/data/quiz_data.json');
      
      // 文字列のJSONデータを、Dartで扱えるリスト形式に変換する
      final List<dynamic> data = json.decode(response);
      
      // リストの長さ＝全問題数
      final int totalQuestions = data.length;
      
      // 1ブロック6問なので、全問題数を6で割る。
      // .ceil() は「切り上げ」の処理。例: 問題が7個なら (7/6 = 1.16...) → 切り上げて 2ブロックになる
      _totalBlocks = (totalQuestions / 6).ceil();
    } catch (e) {
      // 読み込みに失敗した場合のエラー処理
      debugPrint("データの読み込みエラー: $e");
      _totalBlocks = 0; // エラー時は安全のために0ブロックにしておく
    }
  }

  // スマホ本体に保存されている過去のスコアを読み込むメソッド
  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance(); // 端末の保存領域にアクセス
    Map<int, int> tempScores = {};
    
    // 💡 _totalBlocks（計算されたブロック数）の回数だけループを回す
    for (int i = 1; i <= _totalBlocks; i++) {
      // 'score_1', 'score_2'... という名前で保存されたスコアを取り出す
      int? score = prefs.getInt('score_$i');
      if (score != null) {
        tempScores[i] = score; // スコアが存在していれば、変数にセットする
      }
    }
    _scores = tempScores; // 取り出したスコアのまとまりを、画面で使う変数にコピーする
  }

  // 実際の画面のレイアウトを構築するメソッド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面全体の背景設定
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFE53935), Color(0xFF8B0000)], // サンタレッドから暗い赤へのグラデーション
          ),
        ),
        // Stackは、Widget（パーツ）を「奥から手前へ」重ねて配置するためのレイアウト
        child: Stack(
          children: [
            // 一番奥：背景の雪の結晶を描画（...はリストの中身を展開して展開する書き方）
            ..._buildSnowflakes(),

            // 真ん中：スマホのステータスバー（時計や電池）に被らないようにする安全地帯(SafeArea)
            SafeArea(
              child: Column(
                children: [
                  // 上部のヘッダー（戻るボタンとタイトル）
                  _buildHeader(context),

                  // 💡 メインのリスト部分（Expandedは「残りの画面スペースを全部使う」という指示）
                  Expanded(
                    child: _isLoading 
                      // 読み込み中（true）なら、画面の中央に白いクルクルを表示
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      
                      // 読み込み完了（false）なら、ブロックのリストを表示
                      : ListView.builder(
                          // 下にキャラクター画像が重なるので、リストの最下部に220pxの大きな余白を空けておく
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 220),
                          
                          // 💡 動的に計算した _totalBlocks の数だけカードを作る
                          itemCount: _totalBlocks, 
                          
                          // インデックス（0, 1, 2...）を渡して、1枚ずつカードを作る
                          itemBuilder: (context, index) => _buildBlockCard(index),
                        ),
                  ),
                ],
              ),
            ),

            // 一番手前：右下に表示されるキャラクターの画像
            // PositionedはStackの中だけで使える、「絶対位置」を指定するパーツ
            Positioned(
              bottom: -270, // 画面の下側からはみ出させる
              right: -240,  // 画面の右側からはみ出させる
              // IgnorePointerは、画像の透明部分をタップしても、その後ろにあるリストが反応するようにする処理
              child: IgnorePointer(
                // アニメーションに合わせて画像を動かすためのパーツ
                child: AnimatedBuilder(
                  animation: _thinkingController,
                  builder: (context, child) {
                    // Y軸（上下）方向に、コントローラーの数値に合わせて画像を移動させる
                    return Transform.translate(
                      offset: Offset(0, 10 * _thinkingController.value),
                      child: Image.asset(
                        'assets/images/lauschan_tonakaikun_thinking.png',
                        width: MediaQuery.of(context).size.width * 1.6, // 画面幅の1.6倍の超特大サイズ
                        height: MediaQuery.of(context).size.height * 1.0, 
                        fit: BoxFit.contain, // イラストの縦横比を崩さないように表示
                        // 画像が見つからなかった場合にアプリが落ちないようにするエラー処理
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
          // 戻るボタン
          IconButton(
            onPressed: () => Navigator.pop(context), // 押されたら前の画面に戻る
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          // タイトル文字
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

  // 1つのブロックカード（例：Block 1 の四角い箱）を作る部品
  Widget _buildBlockCard(int index) {
    final int blockNum = index + 1; // プログラムは0から数えるので、+1して「ブロック1」にする
    final int? currentScore = _scores[blockNum]; // 保存されているスコアを取り出す

    return Card(
      color: Colors.white.withOpacity(0.12), // ちょっとだけ透けてる白色のカード
      elevation: 0, // 影をなくしてフラットなデザインにする
      margin: const EdgeInsets.only(bottom: 20), // カードとカードの間の隙間
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // 角を丸くする
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1), // うっすらとした枠線をつける
      ),
      // ListTileは、アイコン・タイトル・サブタイトルを綺麗に並べてくれる便利なパーツ
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
        // 左側の丸いアイコン部分
        leading: CircleAvatar(
          radius: 28, 
          backgroundColor: const Color(0xFF2E7D32), // 深い緑色
          child: Text(
            '$blockNum', 
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
          ),
        ),
        // メインの文字（Block 1 など）
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
        // 下の小さな文字（スコア または 未挑戦）
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            // スコアが保存されていればスコアを、なければ「未挑戦」を表示
            currentScore != null ? '前回スコア: $currentScore / 6' : '未挑戦 🎁',
            style: TextStyle(
              // スコアがある場合は黄色、未挑戦は白にする
              color: currentScore != null ? Colors.amberAccent : Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 右側の再生ボタンのアイコン
        trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
        // カード全体がタップされた時の処理
        onTap: () async {
          // クイズ画面へ遷移する（引数として、どのブロックが選ばれたかを渡す）
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => QuizScreen(blockNumber: blockNum))
          );
          // クイズ画面から戻ってきたら、スコアが更新されているかもしれないのでデータを再読み込みする
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
      _p(top: 350, left: 20, size: 120, opacity: 0.1), // ちょっと大きくて薄い雪
      _p(bottom: 150, right: 30, size: 80),
    ];
  }

  // 雪の結晶アイコン1つを好きな位置（上下左右）に配置するための補助部品
  Widget _p({double? top, double? left, double? right, double? bottom, required double size, double opacity = 0.4}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Icon(Icons.ac_unit, color: Colors.white.withOpacity(opacity), size: size),
    );
  }
}