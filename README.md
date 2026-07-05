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

- **Widget Lifecycle Native:** Designed to work naturally with the Flutter widget lifecycle, avoiding heavy third-party state management overhead.

- **Clean Architecture:** Strongly encourages a strict separation of UI and business logic.

- **Asynchronous & Reactive:** Supports async data fetching with automatic UI rebuilds out of the box.

- **Highly Testable:** Predictable and isolated state management, ideal for MVVM-inspired architectures.

## Usage

### Defining a Service

```dart
import 'package:service/service.dart';

/// A simple example service that extends [Service] with integer data.
/// Each call to [fetchData] increments a static counter.
class ExampleService extends Service<int> {
  int count = 0;

  /// Simulates fetching data asynchronously with a 1-second delay.
  @override
  Future<int> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return count += 1; // Increment and return the counter
  }
}
```

### Injecting a Single Service via ServiceWidget

`ServiceWidget` is a convenient widget that ties a single service directly to the widget lifecycle. It automatically creates and disposes of the service, and rebuilds the UI whenever the service notifies listeners.

```dart
import 'package:flutter/material.dart';
import 'package:service/service.dart';

/// A widget that uses [ExampleService] via [ServiceWidget].
class ExampleWidget extends ServiceWidget<ExampleService> {
  const ExampleWidget({super.key});

  /// Provides the initial instance of [ExampleService].
  @override
  ExampleService get initialService => ExampleService();

  /// Builds the UI based on the current state of the service.
  @override
  Widget build(BuildContext context, ExampleService service) {
    if (service.isLoading) {
      return const CircularProgressIndicator();
    }

    if (service.isError) {
      return Text("Service failed: ${service.error}");
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

### Injecting Multiple Services

When a screen or widget tree requires multiple services, you can inject them all at once without nested widget trees by using `MultiServiceWidget` or `MultiServiceContainer`.

#### Subclassing MultiServiceWidget

```dart
import 'package:flutter/material.dart';
import 'package:service/service.dart';

class MyComplexWidget extends MultiServiceWidget {
  const MyComplexWidget({super.key});

  @override
  List<Service> get initialServices => [
    AuthService(),
    ThemeService(),
  ];

  @override
  Widget build(BuildContext context) {
    // Access the injected services anywhere in the subtree
    final auth = Service.of<AuthService>(context);
    final theme = Service.of<ThemeService>(context);

    return Container(
      color: theme.backgroundColor,
      child: Text('Hello, ${auth.userName}'),
    );
  }
}
```

#### Using MultiServiceContainer Directly

If you prefer an inline approach without subclassing, use `MultiServiceContainer`:

```dart
MultiServiceContainer(
  entries: [
    ServiceEntry((context) => AuthService()),
    ServiceEntry((context) => ThemeService()),
  ],
  builder: (context) {
    final auth = Service.of<AuthService>(context);
    return Text('User: ${auth.userName}');
  },
)
```

### Using ServiceContainer Directly

If you prefer not to subclass `ServiceWidget` for a single service, you can use `ServiceContainer` inline:

```dart
ServiceContainer<ExampleService>(
  // Create the initial service instance.
  factory: (_) => ExampleService(),
  builder: (context, service) {
    if (service.isLoading) return const CircularProgressIndicator();

    // Show the service data once loaded.
    return Text(service.data.toString());
  },
)
```

### Accessing Services from the Context

You can easily access an active service instance from any descendant widget in the subtree using the following syntax:

```dart
final service = Service.of<MyService>(context);
```

### Consuming Services via ServiceWidgetOf

If a sub-widget only needs to consume an existing service from the tree without managing its lifecycle, use `ServiceWidgetOf` to keep your code concise:

```dart
/// A subtree widget that depends on [ExampleService] using [ServiceWidgetOf].
class ExampleSubtreeWidget extends ServiceWidgetOf<ExampleService> {
  const ExampleSubtreeWidget({super.key});

  @override
  Widget build(BuildContext context, ExampleService service) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(service.data.toString()),
        TextButton(
          onPressed: service.refresh,
          child: const Text("Refresh"),
        ),
      ],
    );
  }
}
```

### Declarative State Handling with `when`

You can use the `when` extension on any service to declaratively build widgets based on its current state. This eliminates messy conditional statements and maps each state directly to a corresponding widget:

```dart
service.when(
  none: () => const Text("Service is idle"), // optional fallback when 'loading'
  loading: () => const CircularProgressIndicator(),
  refresh: () => const CircularProgressIndicator(), // optional fallback when 'loaded'
  failed: (error) => Text("Service failed: $error"),
  loaded: (data) => Text("Data: $data"),
);
```

---

## Architecture Tips

### Using the Singleton Pattern

Singletons are highly effective when you want **only one instance of a service** to exist across your entire application. This ensures shared state remains consistent and avoids unnecessary re-allocations.

> [!IMPORTANT]
> Declaring a single instance as static and forcefully providing it manually goes against Flutter's widget-tree-driven philosophy. Wrap your singletons cleanly using the framework's native entry points.

```dart
class ExampleService extends Service<int> {
  ExampleService._();

  /// The singleton instance of [ExampleService].
  /// Use this instead of creating a new instance to ensure a single shared service.
  static final ExampleService instance = ExampleService._();

  int count = 0;

  @override
  Future<int> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    return count += 1;
  }
}
```
