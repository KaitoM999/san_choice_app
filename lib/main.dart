import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // ホーム画面を読み込む

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
        primaryColor: const Color(0xFF1A237E),
        scaffoldBackgroundColor: const Color(0xFF1A237E),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // 外部ファイルのクラスを指定
    );
  }
}