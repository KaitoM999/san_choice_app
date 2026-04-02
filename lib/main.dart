import 'package:flutter/material.dart';

void main() {
  runApp(const SanChoiceApp());
}

class SanChoiceApp extends StatelessWidget {
  const SanChoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3択ロース',
      theme: ThemeData(
        // メインカラー：ネイビー
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: const Color(0xFF1A237E),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // タイトルエリア
              const Text(
                '🎅 3択ロース 🎄',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '〜 ベトナム語 1,200単語攻略 〜',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 60),

              // キャラクター表示エリア（仮のプレースホルダー）
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(125),
                ),
                child: const Center(
                  child: Text(
                    'ここにニョッキと\nカルビが登場！',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // 開始ボタン
              ElevatedButton(
                onPressed: () {
                  // TODO: ブロック選択画面へ遷移
                  print('学習を開始します');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), // サンタレッド
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  '学習をはじめる',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // 設定ボタン（アイコンのみ）
              IconButton(
                onPressed: () {
                  // TODO: 設定・リセット画面へ
                },
                icon: const Icon(Icons.settings, color: Colors.white70, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}