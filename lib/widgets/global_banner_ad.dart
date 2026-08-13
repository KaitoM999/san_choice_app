import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GlobalBannerAd extends StatefulWidget {
  const GlobalBannerAd({super.key});

  @override
  State<GlobalBannerAd> createState() => _GlobalBannerAdState();
}

class _GlobalBannerAdState extends State<GlobalBannerAd> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8282996158486757/2396404131'
      : 'ca-app-pub-8282996158486757/4392620892';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('⚠️ 広告の読み込み失敗: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 広告が読み込まれていない時は、高さを0にして完全に隠す（SizedBox.shrink）
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); 
    }

    // 💡 SafeAreaで囲むことで、iPhoneの下の線（ホームインジケーター）と被るのを防ぐ
    return SafeArea(
      top: false, // 上の余白は不要
      child: Container(
        color: Colors.black87, // 広告の背景に少し色をつけてなじませる
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}