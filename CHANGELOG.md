## 1.0.0
- Initial version.

## 1.0.1
- Modified `ServiceBuilder<T>` to automatically load its service only if it hasn't been initialized yet.

## 1.0.2
- Fixed an issue where services could not be referenced due to incorrect generic type handling.

## 1.1.0
- Added `ServiceWhen<T>` extension on services to declaratively build widgets based on their current state.

- Updated `ServiceBuilder<T>` to dispose its Service instance when the widget is disposed if it fully owns the service.

## 1.1.1
- Added `ServiceWidgetOf`, a widget that allows referencing an existing service from the widget tree. This widget is useful when a service has already been initialized and managed by an ancestor widget, allowing descendant widgets to access and rebuild in response to service updates without creating a new instance.

## 1.1.2
- Fixed the issue where `ServiceWidget<T>` and `ServiceWidgetOf<T>` could not correctly reference an ancestor service due to ServiceProvider not having an explicit generic type, ensuring descendant widgets can now access the service with the proper type.

## 2.0.0

### Breaking Changes

- Replaced `ServiceProvider` with a single root `ServiceScope`.
- Removed `ServiceWidget` and `ServiceWidgetOf`.
- Removed `ServiceContainer` and all multi-service container APIs.
- Removed `Service.of()` and `Service.maybeOf()`.
- Services are now lazily created through `BuildContext.serviceOf()`.
- Added automatic service sharing, watching, loading, and lifecycle disposal.
- Added `ServiceMode.read` and `ServiceMode.watch`.

## 2.1.0

- Added an optional `key` parameter to `BuildContext.serviceOf()`, allowing multiple independently configured instances of the same service type.
- Added and exported `ServiceId` to identify services by their type and optional key.

## 2.2.0

- Added `BuildContext.stateOf()` for creating reactive state backed by `ValueNotifier`.
- Added `StateScope` and the `ServiceScope.withState` convenience constructor.
- Added `StateMode.read` and `StateMode.watch` to control widget rebuilds.
- Added automatic state identity based on type and invocation order, with optional keys for explicit sharing or separation.
- Added an `onDispose` callback for cleaning up resources held by state values.
- Added automatic disposal when a state no longer has dependent elements.

## 2.3.0

- Added BuildContext hooks for creating and automatically disposing common Flutter controllers and resources.
- Added hooks for scroll, page, tab, text editing, animation, focus, ticker provider, and stream controllers.
- Added `useTickerProvider()` and its `useVsync()` alias for animation hooks.
- Added and exported `HookTickerProvider` for managing the lifecycle of hook-created tickers.
