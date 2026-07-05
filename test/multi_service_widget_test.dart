import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'lib/multi_test_service.dart';
import 'lib/test_service.dart';

/// A concrete implementation of [ServiceWidget] for testing purposes.
/// It displays the current [Service.maybeData] or "loading" if null.
class _TestServiceWidget extends MultiServiceWidget {
  const _TestServiceWidget({
    required this.service1,
    required this.service2,
  });

  final MultiTestService1 service1;
  final MultiTestService2 service2;

  @override
  List<Service> get initialServices => [service1, service2];

  @override
  Widget build(BuildContext context) {
    final service1 = Service.of<MultiTestService1>(context);
    final service2 = Service.of<MultiTestService2>(context);

    return Column(
      children: [
        Text(service1.maybeData ?? "loading"),
        Text(service2.maybeData ?? "loading"),
      ],
    );
  }
}

void main() {
  testWidgets(
    "MultiServiceWidget rebuilds when service notifies listeners",
    (tester) async {
      final service1 = MultiTestService1();
      final service2 = MultiTestService2();
      final widget = _TestServiceWidget(
        service1: service1,
        service2: service2,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial UI displays the sample data from the service.
      expect(find.text(TestService.sampleData), findsNWidgets(2));

      // Update the service's data and notify listeners.
      service1.data = "2";
      service2.data = "3";
      await tester.pump();

      // Verify that the UI rebuilds and displays the updated value.
      expect(find.text("2"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
    },
  );
}
