import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart'; 
import 'widgets/global_banner_ad.dart'; // 💡 さっき作った広告部品を読み込む！

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
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
      
      // 🌟 ここが最強の魔法！アプリ全体を上から下にレイアウトし直す
      builder: (context, child) {
        return Column(
          children: [
            // 1. 本来の画面（HomeやQuizなど）を可能な限り広げる
            Expanded(child: child!), 
            
            // 2. その一番下に、常に広告部品を固定！
            const GlobalBannerAd(),
          ],
        );
      },
      
      home: const HomeScreen(), 
    );
  }
}