class ResourceBundle {
  final String? title;
  final DateTime? date;
  final List<Resource> resources;

  const ResourceBundle({required this.resources, this.title, this.date});
}

class Resource {
  final String? title;
  final DateTime? date;
  final String url;
  final String? previewUrl;

  const Resource({required this.url, this.title, this.date, this.previewUrl});
}
