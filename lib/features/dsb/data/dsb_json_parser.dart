import 'package:intl/intl.dart';
import 'package:planner/features/dsb/model/dsb_page.dart';

class DsbJsonParser {
  const DsbJsonParser();

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');

  List<DsbPage> parsePages(Map<String, dynamic> data) {
    _validateResponse(data);

    final resultMenuItems = data['ResultMenuItems'];

    if (resultMenuItems is! List) {
      return [];
    }

    final pages = <DsbPage>[];

    for (final menuItem in resultMenuItems) {
      if (menuItem is! Map<String, dynamic>) {
        continue;
      }

      final categories = menuItem['Childs'];

      if (categories is! List) {
        continue;
      }

      for (final category in categories) {
        if (category is! Map<String, dynamic>) {
          continue;
        }

        pages.addAll(_parseCategory(category));
      }
    }

    return pages;
  }

  void _validateResponse(Map<String, dynamic> data) {
    final resultCode = data['Resultcode'];

    if (resultCode != 0) {
      final message = data['ResultStatusInfo'];

      throw Exception(
        message?.toString().isNotEmpty == true
            ? message
            : 'DSB request failed with result code $resultCode',
      );
    }
  }

  List<DsbPage> _parseCategory(Map<String, dynamic> category) {
    final categoryType = _parseCategoryType(category);

    final root = category['Root'];

    if (root is! Map<String, dynamic>) {
      return [];
    }

    final rootChildren = root['Childs'];

    if (rootChildren is! List) {
      return [];
    }

    final pages = <DsbPage>[];

    for (final page in rootChildren) {
      if (page is! Map<String, dynamic>) {
        continue;
      }

      final children = page['Childs'];

      if (children is! List) {
        continue;
      }

      final subPages = _parseSubPages(children);

      if (subPages.isEmpty) {
        continue;
      }

      final resolvedCategory = categoryType ?? _detectCategory(subPages);

      if (resolvedCategory == null) {
        continue;
      }

      final title = page["Title"]?.toString();
      final dateString = page['Date']?.toString();

      DateTime? date;

      if (dateString != null && dateString.isNotEmpty) {
        date = _tryParseDate(dateString);
      }

      pages.add(
        DsbPage(
          title: title,
          category: resolvedCategory,
          childs: subPages,
          date: date,
        ),
      );
    }

    return pages;
  }

  List<DsbSubPage> _parseSubPages(List children) {
    final subPages = <DsbSubPage>[];

    for (final child in children) {
      if (child is! Map<String, dynamic>) {
        continue;
      }

      final title = child['Title']?.toString();
      final dateString = child['Date']?.toString();
      final detail = child['Detail']?.toString();
      final preview = child['Preview'] != null
          ? "https://dsbmobile.de/data/${child["Preview"]}"
          : null;

      DateTime? date;

      if (dateString != null && dateString.isNotEmpty) {
        date = _tryParseDate(dateString);
      }

      if (detail == null) {
        continue;
      }

      subPages.add(
        DsbSubPage(title: title, date: date, url: detail, previewUrl: preview),
      );
    }

    return subPages;
  }

  DsbCategory? _parseCategoryType(Map<String, dynamic> category) {
    final title = category['Title']?.toString().toLowerCase().trim();

    switch (title) {
      case 'aushänge':
        return DsbCategory.resource;

      case 'news':
        return DsbCategory.news;

      case 'stundenpläne':
        return DsbCategory.timetable;

      default:
        return null;
    }
  }

  DsbCategory? _detectCategory(List<DsbSubPage> pages) {
    final hasTimetable = pages.any((page) => _isTimetableUrl(page.url));

    if (hasTimetable) {
      return DsbCategory.timetable;
    }

    return null;
  }

  bool _isTimetableUrl(String url) {
    final normalized = url.toLowerCase();

    return normalized.endsWith('.htm') &&
        !normalized.endsWith('.html') &&
        !normalized.endsWith('news.htm');
  }

  DateTime? _tryParseDate(String value) {
    try {
      return _dateFormat.parse(value);
    } catch (_) {
      return null;
    }
  }
}
