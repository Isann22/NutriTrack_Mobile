import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../service/api_service.dart';
import '../model/recommendation_model.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  // Controller Form
  final _ageController = TextEditingController(text: "25");
  final _weightController = TextEditingController(text: "70.5");
  final _heightController = TextEditingController(text: "1.75"); // Meter

  // Dropdown Values
  String _selectedGender = "Laki-laki";
  String _selectedActivity = "Aktif";
  String _selectedGoal = "Turunkan Berat";

  bool _isLoading = false;
  RecData? _resultData;

  void _generatePlan() async {
    setState(() {
      _isLoading = true;
      _resultData = null;
    });

    try {
      final data = await ApiService.getAIRecommendation(
        age: int.tryParse(_ageController.text) ?? 25,
        weight: double.tryParse(_weightController.text) ?? 60.0,
        height: double.tryParse(_heightController.text) ?? 1.70,
        genderIndo: _selectedGender,
        activityIndo: _selectedActivity,
        goalIndo: _selectedGoal,
      );

      setState(() {
        _resultData = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "AI Nutrition Plan",
          style: GoogleFonts.signika(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Profil Tubuh"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Umur",
                    _ageController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    "Berat (kg)",
                    _weightController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    "Tinggi (m)",
                    _heightController,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            _buildDropdown(
              "Jenis Kelamin",
              _selectedGender,
              ["Laki-laki", "Perempuan"],
              (val) => setState(() => _selectedGender = val!),
            ),
            const SizedBox(height: 15),
            _buildDropdown(
              "Aktivitas",
              _selectedActivity,
              ["Sedenter", "Aktif Ringan", "Aktif", "Sangat Aktif"],
              (val) => setState(() => _selectedActivity = val!),
            ),
            const SizedBox(height: 15),
            _buildDropdown("Tujuan", _selectedGoal, [
              "Turunkan Berat",
              "Pertahankan Berat",
              "Naikkan Berat",
            ], (val) => setState(() => _selectedGoal = val!)),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _generatePlan,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Buat Rencana (AI)",
                        style: GoogleFonts.signika(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            if (_resultData != null) _buildResultView(_resultData!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView(RecData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Analisis Tubuh"),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard("BMI", data.bmi.toStringAsFixed(1), Colors.blue),
            _buildStatCard("BMR", data.bmr.toStringAsFixed(0), Colors.orange),
            _buildStatCard("TDEE", data.tdee.toStringAsFixed(0), Colors.purple),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.nutrinTrackGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.nutrinTrackGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Rekomendasi Kalori: ${data.recommendedCalories.toStringAsFixed(0)} kkal",
                  style: GoogleFonts.signika(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.nutrinTrackGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        _buildSectionTitle("Rencana Makan Harian"),
        const SizedBox(height: 15),

        _buildMealCard("Sarapan", data.mealPlan.breakfast),
        const SizedBox(height: 10),
        _buildMealCard("Makan Siang", data.mealPlan.lunch),
        const SizedBox(height: 10),
        _buildMealCard("Makan Malam", data.mealPlan.dinner),
      ],
    );
  }

  Widget _buildMealCard(String title, MealSection section) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Judul & Target
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.signika(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${section.targetCalories.toStringAsFixed(0)} kkal",
                  style: GoogleFonts.signika(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // List Resep (Looping Recipe Object)
            if (section.recipes.isNotEmpty)
              ...section.recipes.map(
                (recipe) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 16,
                        color: AppTheme.nutrinTrackGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          recipe.name, // Nama Makanan Bersih
                          style: GoogleFonts.signika(
                            fontSize: 15,
                            height: 1.2,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${recipe.calories.toStringAsFixed(0)} kkal",
                        style: GoogleFonts.signika(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                "Belum ada rekomendasi spesifik.",
                style: GoogleFonts.signika(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.signika(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.signika(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.signika(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.signika(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.signika()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
