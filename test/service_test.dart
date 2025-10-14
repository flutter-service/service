import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'service.dart';

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
}
