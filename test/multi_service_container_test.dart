import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'lib/multi_test_service.dart';
import 'lib/test_service.dart';

void main() {
  testWidgets(
    "MultiServiceContainer creates the service and calls load()",
    (tester) async {
      final service1 = MultiTestService1();
      final service2 = MultiTestService2();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MultiServiceContainer(
            entries: [
              ServiceEntry((_) => service1),
              ServiceEntry((_) => service2),
            ],
            builder: (context) {
              return Column(
                children: [
                  Text(service1.maybeData?.toString() ?? "loading"),
                  Text(service2.maybeData?.toString() ?? "loading"),
                ],
              );
            },
          ),
        ),
      );

      // The service should start in loading state immediately.
      expect(service1.status, ServiceStatus.loading);
      expect(service2.status, ServiceStatus.loading);
      expect(find.text("loading"), findsNWidgets(2));

      // Wait for fetchData to complete and trigger UI rebuild.
      await tester.pump();
      await tester.pump(TestService.duration);

      // After data is loaded, the UI should rebuild and display the data.
      expect(find.text(TestService.sampleData), findsNWidgets(2));
    },
  );

  testWidgets(
    "MultiServiceContainer rebuilds when service notifies listeners",
    (tester) async {
      final service1 = MultiTestService1();
      final service2 = MultiTestService2();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MultiServiceContainer(
            entries: [
              ServiceEntry((_) => service1),
              ServiceEntry((_) => service2),
            ],
            builder: (context) {
              return Column(
                children: [
                  Text(service1.maybeData?.toString() ?? "loading"),
                  Text(service2.maybeData?.toString() ?? "loading"),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial build should occur once with the current data.
      expect(find.text(TestService.sampleData), findsNWidgets(2));

      // Update the data and notify listeners.
      service1.data = "2";
      service2.data = "3";
      await tester.pump();

      // Verify that the UI rebuilds and displays the updated value.
      expect(find.text("2"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
    },
  );
}
