import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../screens/tracking_history_screen.dart';
import '../service/mqtt_service.dart';
import 'input_food_screen.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MqttService>().connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttService>(
      builder: (context, mqttService, child) {
        final bool isDeviceConnected = mqttService.isDeviceOn;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const SizedBox(height: 20),
                    _DeviceStatusWidget(isConnected: isDeviceConnected),
                    const SizedBox(height: 20),
                    const _TrackingCard(),
                    const SizedBox(height: 30),
                    _TodayMealSection(isDeviceConnected: isDeviceConnected),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temukan, lacak,\nmakan makanan sehatmu.',
              style: GoogleFonts.signika(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.nutrinTrackGreen,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _DeviceStatusWidget extends StatelessWidget {
  final bool isConnected;
  const _DeviceStatusWidget({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? AppTheme.nutrinTrackGreen : Colors.redAccent;
    final text = isConnected
        ? "Perangkat IoT Terhubung"
        : "Perangkat IoT Offline";
    final icon = isConnected ? Icons.wifi : Icons.wifi_off;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.signika(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard();

  @override
  Widget build(BuildContext context) {
    const Color cardPurpleBlue = Color(0xFF8A98DE);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrackingHistory()),
        );
      },
      borderRadius: BorderRadius.circular(20.0),
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
  final bool isDeviceConnected;

  const _TodayMealSection({required this.isDeviceConnected});

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
              if (isDeviceConnected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputFoodScreen(mealType: meal.title),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Perangkat IoT Offline. Hidupkan alat untuk menimbang.",
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDeviceConnected ? Colors.white : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: [
                  if (isDeviceConnected)
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: isDeviceConnected ? AppTheme.buttonGreen : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
