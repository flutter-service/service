import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// Signature for a function that creates a [Service] instance.
/// Typically used to provide a service to a [ServiceBuilder].
typedef ServiceFactory<T extends Service> = T Function(BuildContext context);

/// Signature for a function that creates a widget using the given [Service] instance.
typedef ServiceWidgetBuilder<T extends Service> = Widget Function(BuildContext context, T service);

/// A widget that acts as a container for a [Service] instance,
/// managing its lifecycle and rebuilding the UI on updates.
///
/// The [ServiceContainer] automatically creates the service using the provided
/// [factory] and calls [Service.load] when initialized.
///
/// ```dart
/// ServiceContainer(
///   factory: (context) => MyService(),
///   builder: (context, service) {
///     return Text(service.value.toString());
///   },
/// )
/// ```
class ServiceContainer<T extends Service> extends StatefulWidget {
  /// Creates a [ServiceContainer] that manages a [Service] instance.
  ///
  /// The [factory] must not be null and is used to create the service.
  /// The [builder] must not be null and is used to build the UI using the service.
  const ServiceContainer({
    super.key,
    required this.factory,
    required this.builder,
  });

  /// A factory function that returns a [Service] instance.
  final ServiceFactory<T> factory;

  /// A builder function that creates a widget using the service.
  final ServiceWidgetBuilder<T> builder;

  @override
  State<ServiceContainer<T>> createState() => ServiceContainerState<T>();
}

/// State for a [ServiceContainer] widget.
class ServiceContainerState<T extends Service> extends State<ServiceContainer<T>> {
  late final T _service;

  /// Returns the service of the [ServiceBuilder] widget.
  T get service => _service;

  /// Indicates whether this widget fully owns the service and is
  /// responsible for managing its lifecycle, including disposal.
  bool _ownsService = false;

  @override
  void initState() {
    super.initState();
    _service = widget.factory(context);

    // Triggers the service to load its data if it hasn't been initialized yet.
    if (_service.status == ServiceStatus.none) {
      _ownsService = true;
      _service.load();
    }
  }

  @override
  void dispose() {
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      services: [service],
      child: ListenableBuilder(
        listenable: _service,
        builder: (context, _) => widget.builder(context, _service),
      ),
    );
  }
}
