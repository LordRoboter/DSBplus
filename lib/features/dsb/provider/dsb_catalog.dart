import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/dsb/data/dsb_api.dart';
import 'package:planner/features/dsb/model/dsb_catalog.dart';
import 'package:planner/features/dsb/provider/dsb_api_provider.dart';

class DsbCatalogNotifier extends AsyncNotifier<DsbCatalog> {
  late final DsbApi api;

  @override
  Future<DsbCatalog> build() async {
    api = ref.read(dsbApiProvider);

    return api.loadCatalog();
  }

  Future<void> refresh() async {
    try {
      state = AsyncData(await api.loadCatalog());
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final dsbCatalogProvider =
    AsyncNotifierProvider<DsbCatalogNotifier, DsbCatalog>(
      DsbCatalogNotifier.new,
    );
