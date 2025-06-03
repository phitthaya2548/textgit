class Recipe {
  final int id;
  final String title;
  final String description;
  final int cookTime;
  final int createdBy;
  final List<String> images;
  bool isFavorite;
  int favoriteCount;
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookTime,
    required this.createdBy,
    required this.images,
    this.isFavorite = false,
    this.favoriteCount = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final List<dynamic> imageList = json['images'] ?? [];
    return Recipe(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      cookTime: json['cook_time'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      images: imageList.cast<String>(),
      isFavorite: json['is_favorite'] ?? false, // <<< ✅
      favoriteCount: json['favoriteCount'] ?? 0
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'cook_time': cookTime,
    'created_by': createdBy,
    'images': images,

  };

  Map<String, String> toFields() {
    final map = {
      'title': title,
      'description': description,
      'cook_time': cookTime.toString(),
      'created_by': createdBy.toString(),
    };
    if (images.isNotEmpty) {
      map['image_url'] = images[0];
    }
    return map;
  }
}
