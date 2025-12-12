class RecommendationResponse {
  final String status;
  final RecData data;

  RecommendationResponse({required this.status, required this.data});

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      status: json['status'],
      data: RecData.fromJson(json['data']),
    );
  }
}

class RecData {
  final double bmi;
  final double bmr;
  final double tdee;
  final double recommendedCalories;
  final MealPlan mealPlan;

  RecData({
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.recommendedCalories,
    required this.mealPlan,
  });

  factory RecData.fromJson(Map<String, dynamic> json) {
    return RecData(
      bmi: (json['bmi'] ?? 0).toDouble(),
      bmr: (json['bmr'] ?? 0).toDouble(),
      tdee: (json['tdee'] ?? 0).toDouble(),
      recommendedCalories: (json['recommended_calories'] ?? 0).toDouble(),
      mealPlan: MealPlan.fromJson(json['meal_plan']),
    );
  }
}

class MealPlan {
  final MealSection breakfast;
  final MealSection lunch;
  final MealSection dinner;

  MealPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      breakfast: MealSection.fromJson(json['breakfast']),
      lunch: MealSection.fromJson(json['lunch']),
      dinner: MealSection.fromJson(json['dinner']),
    );
  }
}

class MealSection {
  final double targetCalories;
  final List<Recipe> recipes; // Sekarang menggunakan List<Recipe>

  MealSection({required this.targetCalories, required this.recipes});

  factory MealSection.fromJson(Map<String, dynamic> json) {
    var list = json['recipes'] as List? ?? [];
    // Parsing setiap item di list menjadi object Recipe
    List<Recipe> recipeList = list.map((i) => Recipe.fromJson(i)).toList();

    return MealSection(
      targetCalories: (json['target_calories'] ?? 0).toDouble(),
      recipes: recipeList,
    );
  }
}

// CLASS BARU: Untuk menangani objek resep
class Recipe {
  final String name;
  final double calories;

  Recipe({required this.name, required this.calories});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      // Backend mengirim 'recipe_name', kita simpan sebagai 'name'
      name: json['recipe_name'] ?? 'Tanpa Nama',
      calories: (json['calories'] ?? 0).toDouble(),
    );
  }
}
