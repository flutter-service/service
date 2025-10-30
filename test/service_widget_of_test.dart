import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_service/mvvm_service.dart';

import 'service.dart';

/// A concrete implementation of [ServiceWidgetOf] for testing purposes.
/// It displays the current [Service.maybeData] or "loading" if null.
class _TestServiceWidget extends ServiceWidgetOf<TestService> {
  const _TestServiceWidget(this._service);

  final Service _service;

  @override
  Widget build(BuildContext context, Service fetchedService) {
    // The fetched service should match the provided service.
    expect(fetchedService, _service);

    return Text(fetchedService.maybeData ?? "loading");
  }
}

void main() {
  testWidgets(
    "Builds with the service instance provided by ServiceProvider",
    (tester) async {
      final service = TestService();
      final widget = _TestServiceWidget(service);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ServiceProvider(
            service: service,
            child: widget,
          ),
        ),
      );
    },
  );
}
