import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stateOf() returns different instances for no keys', (tester) async {
    late ValueNotifier<int> state1;
    late ValueNotifier<int> state2;

    await tester.pumpWidget(
      ServiceScope.withState(
        child: Builder(
          builder: (context) {
            state1 = context.stateOf(() => 1);
            state2 = context.stateOf(() => 2);
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(state1, isNot(same(state2)));
  });

  testWidgets('stateOf() returns different instances for different keys', (tester) async {
    late ValueNotifier<int> state1;
    late ValueNotifier<int> state2;

    await tester.pumpWidget(
      ServiceScope.withState(
        child: Builder(
          builder: (context) {
            state1 = context.stateOf(() => 1, key: ValueKey(1));
            state2 = context.stateOf(() => 2, key: ValueKey(2));
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(state1, isNot(same(state2)));
  });

  testWidgets('stateOf() rebuilds the widget when the value changes', (tester) async {
    late ValueNotifier<int> state;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ServiceScope.withState(
          child: Builder(
            builder: (context) {
              state = context.stateOf(() => 1, key: ValueKey(1));
              return Text(state.value.toString());
            },
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    state.value = 0;

    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });
}
