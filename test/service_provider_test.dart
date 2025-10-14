import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'service.dart';

void main() {
  testWidgets(
    "ServiceProvider.maybeOf returns the correct service",
    (tester) async {
      final service = TestService();

      await tester.pumpWidget(
        ServiceProvider<TestService>(
          service: service,
          child: Builder(
            builder: (context) {
              final fetchedService =
                  ServiceProvider.maybeOf<TestService>(context);

              // The fetched service should match the provided service.
              expect(fetchedService, service);
              return Container();
            },
          ),
        ),
      );
    },
  );

  testWidgets("ServiceProvider.maybeOf returns null when no provider exists",
      (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          final fetchedService = ServiceProvider.maybeOf<TestService>(context);

          // There is no provider, so it should return null.
          expect(fetchedService, isNull);
          return Container();
        },
      ),
    );
  });

  testWidgets("ServiceProvider updates when service changes", (tester) async {
    final oldService = TestService();
    final newService = TestService();

    bool rebuilt = false;

    // Pump the widget with the old service.
    await tester.pumpWidget(
      ServiceProvider<TestService>(
        service: oldService,
        child: Builder(
          builder: (context) {
            ServiceProvider.maybeOf<TestService>(context);
            rebuilt = true;
            return Container();
          },
        ),
      ),
    );

    rebuilt = false;

    // Pump the widget again with a new service.
    await tester.pumpWidget(
      ServiceProvider<TestService>(
        service: newService,
        child: Builder(
          builder: (context) {
            ServiceProvider.maybeOf<TestService>(context);
            rebuilt = true;
            return Container();
          },
        ),
      ),
    );

    // Verify that the widget rebuilt.
    expect(rebuilt, true);
  });
}
