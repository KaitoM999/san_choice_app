import 'package:flutter/material.dart';
import 'block_selection_screen.dart'; // フォルダ内にあるならこれでOK

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色の設定
      backgroundColor: const Color(0xFF1A237E),
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
              const SizedBox(height: 60),

              // キャラクター表示エリア
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(125),
                ),
                child: const Center(
                  child: Text(
                    'ここにトナカイと\n女の子が登場！',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // ★ここが重要！ ElevatedButtonの中にonPressedを書く
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlockSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), // サンタレッド
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '学習をはじめる',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}