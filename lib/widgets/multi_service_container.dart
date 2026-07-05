import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// A widget that acts as a container for multiple [Service] instances,
/// managing their lifecycles and rebuilding the UI on updates.
///
/// The [MultiServiceContainer] automatically creates the services using the provided
/// [entries] and calls [Service.load] for each service when initialized.
///
/// ```dart
/// MultiServiceContainer(
///   entries: [
///     ServiceEntry((context) => MyService1()),
///     ServiceEntry((context) => MyService2()),
///   ],
///   builder: (context) {
///     final service1 = Service.of<MyService1>(context);
///     final service2 = Service.of<MyService2>(context);
///     return Text('${service1.value}, ${service2.value}');
///   },
/// )
/// ```
class MultiServiceContainer extends StatefulWidget {
  const MultiServiceContainer({
    super.key,
    required this.entries,
    required this.builder,
  });

  /// A list of service entries.
  final List<ServiceEntry> entries;

  /// A builder function that creates a widget using the service.
  final WidgetBuilder builder;

  @override
  State<MultiServiceContainer> createState() => MultiServiceContainerState();
}

/// State for a [MultiServiceContainer] widget.
class MultiServiceContainerState extends State<MultiServiceContainer> {
  late final List<Service> _services;

  /// A merged [Listenable] of all services to trigger rebuilds efficiently.
  late final Listenable _mergedListenable;

  /// Tracks the service entries that this widget fully owns and is
  /// responsible for managing their lifecycle, including disposal.
  final Set<Service> _ownedServices = {};

  @override
  void initState() {
    super.initState();
    _services = widget.entries.map((e) => e.build(context)).toList();
    _mergedListenable = Listenable.merge(_services);

    // Triggers the service to load its data if it hasn't been initialized yet.
    for (final service in _services) {
      if (service.status == ServiceStatus.none) {
        _ownedServices.add(service);
        service.load();
      }
    }
  }

  @override
  void dispose() {
    for (final service in _ownedServices) {
      service.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      services: _services,
      child: ListenableBuilder(
        listenable: _mergedListenable,
        builder: (context, _) => widget.builder(context),
      ),
    );
  }
}
