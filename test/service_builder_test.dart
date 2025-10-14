import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'service.dart';

void main() {
  testWidgets(
    "ServiceBuilder creates the service and calls load()",
    (tester) async {
      final service = TestService();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ServiceBuilder<TestService>(
            factory: (context) => service,
            builder: (context, service) {
              return Text(service.maybeData?.toString() ?? "loading");
            },
          ),
        ),
      );

      // The service should start in loading state immediately.
      expect(service.status, ServiceStatus.loading);
      expect(find.text("loading"), findsOneWidget);

      // Wait for fetchData to complete and trigger UI rebuild.
      await tester.pump();
      await tester.pump(const Duration(microseconds: 1));

      // After data is loaded, the UI should rebuild and display the data.
      expect(find.text(TestService.sampleData), findsOneWidget);
    },
  );

  testWidgets(
    "ServiceBuilder rebuilds when service notifies listeners",
    (tester) async {
      final service = TestService();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ServiceBuilder<TestService>(
            factory: (_) => service,
            builder: (_, service) {
              return Text(service.maybeData.toString());
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial build should occur once with the current data.
      expect(find.text(TestService.sampleData), findsOneWidget);

      // Update the data and notify listeners.
      service.data = "2";
      await tester.pump();

      // Verify that the UI rebuilds and displays the updated value.
      expect(find.text("2"), findsOneWidget);
    },
  );
}
