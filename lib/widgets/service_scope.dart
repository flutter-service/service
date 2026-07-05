import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// Holds the services available to a widget subtree.
class ServiceScope extends InheritedWidget {
  const ServiceScope({
    super.key,
    required this.services,
    required super.child,
  });

  /// The services registered by their lookup type.
  final Map<Type, Service> services;

  @override
  bool updateShouldNotify(ServiceScope oldWidget) {
    return oldWidget.services != services;
  }

  /// Returns the closest [ServiceScope] that encloses the given [context].
  static ServiceScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServiceScope>();
  }
}
