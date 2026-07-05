import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// A widget that provides a convenient way to work with multiple [Service] instances.
///
/// This widget automatically wraps the [initialServices] with a [MultiServiceContainer],
/// so the UI rebuilds whenever any of the services notify listeners.
///
/// Subclasses must provide the [initialServices] and implement the [build] method.
abstract class MultiServiceWidget extends StatefulWidget {
  const MultiServiceWidget({super.key});

  /// Returns the initial [Service] instances.
  List<Service> get initialServices;

  /// Similar to [State.build].
  Widget build(BuildContext context);

  @override
  State<MultiServiceWidget> createState() => _MultiServiceWidgetState();
}

/// State for a [MultiServiceWidget] widget.
class _MultiServiceWidgetState extends State<MultiServiceWidget> {
  late final List<ServiceEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.initialServices.map((e) => ServiceEntry((_) => e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiServiceContainer(
      entries: _entries,
      builder: widget.build,
    );
  }
}
