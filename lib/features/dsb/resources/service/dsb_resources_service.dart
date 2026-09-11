import 'package:planner/features/dsb/data/dsb_api.dart';
import 'package:planner/features/dsb/resources/data/dsb_resource_parser.dart';
import 'package:planner/features/dsb/resources/model/resource.dart';

class DsbResourcesService {
  final DsbApi api;
  final DsbResourceParser parser;
  const DsbResourcesService({required this.api, required this.parser});

  Future<List<ResourceBundle>> getResources() async {
    final catalog = await api.loadCatalog();
    final resources = parser.parsePages(catalog.resources);
    return resources;
  }
}
