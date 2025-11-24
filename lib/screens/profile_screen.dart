import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  static const Color iconBgColor = Color(0xFFFFF6F4);
  static const Color iconColor = Color(0xFFF79483);
  static const Color crownColor = Color(0xFFF16567);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.signika(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildProfileHeader(),
              const SizedBox(height: 16),
              Text(
                'Example',
                style: GoogleFonts.signika(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Akun Baru',
                style: GoogleFonts.signika(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              // --- Menu List ---
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.star_outline,
                title: 'Perbarui Rencana',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.settings,
                title: 'Pengaturan',
                onTap: () {},
              ),

              const SizedBox(height: 20), // Pemisah

              _buildProfileMenuItem(
                icon: Icons.article_outlined,
                title: 'Syarat & Kebijakan Privasi',
                onTap: () {},
              ),
              _buildProfileMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                color: crownColor, // Warna merah untuk keluar
                onTap: () {
                  // Tambahkan logika keluar (logout)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk header profil (Foto + Mahkota)
  Widget _buildProfileHeader() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: const NetworkImage(
              'https://i.pravatar.cc/150?img=12',
            ),
          ),
          Positioned(
            bottom: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: crownColor,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2),
                ),
              ),
              child: const Icon(
                Icons.workspace_premium, // Icon Mahkota
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = iconColor, // Warna default
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // Gunakan iconBgColor jika mau
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.signika(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: title == 'Keluar' ? crownColor : AppTheme.textColor,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
