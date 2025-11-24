import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tubes_pemod/screens/main_navigation_screen.dart';
import '../theme/app_theme.dart';

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();

  // 1. Variabel untuk melacak halaman
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      image: 'assets/svg/onboarding1.svg',
      title: 'Makan Sehat',
      description:
          'Menjaga kesehatan yang baik harus menjadi fokus utama setiap orang.',
    ),
    OnboardingItem(
      image: 'assets/svg/onboarding2.svg',
      title: 'Resep Sehat',
      description: 'Merekomendasikan resep yang sehat dan bergizi.',
    ),
    OnboardingItem(
      image: 'assets/svg/onboarding3.svg',
      title: 'Lacak Kesehatan Anda',
      description:
          'Dengan alat IOT yang menakjubkan Anda dapat melacak kemajuan Anda.',
    ),
  ];

  void _navigateToMainApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
              child: Text(
                'NutriTrack',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.nutrinTrackGreen,
                  fontFamily: 'OtomanopeeOne',
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                // 2. Tambahkan onPageChanged
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return _buildOnboardingPage(
                    image: item.image,
                    title: item.title,
                    description: item.description,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotColor: Colors.grey.shade300,
                  activeDotColor: AppTheme.activeDotPink,
                  dotHeight: 10,
                  dotWidth: 10,
                  expansionFactor: 4,
                  spacing: 8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
              ).copyWith(bottom: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonGreen,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                // 3. Perbaiki logika tombol "Mulai"
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    // Jika di halaman terakhir, navigasi ke home
                    _navigateToMainApp();
                  } else {
                    // Jika tidak, pindah ke halaman berikutnya
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(
                  // Ubah teks tombol berdasarkan halaman
                  _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: GoogleFonts.signika(
                      color: AppTheme.textColor.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    // 4. Perbaiki panggilan fungsi tombol "Masuk"
                    onPressed: () {
                      _navigateToMainApp();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.signika(
                        color: AppTheme.nutrinTrackGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            flex: 5,
            child: SvgPicture.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          Flexible(
            flex: 1,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.signika(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            flex: 2,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.signika(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
