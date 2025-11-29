import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
  TextEditingController? _autocompleteController;
  final _pageController = PageController();
  bool _isTranslating = false;

  List<String> _foodOptions = [];

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    try {
      // 1. Baca file JSON dari assets
      final String response = await rootBundle.loadString(
        'assets/data/foods.json',
      );

      // 2. Decode JSON menjadi List
      final List<dynamic> data = json.decode(response);

      // 3. Masukkan ke variabel state
      setState(() {
        _foodOptions = data.cast<String>();
      });
    } catch (e) {
      debugPrint("Gagal memuat data makanan: $e");
    }
  }

  void _goToNextStep() async {
    final text = _autocompleteController?.text ?? '';

    if (text.isEmpty || _isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final translator = GoogleTranslator();
      final foodDisplay = text;

      final translation = await translator.translate(
        foodDisplay,
        from: 'id',
        to: 'en',
      );
      final foodApi = translation.text;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeighingScreen(
              mealType: widget.mealType,
              foodNameDisplay: foodDisplay,
              foodNameApi: foodApi,
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
        iconTheme: const IconThemeData(color: AppTheme.textColor),
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
              Center(child: const SizedBox(height: 40)),
              Text(
                'Apa nama \n makanan kamu?',
                style: GoogleFonts.signika(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _foodOptions.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },

                onSelected: (String selection) {
                  debugPrint('Kamu memilih: $selection');
                },

                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 300,
                        color: Colors.white,
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(
                                option,
                                style: GoogleFonts.signika(
                                  color: AppTheme.textColor,
                                ),
                              ),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },

                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      _autocompleteController = fieldTextEditingController;

                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        style: GoogleFonts.signika(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor,
                        ),
                        decoration: const InputDecoration(
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
                      );
                    },
              ),

              const Spacer(),
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: const ExpandingDotsEffect(
                    dotColor: Colors.grey,
                    activeDotColor: AppTheme.activeDotPink,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
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
