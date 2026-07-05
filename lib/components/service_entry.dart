import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// A typed entry that holds a [Service] instance for [ServiceProvider].
class ServiceEntry<T extends Service> {
  const ServiceEntry(this.create);

  /// The [Service] instance being provided.
  final ServiceFactory<T> create;

  /// The type used to identify the [Service] instance.
  Type get type => T;

  /// Creates the [Service] instance within the current build context.
  T build(BuildContext context) {
    return create(context);
  }
}
