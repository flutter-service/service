import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'lib/test_service.dart';

void main() {
  test("Initial state of the service should be none", () {
    final service = TestService();
    expect(service.status, ServiceStatus.none);
    expect(service.maybeData, isNull);
    expect(service.maybeError, isNull);
  });

  test(
    "load() should change status from loading to loaded and set data",
    () async {
      final service = TestService();
      final future = service.load();

      expect(service.status, ServiceStatus.loading);

      await future;

      expect(service.status, ServiceStatus.loaded);
      expect(service.data, TestService.sampleData);
      expect(service.maybeError, isNull);
    },
  );

  test(
    "load() should change status to failed when fetchData throws an error",
    () async {
      final service = TestService(isThrowError: true);
      final future = service.load();

      expect(service.status, ServiceStatus.loading);

      await future;

      expect(service.status, ServiceStatus.failed);
      expect(service.maybeData, isNull);
      expect(service.maybeError, TestService.sampleError);
    },
  );

  test("refresh() should keep existing data while loading new data", () async {
    final service = TestService();
    await service.load();

    final future = service.refresh();
    expect(service.data, TestService.sampleData);
    expect(service.status, ServiceStatus.refresh);

    await future;

    expect(service.status, ServiceStatus.loaded);
  });

  testWidgets("serviceOf() returns the correct service", (tester) async {
    TestService1? service1;
    TestService2? service2;

    await tester.pumpWidget(
      ServiceScope(
        child: Builder(
          builder: (context) {
            service1 = context.serviceOf(TestService1.new);
            service2 = context.serviceOf(TestService2.new);
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(service1, isNotNull);
    expect(service1, isNot(service2));
  });

  testWidgets("service is disposed when element is unmounted", (tester) async {
    TestService1? service1;
    TestService2? service2;

    await tester.pumpWidget(
      ServiceScope(
        child: Builder(
          builder: (context) {
            service1 = context.serviceOf(TestService1.new);
            service2 = context.serviceOf(TestService2.new);
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(service1!.isDisposed, isFalse);
    expect(service2!.isDisposed, isFalse);

    await tester.pumpWidget(const ServiceScope(child: SizedBox()));
    expect(service1!.isDisposed, isTrue);
    expect(service2!.isDisposed, isTrue);
  });

  test('ignores a load result after dispose', () async {
    final service = TestService();
    final loading = service.load();
    service.dispose();

    await expectLater(loading, completes);
    expect(service.maybeData, isNull);
  });
}
