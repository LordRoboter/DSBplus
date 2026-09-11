import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/dsb/provider/dsb_api_provider.dart';
import 'package:planner/features/dsb/resources/data/dsb_resource_parser.dart';
import 'package:planner/features/dsb/resources/model/resource.dart';
import 'package:planner/features/dsb/resources/service/dsb_resources_service.dart';

final dsbResourcesServiceProvider = Provider<DsbResourcesService>((ref) {
  return DsbResourcesService(
    api: ref.watch(dsbApiProvider),
    parser: ref.watch(dsbResourceParserProvider),
  );
});

final dsbResourcesProvider = FutureProvider<List<ResourceBundle>>((ref) {
  return ref.watch(dsbResourcesServiceProvider).getResources();
});

final dsbResourceParserProvider = Provider<DsbResourceParser>((ref) {
  return DsbResourceParser();
});
