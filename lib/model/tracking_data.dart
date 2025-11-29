import 'package:intl/intl.dart';

class NutritionInfo {
  final double caloriesKcal;
  final double proteinG;
  final double fatTotalG;
  final double carbohydratesG;

  const NutritionInfo({
    required this.caloriesKcal,
    required this.proteinG,
    required this.fatTotalG,
    required this.carbohydratesG,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      caloriesKcal: (json['calories_kcal'] ?? 0.0).toDouble(),
      proteinG: (json['protein_g'] ?? 0.0).toDouble(),
      fatTotalG: (json['fat_total_g'] ?? 0.0).toDouble(),
      carbohydratesG: (json['carbohydrates_g'] ?? 0.0).toDouble(),
    );
  }
}

class FoodLogItem {
  final String name;
  final int gram;
  final String mealType;
  final NutritionInfo nutrition;

  FoodLogItem({
    required this.name,
    required this.gram,
    required this.mealType,
    required this.nutrition,
  });

  factory FoodLogItem.fromJson(Map<String, dynamic> json, String mealType) {
    double gramDouble = 0.0;
    dynamic rawGram = json['portionSize_g'];

    if (rawGram is num) {
      gramDouble = rawGram.toDouble();
    } else if (rawGram is String) {
      gramDouble = double.tryParse(rawGram) ?? 0.0;
    }

    return FoodLogItem(
      name: json['foodName'] ?? 'Unknown',
      gram: gramDouble.toInt(),
      mealType: mealType, // Tetapkan mealType dari parent key
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
    );
  }

  String get displayString =>
      '$name (${gram}g) - ${nutrition.caloriesKcal.toStringAsFixed(0)} kkal';
}

class DailySummary {
  final double totalCaloriesKcal;
  final double totalProteinG;
  final double totalFatG;
  final double totalCarbsG;

  const DailySummary({
    required this.totalCaloriesKcal,
    required this.totalProteinG,
    required this.totalFatG,
    required this.totalCarbsG,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      totalCaloriesKcal: (json['total_calories_kcal'] ?? 0.0).toDouble(),
      totalProteinG: (json['total_protein_g'] ?? 0.0).toDouble(),
      totalFatG: (json['total_fat_g'] ?? 0.0).toDouble(),
      totalCarbsG: (json['total_carbs_g'] ?? 0.0).toDouble(),
    );
  }
}

class DailyLog {
  final DateTime date;
  final DailySummary summary;
  final Map<String, List<FoodLogItem>> log;

  DailyLog({required this.date, required this.summary, required this.log});

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    Map<String, List<FoodLogItem>> parseLog(Map<String, dynamic> logMap) {
      Map<String, List<FoodLogItem>> parsed = {};
      logMap.forEach((mealTypeKey, itemList) {
        if (itemList is List) {
          parsed[mealTypeKey] = itemList
              .map((itemJson) => FoodLogItem.fromJson(itemJson, mealTypeKey))
              .toList();
        }
      });
      return parsed;
    }

    DateTime parseBsonDate(dynamic dateJson) {
      if (dateJson is Map && dateJson.containsKey('\$date')) {
        return DateTime.parse(dateJson['\$date']);
      } else if (dateJson is String) {
        return DateTime.parse(dateJson);
      }
      return DateTime.now();
    }

    return DailyLog(
      date: parseBsonDate(json['tanggal']),
      summary: DailySummary.fromJson(json['summary'] ?? {}),
      log: parseLog(json['log'] ?? {}), // Membaca field 'log'
    );
  }

  String get formattedDate => DateFormat('d MMMM yyyy', 'id_ID').format(date);

  List<FoodLogItem> _getItemsForMeal(String meal) {
    final key = log.keys.firstWhere(
      (k) => k.toLowerCase() == meal.toLowerCase(),
      orElse: () => '',
    );
    return key.isEmpty ? [] : log[key]!;
  }

  List<FoodLogItem> get sarapan => _getItemsForMeal('Sarapan');
  List<FoodLogItem> get makanSiang => _getItemsForMeal('Makan Siang');
  List<FoodLogItem> get makanMalam => _getItemsForMeal('Makan Malam');
}
