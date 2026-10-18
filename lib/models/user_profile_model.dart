/// Model class untuk data profil pengguna
class UserProfileModel {
  String name;
  String description;
  String? profileImageBase64;
  String? bannerImageBase64;
  bool isInitialized;

  UserProfileModel({
    required this.name,
    required this.description,
    this.profileImageBase64,
    this.bannerImageBase64,
    this.isInitialized = false,
  });

  /// Konversi ke Map untuk Hive
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'profileImageBase64': profileImageBase64,
      'bannerImageBase64': bannerImageBase64,
      'isInitialized': isInitialized,
    };
  }

  /// Buat instance dari Map Hive
  factory UserProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return UserProfileModel(
      name: (map['name'] as String?) ?? 'Kuma dayo',
      description: (map['description'] as String?) ?? 'Yahoooo',
      profileImageBase64: map['profileImageBase64'] as String?,
      bannerImageBase64: map['bannerImageBase64'] as String?,
      isInitialized: (map['isInitialized'] as bool?) ?? false,
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? description,
    String? profileImageBase64,
    String? bannerImageBase64,
    bool? isInitialized,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      description: description ?? this.description,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      bannerImageBase64: bannerImageBase64 ?? this.bannerImageBase64,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
