<div align="center">
  <img width="200px" src="https://github.com/flutter-service/service/raw/refs/heads/main/image/logo.png">
  <h1>Flutter Service</h1>
  <p>
    A Flutter-native MVVM service layer that creates, loads, watches,<br>
    shares, and disposes services according to the widget lifecycle.
  </p>
</div>

## Why Flutter Service?

- **No service registration:** Create a service where it is first used with `context.serviceOf()`.
- **Minimal boilerplate:** No provider declarations, consumer widgets, or generated code.
- **Automatic async state:** Loading, loaded, refresh, and error states are built into `Service`.
- **Reactive UI:** Widgets automatically rebuild when a watched service notifies listeners.
- **Widget-bound lifecycle:** A service is disposed when no elements are using it anymore.
- **Shared by type:** Widgets under the same `ServiceScope` reuse the same service instance.

## Quick Start

### 1. Define a service

Extend `Service<T>` and implement `fetchData()`:

```dart
class CounterService extends Service<int> {
  int count = 0;

  @override
  Future<int> fetchData() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return ++count;
  }
}
```

When the service is first created, `load()` is called automatically. The value returned by `fetchData()` becomes `data` and the status changes to `ServiceStatus.loaded`.

### 2. Add one ServiceScope

Place a single `ServiceScope` near the root of the widget tree:

```dart
void main() {
  runApp(
    const ServiceScope(
      child: MainApp(),
    ),
  );
}
```

Only one `ServiceScope` may exist in a widget tree. It owns all active service instances and manages their subscriptions and lifecycles.

### 3. Use the service

Call `context.serviceOf()` from a widget:

```dart
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.serviceOf(CounterService.new);

    if (service.isLoading) {
      return const CircularProgressIndicator();
    }

    if (service.isError) {
      return Text('Failed: ${service.error}');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: service.isRefreshing ? 0.5 : 1,
          child: Text('${service.data}'),
        ),
        TextButton(
          onPressed: service.refresh,
          child: const Text('Refresh'),
        ),
      ],
    );
  }
}
```

`serviceOf()` lazily creates `CounterService`, starts its initial load, and rebuilds `CounterView` whenever the service changes.

## Watch and Read Modes

`ServiceMode.watch` is the default. It subscribes the calling element to service updates:

```dart
final service = context.serviceOf(CounterService.new);
```

This is equivalent to:

```dart
final service = context.serviceOf(
  CounterService.new,
  mode: ServiceMode.watch,
);
```

Use `ServiceMode.read` when the widget needs the instance without rebuilding when it changes:

```dart
final service = context.serviceOf(
  CounterService.new,
  mode: ServiceMode.read,
);
```

Read mode still associates the service with the calling element for lifecycle management. It only disables reactive rebuilds.

Each service is independently created, shared, watched, and disposed.

## Declarative State Handling

The `when` extension maps every `ServiceStatus` to a widget:

```dart
@override
Widget build(BuildContext context) {
  final service = context.serviceOf(CounterService.new);

  return service.when(
    none: () => const Text('Idle'),
    loading: () => const CircularProgressIndicator(),
    refresh: (data) => Text('Refreshing: $data'),
    loaded: (data) => Text('Count: $data'),
    failed: (error) => Text('Failed: $error'),
  );
}
```

`none` falls back to `loading` when omitted, and `refresh` falls back to `loaded` when omitted.

## Service State

Every service exposes:

| API | Description |
| --- | --- |
| `status` | Current `ServiceStatus` |
| `isLoading` | `true` while idle or loading |
| `isRefreshing` | `true` during a refresh |
| `isError` | `true` after a failed load |
| `data` | Loaded data; intended for loaded or refreshing states |
| `maybeData` | Current data, or `null` when unavailable |
| `error` | Current error in the failed state |
| `maybeError` | Current error, or `null` when unavailable |
| `load()` | Loads data and replaces the current state |
| `refresh()` | Reloads while retaining existing data |
| `notifyUpdated()` | Notifies watching widgets after a custom state change |

You can also assign `data` directly. A changed value automatically notifies watching widgets:

```dart
service.data = 42;
```

## Lifecycle

Services are cached by their requested generic type inside `ServiceScope`:

```dart
final first = context.serviceOf(CounterService.new);
final second = context.serviceOf(CounterService.new);

identical(first, second); // true
```

The creation callback only runs when no service of type `T` is active. Elements using the service are tracked as readers or watchers. When the last dependent element is removed from the widget tree, the subscription is cancelled and the service is disposed.

Because services are keyed by type, only one active instance of each service type exists within the scope. If the same type is requested with different factories or constructor arguments, the first active instance is reused:

```dart
final first = context.serviceOf(() => UserService(userId: 1));
final same = context.serviceOf(() => UserService(userId: 2));

identical(first, same); // true
```

Use distinct service types when independently configured instances are required.

## Error Handling

Errors thrown by `fetchData()` are captured automatically:

```dart
class UserService extends Service<User> {
  @override
  Future<User> fetchData() => api.fetchUser();
}
```

On failure:

- `status` becomes `ServiceStatus.failed`.
- `isError` becomes `true`.
- The exception is available through `error` and `maybeError`.
- The error is printed with `debugPrint` by default.

Override these properties to customize error behavior:

```dart
@override
bool get canRethrow => true;

@override
bool get canDebugPrint => false;
```
