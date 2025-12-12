import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../model/tracking_data.dart';
import '../model/user_model.dart';
import '../service/api_service.dart';
import './recommendation_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final VoidCallback onRefreshProfile;

  const HomeScreen({
    super.key,
    required this.userProfile,
    required this.onRefreshProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DailyLog?> _todayLogFuture;

  @override
  void initState() {
    super.initState();
    _todayLogFuture = _fetchTodayLog();
  }

  void _refreshAllData() {
    setState(() {
      _todayLogFuture = _fetchTodayLog();
    });
    widget.onRefreshProfile();
  }

  Future<DailyLog?> _fetchTodayLog() async {
    try {
      final List<dynamic> rawData = await ApiService.getHistory();
      final List<DailyLog> allLogs = rawData
          .map((json) => DailyLog.fromJson(json as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();
      for (final log in allLogs) {
        if (log.date.day == now.day &&
            log.date.month == now.month &&
            log.date.year == now.year) {
          return log;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int targetCalories = widget.userProfile?.targets.calories ?? 2000;
    final String userName = widget.userProfile?.name ?? "User";

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiRecommendationScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF8A98DE),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          "Tanya AI",
          style: GoogleFonts.signika(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(userName: userName, onRefresh: _refreshAllData),
                const SizedBox(height: 30),
                FutureBuilder<DailyLog?>(
                  future: _todayLogFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.nutrinTrackGreen,
                        ),
                      );
                    }

                    final dailyLog = snapshot.data;
                    final summary = dailyLog?.summary;

                    return Column(
                      children: [
                        _SimpleSummaryCard(
                          summary: summary,
                          target: targetCalories,
                        ),
                        const SizedBox(height: 40),
                        _TodayFoodLog(dailyLog: dailyLog),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _SimpleSummaryCard extends StatelessWidget {
  final DailySummary? summary;
  final int target;

  const _SimpleSummaryCard({required this.summary, required this.target});

  @override
  Widget build(BuildContext context) {
    final double caloriesEaten = summary?.totalCaloriesKcal ?? 0.0;

    final double remaining = target - caloriesEaten;

    String statusText;
    Color statusColor;
    String detailText;

    if (remaining < 0) {
      statusText = "Melebihi";
      statusColor = Colors.redAccent;
      detailText = "Lewat: ${remaining.abs().toStringAsFixed(0)} kkal";
    } else if (remaining <= 300) {
      statusText = "Terpenuhi";
      statusColor = AppTheme.nutrinTrackGreen;
      detailText = "Sisa: ${remaining.toStringAsFixed(0)} kkal (Ideal)";
    } else {
      statusText = "Kurang";
      statusColor = Colors.orange;
      detailText = "Sisa: ${remaining.toStringAsFixed(0)} kkal";
    }

    final double progress = (caloriesEaten / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          // Badge Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.signika(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.transparent,
                  ),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        caloriesEaten.toStringAsFixed(0),
                        style: GoogleFonts.signika(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Text(
                        '/ $target kkal',
                        style: GoogleFonts.signika(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            detailText,
            style: GoogleFonts.signika(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 16),

          // Makronutrien
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem("Protein", summary?.totalProteinG ?? 0.0),
              _buildMacroItem("Lemak", summary?.totalFatG ?? 0.0),
              _buildMacroItem("Karbo", summary?.totalCarbsG ?? 0.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String title, double value) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.signika(fontSize: 14, color: Colors.grey),
        ),
        Text(
          '${value.toStringAsFixed(0)}g',
          style: GoogleFonts.signika(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TodayFoodLog extends StatelessWidget {
  final DailyLog? dailyLog;
  const _TodayFoodLog({required this.dailyLog});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log Makanan Hari Ini',
          style: GoogleFonts.signika(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 20),
        _MealCategoryCard(title: 'Sarapan', items: dailyLog?.sarapan ?? []),
        const SizedBox(height: 16),
        _MealCategoryCard(
          title: 'Makan Siang',
          items: dailyLog?.makanSiang ?? [],
        ),
        const SizedBox(height: 16),
        _MealCategoryCard(
          title: 'Makan Malam',
          items: dailyLog?.makanMalam ?? [],
        ),
      ],
    );
  }
}

class _MealCategoryCard extends StatelessWidget {
  final String title;
  final List<FoodLogItem> items;

  const _MealCategoryCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9EB),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.signika(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isNotEmpty)
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(
                  '• ${item.displayString}',
                  style: GoogleFonts.signika(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            )
          else
            Text(
              'Belum ada data',
              style: GoogleFonts.signika(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade400,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onRefresh;
  const _HomeHeader({required this.userName, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $userName!',
              style: GoogleFonts.signika(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.nutrinTrackGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau kalori harianmu.',
              style: GoogleFonts.signika(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
