class UserTargets {
  final int calories;
  final int protein;
  final int fat;
  final int carbs;

  UserTargets({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory UserTargets.fromJson(Map<String, dynamic> json) {
    return UserTargets(
      calories: (json['calories'] ?? 2000).toInt(),
      protein: (json['protein'] ?? 120).toInt(),
      fat: (json['fat'] ?? 70).toInt(),
      carbs: (json['carbs'] ?? 250).toInt(),
    );
  }
}

class UserProfile {
  final String email;
  final String name;
  final int weight;
  final int height;
  final UserTargets targets;

  UserProfile({
    required this.email,
    required this.name,
    required this.weight,
    required this.height,
    required this.targets,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      name: json['nama_lengkap'] ?? 'User',
      weight: (json['berat_badan_kg'] ?? 0).toInt(),
      height: (json['tinggi_badan_cm'] ?? 0).toInt(),
      targets: UserTargets.fromJson(json['targets'] ?? {}),
    );
  }
}
