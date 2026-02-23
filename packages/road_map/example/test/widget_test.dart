import 'package:flutter_test/flutter_test.dart';

import 'package:road_map_example/main.dart';

void main() {
  testWidgets('Example app renders without errors', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Verify the first sample road map renders.
    expect(find.text('Pick Dates'), findsWidgets);
  });
}
