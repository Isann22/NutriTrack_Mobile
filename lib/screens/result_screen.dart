import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import './main_navigation_screen.dart'; // Import Main Screen

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  final String foodNameDisplay;

  const ResultScreen({
    super.key,
    required this.resultData,
    required this.foodNameDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final String foodName = foodNameDisplay;
    final int gram = (resultData['portionSize_g'] ?? 0.0).toInt();

    final Map<String, dynamic> nutrition = resultData['nutrition'] ?? {};
    final double calories = (nutrition['calories_kcal'] ?? 0.0).toDouble();
    final double protein = (nutrition['protein_g'] ?? 0.0).toDouble();
    final double fat = (nutrition['fat_total_g'] ?? 0.0).toDouble();
    final double carbs = (nutrition['carbohydrates_g'] ?? 0.0).toDouble();

    final String detailsText =
        "Satu porsi $foodName (sekitar ${gram}g) mengandung ${calories.toStringAsFixed(0)} kalori, "
        "${fat.toStringAsFixed(0)} gram lemak, ${carbs.toStringAsFixed(0)} gram karbohidrat, "
        "dan ${protein.toStringAsFixed(0)} gram protein.";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textColor),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Deteksi Makanan',
          style: GoogleFonts.signika(
            color: AppTheme.nutrinTrackGreen,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              foodName,
              style: GoogleFonts.signika(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Center(child: SvgPicture.asset('assets/svg/food.svg', height: 150)),
            const SizedBox(height: 30),
            _buildNutritionRow(protein, calories, fat, carbs),
            const SizedBox(height: 30),
            Text(
              'Details',
              style: GoogleFonts.signika(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 10),

            // Tampilkan teks dinamis di sini
            Text(
              detailsText,
              style: GoogleFonts.signika(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.buttonGreen,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          // 3. Auto Refresh saat tombol Selesai ditekan
          onPressed: () {
            // Kembali ke MainNavigationScreen dan hapus semua stack
            // Ini memaksa initState di MainNavigationScreen berjalan lagi -> Data Refreshed
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
          },
          child: Text(
            'Selesai',
            style: GoogleFonts.signika(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(
    double protein,
    double calories,
    double fat,
    double carbs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1.5),
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionItem(
            'Protein',
            '${protein.toStringAsFixed(0)}g',
            AppTheme.activeDotPink,
          ),
          _buildNutritionItem(
            'Kalori',
            '${calories.toStringAsFixed(0)}g',
            Colors.orange.shade300,
          ),
          _buildNutritionItem(
            'Lemak',
            '${fat.toStringAsFixed(0)}g',
            Colors.blue.shade300,
          ),
          _buildNutritionItem(
            'Karbohidrat',
            '${carbs.toStringAsFixed(0)}g',
            Colors.purple.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.signika(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.signika(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }
}
