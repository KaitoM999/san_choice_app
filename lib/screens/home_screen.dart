import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 追加

import '../models/language_config.dart'; // 💡 言語のルールブックを追加
import '../widgets/snowy_background.dart'; // 💡 共通背景を追加

import 'block_selection_screen.dart';
import 'character_intro_screen.dart';
import 'word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // 💡 現在選択されている言語を保持する変数
  late LanguageConfig _currentLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 初期値として最初の言語（ベトナム語）をセット
    _currentLanguage = LanguageConfig.supportedLanguages.first;
    _loadSavedLanguage(); // 💡 保存された言語を読み込む

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  // 💡 スマホに保存されている言語設定を読み込む処理
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangId = prefs.getString('selected_language') ?? 'vi';
    
    setState(() {
      _currentLanguage = LanguageConfig.supportedLanguages.firstWhere(
        (lang) => lang.id == savedLangId,
        orElse: () => LanguageConfig.supportedLanguages.first,
      );
      _isLoading = false;
    });
  }

  // 💡 選択した言語を保存する処理
  Future<void> _setLanguage(LanguageConfig lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang.id);
    setState(() {
      _currentLanguage = lang;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF8B0000),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // 💡 タイトル用に「ベトナム語 (Tiếng Việt)」のスペースより前の部分だけ切り取る
    final String displayTitleName = _currentLanguage.name.split(' ')[0];

    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), 
      // 💡 SnowyBackground を適用してスッキリ！
      body: SnowyBackground(
        child: Stack(
          children: [
            Positioned(
              left: -400, 
              bottom: 150, 
              child: Image.asset(
                'assets/images/home_screen_left.png',
                width: MediaQuery.of(context).size.width * 2, 
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              right: -400, 
              bottom: 150, 
              child: Image.asset(
                'assets/images/home_screen_right.png',
                width: MediaQuery.of(context).size.width * 2,
                fit: BoxFit.contain,
              ),
            ),

            Positioned(
              left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 2.5)) / 2,
              bottom: 00, 
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = math.sin(_controller.value * 2 * math.pi) * 15;
                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 1.5,
                          height: MediaQuery.of(context).size.width * 1.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amberAccent.withOpacity(0.4),
                                blurRadius: 100,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/home_screen_center.png',
                          width: MediaQuery.of(context).size.width * 2.5, 
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SafeArea(
              child: SizedBox(
                width: double.infinity, 
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      // 💡 右上に言語選択ボタンを配置
                      Align(
                        alignment: Alignment.topRight,
                        child: _buildLanguageSelector(),
                      ),

                      const SizedBox(height: 5),
                      Text(
                        // 💡 動的に「〇〇語クイズ」に変わる！
                        '$displayTitleNameクイズ',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansJp(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 38, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [Shadow(color: Colors.black54, offset: Offset(2, 4), blurRadius: 10)],
                          ),
                        ),
                      ),
                      Text(
                        '3択ロース',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansJp(
                          textStyle: const TextStyle(
                            color: Colors.amberAccent, 
                            fontSize: 42, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            shadows: [Shadow(color: Colors.black54, offset: Offset(2, 4), blurRadius: 10)],
                          ),
                        ),
                      ),
                      const Spacer(), 
                      
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 65, 
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BlockSelectionScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32), 
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                              side: const BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🎁', style: TextStyle(fontSize: 26)), 
                              SizedBox(width: 15),
                              Text(
                                '学習をはじめる',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WordListScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9), 
                            foregroundColor: const Color(0xFF8B0000),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Color(0xFF8B0000), width: 2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('📚', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 15),
                              Text(
                                '単語一覧（復習）',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 55, 
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CharacterIntroScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9), 
                            foregroundColor: const Color(0xFF2E7D32),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('⛄️', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 15),
                              Text(
                                'キャラクター紹介',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 00),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 言語を選択するドロップダウンボタン
  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LanguageConfig>(
          value: _currentLanguage,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: const Color(0xFF8B0000),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          onChanged: (LanguageConfig? newValue) {
            if (newValue != null) {
              _setLanguage(newValue);
            }
          },
          items: LanguageConfig.supportedLanguages.map<DropdownMenuItem<LanguageConfig>>((LanguageConfig lang) {
            return DropdownMenuItem<LanguageConfig>(
              value: lang,
              child: Text('${lang.flag} ${lang.name}'),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 💡 雪の結晶は SnowyBackground に任せたので _buildSnowflakes は削除！
}