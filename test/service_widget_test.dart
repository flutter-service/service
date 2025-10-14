import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'service.dart';

/// A concrete implementation of [ServiceWidget] for testing purposes.
/// It displays the current [Service.maybeData] or "loading" if null.
class _TestServiceWidget extends ServiceWidget {
  const _TestServiceWidget(this._service);

  final Service _service;

  @override
  Service get initialService => _service;

  @override
  Widget build(BuildContext context, Service service) {
    return Text(service.maybeData ?? "loading");
  }
}

void main() {
  testWidgets(
    "ServiceWidget rebuilds when service notifies listeners",
    (tester) async {
      final service = TestService();
      final widget = _TestServiceWidget(service);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial UI displays the sample data from the service.
      expect(find.text(TestService.sampleData), findsOneWidget);

      // Update the service's data and notify listeners.
      service.data = "2";
      await tester.pump();

      // Verify that the UI rebuilds and displays the updated value.
      expect(find.text("2"), findsOneWidget);
    },
  );
}
