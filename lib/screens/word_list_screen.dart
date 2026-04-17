import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 追加

import '../models/word_model.dart'; 
import '../models/language_config.dart'; // 💡 ルールブックを追加
import '../widgets/snowy_background.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final FlutterTts _tts = FlutterTts();
  List<Word> _wordList = [];
  bool _isLoading = true;
  
  // 💡 現在選択されている言語を入れる箱
  late LanguageConfig _currentLanguage;

  @override
  void initState() {
    super.initState();
    // 💡 初期値を入れてから、保存された言語を読み込みに行く
    _currentLanguage = LanguageConfig.supportedLanguages.first;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadCurrentLanguage(); // スマホに保存された言語を取得
    
    // 💡 取得した言語に合わせてTTSの言語をセット
    _tts.setLanguage(_currentLanguage.ttsCode);
    _tts.setSpeechRate(0.5);
    
    await _loadWordData(); // その言語のJSONを読み込む
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangId = prefs.getString('selected_language') ?? 'vi';
    
    _currentLanguage = LanguageConfig.supportedLanguages.firstWhere(
      (lang) => lang.id == savedLangId,
      orElse: () => LanguageConfig.supportedLanguages.first,
    );
  }

  Future<void> _loadWordData() async {
    try {
      // 💡 選ばれている言語のJSONファイルを読み込む！
      final String response = await rootBundle.loadString('assets/data/${_currentLanguage.jsonFileName}');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _wordList = data.map((json) => Word.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("データの読み込みエラー: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 タイトルに国旗と名前を表示（例: 🇻🇳 ベトナム語一覧）
    final String displayTitleName = _currentLanguage.name.split(' ')[0];

    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), 
      appBar: AppBar(
        title: Text('${_currentLanguage.flag} $displayTitleName一覧', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SnowyBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView.builder(
                  itemCount: _wordList.length,
                  itemBuilder: (context, index) {
                    final word = _wordList[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE53935).withOpacity(0.1),
                          foregroundColor: const Color(0xFF8B0000),
                          child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        title: Text(
                          word.text,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(word.meaning, style: const TextStyle(fontSize: 16)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                              onPressed: () => _tts.speak(word.text),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          ],
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50]!.withOpacity(0.9),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    word.partOfSpeech,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('例文:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(word.example, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                          const SizedBox(height: 4),
                                          Text(word.exampleMeaning, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.green),
                                      onPressed: () => _tts.speak(word.example),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}