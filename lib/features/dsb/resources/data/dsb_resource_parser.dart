import 'package:planner/features/dsb/model/dsb_page.dart';
import 'package:planner/features/dsb/resources/model/resource.dart';

class DsbResourceParser {
  List<ResourceBundle> parsePages(List<DsbPage> pages) {
    return pages
        .where((page) => page.category == DsbCategory.resource)
        .map(
          (page) => ResourceBundle(
            title: page.title,
            date: page.date,
            resources: page.childs
                .map(
                  (child) => Resource(
                    title: child.title,
                    date: child.date,
                    url: child.url,
                    previewUrl: child.previewUrl,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }
}
