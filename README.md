<div align="center">
    <img width="200px" src="https://github.com/flutter-service/service/raw/refs/heads/main/image/logo.png">
    <h1>Flutter Service</h1>
    <p>
        A Flutter-native service layer inspired by the MVVM pattern,<br>
        managing services according to the widget lifecycle,<br>
        without relying on Provider or Riverpod.
    </p>
</div>

## Why Use This Library?
- Designed to work naturally with Flutter widget lifecycle, rather than relying on heavy third-party state management libraries like Riverpod.

- Encourages separation of UI and business logic.

- Supports async data fetching with automatic rebuilds.

- Testable and predictable, ideal for MVVM-inspired architecture.

## Usage

### Defining a Service

```dart
import 'package:service/service.dart';

/// A simple example service that extends [Service] with integer data.
/// Each call to [fetchData] increments a static counter.
class ExampleService extends Service<int> {
  static int count = 0;

  /// Simulates fetching data asynchronously with a 1-second delay.
  @override
  Future<int> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return count += 1; // Increment and return the counter
  }
}
```

### Using ServiceWidget

`ServiceWidget` is a convenient widget that ties a service to the widget lifecycle:

* Automatically creates and disposes the service.
* Rebuilds the UI whenever the service notifies listeners.
* Provides `build` method with the current service instance.

```dart
import 'package:flutter/material.dart';
import 'package:service/service.dart';

/// A widget that uses [ExampleService] via [ServiceWidget].
/// Shows a loading indicator while data is being fetched,
/// and displays the fetched integer once available.
class ExampleWidget extends ServiceWidget<ExampleService> {
  const ExampleWidget({super.key});

  /// Provides the initial instance of [ExampleService].
  @override
  ExampleService get initialService => ExampleService();

  /// Builds the UI based on the current state of the service.
  /// Shows a [CircularProgressIndicator] while loading,
  /// and displays the service's integer data once loaded.
  @override
  Widget build(BuildContext context, ExampleService service) {
    if (service.isLoading) {
      return CircularProgressIndicator();
    }

    if (service.isError) {
      return Text("Service is failed: ${service.error}");
    }

    return RefreshIndicator(
      onRefresh: service.refresh,
      child: Opacity(
        opacity: service.isRefreshing ? 0.5 : 1,
        child: Text(service.data.toString()),
      ),
    );
  }
}
```

### Using ServiceBuilder Directly

`ServiceBuilder` allows you to use services without subclassing `ServiceWidget`.
It provides a factory for the service and a builder for the UI.

```dart
ServiceBuilder<ExampleService>(
  // Create the initial service instance.
  factory: (_) => ExampleService(),
  builder: (context, service) {
    // (Exception handling omitted)
    ...

    // Show the service data once loaded.
    return Text(service.data.toString());
  },
)
```

### Using Provider-like.
You can easily access a service from an ancestor widget using the following syntax:

```dart
final service = Service.of<MyService>(context);
```
