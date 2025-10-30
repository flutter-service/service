import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// A widget taht provides a convenient way to work with a [Service] instance.
///
/// This widget automatically wraps the [initialService] with a [ServiceBuilder],
/// so the UI rebuilds whenever the service notifies listeners.
///
/// Subclasses must provide the [initialService] and implement the [build] method.
abstract class ServiceWidget<T extends Service> extends StatefulWidget {
  const ServiceWidget({super.key});

  /// Returns the initial [Service] instance.
  T get initialService;

  /// Similar to [State.build], but also provides the [service] instance.
  Widget build(BuildContext context, T service);

  @override
  State<ServiceWidget<T>> createState() => ServiceWidgetState<T>();
}

/// State for a [ServiceWidget] widget.
class ServiceWidgetState<T extends Service> extends State<ServiceWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return ServiceBuilder(
      factory: (context) => widget.initialService,
      builder: widget.build,
    );
  }
}
