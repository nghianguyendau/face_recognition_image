import 'dart:ui';

class Recognition {
  String name;
  Rect location;
  List<double> embeddings;
  double distance;

  Recognition({
    required this.name,
    required this.location,
    required this.embeddings,
    required this.distance,
  });

  factory Recognition.fromJson(Map<String, dynamic> json) => Recognition(
    name: json["name"],
    location: json["location"], // Assuming Rect has a fromJson constructor
    embeddings: List<double>.from(json["embeddings"].map((x) => x.toDouble())),
    distance: json["distance"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "location": location, // Assuming Rect has a toJson method
    "embeddings": embeddings,
    "distance": distance,
  };
}
