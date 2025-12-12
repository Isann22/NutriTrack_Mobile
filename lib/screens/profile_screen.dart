import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_pemod/screens/login_screen.dart';
import '../theme/app_theme.dart';
import '../service/api_service.dart';
import '../model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final VoidCallback onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  late TextEditingController _calController;
  late TextEditingController _protController;
  late TextEditingController _fatController;
  late TextEditingController _carbController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final user = widget.userProfile;
    _nameController = TextEditingController(text: user?.name ?? '');
    _weightController = TextEditingController(
      text: user?.weight.toString() ?? '0',
    );
    _heightController = TextEditingController(
      text: user?.height.toString() ?? '0',
    );

    final t = user?.targets;
    _calController = TextEditingController(
      text: t?.calories.toString() ?? '2000',
    );
    _protController = TextEditingController(
      text: t?.protein.toString() ?? '120',
    );
    _fatController = TextEditingController(text: t?.fat.toString() ?? '70');
    _carbController = TextEditingController(text: t?.carbs.toString() ?? '250');
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller jika data dari parent berubah (misal setelah refresh)
    if (oldWidget.userProfile != widget.userProfile) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _calController.dispose();
    _protController.dispose();
    _fatController.dispose();
    _carbController.dispose();
    super.dispose();
  }

  void _saveAllChanges() async {
    setState(() => _isLoading = true);

    try {
      // 1. Update Profil Fisik
      await ApiService.updateUserProfile(
        _nameController.text,
        int.tryParse(_weightController.text) ?? 0,
        int.tryParse(_heightController.text) ?? 0,
        int.tryParse(_calController.text) ?? 0,
        int.tryParse(_protController.text) ?? 0,
        int.tryParse(_fatController.text) ?? 0,
        int.tryParse(_carbController.text) ?? 0,
      );

      widget.onProfileUpdated();

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
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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

            _buildSectionTitle("Target Nutrisi Harian"),
            const SizedBox(height: 5),
            Text(
              "Sesuaikan target ini agar indikator bekerja akurat.",
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
