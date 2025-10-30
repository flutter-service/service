## 1.0.0
- Initial version.

## 1.0.1
- Modified `ServiceBuilder` to automatically load its service only if it hasn't been initialized yet.

## 1.0.2
- Fixed an issue where services could not be referenced due to incorrect generic type handling.

## 1.1.0
- Added `ServiceWhen<T>` extension on services to declaratively build widgets based on their current state.

- Updated `ServiceBuilder` to dispose its Service instance when the widget is disposed if it fully owns the service.

## 1.1.1
- Added `ServiceWidgetOf`, a widget that allows referencing an existing service from the widget tree. This widget is useful when a service has already been initialized and managed by an ancestor widget, allowing descendant widgets to access and rebuild in response to service updates without creating a new instance.
