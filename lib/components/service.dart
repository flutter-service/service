import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_service/mvvm_service.dart';

/// Signature for the data loading state of a standard [Service].
enum ServiceStatus {
  /// When no action has been performed yet
  none,

  /// When waiting for a response from the server
  loading,

  /// When data request succeeded and deserialization completed
  loaded,

  /// When data request failed
  failed,

  /// When refreshing while keeping existing data
  refresh,
}

/// An abstract class that represents the ViewModel in the `MVVM` architecture pattern.
/// Primarily responsible for data loading and state management.
abstract class Service<T> extends ChangeNotifier {
  Service({ServiceStatus initialStatus = ServiceStatus.none}) {
    _statusNotifier = ValueNotifier(initialStatus);
    _statusNotifier.addListener(notifyListeners);
  }

  /// An internal [Listenable] instance that defines
  /// the current state and notifies listeners for rebuilds.
  late final ValueNotifier<ServiceStatus> _statusNotifier;

  /// Internally updates the current state with the given value.
  set _status(ServiceStatus newStatus) {
    _statusNotifier.value = newStatus;
  }

  /// Returns the current status of the [Service].
  ServiceStatus get status => _statusNotifier.value;

  /// Returns true if the data is currently being loaded or not ready for display.
  /// Typically used to show loading indicators or placeholders.
  bool get isLoading =>
      status == ServiceStatus.none || status == ServiceStatus.loading;

  /// Returns true if the service is currently refreshing its data.
  /// Useful for pull-to-refresh indicators or temporarily disabling
  /// UI interactions.
  bool get isRefreshing => status == ServiceStatus.refresh;

  /// Returns true if the service encountered an error while fetching data.
  bool get isError => status == ServiceStatus.failed;

  /// Determines whether this service should rethrow errors from [load].
  /// Can be overridden by subclasses to customize behavior.
  bool get canRethrow => false;

  /// Determines whether this service should log errors using debugPrint.
  /// Subclasses can override to disable or customize logging.
  bool get canDebugPrint => true;

  T? _data;
  dynamic _error;

  /// Returns the currently deserialized and loaded data.
  ///
  /// Throws an assertion error if the data is not yet loaded.
  T get data {
    assert(
      _data != null || status == ServiceStatus.refresh,
      "Data must be loaded before access.",
    );
    assert(
      status == ServiceStatus.loaded || status == ServiceStatus.refresh,
      "Data should only be accessed when [ServiceStatus.loaded] or refreshing.",
    );

    return _data!;
  }

  /// Updates the currently loaded data with the given value.
  set data(T newData) {
    if (_data != newData) {
      _data = newData;
      notifyUpdated();
    }
  }

  /// Returns the current error. Throws if no error is present.
  dynamic get error {
    assert(
      _error != null || status == ServiceStatus.failed,
      "Error must exist before access.",
    );
    assert(
      status == ServiceStatus.failed,
      "Error should only be accessed when [ServiceStatus.failed].",
    );

    return _error!;
  }

  /// Returns the current data regardless of its existence.
  T? get maybeData => _data;

  /// Returns the current error regardless of its existence.
  dynamic get maybeError => _error;

  /// Called when a data load fails.
  ///
  /// By default, this sets the state to [ServiceStatus.failed].
  void fail(dynamic error) {
    _error = error;
    _status = ServiceStatus.failed;
  }

  /// Called when data has been successfully loaded.
  ///
  /// Internally sets the state to [ServiceStatus.loaded] and updates the data.
  void done(T newData) {
    _data = newData;
    _status = ServiceStatus.loaded;
  }

  /// Starts loading or refreshing the data managed by this service.
  ///
  /// Sets the service status to [ServiceStatus.loading] or [ServiceStatus.refresh]
  /// depending on the [isRefresh] flag. The actual data fetching is performed
  /// by [fetchData]. This method must call either [done] on success or [fail]
  /// on failure to properly update the service state and notify listeners.
  @mustCallSuper
  Future<void> load({bool isRefresh = false}) async {
    _status = isRefresh ? ServiceStatus.refresh : ServiceStatus.loading;

    try {
      done(await fetchData());
    } catch (error) {
      fail(error);

      // Controls error handling: rethrows if [canRethrow], otherwise logs the failure.
      if (canRethrow) {
        rethrow;
      } else if (canDebugPrint) {
        debugPrint("Service $this failed to load: $error");
      }
    }
  }

  /// Fetches the data for this service.
  ///
  /// Implementations should return the requested data or throw an error
  /// if the data cannot be retrieved. This method is called internally
  /// by [load] to perform the actual data retrieval.
  Future<T> fetchData();

  /// Requests a refresh while keeping existing data until new data is loaded.
  Future<void> refresh() async => await load(isRefresh: true);

  /// Notifies listeners that the internal data has been updated.
  void notifyUpdated() => notifyListeners();

  @override
  void dispose() {
    _statusNotifier.dispose();
    super.dispose();
  }

  /// Finds the [Service] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will return null.
  /// To throw an exception instead, use [of] instead of this function.
  static Service<T>? maybeOf<T extends Service>(BuildContext context) {
    return ServiceProvider.maybeOf<Service<T>>(context);
  }

  /// Finds the [Service] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// If no instance of this class encloses the given context, will cause an
  /// assert in debug mode, and throw an exception in release mode.
  static Service<T> of<T extends Service>(BuildContext context) {
    final Service<T>? result = maybeOf<T>(context);
    if (result != null) {
      return result;
    }

    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        "Service.of<T>() called with a context that does not contain a ServiceProvider<Service<T>>.",
      ),
      context.describeElement("The context used was"),
    ]);
  }

  @override
  String toString() {
    return "Service(status: $status, data: $_data, error: $_error)";
  }
}
