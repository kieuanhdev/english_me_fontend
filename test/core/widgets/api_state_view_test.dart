import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:englishme/core/widgets/api_state_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ApiStateView', () {
    testWidgets('renders CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        ApiStateView(
          state: ApiState.loading,
          builder: (_) => const Text('SUCCESS'),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SUCCESS'), findsNothing);
    });

    testWidgets('renders builder when success', (tester) async {
      await tester.pumpWidget(_wrap(
        ApiStateView(
          state: ApiState.success,
          builder: (_) => const Text('SUCCESS'),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('SUCCESS'), findsOneWidget);
    });

    testWidgets('renders error message + retry button and triggers callback',
        (tester) async {
      var retries = 0;
      await tester.pumpWidget(_wrap(
        ApiStateView(
          state: ApiState.error,
          errorMessage: 'Lỗi kết nối tới máy chủ',
          onRetry: () => retries++,
          builder: (_) => const Text('SHOULD NOT SHOW'),
        ),
      ));

      expect(find.text('Lỗi kết nối tới máy chủ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.text('SHOULD NOT SHOW'), findsNothing);

      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('renders empty state without retry button', (tester) async {
      await tester.pumpWidget(_wrap(
        ApiStateView(
          state: ApiState.empty,
          emptyMessage: 'Không có dữ liệu',
          builder: (_) => const Text('SHOULD NOT SHOW'),
        ),
      ));

      expect(find.text('Không có dữ liệu'), findsOneWidget);
      expect(find.text('Thử lại'), findsNothing);
      expect(find.text('SHOULD NOT SHOW'), findsNothing);
    });
  });
}
