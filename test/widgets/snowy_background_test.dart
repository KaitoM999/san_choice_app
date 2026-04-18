import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:san_choice_app/widgets/snowy_background.dart';

void main() {
  group('SnowyBackground Widget Test', () {
    testWidgets('子要素(child)が正しく表示されていること', (WidgetTester tester) async {
      // 1. テスト用のシンプルな子要素を用意
      const testKey = Key('test_child');
      const testChild = Text('Hello World', key: testKey);

      // 2. ウィジェットを描画
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SnowyBackground(child: testChild),
          ),
        ),
      );

      // 3. 子要素が見つかるか確認
      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('雪の結晶(Icons.ac_unit)が複数描画されていること', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SnowyBackground(child: SizedBox()),
          ),
        ),
      );

      // _buildSnowflakes で定義した4つの雪の結晶アイコンを探す
      // Iconウィジェットの内部にある IconData を使って検索
      final snowflakeIcons = find.byIcon(Icons.ac_unit);
      
      // 4つのアイコンが表示されていることを確認
      expect(snowflakeIcons, findsNWidgets(4));
    });

    testWidgets('背景にグラデーションが設定されていること', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SnowyBackground(child: SizedBox()),
          ),
        ),
      );

      // BoxDecoration を持つ Container を探す
      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder.first);
      final decoration = container.decoration as BoxDecoration;

      // RadialGradient が設定されているか確認
      expect(decoration.gradient, isA<RadialGradient>());
      
      // グラデーションの色が指定通りかチェック
      final gradient = decoration.gradient as RadialGradient;
      expect(gradient.colors[0], const Color(0xFFE53935));
      expect(gradient.colors[1], const Color(0xFF8B0000));
    });
  });
}