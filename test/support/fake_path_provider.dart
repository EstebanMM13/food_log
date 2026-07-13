import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Fake `path_provider` backend for tests.
///
/// [PhotoStorage] resolves its base folder through
/// `path_provider`'s `getApplicationDocumentsDirectory()`, which normally
/// talks to a platform channel that isn't available in plain `flutter test`.
/// Installing this as [PathProviderPlatform.instance] redirects that call to
/// a real (disposable) directory on disk instead, so photo persistence can be
/// exercised against the real filesystem without mocking it away.
class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}
