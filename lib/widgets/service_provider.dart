import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// Provides a [Service] instance to the widget subtree using an [InheritedWidget].
class ServiceProvider extends StatelessWidget {
  const ServiceProvider({
    super.key,
    required this.services,
    required this.child,
  });

  /// The [Service] instance being provided to the subtree.
  final List<Service> services;

  /// The child widget subtree that can access the provided [Service].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parent = ServiceScope.maybeOf(context);
    final merged = <Type, Service>{
      if (parent != null) ...parent.services,
      for (final entry in services) entry.runtimeType: entry,
    };

    return ServiceScope(
      services: merged,
      child: child,
    );
  }

  /// Returns the [Service] of type [T] from the closest ancestor [ServiceScope].
  ///
  /// Returns null if no provider is found. To throw an error instead,
  /// you can implement a separate `of` method with assert/exception.
  static T? maybeOf<T extends Service>(BuildContext context) {
    final scope = ServiceScope.maybeOf(context);
    final value = scope?.services[T];

    if (value is T) return value;
    return null;
  }
}
