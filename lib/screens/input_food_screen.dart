import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import 'weighing_screen.dart';

class InputFoodScreen extends StatefulWidget {
  final String mealType;
  const InputFoodScreen({super.key, required this.mealType});

  @override
  State<InputFoodScreen> createState() => _InputFoodScreenState();
}

class _InputFoodScreenState extends State<InputFoodScreen> {
  final _foodNameController = TextEditingController();
  final _pageController = PageController();

  // State untuk loading terjemahan
  bool _isTranslating = false;

  void _goToNextStep() async {
    if (_foodNameController.text.isEmpty || _isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final translator = GoogleTranslator();
      final foodDisplay = _foodNameController.text;

      // Terjemahkan dari Indonesia (id) ke Inggris (en)
      final translation = await translator.translate(
        foodDisplay,
        from: 'id',
        to: 'en',
      );
      final foodApi = translation.text;

      if (mounted) {
        // Kirim kedua versi nama ke layar berikutnya
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeighingScreen(
              mealType: widget.mealType,
              foodNameDisplay: foodDisplay, // Untuk ditampilkan
              foodNameApi: foodApi, // Untuk dikirim ke API
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menerjemahkan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppTheme.textColor),
        title: Text(
          'NutriTrack',
          style: GoogleFonts.signika(
            color: AppTheme.nutrinTrackGreen,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 90),
              Text(
                'Apa nama makanan kamu?',
                style: GoogleFonts.signika(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _foodNameController,
                style: GoogleFonts.signika(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Cth: Roti Gandum',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.nutrinTrackGreen,
                      width: 2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.nutrinTrackGreen,
                      width: 3,
                    ),
                  ),
                ),
              ),
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
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonGreen,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _goToNextStep,
                child: _isTranslating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Lanjut',
                        style: GoogleFonts.signika(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
