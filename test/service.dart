import 'package:mvvm_service/mvvm_service.dart';

/// A test implementation of [Service] for String data.
///
/// Can simulate success or failure based on [isThrowError].
class TestService extends Service<String> {
  TestService({this.isThrowError = false});

  final bool isThrowError;

  static const String sampleData = "Hello, World!";
  static final Error sampleError = Error();

  @override
  Future<String> fetchData() async {
    if (isThrowError) throw sampleError;

    await Future.delayed(Duration(microseconds: 1));
    return sampleData;
  }
}
