/// Model representing a cast member in a movie.
class CastMember {
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String? ?? 'Unknown Actor',
      character: json['character'] as String? ?? 'Cast',
      profilePath: json['profilePath'] as String? ?? json['profile_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'character': character,
      'profilePath': profilePath,
    };
  }
}
