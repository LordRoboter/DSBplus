import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/certificates.dart';

final httpOverridesProvider = Provider<MyHttpOverrides>((ref) {
  final overrides = ref.watch(httpOverridesHolderProvider).instance;

  if (overrides == null) {
    throw StateError('HTTP overrides have not been initialized');
  }

  return overrides;
});

class HttpOverridesHolder {
  MyHttpOverrides? instance;
}

final httpOverridesHolderProvider = Provider<HttpOverridesHolder>((ref) {
  throw UnimplementedError(
    'httpOverridesHolderProvider must be overridden in main()',
  );
});
