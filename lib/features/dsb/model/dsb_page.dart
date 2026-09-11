enum DsbCategory { timetable, resource, news }

class DsbPage {
  final DsbCategory category;
  final String? title;
  //final DateTime? date;
  final List<DsbSubPage> childs;

  const DsbPage({
    required this.category,
    this.title,
    /*this.date,*/ required this.childs,
  });
}

class DsbSubPage {
  final String? title;
  final DateTime? date;
  final String url;
  final String? previewUrl;

  const DsbSubPage({required this.url, this.title, this.date, this.previewUrl});
}
