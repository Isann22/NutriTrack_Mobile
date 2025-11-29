import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../service/api_service.dart';
import './onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Status Loading
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  final _calController = TextEditingController();
  final _protController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 1. Ambil Data dari API & Masukkan ke Controller
  void _loadProfileData() async {
    try {
      final user = await ApiService.getUserProfile();

      setState(() {
        // Data Fisik
        _nameController.text = user.name;
        _weightController.text = user.weight.toString();
        _heightController.text = user.height.toString();

        // Data Target
        _calController.text = user.targets.calories.toString();
        _protController.text = user.targets.protein.toString();
        _fatController.text = user.targets.fat.toString();
        _carbController.text = user.targets.carbs.toString();

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 2. Simpan Semua Perubahan
  void _saveAllChanges() async {
    setState(() => _isLoading = true);

    try {
      // Update Profil
      await ApiService.updateUserProfile(
        _nameController.text,
        int.tryParse(_weightController.text) ?? 0,
        int.tryParse(_heightController.text) ?? 0,
        int.tryParse(_calController.text) ?? 0,
        int.tryParse(_protController.text) ?? 0,
        int.tryParse(_fatController.text) ?? 0,
        int.tryParse(_carbController.text) ?? 0,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil diperbarui!"),
            backgroundColor: AppTheme.buttonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.nutrinTrackGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: GoogleFonts.signika(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: DATA FISIK ---
            _buildSectionTitle("Data Pribadi"),
            const SizedBox(height: 15),
            _buildTextField("Nama Lengkap", _nameController),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Berat (kg)",
                    _weightController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    "Tinggi (cm)",
                    _heightController,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- BAGIAN 2: TARGET NUTRISI ---
            _buildSectionTitle("Target Nutrisi Harian"),
            const SizedBox(height: 5),
            Text(
              "Sesuaikan target ini agar AI bekerja lebih akurat.",
              style: GoogleFonts.signika(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 15),

            _buildTextField(
              "Target Kalori (kkal)",
              _calController,
              isNumber: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    "Protein (g)",
                    _protController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    "Lemak (g)",
                    _fatController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    "Karbo (g)",
                    _carbController,
                    isNumber: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _saveAllChanges,
                child: Text(
                  "Simpan Semua Perubahan",
                  style: GoogleFonts.signika(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.signika(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.nutrinTrackGreen,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.signika(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.signika(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.nutrinTrackGreen,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
