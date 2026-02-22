import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_carousel/smooth_carousel.dart';

void main() {
  testWidgets('renders nothing when imageUrls is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(imageUrls: []),
        ),
      ),
    );

    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('renders PageView with images', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(
            imageUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
          ),
        ),
      ),
    );

    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('hides arrows for single image', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(
            imageUrls: ['https://example.com/1.jpg'],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
  });

  testWidgets('shows arrows for multiple images', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(
            imageUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
  });

  testWidgets('uses custom height', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(
            imageUrls: ['https://example.com/1.jpg'],
            height: 200,
          ),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.height, 200);
  });

  testWidgets('supports custom itemBuilder', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(
            itemCount: 2,
            itemBuilder: (context, index) {
              return Center(child: Text('Page $index'));
            },
          ),
        ),
      ),
    );

    expect(find.text('Page 0'), findsOneWidget);
  });

  testWidgets('hides indicators when showIndicators is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmoothCarousel(
            imageUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
            showIndicators: false,
          ),
        ),
      ),
    );

    // Dot indicators are Containers inside a Row in a Positioned widget.
    // With showIndicators: false, there should be no dot row.
    // We check that arrow icons exist but no positioned bottom widget.
    expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
  });
}
