import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import '../service/api_service.dart';
import 'result_screen.dart';

enum WeighingStage { initial, loading }

class WeighingScreen extends StatefulWidget {
  final String mealType;
  final String foodNameDisplay;
  final String foodNameApi;

  const WeighingScreen({
    super.key,
    required this.mealType,
    required this.foodNameDisplay,
    required this.foodNameApi,
  });

  @override
  State<WeighingScreen> createState() => _WeighingScreenState();
}

class _WeighingScreenState extends State<WeighingScreen> {
  final _pageController = PageController(initialPage: 1);
  WeighingStage _stage = WeighingStage.initial;

  void _handleDetection() async {
    if (_stage == WeighingStage.loading) return;

    setState(() {
      _stage = WeighingStage.loading;
    });

    try {
      final result = await ApiService.analyzeFood(
        widget.foodNameApi,
        widget.mealType,
        widget.foodNameDisplay,
      );

      final Map<String, dynamic> nutritionData = result['data'];

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              resultData: nutritionData,
              foodNameDisplay: widget.foodNameDisplay,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _stage = WeighingStage.initial;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _stage == WeighingStage.loading;
    final String buttonText = isLoading ? 'Menganalisis...' : 'Lihat Nutrisi';
    final String weightText = isLoading ? '... g' : '0 g';
    final String scannerText = isLoading
        ? 'Menganalisis...'
        : 'Simpan makanan Anda\ndi perangkat IoT';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Chip(
              label: Text(
                widget.mealType,
                style: GoogleFonts.signika(
                  color: AppTheme.nutrinTrackGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.nutrinTrackGreen.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            const Spacer(),
            _buildScaleWidget(context, scannerText, weightText),
            const Spacer(),
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: ExpandingDotsEffect(
                  dotColor: Colors.grey.shade300,
                  activeDotColor: AppTheme.activeDotPink,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonGreen,
                    disabledBackgroundColor: Colors.grey.shade300,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleDetection,
                  child: Text(
                    buttonText,
                    style: GoogleFonts.signika(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleWidget(
    BuildContext context,
    String scannerText,
    String weightText,
  ) {
    const Color purpleGlow = Color(0xFFC9C9F9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/Rectangle 34.svg',
                width: MediaQuery.of(context).size.width * 0.8,
              ),
              SvgPicture.asset(
                'assets/svg/Rectangle 35.svg',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              Text(
                scannerText,
                textAlign: TextAlign.center,
                style: GoogleFonts.signika(color: Colors.white70, fontSize: 14),
              ),
              SvgPicture.asset(
                'assets/svg/Rectangle 39.svg',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: purpleGlow.withOpacity(0.7),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: purpleGlow.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                weightText,
                style: GoogleFonts.signika(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
