import 'package:flutter/widgets.dart';
import 'package:mvvm_service/components/service.dart';
import 'package:mvvm_service/components/service_mode.dart';
import 'package:mvvm_service/widgets/service_scope.dart';

/// Provides syntax sugar on [BuildContext] to easily retrieve,
/// manage, and react to application-wide services.
extension ServiceBuildContext on BuildContext {
  /// Retrieves or lazily creates a service of type [T], and binds
  /// its lifecycle to this [BuildContext]'s widget lifecycle.
  T serviceOf<T extends Service>(
    T Function() create, {
    ServiceMode mode = ServiceMode.watch,
  }) {
    final element = getElementForInheritedWidgetOfExactType<ServiceScope>();

    if (element is! ServiceScopeElement) {
      throw FlutterError(
        'ServiceScope was not found above this BuildContext.\n'
        'Please ensure ServiceScope is placed near the root of your widget tree.',
      );
    }

    return element.ensureService<T>(this as Element, mode, create);
  }
}
