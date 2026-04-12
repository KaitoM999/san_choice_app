import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  static const List<String> _successMessages = [
    '『継続は力なり』じゃ！毎日の積み重ねが,今の素晴らしい結果を生んだんじゃな。ホッホッホ！いい新年を迎えられそうじゃわい！ほんとにほんとに！',
    '『努力に勝る天才なし』とはよく言ったものじゃ。お主のひたむきながんばり,わしはちゃんと見とったぞ！新年のお年玉はたーんとやらんとな！ほんとにほんとに！',
    '『千里の道も一歩から』じゃよ。一歩一歩,着実に賢くなっておるな。実に頼もしいぞ！クリスマスは⚪︎ンタッキーをたらふく用意しとくから,そっちでは何も準備しなくていいぞい！ほんとにほんとに！ほんとにほんとに！',
    '『鉄は熱いうちに打て』じゃ！今の素晴らしい勢いのまま,次の問題もどんどん吸収していくんじゃぞ！それはそうと年末はわしとみんなで年越しそばを食べるんじゃぞ！約束じゃぞ！'
  ];

  static const List<String> _failureMessages = [
    '『為（な）せば成る,為さねば成らぬ何事も！』じゃ。。。次頑張ってみんなで初日の出を見に行こうぞ！',
    '『失敗は成功のもと』じゃ！しっかり復習してもう一度チャレンジじゃ！それはそれとして新年の初詣とやらが楽しみじゃな！',
    '『七転び八起き』じゃ！何度でも挑戦すれば必ず上達するぞ！それはそれとしてクリスマスにターキーを食べるのはもう古いわい！',
    '『ローマは一日にして成らず！』コツコツ続けることが大事じゃよ！それはそうとクリスマスはケーキがあれば十分じゃ！'
  ];

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    final String displayMessage = score >= 4
        ? _successMessages[random.nextInt(_successMessages.length)]
        : _failureMessages[random.nextInt(_failureMessages.length)];

    final h = MediaQuery.of(context).size.height;
    // 💡 不要になった `final w = ...` を削除しました！

    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFE53935), Color(0xFF8B0000)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ..._buildBackgroundEffects(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCharBox(score >= 4 ? 'assets/images/result_tonakaikun_happy.png' : 'assets/images/result_tonakaikun_angry.png'),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Text('ブロック終了！', textAlign: TextAlign.center, style: GoogleFonts.mochiyPopOne(textStyle: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                                child: Text('$score / $totalQuestions', style: const TextStyle(color: Colors.amberAccent, fontSize: 42, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        _buildCharBox(score >= 4 ? 'assets/images/result_lauschan_happy.png' : 'assets/images/result_lauschan_angry.png'),
                      ],
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                      child: Row(
                        children: [
                          const Text('🦃', style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 15),
                          Expanded(child: Text(displayMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4))),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: h * 0.28,
                      child: Image.asset(
                        score >= 4 ? 'assets/images/result_success_images.png' : 'assets/images/result_failure_images.png', 
                        fit: BoxFit.contain,
                        cacheWidth: 500,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: () {
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)), elevation: 5),
                          child: Text('ホームへ戻る', style: GoogleFonts.mochiyPopOne(textStyle: const TextStyle(fontSize: 22))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharBox(String path) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        height: 140,
        child: Transform.scale(
          scale: 2.2,
          child: Image.asset(path, fit: BoxFit.contain, cacheWidth: 300),
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundEffects() {
    return [
      _p(top: 80, left: 30, size: 40, icon: Icons.ac_unit, opacity: 0.3),
      _p(top: 150, left: 100, size: 25, icon: Icons.ac_unit, opacity: 0.2),
      _p(top: 220, right: 40, size: 60, icon: Icons.ac_unit, opacity: 0.1),
      _p(top: 300, left: 200, size: 30, icon: Icons.ac_unit, opacity: 0.25),
      _p(bottom: 150, left: 20, size: 50, icon: Icons.ac_unit, opacity: 0.2),
      _p(top: 120, right: 80, size: 25, icon: Icons.star, opacity: 0.6, color: Colors.amberAccent),
      _p(top: 450, left: 120, size: 22, icon: Icons.star, opacity: 0.7, color: Colors.amberAccent),
      _p(bottom: 250, right: 50, size: 45, icon: Icons.star, opacity: 0.5, color: Colors.amberAccent),
      _p(bottom: 100, left: 100, size: 20, icon: Icons.star, opacity: 0.7, color: Colors.amberAccent),
    ];
  }

  Widget _p({double? top, double? left, double? right, double? bottom, required double size, required IconData icon, Color color = Colors.white, double opacity = 0.3}) {
    return Positioned(top: top, left: left, right: right, bottom: bottom, child: Icon(icon, color: color.withOpacity(opacity), size: size));
  }
}