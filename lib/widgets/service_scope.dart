import 'package:flutter/widgets.dart';
import 'package:mvvm_service/components/service.dart';
import 'package:mvvm_service/components/service_mode.dart';
import 'package:mvvm_service/components/service_subscription.dart';

/// A widget that hosts the [ServiceScopeElement] to manage and provide
/// application-wide services down the widget subtree.
///
/// Only one [ServiceScope] should exist near the root of the widget tree.
class ServiceScope extends InheritedWidget {
  const ServiceScope({
    super.key,
    required super.child,
  });

  @override
  InheritedElement createElement() => ServiceScopeElement(this);

  @override
  bool updateShouldNotify(ServiceScope oldWidget) => false;

  /// Looks up the widget tree to find the active [ServiceScopeElement].
  static ServiceScopeElement? maybeElementOf(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<ServiceScope>();
    return element is ServiceScopeElement ? element : null;
  }
}

class ServiceScopeElement extends InheritedElement {
  ServiceScopeElement(ServiceScope super.widget);

  /// Active service subscriptions mapped by their service [Type].
  ///
  /// This serves as the single source of truth for both managing service instances
  /// (and their lifecycles) and tracking which elements are listening to them.
  final Map<Type, ServiceSubscription> _subscriptions = {};

  /// Tracks the service types used by each dependent element.
  final Map<Element, Set<Type>> _serviceDependents = {};

  @override
  void mount(Element? parent, Object? newSlot) {
    if (parent?.getElementForInheritedWidgetOfExactType<ServiceScope>() != null) {
      throw FlutterError('Only one ServiceScope can exist in a widget tree.');
    }

    super.mount(parent, newSlot);
  }

  /// Ensures a service of type [T] is available, lazily creating
  /// it if necessary, and registers the [dependent] element.
  T ensureService<T extends Service>(Element dependent, ServiceMode mode, T Function() create) {
    // Retrieve the existing service or lazily create a new one.
    final subscription = _subscriptions.putIfAbsent(T, () {
      final service = create();

      if (service.status == ServiceStatus.none) {
        service.load();
      }

      late final ServiceSubscription sub;

      void listener() {
        for (final element in sub.watchers) {
          if (element.mounted) {
            element.markNeedsBuild();
          }
        }
      }

      service.addListener(listener);
      sub = ServiceSubscription(service: service, listener: listener);
      return sub;
    });

    // Register the dependency with Flutter's framework using the service Type [T] as the aspect.
    dependent.dependOnInheritedWidgetOfExactType<ServiceScope>(aspect: T);

    // Track the element in either watchers or readers based on the requested [mode].
    if (mode == ServiceMode.watch) {
      subscription.watchers.add(dependent);
    } else {
      subscription.readers.add(dependent);
    }

    return subscription.service as T;
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    super.updateDependencies(dependent, aspect);

    if (aspect is Type) {
      _serviceDependents.putIfAbsent(dependent, () => {}).add(aspect);
    }
  }

  @override
  void removeDependent(Element dependent) {
    final types = _serviceDependents.remove(dependent);

    if (types is Set<Type>) {
      for (final type in types) {
        final subscription = _subscriptions[type];

        if (subscription != null) {
          subscription.watchers.remove(dependent);
          subscription.readers.remove(dependent);

          // Dispose of the service if it is no longer referenced by any widget.
          if (subscription.referenceCount == 0) {
            _subscriptions.remove(type)?.dispose();
          }
        }
      }
    }

    super.removeDependent(dependent);
  }

  @override
  void unmount() {
    for (var sub in _subscriptions.values) {
      sub.dispose();
    }

    _subscriptions.clear();
    super.unmount();
  }
}
