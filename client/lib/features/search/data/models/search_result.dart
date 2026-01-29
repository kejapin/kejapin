enum SearchResultType {
  listing,
  landlord,
  location,
  coordinate,
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.imageUrl,
    this.metadata = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: SearchResultType.values.firstWhere(
        (e) => e.toString() == 'SearchResultType.${json['type']}',
        orElse: () => SearchResultType.listing,
      ),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}
