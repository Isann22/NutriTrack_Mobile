import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_pemod/screens/tracking_history_screen.dart';
import '../theme/app_theme.dart'; // Sesuaikan path
import 'input_food_screen.dart'; // Sesuaikan path

class _MealItem {
  final String svgAsset;
  final String title;

  const _MealItem({required this.svgAsset, required this.title});
}

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(),
                SizedBox(height: 30),
                _TrackingCard(),
                SizedBox(height: 30),
                _TodayMealSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final Color lightTextColor = Colors.grey.shade600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo',
              style: GoogleFonts.signika(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.nutrinTrackGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Temukan, lacak, makan makanan sehatmu.',
              style: GoogleFonts.signika(fontSize: 14, color: lightTextColor),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Colors.grey.shade500,
            size: 30,
          ),
        ),
      ],
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard();

  @override
  Widget build(BuildContext context) {
    const Color cardPurpleBlue = Color(0xFF8A98DE);

    // 1. Dibungkus dengan InkWell agar bisa diklik
    return InkWell(
      onTap: () {
        // 2. Navigasi ke layar riwayat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrackingHistory()),
        );
      },
      borderRadius: BorderRadius.circular(20.0), // Untuk efek ripple
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardPurpleBlue,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lacak Makanan',
                    style: GoogleFonts.signika(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Mingguan Anda',
                    style: GoogleFonts.signika(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                children: [
                  Text(
                    'Lacak Sekarang',
                    style: GoogleFonts.signika(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cardPurpleBlue,
                    ),
                  ),
                  const Icon(
                    Icons.play_arrow_rounded,
                    size: 16,
                    color: cardPurpleBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMealSection extends StatelessWidget {
  const _TodayMealSection();

  static final List<_MealItem> _mealItems = [
    const _MealItem(svgAsset: 'assets/svg/sarapan.svg', title: 'Sarapan'),
    const _MealItem(
      svgAsset: 'assets/svg/makan_siang.svg',
      title: 'Makan Siang',
    ),
    const _MealItem(
      svgAsset: 'assets/svg/makan_malam.svg',
      title: 'Makan Malam',
    ),
  ];

  static const Color mealCardBg = Color(0xFFF2F9EB);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Makan Hari Ini',
          style: GoogleFonts.signika(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          itemCount: _mealItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final meal = _mealItems[index];
            return _buildMealCard(context, meal);
          },
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, _MealItem meal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: mealCardBg,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        children: [
          SvgPicture.asset(meal.svgAsset, width: 30, height: 30),
          const SizedBox(width: 16),
          Text(
            meal.title,
            style: GoogleFonts.signika(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InputFoodScreen(mealType: meal.title),
                ),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.buttonGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
