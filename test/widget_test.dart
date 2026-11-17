import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanager_khmt2411042/app.dart';

void main() {
  testWidgets('TaskManager app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TaskManagerApp());

    // Verify that TaskManager app loads without errors
    expect(find.byType(TaskManagerApp), findsOneWidget);
  });
}
