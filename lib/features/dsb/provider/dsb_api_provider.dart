import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/auth_repository.dart';
import 'package:planner/features/dsb/data/dsb_api.dart';

final dsbApiProvider = Provider<DsbApi>((ref) {
  final auth = ref.watch(authRepositoryProvider);

  return DsbApi(auth);
});
