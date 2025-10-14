import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// Provides a [Service] instance to the widget subtree using an [InheritedWidget].
class ServiceProvider<T extends Service> extends InheritedWidget {
  const ServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  /// The [Service] instance being provided to the subtree.
  final T service;

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) {
    return oldWidget.service != service;
  }

  /// Returns the [Service] of type [T] from the closest ancestor [ServiceProvider].
  ///
  /// Returns null if no provider is found. To throw an error instead,
  /// you can implement a separate `of` method with assert/exception.
  static T? maybeOf<T extends Service>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ServiceProvider<T>>()
        ?.service;
  }
}
