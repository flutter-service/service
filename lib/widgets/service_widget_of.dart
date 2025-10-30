import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// A widget that references an existing service from the widget tree.
///
/// Use this when a service has already been initialized and managed
/// by an ancestor widget. Provides the service instance in [build]
/// without creating or owning it.
abstract class ServiceWidgetOf<T extends Service> extends StatefulWidget {
  const ServiceWidgetOf({super.key});

  /// Similar to [State.build], but also provides the [service] instance.
  Widget build(BuildContext context, T service);

  @override
  State<ServiceWidgetOf<T>> createState() => ServiceWidgetOfState<T>();
}

/// State for a [ServiceWidgetOf] widget.
class ServiceWidgetOfState<T extends Service>
    extends State<ServiceWidgetOf<T>> {
  @override
  Widget build(BuildContext context) {
    final service = Service.of<T>(context);

    // Rebuild the widget whenever the service notifies listeners.
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        return widget.build(context, service);
      },
    );
  }
}
