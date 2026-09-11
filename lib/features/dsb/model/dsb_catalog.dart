import 'package:planner/features/dsb/model/dsb_page.dart';

class DsbCatalog {
  List<DsbPage> pages;

  List<DsbPage> get timetables => pages.where((page) {
    return page.category == DsbCategory.timetable;
  }).toList();
  List<DsbPage> get resources => pages.where((page) {
    return page.category == DsbCategory.resource;
  }).toList();
  /*
  List<DsbPage> get news => pages.where((page) {
    return page.category == DsbCategory.news;
  }).toList();
  */

  DsbCatalog({required this.pages});
}
