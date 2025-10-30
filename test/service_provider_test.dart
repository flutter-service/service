import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'service.dart';

/// A test service-1 that returns a simple string when `fetchData` is called.
class _TestService1 extends Service<String> {
  @override
  Future<String> fetchData() async => "Hello, World! (1)";
}

/// A test service-2 that returns a simple string when `fetchData` is called.
class _TestService2 extends Service<String> {
  @override
  Future<String> fetchData() async => "Hello, World! (2)";
}

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

  testWidgets(
    "ServiceProvider provides correct services for each type",
    (tester) async {
      final service1 = _TestService1();
      final service2 = _TestService2();

      await tester.pumpWidget(
        ServiceProvider<_TestService1>(
          service: service1,
          child: ServiceProvider<_TestService2>(
            service: service2,
            child: Builder(
              builder: (context) {
                final fetchedService1 =
                    ServiceProvider.maybeOf<_TestService1>(context);

                final fetchedService2 =
                    ServiceProvider.maybeOf<_TestService2>(context);

                // Verify that each service is correctly provided by its respective ServiceProvider.
                expect(fetchedService1, service1);
                expect(fetchedService2, service2);

                // Ensure that the two fetched services are distinct instances.
                expect(fetchedService1 != fetchedService2, true);
                return Container();
              },
            ),
          ),
        ),
      );
    },
  );
}
