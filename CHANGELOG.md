## 1.0.0
- Initial version.

## 1.0.1
- Modified `ServiceBuilder` to automatically load its service only if it hasn't been initialized yet.

## 1.0.2
- Fixed an issue where services could not be referenced due to incorrect generic type handling.

## 1.1.0
- Added `ServiceWhen<T>` extension on services to declaratively build widgets based on their current state.

- Updated `ServiceBuilder` to dispose its Service instance when the widget is disposed if it fully owns the service.
